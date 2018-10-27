require './lock'

def wait_for_event(i)
  rand_sleep
  ->{ event "event #{i}" }
end

class Buffer
  def initialize
    @events = []
    @semaphore = Semaphore.new(0)
    @lock = Lock.new
  end

  def add(event)
    @lock.critical_section do
      @events << event
    end
    @semaphore.signal
  end

  def get
    event = nil
    @semaphore.wait
    @lock.critical_section do
      event = @events.shift
    end
    event
  end
end

buffer = Buffer.new

number_of_events = 3

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

assert_history(s("event 0", "event 1", "event 2"))
