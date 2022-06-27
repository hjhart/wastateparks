# frozen_string_literal: true

def every_n_minutes(n)
  seconds = n

  loop do
    before = Time.now
    yield
    interval = seconds - (Time.now - before)
    sleep(interval) if interval.positive?
  end
end
