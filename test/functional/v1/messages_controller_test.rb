require 'test_helper'

class V1::MessagesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.build(:user)
    @user.save
  end

  # NOTE: the available languages for test are :en and :de
  # so :es will result in english response.

  test "get the motd" do
    with_config("customization_directory" => Rails.root+'test/files') do
      login @user
      get :index, :locale => 'es'
      body = JSON.parse(response.body)
      message1 = "<p>\"This\" is a <strong>very</strong> fine message. <a href=\"https://bitmask.net\">https://bitmask.net</a></p>\n"
      assert_equal 2, body.size, 'there should be two messages'
      assert_equal message1, body.first["text"], 'first message text should match files/motd/1.en.md'
    end
  end

  test "get localized motd" do
    with_config("customization_directory" => Rails.root+'test/files') do
      login @user
      get :index, :locale => 'de'
      body = JSON.parse(response.body)
      message1 = "<p>Dies ist eine sehr feine Nachricht. <a href=\"https://bitmask.net\">https://bitmask.net</a></p>\n"
      assert_equal message1, body.first["text"], 'first message text should match files/motd/1.de.md'
    end
  end

  test "get empty motd" do
    login @user
    get :index
    assert_equal "[]", response.body, "motd response should be empty if no motd directory exists"
  end

  ##
  ## For now, only the static file MOTD is supported, not messages in the db.
  ## so, this is disabled:
  ##
=begin
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
=end

end
