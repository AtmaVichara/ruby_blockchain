require 'digest'

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
