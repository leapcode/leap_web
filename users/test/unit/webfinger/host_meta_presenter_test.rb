require 'test_helper'
require 'webfinger'
require 'json'

class Webfinger::HostMetaPresenterTest < ActiveSupport::TestCase

  setup do
    @request = stub(
      url: "https://#{APP_CONFIG[:domain]}/.well-known/host-meta"
    )
    @meta = Webfinger::HostMetaPresenter.new(@request)
  end

  test "creates proper json" do
    hash = JSON.parse @meta.to_json
    assert_equal ["subject", "links"].sort, hash.keys.sort
    hash.each do |key, value|
      assert_equal @meta.send(key.to_sym).to_json, value.to_json
    end
  end

end


