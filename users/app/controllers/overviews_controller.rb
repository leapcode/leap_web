class OverviewsController < UsersBaseController

  before_filter :authorize
  before_filter :fetch_user

  def show
  end

end
