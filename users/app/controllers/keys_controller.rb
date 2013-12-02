class KeysController < ApplicationController

  def show
    user = User.find_by_login(params[:login])
    # layout won't be included if we render text
    # we will show blank page if user doesn't have key (which shouldn't generally occur)
    # and a 404 error if user doesn't exist
    user ? (render text: user.public_key) : (raise ActionController::RoutingError.new('Not Found'))

  end

end
