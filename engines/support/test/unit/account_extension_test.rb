require 'test_helper'

class AccountExtensionTest < ActiveSupport::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
  end

  test "destroying an account triggers ticket destruction" do
    t = FactoryBot.create :ticket_with_creator
    u = t.created_by_user
    Account.new(u).destroy
    assert_nil Ticket.find(t.id)
  end

end
