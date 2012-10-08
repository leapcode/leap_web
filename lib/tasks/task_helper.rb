require File.expand_path('../../../lib/leap_web/version', __FILE__)

module TaskHelper

  ENGINES = %w(core users certs help)

  def putsys(cmd)
    puts cmd
    system cmd
  end

  def each_gem
    ENGINES.each do |gem_name|
      puts "########################### #{gem_name} #########################"
      yield gem_name
    end
  end
end

