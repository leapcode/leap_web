module IntegrationTestHelper
  def submit_signup
    username = "test_#{SecureRandom.urlsafe_base64}".downcase
    password = SecureRandom.base64
    visit '/users/new'
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_on 'Sign Up'
    return username, password
  end
end
