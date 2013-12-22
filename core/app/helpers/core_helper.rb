#
# Misc. helpers needed throughout.
#
module CoreHelper

  #
  # insert common buttons (download, login, etc)
  #
  def home_page_buttons(on_user_page = false)
    render 'common/home_page_buttons', {:on_user_page => on_user_page}
  end

end
