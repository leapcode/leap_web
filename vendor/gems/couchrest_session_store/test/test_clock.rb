class TestClock
  attr_accessor :now

  def initialize(tick = 60)
    @tick = tick
    @now = Time.now
  end

  def tick(seconds = nil)
    @now += seconds || @tick
  end
end
