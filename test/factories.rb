Dir.glob(Rails.root.join('**','test','factories.rb')) do |factory_file|
  require factory_file
end
