# CommonLanguages

A simple gem that provides the ability to display the list of
I18n.available_locales in a localized and friendly way.

There are many similar or related gems. For example:

* https://github.com/davec/localized_language_select
* https://github.com/teonimesic/language_switcher
* https://github.com/grosser/i18n_data
* https://github.com/scsmith/language_list

I wanted something different than what these others provide:

* Language names should be displayed in the native name for each language, not
  a localized or anglicized version.
* There should not be any gem dependencies.
* Since there is no universal collation across all languages, they should be
  sorted in order of popularity.
* There should not be any need to parse large data files, 99% of which will
  never be used.

# Usage

This code:

    I18n.available_locales = [:de, :en, :pt]
    CommonLanguages.available.each do |language|
      p [language.code, language.name, language.english_name, language.rtl?]
    end

Produces:

    [:en, "English", "English", false]
    [:pt, "Português", "Portugues", false]
    [:de, "Deutsch", "German", false]