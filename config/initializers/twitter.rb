#
# When deploying, common customizations can be dropped in config/customizations. This initializer makes this work.
#
APP_CONFIG["customization_directory"] ||= "#{Rails.root}/config/customization"
customization_directory = APP_CONFIG["customization_directory"]

#
# Set customization views as the first view path
#
# Rails.application.config.paths['app/views'].unshift "config/customization/views"
# (For some reason, this does not work here. See application.rb for where this is actually called.)

#
# Set customization stylesheets as the first asset path
#
# Some notes:
#
# * This cannot go in application.rb, as far as I can tell. In application.rb, the default paths
#   haven't been loaded yet, so the path we add will always end up at the end unless we add it here.
#
# * For this to work, config.assets.initialize_on_precompile MUST be set to true, otherwise
#   this initializer will never get called in production mode when the assets are precompiled.
#
Rails.application.config.assets.paths.unshift "#{customization_directory}/stylesheets"

#
# Copy files to public
#
if !defined?(RAKE) && Dir.exist?("#{customization_directory}/public")
  require 'fileutils'
  FileUtils.cp_r("#{customization_directory}/public/.", "#{Rails.root}/public", :preserve => true)
end

#
# Add I18n path
#
Rails.application.config.i18n.load_path += Dir["#{customization_directory}/locales/*.{rb,yml,yaml}"]
