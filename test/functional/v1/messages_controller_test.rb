require 'test_helper'

class V1::MessagesControllerTest < ActionController::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
    @user = FactoryGirl.build(:user)
    @user.save
    @message = Message.new(:text => 'a test message')
    @message.user_ids_to_show << @user.id
    @message.save
  end

  teardown do
    @message.destroy
    @user.destroy
  end

  test "get messages for user" do
    login @user
    get :index
    assert response.body.include? @message.text
    assert response.body.include? @message.id
  end

  test "mark message read for user" do
    login @user
    assert @message.user_ids_to_show.include?(@user.id)
    assert !@message.user_ids_have_shown.include?(@user.id)
    put :update, :id => @message.id
    @message.reload
    assert !@message.user_ids_to_show.include?(@user.id)
    assert @message.user_ids_have_shown.include?(@user.id)
    assert_success :marked_as_read
  end

  test "do not get seen messages" do
    login @user
    put :update, :id => @message.id
    @message.reload
    get :index
    assert !(response.body.include? @message.text)
    assert !(response.body.include? @message.id)
  end


  test "mark read responds even with bad inputs" do
    login @user
    put :update, :id => 'more nonsense'
    assert_not_found
 end

  test "fails if not authenticated" do
    get :index, :format => :json
    assert_login_required
  end

end
