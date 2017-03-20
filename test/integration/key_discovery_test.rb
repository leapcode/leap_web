require 'test_helper'

# This is not really a browser test - key discovery is used from bitmask.
# However we need to make sure to test the full rack stack to replicate
# exception handling.
class KeyDiscoveryTest < RackStackTest
  include Capybara::DSL

  setup do
    # make sure we test the whole stack...
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    # Revert Capybara.current_driver to Capybara.default_driver
    Capybara.use_default_driver
  end

  def test_404_on_non_existing_user
    visit '/key/asjkholifweatg'
    assert_equal 404, status_code
  end
end
