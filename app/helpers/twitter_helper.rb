module TwitterHelper
  def twitter_enabled
    Rails.application.secrets.twitter['enabled'] == true
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter['consumer_key']
      config.consumer_secret = Rails.application.secrets.twitter['consumer_secret']
      config.bearer_token = Rails.application.secrets.twitter['bearer_token']
    end
  end

  def twitter_handle
    Rails.application.secrets.twitter['twitter_handle']
  end

  def twitter_name
    twitter_client.user(twitter_handle).name
  end

  def tweets
    twitter_client.user_timeline(twitter_handle).select{ |tweet| tweet.text.start_with?('RT','@')==false}
  end
end
