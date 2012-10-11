namespace :test do

  Rails::SubTestTask.new(:units => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = '*/test/unit/**/*_test.rb'
  end

  Rails::SubTestTask.new(:functionals => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = '*/test/functional/**/*_test.rb'
  end

  Rails::SubTestTask.new(:integration => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = '*/test/integration/**/*_test.rb'
  end

end
