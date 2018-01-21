require 'colorize'
require 'sinatra'
require 'yaml'
require_relative '../lib/block'
require_relative '../lib/client'
require_relative '../lib/helpers'
require_relative '../lib/pki'

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

$PEERS = ThreadSafe::Array.new([PORT]) # peers are not apart of state. Peers are apart of the network, not the blockchain.
                                       # Peers instead use pub_key to communicate with blockchain

PRIV_KEY, PUB_KEY = PKI.generate_key_pair

if PEER_PORT.nil?
  # you are the progenitor
  $BLOCKCHAIN = BlockChain.new(PUB_KEY, PRIV_KEY) # creating first chain in the blockchain
else
  # you are joining the network
  $PEERS << PEER_PORT # peer port is shuttled into the thread, which is an array of other peers
end

every(3.seconds) do
  $PEERS.dup.each do |port|
    next if port == PORT # skipping over our own port

    puts "Gossiping between peers in the blockchain."
    puts "PEERS: #{port.to_s.cyan}"
    gossip_with_peer(port)
  end
  render_state
end

# @params blockchain
# @params peers

post '/gossip' do # recieve peers gossip, and return your gossip with their gossip to other peers
  their_blockchain = YAML.load(params['blockchain'])
  their_peers = YAML.load(params['peers'])
  update_blockchain(their_blockchain)
  update_peers(their_peers)
  YAML.dump('peers' => $PEERS, 'blockchain' = $BLOCKCHAIN)
end

# @params to (port_number)
# @params amount
post '/send_money' do
  to = Client.get_pub_key(params['to'])
  amount = params['amount'].to_i
  $BLOCKCHAIN.add_to_chain(Transaction.new(PUB_KEY, to, amount, PRIV_KEY))
  'OK BLOCK IS MINED!!!! XD'.green
end

get '/pub_key' do
  PUB_KEY
end
