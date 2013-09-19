# Extend the Time class so that we can offset the time that 'now'
# returns.  This should allow us to effectively time warp for functional
# tests that require limits per hour, what not.
class Time #:nodoc:
  class <<self
    attr_accessor :testing_offset

    def now_with_testing_offset
      now_without_testing_offset - testing_offset
    end
    alias_method_chain :now, :testing_offset
  end
end
Time.testing_offset = 0

module TimeTestHelper
  # Time warp to the specified time for the duration of the passed block
  def pretend_now_is(time)
    begin
      Time.testing_offset = Time.now - time
      yield
    ensure
      Time.testing_offset = 0
    end
  end
end

class ActiveSupport::TestCase
  include TimeTestHelper
end
