ActiveSupport.on_load(:application_controller) do
  include ControllerExtension::Authentication
  include ControllerExtension::TokenAuthentication
  include ControllerExtension::Flash
end
