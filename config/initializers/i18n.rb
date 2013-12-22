I18n.enforce_available_locales = true
I18n.available_locales = APP_CONFIG[:available_locales]
I18n.default_locale = APP_CONFIG[:default_locale]

# Used to match locales route prefixes
MATCH_LOCALE = /(#{I18n.available_locales.join('|')})/

# I18n.available_locales is always an array of symbols, but for comparison with
# params we need it to be an array of strings.
LOCALES_STRING =  I18n.available_locales.map(&:to_s)
