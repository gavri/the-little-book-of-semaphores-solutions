require 'java'

java_import 'java.util.concurrent.Semaphore'

def rand_sleep
  sleep(rand(10) / 1000.0)
end

class Semaphore
  def signal
    release
    rand_sleep
  end

  def wait
    acquire
    rand_sleep
  end
end
