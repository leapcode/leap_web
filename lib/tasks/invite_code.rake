

desc "Generate a batch of invite codes"
task :generate_invites, [:n, :u] => :environment do |task, args|

  codes = args.n
  codes = codes.to_i

  if args.u != nil
    max_uses = args.u
  end

  codes.times do |x|
    x = InviteCode.new
    x.max_uses = max_uses
    x.save
    puts x.invite_code
  end

end

