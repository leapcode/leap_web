module ControllerExtension::JsonFile
  extend ActiveSupport::Concern
  include ControllerExtension::Errors

  protected

  def send_file(filename)
    file = fetch_file(filename)
    if file.present?
      send_file_or_cache_hit(file)
    else
      not_found
    end
  end

  def send_file_or_cache_hit(file)
    if stale?(:last_modified => file.mtime)
      response.content_type = 'application/json'
      render :text => file.read
    end
  end

  def fetch_file(filename)
    File.new(filename) if File.exist?(filename)
  end

end

