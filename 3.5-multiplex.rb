max_allowed_concurrent = 5

sem = Semaphore.new(max_allowed_concurrent)

number_of_threads = 10

number_of_threads.times do
  async do
    sem.acquire
    max_concurrent
    sem.release
  end
end

assert_max_concurrent(max_allowed_concurrent)
