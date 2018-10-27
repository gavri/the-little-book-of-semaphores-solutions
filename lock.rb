class Lock
  def initialize
    @semaphore = Semaphore.new(1)
  end

  def critical_section
    @semaphore.wait
    yield
    @semaphore.signal
  end
end
