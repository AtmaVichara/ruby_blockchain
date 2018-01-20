require 'sinatra'
require 'colorize'
require 'active_support/time'
require_relative '../test/coin_test'
require_relative '../lib/coin'

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

STATE = ThreadSafe::Hash.new
update_state(PORT => nil)
update_state(PEER_PORT => nil)

MOVIES = File.read('./data/movies.txt').map(&:chomp)
@favorite_movie
@version_number
puts "My favorite movie, now and forever, is #{favorite_movie.yellow}"

update_state(PORT => [@favorite_movie, @version_number])

every(8.seconds) do
end

every(3.seconds) do
end
