require 'account_extension/tickets'

ActiveSupport.on_load(:account) do
  include AccountExtension::Tickets
end
