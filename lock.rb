class Lock
  def initialize
    @semaphore = Semaphore.new(1)
  end

  def critical_section
    @semaphore.acquire
    yield
    @semaphore.release
  end
end
