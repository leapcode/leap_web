require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  test "should get index if logged in" do 
    login(User.last)
    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
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

    login User.last
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
    ticket = Ticket.last
    ticket.created_by = nil # TODO: hacky, but this makes sure this ticket is an unauthenticated one 
    ticket.save
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end

    assert_equal ticket, assigns(:ticket) # still same ticket, with different comments
    assert_not_equal ticket.comments, assigns(:ticket).comments # ticket == assigns(:ticket), but they have different comments (which we want)

  end


  test "add comment to own authenticated ticket" do

    login(User.last)
    ticket = Ticket.last
    ticket.created_by = User.last.id # TODO: hacky, but confirms it is their ticket
    ticket.save
    #they should be able to comment if it is their ticket:
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

  end


  test "cannot comment if it is not your ticket" do

    login(User.last) # assumes User.last is not admin
    assert !@current_user.is_admin?

    ticket = Ticket.last

    assert_not_nil User.first.id
    ticket.created_by = User.first.id #assumes User.first != User.last:
    assert_not_equal User.first, User.last
    ticket.save
    # they should *not* be able to comment if it is not their ticket
    put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_response :redirect
    assert_access_denied
    assert_equal ticket.comments, assigns(:ticket).comments
   
  end


  test "admin add comment to authenticated ticket" do

    admin_login = APP_CONFIG['admins'].first
    admin_user = User.find_by_login(admin_login) #assumes that there is an admin login
    login(admin_user) 

    ticket = Ticket.last
    assert_not_nil User.last.id
    ticket.created_by = User.last.id # TODO: hacky, but confirms it somebody elses ticket. assumes last user is not admin user:
    assert_not_equal User.last, admin_user
    ticket.save

    #admin should be able to comment:
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id

  end

  test "tickets by admin" do

    admin_login = APP_CONFIG['admins'].first
    admin_user = User.find_by_login(admin_login) #assumes that there is an admin login
    login(admin_user)
    
    post :create, :ticket => {:title => "test tick", :comments_attributes => {"0" => {"body" =>"body of test tick"}}}
    post :create, :ticket => {:title => "another test tick", :comments_attributes => {"0" => {"body" =>"body of another test tick"}}}

    assert_not_nil assigns(:ticket).created_by
    assert_equal assigns(:ticket).created_by, admin_user.id

    get :index, {:status => "open tickets I admin"}
    assert assigns(:tickets).count > 1 # at least 2 tickets

    # if we close one ticket, the admin should have 1 less open ticket they admin
    assert_difference('assigns[:tickets].count', -1) do
      assigns(:ticket).close
      assigns(:ticket).save
      get :index, {:status => "open tickets I admin"}
    end
    assigns(:ticket).destroy

    testticket = Ticket.create :title => 'testytest'
    assert !assigns(:tickets).include?(testticket)

    # admin should have one more ticket if a new tick gets an admin comment
    assert_difference('assigns[:tickets].count') do
      put :update, :id => testticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}}} 
      get :index, {:status => "open tickets I admin"}
    end

    assert assigns(:tickets).include?(assigns(:ticket))
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, admin_user.id

    assigns(:ticket).destroy
    
  end

end

