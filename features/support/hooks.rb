After '@tempfile' do
  if @tempfile
    @tempfile.close
    @tempfile.unlink
  end
end

After do |scenario|
  if scenario.failed?
    logfile_path = Rails.root + 'tmp'
    logfile_path += "#{scenario.title.gsub(/\s/, '_')}.log"
    File.open(logfile_path, 'w') do |test_log|
      test_log.puts scenario.title
      test_log.puts "========================="
      test_log.puts `tail log/test.log -n 200`
    end
  end
end
