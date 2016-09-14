module TwitterHelper
  def twitter_enabled
    if Rails.application.secrets.twitter
      Rails.application.secrets.twitter['enabled'] == true
    end
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.bearer_token = Rails.application.secrets.twitter['bearer_token']
    end
  end

  def twitter_handle
    Rails.application.secrets.twitter['twitter_handle']
  end

  def twitter_user_info
      $twitter_user_info ||= []
  end

  def update_twitter_info
    twitter_user_info[0] = Time.now
    twitter_user_info[1] = twitter_client.user(twitter_handle).name
    twitter_user_info[2] = twitter_client.user_timeline(twitter_handle).select{ |tweet| tweet.text.start_with?('RT','@')==false}.take(3)
  end

  def cached_info
    if twitter_user_info[0] == nil
      update_twitter_info
    else
      if Time.now > twitter_user_info[0] + 15.minutes
        update_twitter_info
      end
    end
    twitter_user_info
  end

  def twitter_name
    cached_info[1]
  end

  def tweets
    cached_info[2]
  end
end
