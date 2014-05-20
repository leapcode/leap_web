require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  teardown do
    # destroy all tickets that were created during the test
    Ticket.all.each{|t| t.destroy}
  end

  test "should get index if logged in" do
    login
    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test "no index if not logged in" do
    get :index
    assert_response :redirect
    assert_nil assigns(:tickets)
  end

  test "should get new" do
    get :new
    assert_equal Ticket, assigns(:ticket).class
    assert_response :success
  end

  test "unauthenticated tickets are visible" do
    ticket = find_record :ticket, :created_by => nil
    get :show, :id => ticket.id
    assert_response :success
  end

  test "user tickets are not visible without login" do
    user = find_record :user
    ticket = find_record :ticket, :created_by => user.id
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to login_url
  end

  test "user tickets are visible to creator" do
    user = find_record :user
    ticket = find_record :ticket, :created_by => user.id
    login user
    get :show, :id => ticket.id
    assert_response :success
  end

  test "other users tickets are not visible" do
    other_user = find_record :user
    ticket = find_record :ticket, :created_by => other_user.id
    login
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to home_url
  end

  test "should create unauthenticated ticket" do
    params = {:subject => "unauth ticket test subject", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    assert_nil assigns(:ticket).created_by

    assert_equal 1, assigns(:ticket).comments.count
    assert_nil assigns(:ticket).comments.first.posted_by

  end

  test "handle invalid ticket" do
    params = {:subject => "unauth ticket test subject", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}, :email => 'a'}

    assert_no_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_template :new
    assert_equal params[:subject], assigns(:ticket).subject
  end

  test "should create authenticated ticket" do

    params = {:subject => "auth ticket test subject",:email => "", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    login

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect

    assert_not_nil assigns(:ticket).created_by
    assert_equal assigns(:ticket).created_by, @current_user.id
    assert_equal "", assigns(:ticket).email

    assert_equal 1, assigns(:ticket).comments.count
    assert_not_nil assigns(:ticket).comments.first.posted_by
    assert_equal assigns(:ticket).comments.first.posted_by, @current_user.id
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

