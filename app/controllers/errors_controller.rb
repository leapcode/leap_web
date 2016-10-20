# We render http errors ourselves so we can customize them
class ErrorsController < ApplicationController
  respond_to :html

  # 404
  def not_found
    render status: 404
  end

  # 500
  def server_error
    render status: 500
  end
end
