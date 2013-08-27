ActiveSupport.on_load(:application_controller) do
  include ControllerExtension::Authentication
  include ControllerExtension::TokenAuthentication
end
