require './lock'

def wait_for_event(i)
  rand_sleep
  ->{ event "event #{i}" }
end

class Buffer
  def initialize(size)
    @size = size
    @events = []
    @data_availability_semaphore = Semaphore.new(0)
    @write_limit_semaphore = Semaphore.new(size)
    @lock = Lock.new
    @max_used = 0
  end

  def add(event)
    @write_limit_semaphore.wait
    @lock.critical_section do
      @events << event
      @max_used = [@events.size, @max_used].max
    end
    @data_availability_semaphore.signal
  end

  def get
    event = nil
    @data_availability_semaphore.wait
    @lock.critical_section do
      event = @events.shift
    end
    @write_limit_semaphore.signal
    event
  end

  attr_reader :max_used
end

buffer_size = 4
buffer = Buffer.new(buffer_size)

number_of_events = 10

async do
  number_of_events.times do |i|
    event = wait_for_event(i)
    buffer.add(event)
  end
end

async do
  number_of_events.times do
    event = buffer.get
    event.call
  end
end

wait_on_test_threads

assert_operator buffer.max_used, :<=, buffer_size

assert_history(s("event 0", "event 1", "event 2", "event 3", "event 4", "event 5", "event 6", "event 7", "event 8", "event 9"))
