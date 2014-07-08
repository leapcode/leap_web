
Given /^I authenticated$/ do
  @user = FactoryGirl.create(:user)
  @my_auth_token = Token.create user_id: @user.id
end

