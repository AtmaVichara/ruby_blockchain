require 'sinatra'
require 'colorize'
require 'active_support/time'
require_relative '../test/coin_test'
require_relative '../lib/helpers'
require_relative '../lib/gossip_helper'

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

STATE = ThreadSafe::Hash.new
update_state(PORT => nil)
update_state(PEER_PORT => nil)

MOVIES = File.readlines('./data/movies.txt').map(&:chomp)
@favorite_movie = MOVIES.sample
@version_number = 0 # this is a counter for determining new messages from old messages
puts "My favorite movie, now and forever, is #{@favorite_movie.green}"

update_state(PORT => [@favorite_movie, @version_number])

every(8.seconds) do
  puts "You know what screw #{@favorite_movie.yellow} it's so cliche"
  @favorite_movie = MOVIES.sample
  @version_number += 1
  update_state(PORT => [@favorite_movie, @version_number])
  puts "My new favorite movie is #{@favorite_movie.cyan}"
end

every(3.seconds) do
  STATE.dup.each_key do |peer_port|
    next if peer_port == PORT
    puts "Gossiping with #{peer_port}.... gossip gossip."
    begin
      their_state = Client.gossip(peer_port, JSON.dump(STATE)) # this will grab the state of a peer network, specifically the state of the PEER_PORT VARIABLE
      update_state(JSON.parse(their_state)) # this will then update the state so it shows their connected state
    rescue Faraday::ConnectionFailed => e # create a rescue just in case a client quits
      puts e
      STATE.delete(peer_port) # delete that peer_ports state if not found
    end
  end
  render_state # we then render the newly updated state.
end

# @param state
post '/gossip' do
  their_state = params['state'] # this is grabbing the post from the peer_port which is their state
  update_state(JSON.parse(their_state)) # we are updating the parsed peer_port state
  JSON.dump(STATE) # then we are dumping our state back in for them to see.
end
