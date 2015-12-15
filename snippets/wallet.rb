require "pry"
require "openssl"
require "base64"
require "json"

class Wallet
  attr_reader :key_pair

  def initialize(wallet_path = "#{ENV["HOME"]}/.wallet.pem")
    @key_pair = load_or_generate_wallet(wallet_path)
  end

  def load_or_generate_wallet(path)
    if File.exists?(path)
      OpenSSL::PKey.read(File.read(path))
    else
      key_pair = OpenSSL::PKey::RSA.generate(2048)
      File.write(path, key_pair.to_pem)
      key_pair
    end
  end

  def public_key
    key_pair.public_key
  end

  def sign(string)
    Base64.encode64(key_pair.sign(OpenSSL::Digest::SHA256.new, string))
  end

  def public_pem
    public_key.to_pem
  end
end

class Transaction < Struct.new(:inputs, :outputs, :wallet)

  # Transaction.coinbase("my-key")

  def self.coinbase(pub_key, amount = 25)
    # generate txn that gives 25 coins to that key
    # with no inputs
    self.new([], [TransactionOutput.new(amount, pub_key)])
  end

  def sign!(wallet)
    inputs.each do |i|
      i.signature = wallet.sign(signable_json)
    end
  end

  def to_json
    [inputs, outputs].to_json
  end

  def hash
    Digest::SHA256.hexdigest(to_json)
  end

  def signable_json
    # [[
    #    [input1 origin hash, input 1 origin index],
    #    [input2 origin hash, input 2 origin index]
    #  ],
    #  [
    #    [output 1 amount, output 1 address],
    #    [output 2 amount, output 2 address]
    #  ]
    # ]

    [inputs.map(&:signable), outputs].to_json
  end

end

class TransactionInput < Struct.new(:source_hash, :source_index, :signature)
  def to_json(options = {})
    [source_hash, source_index, signature].to_json(options)
  end

  def signable
    [source_hash, source_index]
  end
end

class TransactionOutput < Struct.new(:amount, :address)
  def to_json(options={})
    [amount, address].to_json(options)
  end
end

wallet = Wallet.new
input = TransactionInput.new("source hash", "source index")
output = TransactionOutput.new("output amount", wallet.public_pem)

transaction = Transaction.new([input], [output])
puts transaction.to_json
transaction.sign!(wallet)
puts transaction.to_json

coinbase_txn = Transaction.coinbase(wallet.public_pem)

puts coinbase_txn.to_json

# block contains multiple transactions

class Block
  attr_reader :parent_hash, :transactions, :target, :nonce, :timestamp

  def default_target
    # get desired block-generation timeframe
    # (1 minute)
    # look at last N blocks
    # see what the average freq spacing
    # was of those blocks

    # get ratio of that average spacing
    # vs. desired freq

    # 155500 - 155490 -> 10
    # 155490 - 155470 -> 20
    # 155470 - 155430 -> 30
    # 155430 - 0      -> 155430
    # multiply target of last block
    # by this ratio
    "00000" + "F" * 59
  end

  def initialize(transactions, parent_hash, target = default_target)
    @transactions = transactions
    @parent_hash = parent_hash
    @target = target
    @timestamp = Time.now.to_i
    @nonce = 0
  end

  def transactions_hash
    tx_hashes = transactions.map(&:hash).join
    Digest::SHA256.hexdigest(tx_hashes)
  end

  def header_values
    [parent_hash,
     transactions_hash,
     timestamp,
     target,
     nonce].join
  end

  def hash
    Digest::SHA256.hexdigest(header_values)
  end

  def block_hash_below_target?
    hash.to_i(16) < target.to_i(16)
  end

  def valid?
    block_hash_below_target?
  end

  def increment_nonce!
    @nonce += 1
  end

  def mine!
    until valid?
      increment_nonce!
    end
    self
  end
end

block = Block.new([coinbase_txn], "0" * 64)

