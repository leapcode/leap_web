module AccountExtension::Tickets
  extend ActiveSupport::Concern

  def destroy_with_tickets
    Ticket.destroy_all_from(self.user)
    destroy_without_tickets
  end

  included do
    alias_method_chain :destroy, :tickets
  end

end
