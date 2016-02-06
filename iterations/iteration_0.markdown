# Iteration 0 - Creating Wallets, Creating a Coinbase Transaction, and Serializing Transactions

## Wallets

Many cryptocurrencies include a component called a "Wallet" which
provides a handful of tools to let users interact with their money.
In this iteration, the main functions we'll be interested in are:

1. Generating public/private keys
2. Storing and retrieving keypairs from the filesystem
3. Producing a special type of transaction called a "Coinbase"
4. Serializing transactions so that they can be distributed
over the network

### 1 - Generating and Storing a Public/Private Key Pair

Fortunately this process is fairly straightforward for us since
there are plenty of tools out there that implement the underlying
cryptography for us.

Bitcoin uses a cryptography algorithm called the "Elliptic Curve Digital
Signature Algorithm" (ECDSA), but we're going to take a slightly simpler tack
and use the slightly more pedestrian RSA public/private key algorithm.

RSA and ECDSA both rely on mathematical operations that can be made
asymmetrically difficult -- that is, they are trivially easy to complete
in one direction, but immensely difficult to reverse. This is a great
recipe for something like encryption -- we want things to be easy to
encrypt (and to decrypt, if you have the key), but effectively impossible
to decrypt if you don't have the key.

To start with a basic wallet implementation, write a program which, when run, will
look for a special set of wallet files on the user's computer. We'll use a common
format for serializing RSA keys called `.pem`, so let's assume these files are
`~/.wallet/public_key.pem` and `~/.wallet/private_key.pem`, respectively.

When your wallet program runs, it should search for a valid wallet to exist in
these files. It should read this into memory and print
the public key (in general, we want to avoid printing a private key).

If the program doesn't find this file, it should create it by first generating
a keypair and then writing them to the appropriate public/private key files.

(Technically RSA allows us to re-generate the public key from the private key,
so storing the public key is somewhat optional -- you could simply re-generate
it from the private key if you preferred to store just that.)

### Generating a Keypair

To generate keys, we'll want to use a library that implements RSA. Fortunately
many languages include something like this in their standard library. In Ruby,
the included `OpenSSL` module provides a good (albeit poorly documented) RSA
implementation.

**Note** - One of the main variables to control when using RSA is the length
of your keys -- we'll use **2048-bit Keys**.

Consult [this code snippet](https://github.com/worace/coinage/blob/master/snippets/rsa.rb)
for some detailed examples of working with the RSA implementation included in Ruby's
OpenSSL package to generate keys and encrypt and decrypt messages.

### 2 - Generating a Transaction

A "transaction" represents a transfer of currency from one address to another.
If Bitcoin functions as a shared, universal ledger of money transfers, then
transactions are analagous to individual rows in the ledger (_Blocks_, as we'll
see later, are analagous to whole pages).

Concretely, a Transaction is composed of _inputs_ and _outputs_ -- where
inputs are our way of referring back to amounts of currency that were previously
transferred to us, and outputs are our way of transferring these to someone
else.

When we "spend" coins in Bitcoin, we are actually transferring *Unspent Transaction Outputs*  -- i.e. Outputs from a previous transaction which have never yet been spent. This transfer will in turn generate new Transaction Outputs that could later be spent by the new owner as an input to a different transaction.

Thus we can think of a transaction as a collection of inputs on one side and outputs on the other.

One slightly tricky point to keep in mind is that in BitCoin we don't simply pull funds out of a single pile representing our "balance." Rather, the system keeps track of all the individual payments that you have received. When you want to pay someone, you're actually transferring one of these specific payments to the new recipient.

Where do the original outputs come from? Ultimately we'll be generating
them through the mining process. However for now (since we're starting
at the "bottom" with just wallets and transactions), we'll want
to figure out some way to mock that part out.

#### Transaction Structure

We'll use a much-simplified version of Bitcoin's format for representing a transaction.
The important pieces of information to include here are the individual transaction
inputs followed by the individual transaction outputs. The actual Bitcoin protocol
accomplishes this by defining its own binary data format, which packs the various
pieces of transaction info into a carefully sequenced series of bits. This makes for more efficient
storage and transfer over the network, but is also more tedious to work with.

Instead, we'll use straightforward JSON structures to represent transactions in our
system.

With that in mind, let's say that a Transaction can be represented as a simple
JSON object containing 3 keys:

1. **inputs** - an array of transaction inputs following the structure defined below
2. **outputs** - an array of transaction outputs following the structure defined below
3. **hash** - a SHA256 hash of the transaction; the hash process will be discussed in detail later

This would look something like this:

```json
{"inputs": [],
 "outputs": [],
 "hash": "some-sha-hash"
 "timestamp": "some unix timestamp"
}
```

Except that the input and output keys would contain actual collections of inputs and outputs.

#### Transaction Output Structure

Remember that Transaction Outputs are the entries in the collective ledger
which indicate the transfer of some amount of currency to a given
user (as identified by their cryptographic public key).

Structurally, a transaction output consists of 2 things: the amount
of currency being transferred and the address to which it is being
assigned.

A TXO does not in and of itself attempt to prove the validity of the
money being spent -- rather the network takes on this responsibility
by verifying that the *transaction inputs* being consumed are valid.

When encoding a transaction output into a transaction, we'll follow
a similar approach using a JSON object containing:

1. **amount** - The Integer value of the output
2. **address** - PEM-formatted encoding of the **RSA Public Key** to which the
amount in this output is being assigned. In order to spend
this output as an input to a subsequent transaction, the owner
will have to produce a valid signature for this transaction.

__Example:__

This simple transaction output would represent the transfer of 5 coins to the owner of the specified public key:

```json
{
  "amount": 5,
  "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
}
```

### Coinbase: The Simplest Transaction

Eventually, we'll dive in to working with more complicated transactions. But for now, we're going to work toward getting a basic miner up and running as simply as possible. To accomplish this, we actually only need to be able to handle one type of simple transaction.

A Coinbase is a single transaction which a miner includes in the beginning of a block to award themself coins for mining the block. A coinbase transaction represents the creation of new coins, and as such it has no *inputs* and one *output*.

The coinbase transaction is especially significant because it solves 2 problems: first, it provides additional incentives for miners to generate new blocks, since they are rewarded for doing so. Secondly, it manages the introduction of new coins into the money supply.

Coinbases are especially convenient for the moment since they have outputs but no inputs. This lets us get away with starting our block chain without having to deal with the process of signing and validating inputs.

So what does one look like? Here's an example:

#### Example Coinbase:

```json
{
    "inputs": [],
    "outputs": [
        {
            "amount": 25,
            "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
        }
    ],
    "timestamp": 1450565806588,
    "hash": "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9"
}
```

This is a JSON object representing an example coinbase transaction. Note that it follows all the structural
patterns we discussed above:

1. The transaction contains an array of `inputs` which is empty in this case
2. The transaction contains an array of `outputs`, each of which specifies an `amount` and an `address` to which it should be transferred
3. The transaction contains a UNIX `timestamp` specifying the time it was created, in milliseconds.
4. The transaction includes a SHA-256 hash of all of its contents (more on this next)

### Hashing Transactions

To produce a Hash of a transaction, we need to run all of the transaction
contents through SHA256. To do this, we'll follow a similar process to
the signing process above, except now we'll include the transaction input
signatures and the timestamp as part of our hash content.

So, to get the hashable string representation of a transaction, we'll
follow these steps:

1. Concatenate the *source_hash*, *source_index*, and *signature* of each input
2. Concatenate those strings into a single *inputs_string*
3. Concatenate the *amount* and *address* fields of each output
4. Concatenate those strings into a single *outputs_string*
5. Concatenate the *inputs_string* with the *outputs_string* and the *timestamp*

```
SHA256( hashable-transaction-string )
```

For the hash of the example coinbase transaction above, this would look like (in ruby):

```ruby
require "json"
require "digest"

inputs = []
outputs = JSON.parse('{
            "amount": 25,
            "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
        }')
timestamp = 1450565806588 # or... (Time.now.to_f * 1000).to_i

inputs_string = inputs.map { |i| i["source_hash"] + i["source_index"].to_s + i["signature"] }.join
# ^^ this will just give us an empty string, since we have no inputs
outputs_string = outputs.map { |i| i["amount"].to_s + i["address"] }.join

hashable_transaction_string = inputs_string + outputs_string + timestamp.to_s

txn_hash = Digest::SHA256.hexdigest(hashable_transaction_string)
=> "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9"
```

### Transactions and Mining

So how does this Coinbase transaction fit into writing a basic miner?
In short, miners generate blocks, and blocks contain transactions. Eventually
our blocks willl contain lots of different transactions sourced dynamically
from the larger network, but to start with each block needs to contain
at least one particular transaction -- the coinbase.

Once you can a) create a simple "wallet" containing a public and private
key and b) create a simple coinbase transaction by following the structure
above, you're ready to create your first block to hold one of these transactions.

## Iteration 0 Exercises

### 1 - TXN Hashing

Take the example coinbase transaction below and see if you can manually verify the transaction hash that was produced by pulling out the appropriate pieces, concatenating them in the proper order, and running them through SHA256. This is probably best done in a repl session of some sort.

```json
{
    "inputs": [],
    "outputs": [
        {
            "amount": 25,
            "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
        }
    ],
    "timestamp": 1450565806588,
    "hash": "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9"
}
```

### 2 - Your own Coinbase

Now, see if you can manually construct your own coinbase using the following steps:

1. Create a public/private key pair
2. Add the inputs for your transaction (`[]`)
3. Add the timestamp for your transaction
4. Add the output for your transaction with the amount `25` and the address of the public key you created in step 1. Remember that outputs are represented as an array even when you only have one of them.
5. Add the hash for your transaction by following the transaction hashing steps described above.

### Note on Hex Strings

We'll be working with hexadecimal representations of SHA hashes a lot, and sometimes
passing these hashes into another hashing function. For these to give us consistent
results, we'll agree on the convention of representing Hex strings using the
digits 0-9 and the lowercase letters "a" - "f"
