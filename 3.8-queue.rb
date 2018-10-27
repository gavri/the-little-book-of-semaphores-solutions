number_of_pairs = 3

leaders = followers = 0
mutex = Semaphore.new(1)
leaders_sem = Semaphore.new(0)
followers_sem = Semaphore.new(0)
rendezvous = Semaphore.new(0)

number_of_pairs.times do |i|
  async do
    mutex.wait
    if followers > 0
      followers -= 1
      followers_sem.signal
    else
      leaders += 1
      mutex.signal
      leaders_sem.wait
    end

    event "leader"
    rendezvous.wait
    mutex.signal
  end
end

number_of_pairs.times do |i|
  async do
    mutex.wait
    if leaders > 0
      leaders -= 1
      leaders_sem.signal
    else
      followers += 1
      mutex.signal
      followers_sem.wait
    end

    event "follower"
    rendezvous.signal
  end
end

wait_on_test_threads

assert_history(s(
  c("leader", "follower"),
  c("leader", "follower"),
  c("leader", "follower")))
