require 'test_helper'

class CreateTicketTest < BrowserIntegrationTest

  test "can submit ticket anonymously" do
    visit '/'
    click_on 'Get Help'
    fill_in 'Subject', with: 'test ticket'
    fill_in 'Description', with: 'description of the problem goes here'
    click_on 'Create Ticket'
    assert page.has_content?("Ticket was successfully created.")
    assert page.has_content?("You can later access this ticket at the URL")
    assert page.has_content?(current_url)
    assert ticket = Ticket.last
    ticket.destroy
  end

  test "get help when creating ticket with invalid email" do
    visit '/'
    click_on 'Get Help'
    fill_in 'Subject', with: 'test ticket'
    fill_in 'Email', with: 'invalid data'
    fill_in 'Description', with: 'description of the problem goes here'
    click_on 'Create Ticket'
    assert page.has_content?("is invalid")
  end

end
