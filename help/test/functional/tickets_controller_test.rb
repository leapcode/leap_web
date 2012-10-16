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


  test "should create authenticated ticket" do
    params = {:title => "ticket test title", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end
    
    assert_response :redirect
    assert_equal assigns(:ticket).email, User.current_test.email
    assert_equal User.find(assigns(:ticket).created_by).login, User.current_test.login
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
