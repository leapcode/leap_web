# Display of status updates from twitter on main view #

This is a feature to include status updates that displays most recent tweets
of a (determined) twitter account (accessed via Twitter API).
If you chose to use it, the feature gets included in `home/index` of
LEAP web app (as part of the main view).

## How to use it ##

* Create Twitter Application on https://apps.twitter.com/
  * Visit https://apps.twitter.com/ and log in with the twitter account you want to use
  * Make sure you have a mobile phone number registered with your account to be able to proceed
  * Choose the option to `Create New App`
  * Fill in Application Details and Developer Agreement and `Create your Twitter application`
  * Choose the section "Keys and Access Tokens" to get your consumer key and consumer secret
  * Optional: Go to section "Permissions" and change the "Access" from `Read and Write` (by default) to `Read only`
  * Have your consumer key and secret by hand for one of the next steps

* Activate the feature within your local LEAP Web Application
  * If not already existing create a secrets-file in /config with the name secrets.yml (`/config/secrets.yml`)
  * Secrets-file should contain the following, make sure its in YAML: {"development"=> {"twitter"=>{"enabled"=>false, "twitter_handle"=>"", "bearer_token"=>"", "twitter_picture"=>nil}}, "test"=>{"twitter"=>{"enabled"=>false, "twitter_handle"=>"", "bearer_token"=>"", "twitter_picture"=>nil}}}
  * To have your bearer token created, run script in terminal being in the file of leap_web: `script/generate_bearer_token`
  * To have the script run properly you have to add before running: `--key your_consumerkey --secret your_consumersecret`
  * Add also `--projectroot your_projectroot --twitterhandle your_twitterhandle` as well to not have manually put the data in your secrets-file
  * The full command looks like this: `script/generate_bearer_token --key your_consumerkey --secret your_consumersecret --projectroot your_projectroot --twitterhandle your_twitterhandle`
  * If you didn't give all your information to the script, had a typo or want to change anything else, please do so by finding the secrets-file at `/config/secrets.yml`
  * Make sure that the correct twitterhandle and bearer-token is included

* Deactivate your bearer token
  * To deactivate your generated bearer token you can run script/invalidate_bearer_token
  * The full command looks like this: script/invalidate_bearer_token --key your_consumerkey --secret your_consumersecret --token your_bearer_token

### Default avatar image ###

This feature uses by default the twitter bird as avatar picture (Twitter_Logo_Blue.png). By using the Twitter trademarks in these Brand Guidelines, you agree to follow these Twitter Trademark Guidelines (the “Guidelines”) as well as our Terms of Service and all other Twitter rules and policies. Please find more details here: https://brand.twitter.com/.
