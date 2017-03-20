require 'test_helper'

class ProviderInfoTest < BrowserIntegrationTest

  def test_404_on_missing_page
    visit '/about'
    assert_equal 404, status_code
  end

  def test_404_on_missing_language_page
    visit '/de/about'
    assert_equal 404, status_code
  end

  def test_404_en_fallback
    visit '/de/bye'
    assert_equal 200, status_code
  end

end
