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

    assert_equal 1, assigns(:ticket).comments.count
  end


  test "should create authenticated ticket" do

    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    login :email => "test@email.net"

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    ticket = assigns(:ticket)
    assert ticket
    assert_equal @current_user.id, ticket.created_by
    assert_equal @current_user.email, ticket.email

    assert_equal 1, assigns(:ticket).comments.count
  end

  test "add comment to ticket" do

    ticket = Ticket.last
    assert_difference('Ticket.last.comments.count') do
      put :update, :id => ticket.id,
        :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    end
    assert_equal ticket, assigns(:ticket)

  end

end
