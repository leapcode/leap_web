module TicketI18nHelper

  #
  # outputs translations for all the possible translated strings.
  # used in emails, sense we don't know the locale of the recipient.
  #
  def t_all_available(key)
    default = I18n.t(key, locale: I18n.default_locale)
    result = []
    result << "[#{I18n.default_locale}] #{default}"
    I18n.available_locales.each do |locale|
      text = I18n.t(key, locale: locale, default: default)
      if text != default
        result << "[#{locale}] #{text}"
      end
    end
    result.join("\n")
  end

end
