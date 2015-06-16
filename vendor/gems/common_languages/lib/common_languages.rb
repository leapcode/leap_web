# encoding: utf-8

require_relative "common_languages/version"
require_relative "common_languages/data"
require_relative "common_languages/language"

module CommonLanguages
  def self.available_codes
    @available_codes ||= self.codes & I18n.available_locales.map(&:to_s)
  end

  def self.available
    @available ||= self.available_codes.map {|lc| self.get(lc) }
  end

  def self.available_code?(code)
    if !code.nil?
      self.available_codes.include?(code.to_s)
    else
      false
    end
  end

  def self.get(code)
    if !code.nil?
      self.languages[code.to_s]
    else
      false
    end
  end

  # a regexp that will match the available codes
  def self.match_available
    @match_available ||= /(#{self.available_codes.join('|')})/
  end

  # clears caches, useful only when testing
  def self.reset
    @codes = nil
    @available_codes = nil
    @available = nil
    @languages = nil
    @match = nil
    @match_available = nil
  end
end
