require 'test_helper'

class CertsControllerTest < ActionController::TestCase
  setup do
  end

  test "should send cert" do
    cert = stub :zipped => "adsf", :zipname => "cert_stub.zip"
    Cert.expects(:pick_from_pool).returns(cert)
    get :show
    assert_response :success
    assert_equal cert.zipped, @response.body
    assert_attachement_filename "cert_stub.zip"
  end
end
