module AccountExtension::Tickets
  extend ActiveSupport::Concern

  def destroy_with_tickets(destroy_identities=false)
    Ticket.destroy_all_from(self.user)
    destroy_without_tickets(destroy_identities)
  end

  included do
    alias_method_chain :destroy, :tickets
  end

end
