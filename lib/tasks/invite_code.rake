

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

  codes.times do |x|
    x = InviteCode.new
    x.max_uses = max_uses
    x.save
    puts "#{x.invite_code} Code generated with #{x.max_uses} uses."
  end

end

