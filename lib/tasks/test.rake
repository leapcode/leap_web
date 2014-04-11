namespace :test do

  [:units, :functionals, :integration].each do |type|
    Rails::SubTestTask.new(type => "test:prepare") do |t|
      t.libs << "test"
      subdir = type.to_s.singularize
      t.pattern = "engines/*/test/#{subdir}/**/*_test.rb"
    end
  end

end
