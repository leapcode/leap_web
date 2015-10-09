require 'base64'
require 'securerandom'

desc "Generate a batch of invite codes"
task :generate_invites, [:n, :u] => :environment do |task, args|

  codes = args.n
  codes = codes.to_i

  if args.u != nil
    max_uses = args.u
  end

  def generate_invite
    Base64.encode64(SecureRandom.random_bytes).downcase.gsub(/[0oil1+_\/]/,'')[0..7].scan(/..../).join('-')
  end

  codes.times do |x|
    x = InviteCode.new
    x.max_uses = max_uses
    x.save
    puts x.invite_code
  end

end

