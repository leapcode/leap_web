Customizing LEAP Webapp
============================================

By default, this directory is empty. Any file you place here will override the default files for the application.

For example:

    stylesheets/ -- overrides files Rails.root/app/assets/stylesheets
      tail.scss -- included before all others
      head.scss -- included after all others

    public/ -- overrides files in Rails.root/public
      favicon.ico -- custom favicon
      img/ -- customary directory to put images in

    views/ -- overrides files Rails.root/app/views
      home/
        index.html.haml -- this file is what shows up on the home page

    locales/ -- overrides files in Rails.root/config/locales
      en.yml -- overrides for English
      de.yml -- overrides for German
      and so on...

For most changes, the web application must be restarted after any changes are made to the customization directory.

Sometimes a `rake tmp:clear` and a rails restart is required to pick up a new stylesheet.
