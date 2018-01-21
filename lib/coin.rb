require 'colorize'
require 'sinatra'
require 'yaml'
require_relative '../lib/block'
require_relative '../lib/client'
require_relative '../lib/helpers'
require_relative '../lib/pki'

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

$PEERS = ThreadSafe::Array.new([PORT])

PRIV_KEY, PUB_KEY = PKI.generate_key_pair

if PEER_PORT.nil?
  # you are the progenitor
  $BLOCKCHAIN = 
