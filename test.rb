require_relative './sem'
require 'minitest'
require 'set'
require 'optparse'

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
    instance_eval(File.read(name))
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

number_of_trials = 100
verbose = false

OptionParser.new do |opts|
  opts.on("-n", "--number_of_trials NUMBER_OF_TRIALS") do |n|
    number_of_trials = n.to_i
  end
  opts.on("-v", "--verbose") do |v|
    verbose = v
  end
end.parse!

test_names = []

if ARGV.empty?
  test_names = Dir.glob('[0-9]*.rb')
else
  test_names = ARGV
end

test_names.each do |test_name|
  puts test_name if verbose
  number_of_trials.times do |i|
    print "#{i}\r" if verbose
    ExerciseContext.new(test_name).run
  end
end
