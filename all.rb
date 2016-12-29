require_relative './sem'
class ExerciseContext
  def initialize(name)
    @name = name
    @statements = []
    @threads = []
  end

  def run
    test_src = File.read(name)
    instance_eval(test_src)
  end

  def statement name
    @statements << name
  end

  def assert_order(*expected)
    threads.each(&:join)
    raise "FAILED" unless expected == statements
  end

  private
  attr_reader :name, :threads, :statements

  def async(&block)
    @threads << Thread.new(&block)
  end
end

['3.1-signalling.rb'].each do |test_name|
  100.times do
    ExerciseContext.new(test_name).run
  end
end

