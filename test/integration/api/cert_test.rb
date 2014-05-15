require 'test_helper'

class CertTest < ApiIntegrationTest

  test "retrieve eip cert" do
    login
    get '/1/cert', {}, RACK_ENV
    assert_text_response
    assert_response_includes "BEGIN RSA PRIVATE KEY"
    assert_response_includes "END RSA PRIVATE KEY"
    assert_response_includes "BEGIN CERTIFICATE"
    assert_response_includes "END CERTIFICATE"
  end

  test "fetching certs requires login by default" do
    get '/1/cert', {}, RACK_ENV
    assert_json_response error: I18n.t(:not_authorized)
  end

  test "retrieve anonymous eip cert" do
    with_config allow_anonymous_certs: true do
      get '/1/cert', {}, RACK_ENV
      assert_text_response
      assert_response_includes "BEGIN RSA PRIVATE KEY"
      assert_response_includes "END RSA PRIVATE KEY"
      assert_response_includes "BEGIN CERTIFICATE"
      assert_response_includes "END CERTIFICATE"
    end
  end
end
