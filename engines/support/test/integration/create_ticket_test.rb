require 'test_helper'

class CreateTicketTest < BrowserIntegrationTest

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  teardown do
    Ticket.last.destroy if Ticket.last.present?
  end

  test "can submit ticket anonymously" do
    submit_ticket
    assert_ticket_submitted
  end

  test "get help when creating ticket with invalid email" do
    submit_ticket email: 'invalid data',
      regarding_user: 'some user'
    assert_invalid_submission
    assert_equal 'invaliddata', find_field('Email').value
    assert_equal 'some user', find_field('Regarding User').value
    resubmit_ticket email: 'valid@data.info'
    assert_ticket_submitted
  end

  test "can resubmit after missing description" do
    submit_ticket description: ''
    assert page.has_content?("can't be blank")
    resubmit_ticket description: 'okay, okay... you get a subject'
    assert_ticket_submitted
  end

  test "prefills fields" do
    login FactoryGirl.create(:premium_user, :invite_code => @testcode.invite_code)
    visit '/'
    click_on "Support Tickets"
    click_on "New Ticket"
    email = "#{@user.login}@#{APP_CONFIG[:domain]}"
    assert_equal email, find_field('Email').value
    assert_equal @user.login, find_field('Regarding User').value
  end

  test "no prefill of email without email service" do
    login
    visit '/'
    click_on "Support Tickets"
    click_on "New Ticket"
    assert_equal "", find_field('Email').value
    assert_equal @user.login, find_field('Regarding User').value
  end

  test "cleared email field should remain clear" do
    login FactoryGirl.create(:premium_user, :invite_code => @testcode.invite_code)
    visit '/'
    click_on "Support Tickets"
    click_on "New Ticket"
    fill_in 'Subject', with: 'test ticket'
    fill_in 'Email', with: ''
    fill_in 'Description', with: 'description of the problem goes here'
    click_on 'Submit Ticket'
    ticket = Ticket.last
    assert_equal "", ticket.email
    ticket.destroy
  end

  def submit_ticket(email: nil, regarding_user: nil, description: 'some content')
    visit '/'
    click_on 'Get Help'
    fill_in 'Subject', with: 'test ticket'
    fill_in 'Email', with: email if email
    fill_in 'Regarding User', with: regarding_user if regarding_user
    fill_in 'Description', with: description
    click_on 'Submit Ticket'
  end

  def assert_invalid_submission
    assert page.has_content?("is invalid")
  end

  def resubmit_ticket(email: nil, description: nil)
    fill_in 'Email', with: email if email
    fill_in 'Description', with: description if description
    click_on 'Submit Ticket'
  end

  def assert_ticket_submitted
    assert page.has_content?("Ticket was successfully created.")
    assert page.has_content?("You can later access this ticket at the URL")
    assert page.has_content?(current_url)
  end
end
