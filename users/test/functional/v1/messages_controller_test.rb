require 'test_helper'

class V1::MessagesControllerTest < ActionController::TestCase
  
  #TODO ensure authentication for all tests here

  setup do
    @user = FactoryGirl.build(:user)
    @user.save
    @message = Message.new(:text => 'a test message')
    @message.save
    @user_message = UserMessage.new(:message_id => @message.id, :user_id => @user.id)
    @user_message.save
  end

  teardown do
    @user_message.destroy
    @user.destroy
    @message.destroy
  end

  test "get messages for user" do
    get :user_messages, :user_id => @user.id
    assert response.body.include? @message.text
    assert response.body.include? @message.id
  end

  test "mark message read for user" do
    assert !@user_message.seen
    put :mark_read, :user_id => @user.id, :message_id => @message.id
    @user_message.reload
    assert @user_message.seen
    assert_json_response true
  end

  test "do not get seen messages" do
    @user_message.seen = true
    @user_message.save
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

end
