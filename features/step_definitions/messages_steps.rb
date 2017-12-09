Given /^there is a message for me$/ do
  @message = FactoryBot.create :message, user_ids_to_show: [@user.id]
end

Given /^there is a message for me with:$/ do |options|
  attributes = options.rows_hash
  attributes.merge! user_ids_to_show: [@user.id]
  if old_message = Message.find(attributes['id'])
    old_message.destroy
  end
  @message = FactoryBot.create :message, attributes
end

Given(/^that message is marked as read$/) do
    @message.mark_as_read_by(@user)
    @message.save
end

Then /^the response should (not)?\s?include that message$/ do |negative|
  json = JSON.parse(last_response.body)
  message = json.detect{|message| message['id'] == @message.id}
  if negative.present?
    assert !message
  else
    assert_equal @message.text, message['text']
  end
end

Then /^that message should be marked as read$/ do
  assert @message.reload.read_by? @user
  assert !@message.unread_by?(@user)
end
