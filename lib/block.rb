require 'colorize'
require 'digest'

class Block
  attr_reader :msg

  def initialize(previous_block, msg)
    @msg = msg
    @previous_block = previous_block.block_hash
    mine_block!
  end

  def self.create_genesis_block(msg)
    Block.new(nil, msg)
  end

  def mine_block!

  end

  private

  NUM_ZEROES = 4 # number of zeroes that trail hash to represent valid nonce

  def hash(message) # function to hash the message
    Digest::SHA256.hexdigest(message)
  end

  def find_nonce(message)
    nonce = "HELP I'M TRAPPED IN A NONCE FACTORY"
    count = 0
    until is_valid_nonce?(nonce, message)
      nonce = nonce.next
      count += 1
    end
    puts count
    nonce
  end

  def is_valid_nonce?(nonce, message) # checking to see if hash has trailing zeroes to indicate valid nonce
    hash(message + nonce).start_with?("0" * NUM_ZEROES)
  end
  
end

class BlockChain

  attr_reader :blocks

  def initialize(msg)
    @blocks = Block.create_genesis_block(msg)
  end

  def add_to_chain(msg)
    @blocks << Block.new(@blocks.last, msg)
  end

  def valid?
  end

  def to_s
    @blocks.map(&:to_s).join("\n")
  end

end

b = BlockChain.new('----Genesis Block----')
b.add_to_chain('What it do')
b.add_to_chain('JOIN US')
b.add_to_chain('And another msg')
