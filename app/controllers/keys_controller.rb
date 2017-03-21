class KeysController < ApplicationController

  #
  # Render the user's key as plain text, without a layout.
  #
  # 404 error if user doesn't exist
  #
  # blank result if user doesn't have key (which shouldn't generally occur)
  #
  def show
    user = User.find_by_login(params[:login])
    if user
      render text: user.public_key, content_type: 'text/text'
    else
      head 404
    end
  end

end
