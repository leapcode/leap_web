class KeysController < ApplicationController

  #
  # Render the user's key as plain text, without a layout.
  #
  # We will show blank page if user doesn't have key (which shouldn't generally occur)
  # and a 404 error if user doesn't exist
  #
  def show
    user = User.find_by_login(params[:login])
    if user
      render text: user.public_key, content_type: 'text/text'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
