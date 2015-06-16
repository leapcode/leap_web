require_relative 'test_helper'
require 'i18n'

class UsageTest < MiniTest::Test

  def setup
    CommonLanguages.reset
  end

  def test_available_codes_are_sorted
    I18n.available_locales = ['pt', 'en', :de, :es]
    assert_equal ['es', 'en', 'pt', 'de'], CommonLanguages.available_codes
  end

  def test_available
    I18n.available_locales = [:en]
    english = CommonLanguages::Language.new(CommonLanguages::DATA[2])
    assert_equal english, CommonLanguages.get(:en)
    assert_equal [english], CommonLanguages.available
  end

  def test_unique_codes
    assert_equal CommonLanguages::DATA.size, CommonLanguages::languages.size
  end

  #def test_data
  #  I18n.available_locales = [:en, :de, :pt]
  #  CommonLanguages.available.each do |language|
  #    p [language.code, language.name, language.english_name, language.rtl?]
  #  end
  #end

end
