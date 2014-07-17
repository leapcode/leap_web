module ControllerExtension::JsonFile
  extend ActiveSupport::Concern
  include ControllerExtension::Errors

  protected

  def send_file
    if stale?(:last_modified => @file.mtime)
      response.content_type = 'application/json'
      render :text => @file.read
    end
  end

  def fetch_file
    if File.exists?(@filename)
      @file = File.new(@filename)
    else
      not_found
    end
  end

end

