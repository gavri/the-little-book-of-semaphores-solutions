sem = Semaphore.new(0)

async do
  statement :a1
  sem.signal
end

async do
  sem.wait
  statement :b1
end

assert_order(:a1, :b1)
