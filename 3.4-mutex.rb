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

assert_count(2)
