class AtomicIncrementer
  def initialize(n)
    @n = n
    @mutex = Semaphore.new(1)
  end

  def increment
    @mutex.acquire
    @n += 1
    @mutex.release
  end

  def count_is_at?(n)
    @n == n
  end
end

turnstile = Semaphore.new(0)

number_of_threads = 3
number_of_threads_at_barrier = AtomicIncrementer.new(0)

number_of_threads.times do |i|
  async do
    event "before barrier: #{i}"
    number_of_threads_at_barrier.increment
    turnstile.release if number_of_threads_at_barrier.count_is_at?(number_of_threads)
    turnstile.acquire
    turnstile.release
    event "after barrier: #{i}"
  end
end

wait_on_test_threads

assert_history(s(
  c("before barrier: 0", "before barrier: 1", "before barrier: 2"),
  c("after barrier: 0", "after barrier: 1", "after barrier: 2")
))
