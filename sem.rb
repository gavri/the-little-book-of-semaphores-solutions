require 'java'

java_import 'java.util.concurrent.Semaphore'

def rand_sleep
  sleep(rand(10) / 1000.0)
end

class Semaphore
  def signal(n = 1)
    release(n)
  end

  def wait
    acquire
  end
end
