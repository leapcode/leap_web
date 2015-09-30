

desc "Generate a batch of invite codes"
task :generate_invites, [:n] => :environment do |task, args|

    codes = args.n
    codes = codes.to_i

    codes.times do |x|
    x = InviteCode.new
    x.save
    puts "#{x.invite_code} Code generated."

  end
end

