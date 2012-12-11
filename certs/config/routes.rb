Rails.application.routes.draw do
  scope '/1' do
    resource :cert, :only => [:show]
  end
end
