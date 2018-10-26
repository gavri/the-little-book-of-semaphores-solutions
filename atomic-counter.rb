require './lock'

class AtomicCounter
  def initialize(n)
    @n = n
    @lock = Lock.new
  end

  def increment
    @lock.critical_section { @n += 1 }
  end

  def decrement
    @lock.critical_section { @n -= 1 }
  end

  def count_is_at?(n)
    @n == n
  end
end

