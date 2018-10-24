require_relative './sem'

require 'minitest'

require 'set'

class ExerciseContext < Minitest::Test
  def initialize(name)
    @name = name
    @events = []
    @count = 0
    @events_mutex = Mutex.new
    @threads = []
    @number_of_concurrent_threads = java.util.concurrent.atomic.AtomicInteger.new(0)
    @maximum_number_of_concurrent_threads = 0
    super(name)
  end

  def run
    test_src = File.read("#{name}.rb")
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
    assert_operator @maximum_number_of_concurrent_threads, :<=, max_allowed_concurrent
  end

  def event name
    @events_mutex.synchronize { @events << name }
  end

  def assert_count(expected)
    assert_equal expected, @count
  end

  def assert_order(*expected)
    assert_equal expected, events
  end

  def assert_order_is_one_of(*expected)
    assert_includes expected, events
  end

  def c(*expected)
    Set.new(expected)
  end

  def s(*expected)
    [*expected]
  end

  def assert_history(expected)
    length = expected.size
    rest_of_events = events.clone
    expected.each do |e|
      if e.is_a? Set
        size = e.size
        events_for_e = rest_of_events[0...size]
        rest_of_events = rest_of_events[size..-1]
        assert_equal e, Set.new(events_for_e)
      else
        assert_equal e, rest_of_events.shift
      end
    end
    assert_equal 0, rest_of_events.size
  end

  def wait_on_test_threads
    threads.each(&:join)
  end

  private
  attr_reader :name, :threads, :events

  def async(&block)
    @threads << Thread.new(&block)
  end
end

%w[3.1-signalling 3.3-rendezvous 3.4-mutex 3.5-multiplex 3.6-barrier].each do |test_name|
  100.times do
    ExerciseContext.new(test_name).run
  end
end

