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
  end

  test "do not get seen messages" do
    @user_message.seen = true
    @user_message.save
    get :user_messages, :user_id => @user.id
    assert !(response.body.include? @message.text)
    assert !(response.body.include? @message.id)
  end

end
