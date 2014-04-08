# desc "Explaining what the task does"
# task :leap_web_users do
#   # Task goes here
# end

# recommended that for our setup, we should have this triggered from a cron job in puppet rather than using whenever gem
desc "Send one month warning messages"
task :leap_web_users do
  User.send_one_month_warnings
end
