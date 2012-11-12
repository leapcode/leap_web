require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  test "should get index if logged in" do 
    #todo: should redo this and actually authorize
    user = User.last
    session[:user_id] = user.id
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

    assert_equal assigns(:ticket).comments.count, 1
    assigns(:ticket).destroy # destroys without checking permission. is that okay?
  end


  test "should create authenticated ticket" do

    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    #todo: should redo this and actually authorize
    user = User.last
    session[:user_id] = user.id

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    assert_equal assigns(:ticket).created_by, user.id
    assert_equal assigns(:ticket).email, user.email

    assert_equal assigns(:ticket).comments.count, 1

    assigns(:ticket).destroy # ?
  end

  test "add comment to unauthenticated ticket" do

    t = Ticket.last
    t.created_by = nil # TODO: hacky, but this makes sure this ticket is an unauthenticated one 
    t.save
    comment_count = t.comments.count
    put :update, :id => t.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_equal(comment_count + 1, assigns(:ticket).comments.count)
    #assert_difference block isn't working
  end


  test "add comment to authenticated ticket" do


    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    #todo: should redo this and actually authorize
    user = User.last
    session[:user_id] = user.id
    
    post :create, :ticket => params
    t = assigns(:ticket)

    comment_count = t.comments.count
    debugger
    put :update, :id => t.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} } # this isn't working
    assert_equal(comment_count + 1, t.comments.count) 

    #comment_count = t.comments.count
    # now log out: and retry
    #session[:user_id] = nil
    #put :update, :id => t.id, :ticket => {:comments_attributes => {"0" => {"body" =>"EVEN NEWER comment"}} } # should fail
#    assert_equal(comment_count, t.comments.count)
    #assert_difference block isn't working
    t.destroy
  end

end
