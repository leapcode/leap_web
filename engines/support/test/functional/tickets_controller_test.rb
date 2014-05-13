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

  test "add comment to unauthenticated ticket" do
    ticket = FactoryGirl.create :ticket, :created_by => nil

    assert_difference('Ticket.find(ticket.id).comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end

    assert_equal ticket, assigns(:ticket) # still same ticket, with different comments
    assert_not_equal ticket.comments, assigns(:ticket).comments # ticket == assigns(:ticket), but they have different comments (which we want)

  end


  test "add comment to own authenticated ticket" do

    login
    ticket = FactoryGirl.create :ticket, :created_by => @current_user.id

    #they should be able to comment if it is their ticket:
    assert_difference('Ticket.find(ticket.id).comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

  end


  test "cannot comment if it is not your ticket" do

    other_user = find_record :user
    login :is_admin? => false, :email => nil
    ticket = FactoryGirl.create :ticket, :created_by => other_user.id
    # they should *not* be able to comment if it is not their ticket
    put :update, :id => ticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"not allowed comment"}} }
    assert_response :redirect
    assert_access_denied

    assert_equal ticket.comments.map(&:body), assigns(:ticket).comments.map(&:body)

  end


  test "admin add comment to authenticated ticket" do

    other_user = find_record :user
    login :is_admin? => true

    ticket = FactoryGirl.create :ticket, :created_by => other_user.id

    #admin should be able to comment:
    assert_difference('Ticket.find(ticket.id).comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id
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

  test "commenting on a ticket adds to tickets that are mine" do
    testticket = FactoryGirl.create :ticket
    user = find_record :admin_user
    login user
    get :index, {:user_id => user.id, :open_status => "open"}
    assert_difference('assigns[:all_tickets].count') do
      put :update, :id => testticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}}}
      get :index, {:user_id => user.id, :open_status => "open"}
    end

    assert assigns(:all_tickets).include?(assigns(:ticket))
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id
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

  test "tickets for regular user" do
    login
    ticket = FactoryGirl.create :ticket
    other_ticket = FactoryGirl.create :ticket

    put :update, :id => ticket.id,
      :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

    get :index, {:open_status => "open"}
    assert assigns(:all_tickets).count > 0
    assert assigns(:all_tickets).include?(ticket)
    assert !assigns(:all_tickets).include?(other_ticket)

    # user should have one more ticket if a new tick gets a comment by this user
    assert_difference('assigns[:all_tickets].count') do
      put :update, :id => other_ticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}}}
      get :index, {:open_status => "open"}
    end
    assert assigns(:all_tickets).include?(other_ticket)

   # if we close one ticket, the user should have 1 less open ticket
    assert_difference('assigns[:all_tickets].count', -1) do
      other_ticket.reload
      other_ticket.close
      other_ticket.save
      get :index, {:open_status => "open"}
    end

    number_open_tickets = assigns(:all_tickets).count

    # look at closed tickets:
    get :index, {:open_status => "closed"}
    assert !assigns(:all_tickets).include?(ticket)
    assert assigns(:all_tickets).include?(other_ticket)
    number_closed_tickets = assigns(:all_tickets).count

    # all tickets should equal closed + open
    get :index, {:open_status => "all"}
    assert assigns(:all_tickets).include?(ticket)
    assert assigns(:all_tickets).include?(other_ticket)
    assert_equal assigns(:all_tickets).count, number_closed_tickets + number_open_tickets


  end

end

