require 'base64'
require 'securerandom'

desc "Generate a batch of invite codes"
task :generate_invites, [:n, :u] => :environment do |task, args|

  codes = args.n
  codes = codes.to_i

  if args.u == nil
    max_uses = 1

  elsif
    max_uses = args.u
    max_uses = max_uses.to_i
  end

  def generate_invite
    Base64.encode64(SecureRandom.random_bytes).downcase.gsub(/[0oil1+_\/]/,'')[0..7].scan(/..../).join('-')
  end

  codes.times do |x|
    new_code = generate_invite

    x = InviteCode.new(:id => new_code)
    x.set_invite_code(new_code)
    x.max_uses = max_uses
    x.save
    puts x.invite_code
  end

end

