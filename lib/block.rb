require 'colorize'
require 'digest'

class Block
  NUM_ZEROES = 5 # number of zeroes that trail hash to represent valid nonce

  attr_reader :msg, :previous_block_hash, :block_hash

  def initialize(previous_block, msg)
    @msg = msg
    @previous_block_hash = previous_block.block_hash if previous_block
    mine_block!
  end

  def self.create_genesis_block(msg)
    Block.new(nil, msg)
  end

  def mine_block!
    @nonce = find_nonce
    @block_hash = hash(block_contents + @nonce)
  end

  def to_s
    [
      "",
      "-" * 80,
      "Previous hash: ".rjust(15) + @previous_block_hash.to_s.yellow,
      "Message: ".rjust(15) + @msg.green,
      "Nonce: ".rjust(15) + @nonce.red,
      "Own hash: ".rjust(15) + @block_hash.yellow,
      "-" * 80,
      "|".rjust(40),
      "|".rjust(40),
      "↓".rjust(40),
    ].join("\n")
  end

  private

  def hash(message) # function to hash the message
    Digest::SHA256.hexdigest(message)
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

  def block_contents
    [@previous_block_hash, @msg].compact.join
  end

  def is_valid_nonce?(nonce) # checking to see if hash has trailing zeroes to indicate valid nonce
    hash(block_contents + nonce).start_with?("0" * NUM_ZEROES)
  end
end

class BlockChain
  attr_reader :blocks

  def initialize(msg)
    @blocks = [Block.create_genesis_block(msg)]
  end

  def add_to_chain(msg)
    @blocks << Block.new(@blocks.last, msg)
    puts @blocks.last.to_s
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
