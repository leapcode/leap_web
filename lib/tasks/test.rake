namespace :test do

  namespace :engines do
    [:units, :functionals, :integration].each do |type|
      desc "Test engine #{type}"
      Rails::TestTask.new(type => "test:prepare") do |t|
        t.libs << "test"
        subdir = type.to_s.singularize
        t.pattern = "engines/*/test/#{subdir}/**/*_test.rb"
      end
      Rake::Task["test:#{type}"].enhance ["test:engines:#{type}"]
      Rake::Task["test"].enhance ["test:engines:#{type}"]
    end
  end

end
