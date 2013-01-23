require 'test_helper'
require 'webfinger'
require 'json'

class Webfinger::UserPresenterTest < ActiveSupport::TestCase


  setup do
    @user = stub(
      username: 'testuser',
      email_address: "testuser@#{APP_CONFIG[:domain]}"
    )
    @request = stub(
      host: APP_CONFIG[:domain]
    )
  end

  test "user without key has no links" do
    @user.stubs :public_key => nil
    presenter = Webfinger::UserPresenter.new(@user, @request)
    assert_equal Hash.new, presenter.links
  end

  test "user with key has corresponding link" do
    @user.stubs :public_key => "here's a key"
    presenter = Webfinger::UserPresenter.new(@user, @request)
    assert_equal [:public_key], presenter.links.keys
    assert_equal "PGP", presenter.links[:public_key][:type]
    assert_equal presenter.send(:key), presenter.links[:public_key][:href]
  end

  test "key is base64 encoded" do
    @user.stubs :public_key => "here's a key"
    presenter = Webfinger::UserPresenter.new(@user, @request)
    assert_equal Base64.encode64(@user.public_key), presenter.send(:key)
  end

  test "creates proper json representation" do
    @user.stubs :public_key => "here's a key"
    presenter = Webfinger::UserPresenter.new(@user, @request)
    hash = JSON.parse presenter.to_json
    assert_equal ["subject", "links", "aliases"].sort, hash.keys.sort
    hash.each do |key, value|
      assert_equal presenter.send(key.to_sym).to_json, value.to_json
    end
  end


end
