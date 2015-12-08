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

  def sign!(wallet)
    inputs.each do |i|
      i.signature = wallet.sign(signable_json)
    end
  end

  def to_json
    [inputs, outputs].to_json
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



coinbase_out = TransactionOutput.new(25, wallet.public_pem)

coinbase_txn = Transaction.new([], [coinbase_out])

puts coinbase_txn.to_json
