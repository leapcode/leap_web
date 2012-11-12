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

  test "should create unauthenticated ticket" do
    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    #assert_equal assigns(:ticket).email, User.current.email
    #assert_equal User.find(assigns(:ticket).created_by).login, User.current.login
    assert_nil assigns(:ticket).created_by

    assert_equal 1, assigns(:ticket).comments.count
    assigns(:ticket).destroy # destroys without checking permission. is that okay?

  end


  test "should create authenticated ticket" do

    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    login User.last

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    ticket = assigns(:ticket)
    assert ticket
    assert_equal @current_user.id, ticket.created_by
    assert_equal @current_user.email, ticket.email

    assert_equal 1, assigns(:ticket).comments.count
    assigns(:ticket).destroy # ?
  end

  test "add comment to unauthenticated ticket" do
    ticket = Ticket.last
    ticket.created_by = nil # TODO: hacky, but this makes sure this ticket is an unauthenticated one 
    ticket.save
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end

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

  end


  test "cannot comment if it is not your ticket" do

    login(User.last) # assumes User.last is not admin
    assert !@current_user.is_admin?

    ticket = Ticket.last

    ticket.created_by = User.first.id #assumes User.first != User.last
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
    attribs = User.valid_attributes_hash
    attribs[:login] = admin_login
    admin_user = User.new(attribs)
    login(admin_user)

    ticket = Ticket.last
    ticket.created_by = User.last.id # TODO: hacky, but confirms it somebody elses ticket
    assert_not_equal User.last, admin_user
    ticket.save

    #admin should be able to comment:
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_not_equal ticket.comments, assigns(:ticket).comments

  end


  test "test_tickets_by_admin" do
    #TODO
  end

end

