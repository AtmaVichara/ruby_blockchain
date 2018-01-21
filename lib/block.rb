require 'colorize'
require 'digest'
require_relative '../lib/pki'
require_relative '../lib/transaction'
require_relative '../lib/blockchain'

class Block
  NUM_ZEROES = 5 # number of zeroes that trail hash to represent valid nonce

  attr_reader :transaction, :previous_block_hash, :block_hash

  def self.create_genesis_block(pub_key, priv_key)
    genesis_txn = Transaction.new(nil, pub_key, 500_000, priv_key) # with genesis block, creating first transaction for user
    Block.new(nil, genesis_txn) # creating block from genesis block
  end

  def initialize(previous_block, transaction)
    raise TypeError unless transaction.is_a?(Transaction) # edgecase to determine that a transaction is a class of Transaction
    @transaction = transaction
    @previous_block_hash = previous_block.block_hash if previous_block
    mine_block! # upon initialization, mine the blocks
  end

  def mine_block!
    @nonce = find_nonce
    @block_hash = hash(full_block(@nonce))
  end

  def valid?
    is_valid_nonce?(@nonce) && @transaction.is_valid_signature?
  end

  private

  def hash(contents) # function to hash the message
    Digest::SHA256.hexdigest(contents)
  end

  def find_nonce
    nonce = "HELP I'M TRAPPED IN A NONCE FACTORY"
    count = 0
    until is_valid_nonce?(nonce)
      print "." if count % 100_000 == 0
      nonce = nonce.next
      count += 1
    end
    puts count
    nonce
  end

  def full_block(nonce)
    [@transaction.to_s, @previous_block_hash, nonce].compact.join
  end

  def is_valid_nonce?(nonce) # checking to see if hash has trailing zeroes to indicate valid nonce
    hash(full_block(nonce)).start_with?("0" * NUM_ZEROES)
  end
end
