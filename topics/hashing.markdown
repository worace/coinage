## Intro to Cryptographic Hashing

"Hashing", or, more specifically, the use of cryptographic hash functions, is essential to the design of Bitcoin. It's important to have at least a basic grasp of this technique before continuing.

### What is Hashing

When we talk about hashing in the context of Bitcoin, we're not talking about tasty breakfast hash:

![Hash](http://www.simplyrecipes.com/photos/corned-beef-hash-b.jpg)

or even about a popular data structure:

```ruby
$ ruby -e "puts({}.class)"
Hash
```

Rather "Hashing" refers to a type of cryptographic function designed to take an arbitrary amount of data and reduce it down to a numeric fingerprint (often called a "digest" or just a "hash"). For example, using the SHA1 hashing function, if we input the string "pizza", we'll get the following fingerprint: "1f6ccd2be75f1cc94a22a773eea8f8aeb5c68217".

It's important to note that while we often represent these hashes using what looks like a textual string, they are really numbers, in this case being represented in hexadecimal. If we represent the SHA-1 hash of "pizza" in Base-10, it looks like: `179405067335283640084579532467505022408577155607`. This ability to numerically manipulate hash digests comes up in a variety of applications.

There are a few properties of a good hash function that make this ability particularly useful:

1. It's quick to generate a single hash. This makes it easy, for example, to verify that a hash and a piece of data match, since I can just hash the data and check that the hashes match.
2. The fingerprint for a piece of data should be unique to that piece of data (hence the fingerprint analogy. this property is known as __Collision Resistance__)
3. Given a fingerprint, it's extremely difficult to guess what data was used to produce it. Hashing functions are considered **one-way functions**.
4. Even a small change to the input data will result in a wildly different hash being generated. This property is referred to as an **Avalanche Effect**, since a minor input change of even a single bit triggers an "avalanche" of changes to the resulting fingerprint.

There are a lot of hashing functions out there, but some common ones you might encounter included:

* MD5 (often used for open source software checksums; now considered less secure)
* SHA-1 (used by git)
* SHA-256 (used by Bitcoin)
* Other SHA-* family hashes
* RIPEMD family hashes

### Hashing in Bitcoin

We see hashes come up in a lot of places in Bitcoin, generally to serve 2 purposes:

1. As a unique identifier (fingerprint) for a piece of information -- we'll generally refer to Blocks and Transactions by their hashes. Since each block and each transaction are unique, and the hashes are derived from the data they contain, the hashes are also unique, and thus serve as a reliable way to refer to a specific item.
2. As a way to secure the network via a **Proof of Work** algorithm. This is the essence of the mining process, and we'll look at it in more detail now.

#### Proof of Work

One of the essential problems in Bitcoin is proving to the network which transactions and blocks are valid. Additionally, we'd like to make it difficult for an attacker to generate a bogus block that looks valid to the network. And finally, we'd ideally like to solve these problems in a way that is very *easy* for other participants on the network to double check (i.e. it's not great to have a good security system if all the nodes on the network have to spend all of their time verifying the validity of blocks).

It turns out that Hashing provides an elegant solution for all of these problems. Every block in Bitcoin's blockchain is identified by a unique hash. However not just any hash will do -- when considering a new block for entry into the chain, the network establishes a **Target** for that block's hash. The target is ultimately just a number (just as the hashes themselves are numbers), and in order to be accepted by the network, the block must generate a hash that is numerically smaller than the specified target.

Let's consider a simplistic example. Suppose I had a block whose contents were simply the string `Pay 10 coins to Suzy.`, and that
the network had established that the current target is the number: `00ffffffffffffffffffffffffffffffffffffff`, and that we had agreed to use SHA-1 as our hashing function.

To generate the hash of this block I would run it through SHA-1:

```ruby
require "digest"
digest::sha1.hexdigest("pay 10 coins to suzy.")
=> "60f93bba4019faeda09c739293a04ccad2000344"
```

Well shucks...our block didn't produce a value lower than the target. But don't worry -- our block is not doomed. It just needs a little work, i.e. some **mining**.

Bitcoin's approach to block hashing is to allow miners to add additional data as needed to their blocks in order to make the hashes work out right. In particular, we append a special, throwaway number called a **Nonce** to each block.

So, given the block above, I might try adding a simple nonce:

```ruby
require "digest"
Digest::SHA1.hexdigest("Pay 10 coins to Suzy. Nonce: 1")
=> "03ddf6c13b2dcfc698770da8cbf357fdd703677c"
```

Well, that's better! The block hash got lower. But it's still not lower than the target of `00ffffffffffffffffffffffffffffffffffffff`, so we need to try again. Let's try with the nonce of `2`.

```ruby
require "digest"
Digest::SHA1.hexdigest("Pay 10 coins to Suzy. Nonce: 2")
=> "0f14226b3d9ac170f93a51f9302ec0a0c12bf56d"
```

Well...now it actually got larger. But that's ok -- remember what we said about hashing algorithms: The output of the hash is effectively unpredictable based on the inputs. There's no magical correlation which says incrementing the nonce by 1 will give us a lower hash value. Rather it's effectively random.

So what does this mean for our search for a valid block hash? It turns out the process of "mining" is basically trial and error. Miners take a block they want to work on, hash it, and see what the results are. If the hash comes out smaller than the target -- good job! You're done. If not...well, try again. Mining blocks in Bitcoin is effectively playing a SHA lottery.

For our block, after a few more tries we eventually find that the number `11` gives us an appropriate nonce to beat the target:

```ruby
require "digest"
Digest::SHA1.hexdigest("Pay 10 coins to Suzy. Nonce: 11")
=> "003421bc7673ce8ba8cd82b9b01fb35722895981"
```

#### Verifying Hashes

It took us 11 tries to find the appropriate nonce to complete this block, but if targets get smaller, it could easily take us millions or billions of tries until we find a valid nonce.

But what if we want to "check" the validity of the block (for example when I go to share this block with other users on the network) -- will they also have to complete all billion hash attempts?

Fortunately not. Remember what we said about hashing -- it's very quick to compute a single hash. Just difficult to predict what hash a given input will produce. Bitcoin is able to exploit this fundamental asymmetry of hashing algorithms to place the burden of valid hashing on those trying to produce new blocks.

When I send you my block, it's trivial for you to take the block contents, hash them, and see that everything is in order. However it takes me many tries to generate those block contents. Thus a block containing a valid nonce and a hash below the target represents cryptographic proof that I have put in the required amount of work to generate the block.

The fact that it's hard to make blocks but easy to check them prevents attackers from generating bogus blocks. Hashing functions are what make this possible, and thus are essential to the operation of the Bitcoin network.

## Other Hashing applications

Hashing functions have a lot of other useful applications, including:

#### Checksums

When you download a piece of software from the internet, there will often be a pre-computed Checksum (hash) posted with it. Once you download the software, you can run its contents through a hashing function and make sure the hash you produce and the one posted with the source match up. If they don't, you know something's not right -- either the data got corrupted during transmission, or perhaps an attacker swapped your software for malware.

#### Password Storage

Storing user passwords is somewhat dangerous. If the stored passwords somehow get out (generally because of a hack), attackers can easily access all of your users' data. To prevent this, but still allow the security and convenience that a password-based login system provides, we often store hashes of passwords rather than the original passwords themselves.

When a user first registers, we take the password they provided, hash it, and store the hash. Later, when they need to log in, they type in their password, we hash it (making sure to use the same hashing algorithm, etc), and verify that the new hash matches the one we previously stored. Since hashes are **collision resistant**, we can be confident that the password they typed in this time is the same as the one originally provided.

Even if our data is somehow compromised, hackers will only have access to the hashes. And since a hash function is non-reversible, it's impossible for them to guess the original password knowing only the hash.

#### Data Structures

Most programming languages these days include some kind associative Dictionary or Map data structure. A common way to implement these is using a "Hash Map" -- when inserting data into the structure we first compute a cryptographic hash and use this as a unique identifier to determine where to store it. Some clever tricks allow this to be done extremely efficiently, even as the size of the data set grows. This is where Ruby gets the name for its "Hash" data structure.
