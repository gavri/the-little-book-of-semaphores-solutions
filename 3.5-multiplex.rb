max_allowed_concurrent = 5

sem = Semaphore.new(max_allowed_concurrent)

number_of_threads = 10

number_of_threads.times do
  async do
    sem.wait
    max_concurrent
    sem.signal
  end
end

wait_on_test_threads

assert_max_concurrent(max_allowed_concurrent)
