require "pry"
require "openssl"

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


wallet = Wallet.new
wallet.sign("pizza")
