require './lock'

number_of_writes = 4
number_of_reads = 10

class NonatomicStore
  def initialize
    @data = {a: 0, b: 0}
  end

  def inc
    @data[:a] += 1
    rand_sleep
    @data[:b] += 1
  end

  def read
    @data.clone
  end
end

class LightSwitch
  def initialize(binary_semaphore)
    @count = 0
    @count_mutex = Lock.new
    @binary_semaphore = binary_semaphore
  end

  def enter
    @count_mutex.critical_section do
      @count += 1
      @binary_semaphore.wait if @count == 1
    end
  end

  def leave
    @count_mutex.critical_section do
      @count -= 1
      @binary_semaphore.signal if @count == 0
    end
  end
end

class ReadWriteLock
  def initialize
    @room_empty = Semaphore.new(1)
    @light_switch = LightSwitch.new(@room_empty)
  end

  def write
    @room_empty.wait
    yield
    @room_empty.signal
  end

  def read
    @light_switch.enter
    result = yield
    @light_switch.leave
    result
  end
end

counter = NonatomicStore.new
read_write_lock = ReadWriteLock.new

number_of_writes.times do
  async do
    read_write_lock.write { counter.inc }
  end
end

number_of_reads.times do
  async do
    read_write_lock.read { event counter.read }
  end
end

wait_on_test_threads

assert_equal({a: 4, b: 4}, counter.read)
assert_equal 10, events.size
events.each do |event|
  assert_equal event[:a], event[:b]
end
