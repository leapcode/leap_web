class KeysController < ApplicationController

  def show
    user = User.find_by_login(params[:login])
    # layout won't be included if we render text
    # we will show blank page if user doesn't have key or user doesn't exist
    render text: user ? user.public_key : ''
  end

end
