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
    if twitter_user_info[2] == nil
      error_handling
      twitter_user_info[3] = "The twitter-handle does not exist or the account is private. Please change it or contact your provider-admin."
    end
  rescue Twitter::Error::BadRequest
    error_handling
    twitter_user_info[3] = "The request to have the tweets shown was invalid or cannot be otherwise served."
  rescue Twitter::Error::Unauthorized
    error_handling
    twitter_user_info[3] = "Please change your twitter-credentials, make sure that the twitter-account you access is public or contact your provider-admin to have the tweets shown."
  rescue Twitter::Error::Forbidden
    error_handling
    twitter_user_info[3] = "The request to have the tweets shown is understood, but it has been refused or access is not allowed."
  rescue Twitter::Error::NotAcceptable
    error_handling
    twitter_user_info[3] = "An invalid format is specified in the request to have the tweets shown."
  rescue Twitter::Error::TooManyRequests
    error_handling
    twitter_user_info[3] = "The rate-limit for accessing the tweets is reached. You should be able to see the tweets in a couple of minutes."
  end

  def error_handling
    twitter_user_info[2] = []
    return twitter_user_info
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

  def error_message
    cached_info[3]
  end
end
