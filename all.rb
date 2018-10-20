require_relative './sem'

class ExerciseContext
  def initialize(name)
    @name = name
    @statements = []
    @count = 0
    @statements_mutex = Mutex.new
    @threads = []
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

  def statement name
    @statements_mutex.synchronize { @statements << name }
  end

  def assert_count(expected)
    threads.each(&:join)
    raise "FAILED" unless expected == @count
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

['3.1-signalling.rb', '3.3-rendezvous.rb', '3.4-mutex.rb'].each do |test_name|
  100.times do
    ExerciseContext.new(test_name).run
  end
end

