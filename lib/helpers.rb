Thread.abort_on_exception = true # thread will abort on exception

def every(seconds)
  Thread.new do # creating a new thread
    loop do # will loop and sleep based upon the seconds argument variable
      sleep seconds
      yield
    end
  end
end

def render_state
  puts "-" * 40
  STATE.to_a.sort_by(&:first).each do |port, (movie, version_number)| # grabbing the state, turning into array, then sorting by port, and iterating over it
    puts "#{port.to_s.green} currently likes #{movie.yellow}"
  end
  puts "-" * 40
end

def update_state(update)
  update.each do |port, (movie, version_number)| #iterating over the each port unless nil
    next if port.nil?

    if [movie, version_number].any?(&:nil?) # if either the movie or version number is nil, the port in the STATE hash will be assigned nil
      STATE[port] ||= nil
    else
      STATE[port] = [STATE[port], [movie, version_number]].compact.max_by(&:last)
    end
  end
end
