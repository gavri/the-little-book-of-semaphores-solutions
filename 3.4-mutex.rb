sem = Semaphore.new(1)

async do
  sem.wait
  inc_count
  sem.signal
end

async do
  sem.wait
  inc_count
  sem.signal
end

wait_on_test_threads

assert_count(2)
