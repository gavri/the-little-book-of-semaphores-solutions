require './lock'
require './atomic-counter'

class ReusableBarrierWithPreloadedTurnstiles
  def initialize(number_of_threads)
    @number_of_threads = number_of_threads
    @number_of_threads_at_barrier = AtomicCounter.new(0)
    @first_turnstile = Semaphore.new(0)
    @second_turnstile = Semaphore.new(0)
    @lock = Lock.new
  end

  def await
    @lock.critical_section do
      @number_of_threads_at_barrier.increment
      if @number_of_threads_at_barrier.count_is_at?(@number_of_threads)
        @first_turnstile.signal(@number_of_threads)
      end
    end
    @first_turnstile.wait
    @lock.critical_section do
      @number_of_threads_at_barrier.decrement
      if @number_of_threads_at_barrier.count_is_at?(0)
        @second_turnstile.signal(@number_of_threads)
      end
    end
    @second_turnstile.wait
  end
end

number_of_threads = 3
number_of_rounds = 3

barrier = ReusableBarrierWithPreloadedTurnstiles.new(number_of_threads)

number_of_threads.times do |thread_number|
  async do
    number_of_rounds.times do |round_number|
      event "iteration: #{round_number} thread: #{thread_number}"
      barrier.await
    end
  end
end

wait_on_test_threads

assert_history(s(
  c("iteration: 0 thread: 0", "iteration: 0 thread: 1", "iteration: 0 thread: 2"),
  c("iteration: 1 thread: 0", "iteration: 1 thread: 1", "iteration: 1 thread: 2"),
  c("iteration: 2 thread: 0", "iteration: 2 thread: 1", "iteration: 2 thread: 2")
))
