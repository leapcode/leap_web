require 'test_helper'

class TicketsCommentsTest < ActionController::TestCase
  tests TicketsController

  teardown do
    # destroy all tickets that were created during the test
    Ticket.all.each{|t| t.destroy}
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


  test "cannot comment if it is another users ticket" do
    other_user = find_record :user
    login :is_admin? => false, :email => nil
    ticket = FactoryGirl.create :ticket, :created_by => other_user.id
    # they should *not* be able to comment if it is not their ticket
    put :update, :id => ticket.id, :ticket => {:comments_attributes => {"0" => {"body" =>"not allowed comment"}} }
    assert_response :redirect
    assert_access_denied

    assert_equal ticket.comments.map(&:body), assigns(:ticket).comments.map(&:body)
  end

  test "authenticated comment on an anonymous ticket adds to my tickets" do
    login
    ticket = FactoryGirl.create :ticket
    other_ticket = FactoryGirl.create :ticket
    put :update, :id => ticket.id,
      :ticket => {:comments_attributes => {"0" => {"body" =>"NEWER comment"}} }
    assert_not_nil assigns(:ticket).comments.last.posted_by
    assert_equal assigns(:ticket).comments.last.posted_by, @current_user.id
    visible_tickets = Ticket.search admin_status: 'mine',
      user_id: @current_user.id, is_admin: false
    assert_equal [ticket], visible_tickets.all
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

end
