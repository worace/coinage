require 'base64'
require 'openssl'

# =====  Generate keys  =====
private_key = OpenSSL::PKey::RSA.generate(1024)
public_key  = private_key.public_key
public_key_pem = public_key.to_pem # => "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDWZm/1WiN3oZG92aHycSkBsUlr\n8PBdQWEQBMkKjYEJB2lG/vBEoIxIzEdxkoCYPUeDtFMemYXX9R7rpq7gk2i0B92+\nAshocajBlIguAbBmMDWunn3aDYtF3Nm/pSQlukYRlSwjczLiJ9W8LkaD/M+J8hzS\n0KLML4YAnpxrF2e8fwIDAQAB\n-----END PUBLIC KEY-----\n"
private_key.to_pem                 # => "-----BEGIN RSA PRIVATE KEY-----\nMIICXwIBAAKBgQDWZm/1WiN3oZG92aHycSkBsUlr8PBdQWEQBMkKjYEJB2lG/vBE\noIxIzEdxkoCYPUeDtFMemYXX9R7rpq7gk2i0B92+AshocajBlIguAbBmMDWunn3a\nDYtF3Nm/pSQlukYRlSwjczLiJ9W8LkaD/M+J8hzS0KLML4YAnpxrF2e8fwIDAQAB\nAoGBAIXECcxBfelw49ZYh4MU+Sm2LAHtpHn6hY2R/sDXwo8YkaWa/9tBc+UjltuU\nNSlG6myQwF9SF8DCjZUnPOqe7e5nlxIk8VMeH0DMOmZc7gq0bVAQv1cXCI5K0KlD\nXivNrQoof7FttcqMqjy5OK29wGnz...

# =====  Writing / reading keys =====
require 'tmpdir'
Dir.mktmpdir do |dir|
  Dir.chdir dir do
    File.write('public_key.pem', public_key.to_pem)
    public_key_from_file = OpenSSL::PKey.read(
      File.read('public_key.pem') # => "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDWZm/1WiN3oZG92aHycSkBsUlr\n8PBdQWEQBMkKjYEJB2lG/vBEoIxIzEdxkoCYPUeDtFMemYXX9R7rpq7gk2i0B92+\nAshocajBlIguAbBmMDWunn3aDYtF3Nm/pSQlukYRlSwjczLiJ9W8LkaD/M+J8hzS\n0KLML4YAnpxrF2e8fwIDAQAB\n-----END PUBLIC KEY-----\n"
    )                             # => #<OpenSSL::PKey::RSA:0x007fe5e31187c8>

    public_key_from_file.to_pem == public_key.to_pem # => true
  end
end


# ===== Base64 is often used to turn binary data into ascii data =====
# I'll omit it from these examples
Base64.decode64(
  Base64.encode64(
    "\x00\x01\x02\x03\x04\x05"
  ) # => "AAECAwQF\n"
)   # => "\x00\x01\x02\x03\x04\x05"

# =====  Signing =====
signature = private_key.sign(
  OpenSSL::Digest::SHA256.new,
  public_key.to_pem  # => "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDWZm/1WiN3oZG92aHycSkBsUlr\n8PBdQWEQBMkKjYEJB2lG/vBEoIxIzEdxkoCYPUeDtFMemYXX9R7rpq7gk2i0B92+\nAshocajBlIguAbBmMDWunn3aDYtF3Nm/pSQlukYRlSwjczLiJ9W8LkaD/M+J8hzS\n0KLML4YAnpxrF2e8fwIDAQAB\n-----END PUBLIC KEY-----\n"
)                    # => "\xD0\xD1\xB8;\xCF\x8E\xD2\x93u\x88q\xDD!\xE1\x1FR\x8E'\xAB\xBD\xA9D\xD5\xDE\xFD\x1C\xE9\xD9Pfj\xD1\x8CA\r\x05\x97\xE6\xF3d\x91T\xD0\xF0/|0\xA4A,\xD2]\x04?\xD7\x00K.I\xDC\xD3\x9C#\xEC\x01\x80\xC00-\x03\xA9\xD3\xBA\x92\xEC\xF4q\x97\b\xD9\x91m\ng\xD7L\x9B\xD5\xBCb\x98\xA9Q\e\x0F\x18\xAAz;h\xBF\x80\xB9\xA3\xF7\xA0\x19\x00\xC9NdJ\xDCDE\xF5\xEB-u>1\x9F\"\xF2XDV\xD9"

# =====  Verifying  =====
OpenSSL::PKey.read(public_key_pem).verify(
    OpenSSL::Digest::SHA256.new,
    signature,       # => "\xD0\xD1\xB8;\xCF\x8E\xD2\x93u\x88q\xDD!\xE1\x1FR\x8E'\xAB\xBD\xA9D\xD5\xDE\xFD\x1C\xE9\xD9Pfj\xD1\x8CA\r\x05\x97\xE6\xF3d\x91T\xD0\xF0/|0\xA4A,\xD2]\x04?\xD7\x00K.I\xDC\xD3\x9C#\xEC\x01\x80\xC00-\x03\xA9\xD3\xBA\x92\xEC\xF4q\x97\b\xD9\x91m\ng\xD7L\x9B\xD5\xBCb\x98\xA9Q\e\x0F\x18\xAAz;h\xBF\x80\xB9\xA3\xF7\xA0\x19\x00\xC9NdJ\xDCDE\xF5\xEB-u>1\x9F\"\xF2XDV\xD9"
    public_key_pem   # => "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDWZm/1WiN3oZG92aHycSkBsUlr\n8PBdQWEQBMkKjYEJB2lG/vBEoIxIzEdxkoCYPUeDtFMemYXX9R7rpq7gk2i0B92+\nAshocajBlIguAbBmMDWunn3aDYtF3Nm/pSQlukYRlSwjczLiJ9W8LkaD/M+J8hzS\n0KLML4YAnpxrF2e8fwIDAQAB\n-----END PUBLIC KEY-----\n"
  )                  # => true

# =====  Encrypting / Decrypting =====
# Public key encrypts for private key
private_key.private_decrypt(
  public_key.public_encrypt("hello")  # => "Q\xD9t\x9B\xB2\xA2n\xB2U\xAA\xEB\xA7\xAF\x9A\x98\xD2s\xA8\xF93\xD4MG\xD1\xD4l+\x8Dv\xFC6+\xAB\vXU\b\e.\xB6D\xC0w+4\x04\xAB\xFAH\"\xC5\xEA\xB7\x15y\xAC\xB4\xDFGM\xBA\x92,\v\xED!\xBB\xA4\x18\xC8\xB4\xC0^\xAA&\x19M%\xD2c\x17a\xE8T\xA7)\x93\fn\xC3\xBF\xEE\xBB\xDD\xAEq\x9F9U\r_\xFEk\xB2\r\x13\x9BS\xB8--s\x80\xD2\xC4\x7FVF\xCC}\x7F\xB6l\xD2\xE5B\xBB\x1D"
)                                     # => "hello"

# private key encrypts for public key
public_key.public_decrypt(
  private_key.private_encrypt('Goodbye') # => "\xA8x$G\x92<2\a\xA3j\x9E\xED\xA4F$,\xE6b|\x836k\x04\xA7V\xB0\xF1:\x93\xF7P\t\xFDfc\xF3+\x98\x04oU\xA79(\xD3r\x86\xBFV\xA7W\x18\xAD'\a\xD3\xE5]\b0\b\x01>\x9F\a\x19yqT\x11\x8C$.H7\xBDM)d\x13\xE5\xAA\xFDE@\x84j\x16\xB7\xB2\xE9\x9BY\xC9\xD3C\x81\xB2\x9B\x02\xF6e\xDE\x86-\xD4\bs\xC7X\xBE\xC3\xB5\xD2\xA1\xFD\xEA\x8E\x8B\xD6p\nC\x88{3\xF3\x85"
)                                        # => "Goodbye"

