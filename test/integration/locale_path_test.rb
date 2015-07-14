require 'test_helper'

#
# Test how we handle redirections and locales.
#
# The basic rules are:
#
# (1) If the browser header Accept-Language matches default locale, then don't do a locale prefix.
# (2) If browser locale is supported in available_locales, but is not the default, then redirect.
# (3) If browser locale is not in available_locales, use the default locale with no prefix.
#
# Settings in defaults.yml
#
#  default_locale: :en
#  available_locales:
#    - :en
#    - :de
#
# NOTE: Although the browser sends the header Accept-Language, this is parsed by
# ruby as HTTP_ACCEPT_LANGUAGE
#

class LocalePathTest < ActionDispatch::IntegrationTest
  test "redirect if accept-language is not default locale" do
    get_via_redirect '/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'de'
    assert_equal '/de', path
    assert_equal({:locale => :de}, default_url_options)
  end

  test "no locale prefix" do
    get_via_redirect '/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'en'
    assert_equal '/', path
    assert_equal({:locale => nil}, default_url_options)

    get_via_redirect '/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'pt'
    assert_equal '/', path
    assert_equal({:locale => nil}, default_url_options)
  end

  test "no redirect if locale explicit" do
    get_via_redirect '/de', {}, 'HTTP_ACCEPT_LANGUAGE' => 'en'
    assert_equal '/de', path
    assert_equal({:locale => :de}, default_url_options)
  end

  test "strip prefix from url options if locale is default" do
    get_via_redirect '/en', {}, 'HTTP_ACCEPT_LANGUAGE' => 'en'
    assert_equal '/en', path
    assert_equal({:locale => nil}, default_url_options)
  end

  protected

  def default_url_options
    @controller.send(:default_url_options)
  end

end