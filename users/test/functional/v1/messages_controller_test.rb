require 'test_helper'

class V1::MessagesControllerTest < ActionController::TestCase

  setup do
    @message = Message.new(:text => 'a test message')
    @message.save
    @user = FactoryGirl.build(:user)
    @user.message_ids_to_see << @message.id
    @user.save
    login :is_admin? => true
  end

  teardown do
    @user.destroy
    @message.destroy
  end

  test "get messages for user" do
    get :user_messages, :user_id => @user.id
    assert response.body.include? @message.text
    assert response.body.include? @message.id
  end

  test "mark message read for user" do
    assert @user.message_ids_to_see.include?(@message.id)
    assert !@user.message_ids_seen.include?(@message.id)

    put :mark_read, :user_id => @user.id, :message_id => @message.id
    @user.reload
    assert !@user.message_ids_to_see.include?(@message.id)
    assert @user.message_ids_seen.include?(@message.id)
    assert_json_response true
  end

  test "do not get seen messages" do
    put :mark_read, :user_id => @user.id, :message_id => @message.id
    @user.reload
    get :user_messages, :user_id => @user.id
    assert !(response.body.include? @message.text)
    assert !(response.body.include? @message.id)
  end

  test "empty messages for non-existing user" do
    get :user_messages, :user_id => 'some random string'
    assert_json_response []
  end

  test "mark read responds even with bad inputs" do
    put :mark_read, :user_id => 'nonsense', :message_id => 'more nonsense'
    assert_json_response false
 end

  test "fails if not admin" do
    login :is_admin? => false
    get :user_messages, :user_id => @user.id
    assert_access_denied
  end

end
