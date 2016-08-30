class HomeController < ApplicationController
  layout 'home'

  respond_to :html

  def index
    unless Rails.application.secrets.twitter['enabled'] == false
      twitter_handle = Rails.application.secrets.twitter['twitter_handle']
      @twitter_screen_name = twitter_handle
      @twitter_name = twitter_client.user(twitter_handle).name
      @tweets = twitter_client.user_timeline(twitter_handle).select{ |tweet| tweet.text.start_with?('RT','@')==false}
      @tweet_time = "tweeted on"
    end

    if logged_in?
      redirect_to current_user
    end
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      # config.consumer_key = Rails.application.secrets.twitter['consumer_key']
      # config.consumer_secret = Rails.application.secrets.twitter['consumer_secret']
      config.bearer_token = Rails.application.secrets.twitter['bearer_token']
    end
  end

end
