require 'test_helper'

class TicketsControllerTest < ActionController::TestCase

  test "should get index" do
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
  end

  test "add comment to ticket" do

    t = Ticket.last
    comment_count = t.comments.count
    put :update, :id => t.id, :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_equal(comment_count + 1, assigns(:ticket).comments.count)
    #assert_difference block isn't working

  end

end
