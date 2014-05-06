# We render http errors ourselves so we can customize them
class ErrorsController < ApplicationController
  # 404
  def not_found
  end

  # 500
  def server_error
  end
end
