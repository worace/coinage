# Intro to Public Key Cryptography

In this post, we'll look at the basics of working with Public/Private Key Cryptography from a developer's perspective. We'll talk a bit about the history and advantages of public-key encryption without going too deep into the mathematic ideas that make it all work (perhaps I'll cover this in a future post after doing more research so I can understand it myself...)

## History: Cryptography is Hard

The term Cryptography comes from Greek words for "secret writing," and it seems that people have been trying to write secretly for pretty much as long as they've been trying to write at all. At its core cryptography deals with hiding the contents of a message so it can only be read by those who we choose and over the centuries, cryptographers developed a lot of techniques for doing this. Meanwhile, their adversaries, known as _cryptanalysts_, have been constantly trying to undo everything the cryptographers come up with.

![Top Secret][spy-vs-spy]

There's a lot of interesting stuff to read about in the history of cryptography, but one over-arching trend we can see is a grudging march toward reliance on randomness. The problem, it turns out, is that human language is very _un_-random. Each language has very distinct observable patterns -- in English, for example, we tend to use a lot of vowels, especially "a" and "e" -- and code-breakers are able to use these tendencies to crack encrypted messages. This was especially easy given our tendency to use predictable or formulaic encryption schemes -- rotate letters of the alphabet according to the offsets of a sweetheart's name, a birthdate, etc.

Over time, cryptographers had to accept that the only way to reliably encrypt something is to use true randomness to thoroughly scramble a message. This is best embodied in one of the few encryption schemes believed to be truly unbreakable -- the [One-Time Pad][otp].

__Some one-time pads were very small:__

![One-Time Pad][otp]

By using random keys, cryptographers were able to escape the inherent predictability of human language. But even this approach comes with some cumbersome restrictions. First, you can't re-use the key. As soon as the randomness of the original key starts to be repeated, patterns emerge, and we're right back where we started (hence _one_-time pad). Note that this includes encrypting messages longer than the key itself, since we would have to re-use key digits. Finally, if we want to reliably use this scheme, we need to distribute and keep track of a *ton* of keys!

![Keys][keys]

And this lands us in a bit of a catch-22. We can't share quality random keys securely if we don't have a good crypto scheme. And we can't have a good crypto scheme of we can't share keys securely... If designing good cryptosystems is the first problem of cryptography, then figuring out reasonable key exchange systems rapidly became the second. Especially from a pragmatic perspective, this often became the biggest question when implementing a new cryptosystem -- the algorithm might be exquisite, but if the key exchange can't be worked out then it's no good to anyone.

## Cutting the Gordian Knot with Public Key Cryptography

> "If you would keep your secret from an enemy,
> tell it not to a friend." - Ben Franklin

This all changed in the 1970's with the discovery of Public-Key encryption. Up to this point, cryptosystems had been based on a _symmetric_ approach to encryption and decryption -- that is, the same key is used both for encrypting and for decrypting the message. This imposes the key-exchange difficulty we just looked at since the sender and receiver need to figure out some means of sharing the key without also letting it fall into enemy hands.

The great innovation of PK Crypto was to move to an _asymmetric_ encryption model where encryption and decryption are done using _separate_ keys. The keys come in pairs, and the pairs are mathematically linked (more on that in a second) so that the encryption-key of the pair can be used to encrypt a message which only its associated decryption key can decrypt.

Instead of attempting to share the same keys around all the time and keep them out of the eyes of eavesdroppers, we can simply each have our own _pair_. If you want to send me a message, I can send you my _encryption_ key. You use that key to encrypt your message, send it to me, and I can then use my corresponding _decryption_ key to read it. The real beauty of this system is that the encryption key is useless for _de_-crypting, so I don't have to be particularly careful about how I distribute it. In fact, there's no harm in shouting it from the roof-top or posting it on my website. Hence we tend to refer to the encryption key as our **Public Key**.

The decryption key, on the other hand, is still precious. Anyone who has it can read all messages encrypted with the corresponding encryption (Public) key. It obviously needs to be kept secret, but the problem is greatly simplified now since we no longer need to share it with anyone. Thus we refer to this key as our **Private Key**.

## So how does it really work?

The short answer is: Math. The general idea of an asymetric encryption system had been around for a while, but it took until the 1970's for the right people to figure out a viable system for making it work. Specifically [Whitfield Diffie](https://en.wikipedia.org/wiki/Whitfield_Diffie) and [Martin Hellman](https://en.wikipedia.org/wiki/Martin_Hellman) developed a system that relies on multiplying large prime numbers to encrypt messages. Cracking the encryption would require an attacker to find the prime factors of a very large number, something which we don't currently have an efficient way to do. This is wildly simplified explanation, but for now we can get by without fully understanding the details.

A few years later a group of MIT students developed a more generalized system for putting Diffie and Hellman's technique into practice. This became known as RSA encryption, after the students Rivest, Shamir, and Adelson, and the rest was history.

__Sidenote:__ Interestingly, the same approach was actually independently developed a few years earlier by a group of cryptographers working for the British Government, but their research was classified so the world didn't find out about it until the late 90's.

## PK Crypto for Lowly Code Monkeys

So how do we actually use it? Fortunately for us, most of the hard stuff has already been worked out. Not only are the algorithms thoroughly refined and vetted at this point, but most contemporary programming languages include handy library support for common crypto algorithms.

### RSA

In Ruby, for example, the OpenSSL library includes support for the popular RSA algorithm.

Let's look at a few common operations we might like to do with RSA:

* Generate a private key
* Retrieve the public key associated with the private key
* Serialize the public key (so that we could share it with someone)
* Encrypt a message using the public key
* Decrypt a message using the private key

We can use it to generate a private key:

```ruby
require 'openssl'
private_key = OpenSSL::PKey::RSA.generate(1024) # 1024 is the bit-length of the key; longer keys are more secure but also slower
public_key  = private_key.public_key
public_key.to_pem # serialize key in PEM format
public_key.to_der # serialize key in DER format

plaintext = "keep this secret"
ciphertext = public_key.public_encrypt(plaintext)
private_key.private_decrypt(ciphertext) == plaintext # => true
```

### But wait, there's more! -- Signature Verification

Using a public key to encrypt a message that can only be decrypted with the corresponding private key is pretty neat, but what about going the other direction? It turns out that the mathematical relationship between public and private keys also lets us do encryption/decryption in the reverse direction. Using the private key, we can encrypt a message that can be only be decrypted using the corresponding public key.

This isn't particularly useful for actually keeping things secret, since your public key is, well, public. But it does give us an effective way of proving identity. Since encryption via Private Key can only be reversed by the corresponding public key, and the private key is kept secret, we can safely assume that anyone who is able to produce a message that can be validly decrypted with a given Public Key must have access to the corresponding Private Key.

Since this technique establishes identity, we refer to it as **signing** and **verifying**. A user **signs** a message using their Private Key and anyone can use that person's Public Key to **verify** the identity of the signer.

### Signing in Code

We can do this in Ruby as well:

```ruby
require 'openssl'
private_key = OpenSSL::PKey::RSA.generate(1024)
public_key  = private_key.public_key

message = "Sign this to prove your identity..."
signature = private_key.sign(OpenSSL::Digest::SHA256.new, message)
public_key.verify(OpenSSL::Digest::SHA256.new, signature, message)
=> true
```

## Public Keys in Crypocurrencies

It turns out that in the context of cryptocurrency we're actually most interested in this last public key mechanism. We use private key signatures to prove identity of users in the system -- like a vastly more secure version of your bank PIN.

When we transfer funds, we don't assign them to a specific person ("Transfer 10 coins to Jane", etc). Instead, we assign funds to a specific Public Key ("Transfer 10 coins to Jane's Public Key"). Conveniently, this gives us a built-in mechanism for proving our identity when it comes time to spend those funds. Since Jane is the only person with access to the associated Private Key, all she has to do to spend the funds is produce a valid signature that matches the Public Key to which her funds were assigned. Anyone who's watching on the network can verify that the provided signature matches the assigned key, and approve the transaction.

[spy-vs-spy]: http://www.codeproject.com/KB/vista-security/ECDH/spy-vs-spy.gif
[otp]: http://www.ranum.com/security/computer_security/papers/otp-faq/otp.jpg
[one-time-pad-example]: http://association-sas.chez-alice.fr/OneTimePadFrench.JPG
[keys]: https://s-media-cache-ak0.pinimg.com/236x/d5/1a/89/d51a89881e03de7f96793a63118525fd.jpg
[NSA]: https://upload.wikimedia.org/wikipedia/commons/8/84/National_Security_Agency_headquarters,_Fort_Meade,_Maryland.jpg
