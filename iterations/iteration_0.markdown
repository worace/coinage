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
pieces of transaction info into a carefully sequenced series of bits.

The transaction format is important because we'll eventually need
to verify transactions by running them through a Hashing Function.
As we know, the output of a hash function depends very precisely on
the ordering and contents of the input data -- So if we all want to be
able to get the same results from hashing a transaction, we need
to make sure we're feeding in the transaction data in the same
order and format.

Bitcoin's binary formats solve this problem and also provide a very
compact storage format, but for now, we're going to see if we can get
away with a more readable format by serializing our transactions as JSON.

With that in mind, let's say that a Transaction can be represented as a simple
JSON object containing 3 keys:

1. **inputs** - an array of transaction inputs following the structure defined below
2. **outputs** - an array of transaction outputs following the structure defined below
3. **hash** - a SHA256 hash of the transaction; the hash process will be discussed in detail later

This would look something like this:

```json
{"inputs":[],
 "outputs":[],
 "hash":"some-sha-hash"
}
```

Except that the input and output keys would contain actual collections of inputs and outputs.

__Looking up Transaction Outputs__

One thing to note about this structure is that within a transaction,
we simply stack the outputs (and inputs) back to back in an array.

Thus if we want to refer back to a specific output in a subsequent
transaction, we'll need to first identify which transaction it is
contained in, and then identify the _index_ of that output within
the sequence of that transaction's outputs.

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

```json
{
  "amount": 5,
  "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
}
```

#### Transaction Input Strucutre

When we want to "spend" a chunk of bitcoin that was transferred
to us in a previous transaction, we'll use it as an "input"
to a new transaction. When doing this, we'll talk about transaction
*inputs*, but it's important to remember that transaction inputs
are really just outputs generated in previous transactions.

An input is a little more involved than an output because it needs
to identify a few key pieces of information:

1. The previous transaction, in which the input we're trying to
consume was originally generated (as an output). This transaction
will be identified by its unique hash.
2. The *index* of the output in that previous transaction (remember
that a transaction contains multiple outputs, so to identify a specific
one we need to specify its index in the sequence)
3. A special *signature* proving that the person creating this transaction
does in fact have own the input they are trying to spend. This piece is
crucial to guaranteeing the security of the system.

So what does this look like in a more concrete serialization format?
Let's stick with the JSON approach and try to express a transaction
input as a JSON object containing the following keys:

1. **source_hash** - SHA256 hash of the previous transaction
that contains the transaction Output being spent by this input. This
serves as an identifier for looking up that transaction among the chain
of all previous transactions.
2. **source_index** - The zero-based numeric index of
the specific output within the identified transaction which is being
spent.
3. **signature** - RSA Signature of the SHA256 hash of all contents
from the current transaction (minus the signatures). We'll cover hashing transactions in more detail,
but in short, you would line up all the contents of the transaction, run them
through SHA256, then take the resulting SHA hash and sign
that with your private key.

__Example:__

```json
{
  "source_hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
  "source_index": 0,
  "signature": "psO\/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt\/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="
}
```

This example would represent a transaction input which is attempting to spend
the **transaction output** contained at index 0 among all of the outputs
contained within transaction "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e".

##### More on the Input Signature

From the Bitcoin Protocol developer reference:

> The entire transaction's outputs, inputs, and script (from the most recently-executed
> OP_CODESEPARATOR to the end) are hashed.
> The signature used by OP_CHECKSIG must be a valid signature for this hash and public key.
> If it is, 1 is returned, 0 otherwise.

The output signature of a transaction is essential to the security of the overall system
because it guarantees 2 things.

First, using your private key to sign a TXInput proves to the network that you are the
valid owner of the corresponding TXOutput. This is because the output itself contains the
public key associated with your private key, and other nodes on the network can use
this public key to mathematically prove that your private key is the only one that
could produce the given signature -- thus proving your ownership.

However, it's not enough to just use the signature to prove ownership of the specified
TXOutput -- we also need to prove that this input is intended to be included in this
specific transaction.

Technically we could use our private key to sign anything we wanted
and it could still be proved to be associated with the known public key.
But in order to pin the signature to the specific transaction, we use it to sign
a very specific value -- the Hash of the transaction we are working on. We know that
if someone tried to change the transaction context of the input, it would completely
change the transaction hash, which would in turn invalidate the signature.

Thus using the Input Signature to sign a hash of the whole transaction, we can
prevent others from taking our signed input and using it in another transaction.

**A couple notes** - An alternative here would be to just sign all of the outputs
of the transaction. This would simplify the process a bit since we wouldn't have to
worry about "zeroing out" the signatures of the pending tx inputs so that we can sign them.
But it also would in theory allow the signed input to be re-used in another transaction
that had the same outputs (but possibly different inputs). Not sure if this represents
a vulnerability or not.

[More Info](https://en.bitcoin.it/wiki/OP_CHECKSIG)

### Transaction Example

To represent a full transaction, we take the input and output structures outlined above
and embed them within a larger transaction structure. We then add a special "hash" key
containing the SHA256 hash of the transaction, and that represents our transaction.

Here's an example formatted as json:

```json
{
  "inputs": [
    {
      "source-hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
      "source-index": 0,
      "signature": "psO\/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt\/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="
    }
  ],
  "outputs": [
    {
      "amount": 5,
      "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
    }
  ],
  "timestamp": 1450310016721,
  "hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
}
```

### Signing Transaction Inputs

Now let's look at how the "signature" field of each transaction input is generated.

Recall that to generate a valid Transaction Input, the sender needs to include a
valid RSA signature of a Hash of the contents of the transaction into which they
are trying to embed the signature.

However this presents a small problem since the Transaction Hash itself is dependent
on the signature (since the signature is part of the input and this is part of the
transaction).

To get around this, we'll generate the signature for each input by signing a
representation of the transaction *without the signatures*.

To generate the input to this signature, we'll do the following:

1. Concatenate the *source_hash* and *source_index* of each input
2. Concatenate those strings into a single *inputs_string*
3. Concatenate the *amount* and *address* fields of each output
4. Concatenate those strings into a single *outputs_string*
5. Concatenate the *inputs_string* and *outputs_string*

We'll treat the output of step 5 as a "signable transaction string" which
we'll use to generate the unlocking signature for each of our inputs.

Thus, we can think of the signature for a Transaction Input as:

RSA-signature-with-SHA256( signable-transaction-string )

So, given the example input and output shown above, we could look at a ruby example like so:


```ruby
inputs = JSON.parse('[{"source_hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", "source_index": 0}]')
outputs = JSON.parse('[{"amount": 5, "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"}]')

inputs_string = inputs.map { |i| i["source_hash"] + i["source_index"].to_s }.join
outputs_string = outputs.map { |i| i["amount"].to_s + i["address"] }.join

signable_transaction_string = inputs_string + outputs_string

private_key = OpenSSL::PKey.read("/Path/to/my/key.pem")
=> #<OpenSSL::PKey::RSA:0x007f9218991270>

signature = private_key.sign(OpenSSL::Digest::SHA256.new, signable_transaction_string)
private_key.public_key.verify(OpenSSL::Digest::SHA256.new, signature, signable_transaction_string)
=> true
```

This signature would then be inserted into each transaction input to validate it

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

For the hash of the example transaction above, this would look like (in ruby):

```ruby
inputs = JSON.parse('[{"source_hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e", "source_index": 0, "signature": "some-signature"}]')
outputs = JSON.parse('[{"amount": 5, "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"}]')
timestamp = (Time.now.to_f * 1000).to_i

inputs_string = inputs.map { |i| i["source_hash"] + i["source_index"].to_s + i["signature"] }.join
outputs_string = outputs.map { |i| i["amount"].to_s + i["address"] }.join

hashable_transaction_string = inputs_string + outputs_string + timestamp.to_s

txn_hash = Digest::SHA256.hexdigest(hashable_transaction_string)
```

### Verifying transactions

As transactions get propagated to the network, clients will need to verify
several things about the transaction:

1. All transaction inputs must have a valid signature proving
that the sender has authority to use those inputs
2. All outputs must be assigned to valid addresses
3. All inputs must still be available for spending

#### Change

When spending an output, it must be consumed in its entirety. However often
we will want to transfer an amount that doesn't exactly match the inputs
we are feeding in. In these cases we will need to return "change" back to
ourselves.

Since all currency must be transferred in the form of discrete outputs, our
change will simply form another output of the transaction. Thus a transaction
will often take the form of 1 input -> 2 outputs, where 1 of the outputs
is going to the other party's address and the other output goes back to
our own address in the form of "change"

It's important that change appears as another output within the same
transaction (as opposed to a separate transaction). This allows
a single input to be split into multiple outputs at once, and also
guarantees that our change and transfer outputs can't be separated from
one another.

### Note on Hex Strings

We'll be working with hexadecimal representations of SHA hashes a lot, and sometimes
passing these hashes into another hashing function. For these to give us consistent
results, we'll agree on the convention of representing Hex strings using the
digits 0-9 and the lowercase letters "a" - "f"
