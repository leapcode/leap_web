require 'test_helper'

class TicketsListTest < ActionController::TestCase
  tests TicketsController

  teardown do
    # destroy all records that were created during the test
    Ticket.all.each{|t| t.destroy}
    User.all.each{|u| u.account.destroy}
  end


  test "tickets by admin" do
      other_user = find_record :user
      ticket = FactoryGirl.create :ticket, :created_by => other_user.id

      login :is_admin? => true

      get :index, {:admin_status => "all", :open_status => "open"}
      assert assigns(:all_tickets).count > 0

      # if we close one ticket, the admin should have 1 less open ticket
      assert_difference('assigns[:all_tickets].count', -1) do
        assigns(:tickets).first.close
        assigns(:tickets).first.save
        get :index, {:admin_status => "all", :open_status => "open"}
      end
  end


  test "admin_status mine vs all" do
    testticket = FactoryGirl.create :ticket
    user = find_record :user
    login :is_admin? => true, :email => nil

    get :index, {:open_status => "open"}
    assert assigns(:all_tickets).include?(testticket)
    get :index, {:user_id => user.id, :open_status => "open"}
    assert !assigns(:all_tickets).include?(testticket)
  end

  test "admin ticket ordering" do
    tickets = FactoryGirl.create_list :ticket, 2

    login :is_admin? => true, :email => nil
    get :index, {:admin_status => "all", :open_status => "open", :sort_order => 'created_at_desc'}

    # this will consider all tickets, not just those on first page
    first_tick = assigns(:all_tickets).all.first
    last_tick = assigns(:all_tickets).all.last
    assert first_tick.created_at > last_tick.created_at

    # and now reverse order:
    get :index, {:admin_status => "all", :open_status => "open", :sort_order => 'created_at_asc'}

    assert_equal first_tick, assigns(:all_tickets).last
    assert_equal last_tick, assigns(:all_tickets).first

    assert_not_equal first_tick, assigns(:all_tickets).first
    assert_not_equal last_tick, assigns(:all_tickets).last

  end

  test "own tickets include tickets commented upon" do
    login
    ticket = FactoryGirl.create :ticket
    other_ticket = FactoryGirl.create :ticket
    comment = FactoryGirl.build(:ticket_comment, posted_by: @current_user.id)
    ticket.comments << comment
    ticket.save

    get :index, {:open_status => "open"}
    assert assigns(:all_tickets).count > 0
    assert assigns(:all_tickets).include?(ticket)
    assert !assigns(:all_tickets).include?(other_ticket)
  end

  test "list all tickets created by user" do
    login
    ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    other_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    get :index, {:open_status => "open"}
    assert_equal 2, assigns[:all_tickets].count
  end

  test "closing ticket removes from open tickets list" do
    login
    ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    other_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    other_ticket.reload
    other_ticket.close
    other_ticket.save
    get :index, {:open_status => "open"}
    assert_equal 1, assigns[:all_tickets].count
  end

  test "list closed tickets only" do
    login
    open_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    closed_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id, is_open: false
    get :index, {:open_status => "closed"}
    assert_equal [closed_ticket], assigns(:all_tickets).all
  end

  test "list all tickets inludes closed + open" do
    login
    open_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id
    closed_ticket = FactoryGirl.create :ticket_with_comment,
      created_by: @current_user.id, is_open: false
    get :index, {:open_status => "all"}
    assert_equal 2, assigns(:all_tickets).count
    assert assigns(:all_tickets).include?(open_ticket)
    assert assigns(:all_tickets).include?(closed_ticket)
  end
end
