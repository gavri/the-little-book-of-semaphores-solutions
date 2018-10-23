sem = Semaphore.new(1)

async do
  sem.acquire
  inc_count
  sem.release
end

async do
  sem.acquire
  inc_count
  sem.release
end

wait_on_test_threads

assert_count(2)
