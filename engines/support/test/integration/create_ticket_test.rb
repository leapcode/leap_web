require 'test_helper'

class CreateTicketTest < BrowserIntegrationTest

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  test "can submit ticket anonymously" do
    visit '/'
    click_on 'Get Help'
    fill_in 'Subject', with: 'test ticket'
    fill_in 'Description', with: 'description of the problem goes here'
    click_on 'Submit Ticket'
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
    fill_in 'Regarding User', with: 'some user'
    fill_in 'Description', with: 'description of the problem goes here'
    click_on 'Submit Ticket'
    assert page.has_content?("is invalid")
    assert_equal 'invalid data', find_field('Email').value
    assert_equal 'some user', find_field('Regarding User').value
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

end
