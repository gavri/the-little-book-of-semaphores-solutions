a_sem = Semaphore.new(0)
b_sem = Semaphore.new(0)

async do
  event :a1
  a_sem.signal
  b_sem.wait
  event :a2
end

async do
  event :b1
  b_sem.signal
  a_sem.wait
  event :b2
end

wait_on_test_threads

assert_order_is_one_of(
  [:a1, :b1, :a2, :b2],
  [:b1, :a1, :a2, :b2],
  [:a1, :b1, :b2, :a2],
  [:b1, :a1, :b2, :a2]
)
