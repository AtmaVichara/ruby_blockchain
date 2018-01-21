require 'digest'

Thread.abort_on_exception = true # thread will abort on exception

def every(seconds)
  Thread.new do # creating a new thread
    loop do # will loop and sleep based upon the seconds argument variable
      sleep seconds
      yield
    end
  end
end

HUMAN_READABLE_NAMES = File.readlines("./data/names.txt").map(&:chomp)

def human_readable_names(pub_key)
  pk_hash = Digest::SHA256.hexdigest(pub_key).to_i(16)
  HUMAN_READABLE_NAMES[pk_hash % HUMAN_READABLE_NAMES.length]
end

def readable_balances
  returns "" if $BLOCKCHAIN.nil?
  $BLOCKCHAIN.compute_balances.map do |pub_key, balance|
    "#{human_readable_names(pub_key).yellow} currently has a balance of #{balance}"
  end.join("\n")
end

def render_state
  system 'clear'
  puts Time.now.to_s.split[1].light_blue
  puts "My blockchain: " + $BLOCKCHAIN.to_s
  puts "Blockchain length: " + ($BLOCKCHAIN || []).length.to_s
  puts "PORT: #{PORT}"
  puts "My name: " + human_readable_names(PUB_KEY).red
  puts "My peers: " + $PEERS.sort.join(', ').to_s.green
  puts readable_balances
end

def gossip_with_peer(port)
  gossip_response = Client.gossip(port, YAML.dump($PEERS), YAML.dump($BLOCKCHAIN))
  parsed_response = YAML.load(gossip_response)
  their_peers = parsed_response['peers']
  their_blockchain = parsed_response['blockchain']

  update_peers(their_peers)
  update_blockchain(their_blockchain)
rescue Faraday::ConnectionFailed => e # keep connection and server up if a peer disconnects
  $PEERS.delete(port)
end

def update_blockchain(their_blockchain)
  return if their_blockchain.nil? # if you don't have a blockchian screw you
  return if $BLOCKCHAIN && their_blockchain.length <= $BLOCKCHAIN.length # fork choice rule: if their blockchain is shorter than mine, then it is an older version of the blockchain, and possibly corrupted
  return unless their_blockchain.valid? # must check to see that their blockchain is valid. Never trust that they are valid, until you are able to validate their blockchain.

  $BLOCKCHAIN = their_blockchain # if all parameters are met, then their blockchain is your blockchian.
end

def update_peers(their_peers)
  $PEERS = ($PEERS + their_peers).uniq #updating the peers of peers by making my peers equal to theirs plus mine, then uniqed
end
