I18n.enforce_available_locales = true
I18n.available_locales = APP_CONFIG[:available_locales]
I18n.default_locale = APP_CONFIG[:default_locale]
I18n.load_path += Dir[Rails.root.join('config', 'locales', 'en', '*.yml')]

# enable using the cascade option
# see svenfuchs.com/2011/2/11/organizing-translations-with-i18n-cascade-and-i18n-missingtranslations
I18n::Backend::Simple.send(:include, I18n::Backend::Cascade)
