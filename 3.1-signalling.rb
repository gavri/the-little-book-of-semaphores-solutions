sem = Semaphore.new(0)

async do
  event :a1
  sem.signal
end

async do
  sem.wait
  event :b1
end

wait_on_test_threads

assert_order(:a1, :b1)
