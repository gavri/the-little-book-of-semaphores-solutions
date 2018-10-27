number_of_pairs = 3

leaders = followers = 0
mutex = Semaphore.new(1)
leaders_sem = Semaphore.new(0)
followers_sem = Semaphore.new(0)
rendezvous = Semaphore.new(0)

number_of_pairs.times do |i|
  async do
    mutex.acquire
    if followers > 0
      followers -= 1
      followers_sem.release
    else
      leaders += 1
      mutex.release
      leaders_sem.acquire
    end

    event "leader"
    rendezvous.acquire
    mutex.release
  end
end

number_of_pairs.times do |i|
  async do
    mutex.acquire
    if leaders > 0
      leaders -= 1
      leaders_sem.release
    else
      followers += 1
      mutex.release
      followers_sem.acquire
    end

    event "follower"
    rendezvous.release
  end
end

wait_on_test_threads

assert_history(s(
  c("leader", "follower"),
  c("leader", "follower"),
  c("leader", "follower")))
