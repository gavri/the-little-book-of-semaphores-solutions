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

class ReadWriteLock
  def initialize
    @number_of_readers_mutex = Lock.new
    @number_of_readers = 0
    @room_empty = Semaphore.new(1)
  end

  def write
    @room_empty.wait
    yield
    @room_empty.signal
  end

  def read
    @number_of_readers_mutex.critical_section do
      @number_of_readers += 1
      @room_empty.wait if @number_of_readers == 1
    end
    result = yield
    @number_of_readers_mutex.critical_section do
      @number_of_readers -= 1
      @room_empty.signal if @number_of_readers == 0
    end
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
