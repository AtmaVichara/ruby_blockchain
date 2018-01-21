require 'colorize'
require 'digest'
require_relative 'pki'

class Block
  NUM_ZEROES = 5 # number of zeroes that trail hash to represent valid nonce

  attr_reader :transaction, :previous_block_hash, :block_hash

  def self.create_genesis_block(pub_key, priv_key)
    genesis_txn = Transaction.new(nil, pub_key, 500_000, priv_key) # with genesis block, creating first transaction for user
    Block.new(nil, genesis_txn) # creating block from genesis block
  end

  def initialize(previous_block, transaction)
    raise TypeError unless transaction.is_a?(Transacation) # edgecase to determine that a transaction is a class of Transaction
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

class Transaction

  attr_reader :from, :to, :amount

  def initialize(from, to, amount, priv_key)
    @from = from # is a public key
    @to = to     # is a public key
    @amount = amount
    @signature = PKI.sign(message, priv_key) # provide the signature to verify that you are who you are with your private key
  end

  def is_valid_signature?
    return true if genesis_transaction? # genesis_transaction is always true
    PKI.valid_signature?(message, @signature, from) # checking to see if key's match with signature's keys with message keys, and finally the from public key
  end

  def genesis_transaction?
    from.nil?
  end

  def message
    Digest::SHA256.hexdigest([@from, @to, @amount].join) # the message is the transaction data, and must be joined to keep data as small as possible for encryption since it is slow
  end

  def to_s
    message
  end

end

class BlockChain
  attr_reader :blocks

  def initialize(transaction)
    @blocks = []
    @blocks << Block.create_genesis_block(originator_pub_key, originator_priv_key)
  end

  def length
    @blocks.length
  end

  def add_to_chain(transaction)
    @blocks << Block.new(@blocks.last, transaction)
  end

  def valid?
    @blocks.all? { |block| block.is_a?(Block) } &&
      @blocks.all?(&:valid?) &&
      @blocks.each_cons(2).all? { |a, b| a.block_hash == b.previous_block_hash } &&
      all_spends_valid? # our blockchain is an application, so you cannot spend past zero, cannot go into red
  end

  def all_spends_valid?
    compute_balances do |balances, from, to|
      return false if balances.values_at(from, to).any? { |bal| bal < 0 }
    end
    true
  end

  def compute_balances
    genesis_txn = @blocks.first.transaction
    balances = { genesis_txn.to => genesis_txn.amount }
    balances.default = 0 # New people automatically have balance of 0
    @blocks.drop(1).each do |block| # ignore genesis block
      from = block.transaction.from
      to = block.transaction.to
      amount = block.transaction.amount
      balances[from] -= amount
      balances[to] += amount
      yield balances, from, to if block_given?
    end
    balances
  end

  def to_s
    @blocks.map(&:to_s).join("\n")
  end
end

b = BlockChain.new('----Genesis Block----')
b.add_to_chain('What it do')
b.add_to_chain('JOIN US')
b.add_to_chain('And another msg')
puts b.valid?
