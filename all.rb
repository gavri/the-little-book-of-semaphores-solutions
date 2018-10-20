require_relative './sem'

class ExerciseContext
  def initialize(name)
    @name = name
    @statements = []
    @count = 0
    @statements_mutex = Mutex.new
    @threads = []
    @number_of_concurrent_threads = java.util.concurrent.atomic.AtomicInteger.new(0)
    @maximum_number_of_concurrent_threads = 0
  end

  def run
    test_src = File.read(name)
    instance_eval(test_src)
  end

  def inc_count
    new_count = @count + 1
    rand_sleep
    @count = new_count
  end

  def max_concurrent
    rand_sleep
    number_of_concurrent_threads = @number_of_concurrent_threads.increment_and_get
    @maximum_number_of_concurrent_threads = [@maximum_number_of_concurrent_threads, number_of_concurrent_threads].max
    @number_of_concurrent_threads.decrement_and_get
    rand_sleep
  end

  def assert_max_concurrent(max_allowed_concurrent)
    threads.each(&:join)
    raise "FAILED" unless @maximum_number_of_concurrent_threads <= max_allowed_concurrent
  end

  def statement name
    @statements_mutex.synchronize { @statements << name }
  end

  def assert_count(expected)
    threads.each(&:join)
    raise "expected: #{expected}, actual: #{@count}" unless expected == @count
  end

  def assert_order(*expected)
    threads.each(&:join)
    raise "FAILED" unless expected == statements
  end

  def assert_order_is_one_of(*expected)
    threads.each(&:join)
    raise "#{expected.inspect}:#{statements.inspect}" unless expected.include?(statements)
  end

  private
  attr_reader :name, :threads, :statements

  def async(&block)
    @threads << Thread.new(&block)
  end
end

['3.1-signalling.rb', '3.3-rendezvous.rb', '3.4-mutex.rb', '3.5-multiplex.rb'].each do |test_name|
  100.times do
    ExerciseContext.new(test_name).run
  end
end

