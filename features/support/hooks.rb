After '@tempfile' do
  if @tempfile
    @tempfile.close
    @tempfile.unlink
  end
end

Around '@config' do |scenario, block|
  old_config = APP_CONFIG.dup
  block.call
  APP_CONFIG.replace old_config
end

# store end of server log for failing scenarios
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

# clear all records we created
After do
  names = self.instance_variables.reject do |v|
    v.to_s.starts_with?('@_')
  end
  names.each do |name|
    record = self.instance_variable_get name
    if record.is_a?(CouchRest::Model::Base) && record.persisted?
      record.reload && record.destroy
    end
  end
end
