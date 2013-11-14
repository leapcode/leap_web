#
# When deploying, common customizations can be dropped in config/customizations. This initializer makes this work.
#
customization_directory = "#{Rails.root}/config/customization"

#
# Set customization views as the first view path
#
# Rails.application.config.paths['app/views'].unshift "config/customization/views"
# (For some reason, this does not work here. See application.rb for where this is actually called.)

#
# Set customization stylesheets as the first asset path
#
#   (This cannot go in application.rb, because the default paths
#    haven't been loaded yet, as far as I can tell)
#
Rails.application.config.assets.paths.unshift "#{customization_directory}/stylesheets"

#
# Copy files to public
#
if Dir.exists?("#{customization_directory}/public")
  require 'fileutils'
  FileUtils.cp_r("#{customization_directory}/public/.", "#{Rails.root}/public")
end

#
# Add I18n path
#
Rails.application.config.i18n.load_path += Dir["#{customization_directory}/locales/*.{rb,yml,yaml}"]
