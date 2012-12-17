require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  setup do
    User.create(User.valid_attributes_hash.merge({:login => 'first_test'}))
    User.create(User.valid_attributes_hash.merge({:login => 'different'}))
    Ticket.create( {:title => "stub test ticket", :id => 'stubtestticketid', :comments_attributes => {"0" => {"body" =>"body of stubbed test ticket"}}})
    Ticket.create( {:title => "stub test ticket two", :id => 'stubtestticketid2', :comments_attributes => {"0" => {"body" =>"body of second stubbed test ticket"}}})
  end

  teardown do
    User.find_by_login('first_test').destroy
    User.find_by_login('different').destroy
    Ticket.find('stubtestticketid').destroy
    Ticket.find('stubtestticketid2').destroy
  end

  test "should get index if logged in" do
    login :is_admin? => false
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

  test "ticket show access" do
    ticket = Ticket.first
    ticket.created_by = nil # TODO: hacky, but this makes sure this ticket is an unauthenticated one
    ticket.save
    get :show, :id => ticket.id
    assert_response :success

    ticket.created_by = User.last.id
    ticket.save
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to login_url

    login(User.last)
    get :show, :id => ticket.id
    assert_response :success

    login(User.first) #assumes User.first != User.last:
    assert_not_equal User.first, User.last
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to root_url

  end

  test "should create unauthenticated ticket" do
    params = {:title => "unauth ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    assert_nil assigns(:ticket).created_by

    assert_equal 1, assigns(:ticket).comments.count
    assert_nil assigns(:ticket).comments.first.posted_by
    assigns(:ticket).destroy # destroys without checking permission. is that okay?

  end

  test "should create authenticated ticket" do

    params = {:title => "auth ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    login :email => "test@email.net"

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect

    assert_not_nil assigns(:ticket).created_by
    assert_equal assigns(:ticket).created_by, @current_user.id
    assert_equal assigns(:ticket).email, @current_user.email

    assert_equal 1, assigns(:ticket).comments.count
    assert_not_nil assigns(:ticket).comments.first.posted_by
    assert_equal assigns(:ticket).comments.first.posted_by, @current_user.id
    assigns(:ticket).destroy
  end

  test "add comment to unauthenticated ticket" do
    ticket = Ticket.find('stubtestticketid')
    ticket.created_by = nil # TODO: hacky, but this makes sure this ticket is an unauthenticated one
    ticket.save

    assert_difference('Ticket.find("stubtestticketid").comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end

    assert_equal ticket, assigns(:ticket) # still same ticket, with different comments
    assert_not_equal ticket.comments, assigns(:ticket).comments # ticket == assigns(:ticket), but they have different comments (which we want)

  end


  test "add comment to own authenticated ticket" do

    login User.last
    ticket = Ticket.find('stubtestticketid')
    ticket.created_by = @current_user.id # TODO: hacky, but confirms it is their ticket
    ticket.save

    #they should be able to comment if it is their ticket:
    assert_difference('Ticket.find("stubtestticketid").comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

  end


  test "cannot comment if it is not your ticket" do

    login :is_admin? => false, :email => nil
    ticket = Ticket.first

    assert_not_nil User.first.id
    ticket.created_by = User.first.id
    ticket.save
    # they should *not* be able to comment if it is not their ticket
    put :update, :id => ticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"not allowed comment"}} }
    assert_response :redirect
    assert_access_denied

    assert_equal ticket.comments, assigns(:ticket).comments

  end


  test "admin add comment to authenticated ticket" do

    login :is_admin? => true

    ticket = Ticket.find('stubtestticketid')
    assert_not_nil User.last.id
    ticket.created_by = User.last.id # TODO: hacky, but confirms it somebody elses ticket:
    assert_not_equal User.last.id, @current_user.id
    ticket.save

    #admin should be able to comment:
    assert_difference('Ticket.find("stubtestticketid").comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

  end

  test "tickets by admin" do

    login :is_admin? => true, :email => nil

    get :index, {:admin_status => "all", :open_status => "open"}
    assert assigns(:all_tickets).count > 1

    # if we close one ticket, the admin should have 1 less open ticket
    assert_difference('assigns[:all_tickets].count', -1) do
      assigns(:tickets).first.close
      assigns(:tickets).first.save
      get :index, {:admin_status => "all", :open_status => "open"}
    end
  end


  test "admin_status mine vs all" do
    testticket = Ticket.create :title => 'temp testytest'
    login :is_admin? => true, :email => nil

    get :index, {:admin_status => "all", :open_status => "open"}
    assert assigns(:all_tickets).include?(testticket)
    get :index, {:admin_status => "mine", :open_status => "open"}
    assert !assigns(:all_tickets).include?(testticket)
  end

  test "commenting on a ticket adds to tickets that are mine" do
    testticket = Ticket.create :title => 'temp testytest'
    login :is_admin? => true, :email => nil

    get :index, {:admin_status => "mine", :open_status => "open"}
    assert_difference('assigns[:all_tickets].count') do
      put :update, :id => testticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}}}
      get :index, {:admin_status => "mine", :open_status => "open"}
    end

    assert assigns(:all_tickets).include?(assigns(:ticket))
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

    assigns(:ticket).destroy
  end

  test "admin ticket ordering" do

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
    login :is_admin? => false, :email => nil

    put :update, :id => 'stubtestticketid',:ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

    get :index, {:open_status => "open"}
    assert assigns(:all_tickets).count > 0
    assert assigns(:all_tickets).include?(Ticket.find('stubtestticketid'))

    assert !assigns(:all_tickets).include?(Ticket.find('stubtestticketid2'))

    # user should have one more ticket if a new tick gets a comment by this user
    assert_difference('assigns[:all_tickets].count') do
      put :update, :id => 'stubtestticketid2' , :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}}}
      get :index, {:open_status => "open"}
    end
    assert assigns(:all_tickets).include?(Ticket.find('stubtestticketid2'))

   # if we close one ticket, the user should have 1 less open ticket
    assert_difference('assigns[:all_tickets].count', -1) do
      t = Ticket.find('stubtestticketid2')
      t.close
      t.save
      get :index, {:open_status => "open"}
    end

    number_open_tickets = assigns(:all_tickets).count

    # look at closed tickets:
    get :index, {:open_status => "closed"}
    assert assigns(:all_tickets).include?(Ticket.find('stubtestticketid2'))
    assert !assigns(:all_tickets).include?(Ticket.find('stubtestticketid'))
    number_closed_tickets = assigns(:all_tickets).count

    # all tickets should equal closed + open
    get :index, {:open_status => "all"}
    assert assigns(:all_tickets).include?(Ticket.find('stubtestticketid2'))
    assert assigns(:all_tickets).include?(Ticket.find('stubtestticketid'))
    assert_equal assigns(:all_tickets).count, number_closed_tickets + number_open_tickets

  end

end

