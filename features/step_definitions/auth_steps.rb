Given /^I authenticated$/ do
  @testcode = InviteCode.new
  @testcode.save!
  @user = FactoryGirl.create(:user, :invite_code => @testcode.invite_code)
  @my_auth_token = Token.create user_id: @user.id
end

Given /^I am not logged in$/ do
  @my_auth_token = nil
end

When /^I send requests to these endpoints:$/ do |endpoints|
  @endpoints = endpoints.rows_hash
end

Then /^they should require authentication$/ do
  @endpoints.each do |type, path|
    opts = {method: type.downcase.to_sym}
    request path, opts
    assert_equal 401, last_response.status,
      "Expected #{type} #{path} to require authentication."
  end
end
