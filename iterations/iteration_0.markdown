# Iteration 0 - Creating Wallets, Creating Transactions, and Signing/Serializing Transactions

## Wallets

Many cryptocurrencies include a component called a "Wallet" which
provides a handful of tools to let users interact with their money.
In this iteration, the main functions we'll be interested in are:

1. Generating public/private keys
2. Storing and retrieving keypairs from the filesystem
3. Producing and signing transactions
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
As we'll see, we use our private key to _sign_ this transfer,
mathematically proving that we are authorized to transfer the specified
money.

Fundamental to creating a Transaction is the idea of "Transaction Outputs" --
individual chunks of currency that are available to be transferred.
When we "spend" coins in Bitcoin, we are actually transferring *Unspent Transaction Outputs*.
This transfer will in turn generate new Transaction Outputs that could
later be spent by the new owner as an input to a different transaction.

Thus we can think of a transaction as a collection of inputs on
one side and outputs on the other.

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
nested JSON array:

1. Array of Transaction Inputs
2. Array of Transaction Outputs

This would look something like this: `"[["Input 1", "Input 2"], ["Output 1", "Output 2"]]"`.
Except that our inputs and outputs will be more complicated than simple Strings.

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
a similar approach using a structured JSON array containing:

1. **Amount** - The Integer value of the output
2. **Receiving Address** - PEM-formatted encoding of the **RSA Public Key** to which the
amount in this output is being assigned. In order to spend
this output as an input to a subsequent transaction, the owner
will have to produce a valid signature for this transaction.

#### Transaction Input Strucutre

When we want to "spend" a chunk of bitcoin that was transferred
to us in a previous transaction, we'll use it as an "input"
to a new transaction. When doing this, we'll talk about transaction
*inputs*, but it's important to remember that transaction inputs
are really just outputs generated in previous transactions.

An input is a little more involved than an output because it needs
to identify a few key pieeces of information:

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
input as a JSON array containing, in order, the following:

1. **Transaction Hash** - SHA256 hash of the previous transaction
that contains the transaction Output being spent by this input. This
serves as an identifier for looking up that transaction among the chain
of all previous transactions.
2. **Transaction Output Index** - The zero-based numeric index of
the specific output within the identified transaction which is being
spent.
3. **Input Signature** - RSA Signature of the SHA256 hash of all contents
from the current transaction (minus the signatures). We'll cover hashing transactions in more detail,
but in short, you would line up all the contents of the transaction, run them
through SHA256, then take the resulting SHA hash and sign
that with your private key.

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

To represent a full transaction, we take the structures outlined above
and embed them in a sequence, starting with the inputs then adding
the outputs.

Here's an example Transaction data structure in [EDN](http://www.compoundtheory.com/clojure-edn-walkthrough/):

```clj
{:inputs [{:source-hash "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
           :source-index 0
           :signature "psO/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="}
	     ]
 :outputs [{:amount 5
            :address "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
			}
		  ]
 :hash "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
}
```

And here's that same transaction formatted as JSON:

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
  "hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
}
```

* [Reference](http://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx)
* [Ruby Reference](https://gist.github.com/Sjors/5574485)

### Hashing Transactions

To produce a Hash of a transaction, we need to run all of the transaction
contents through SHA256. A straightforward way to do this is to simply hash the
JSON-serialized version of the transaction from above.

Note that the example in the last section included some additional lines
and indentation for formatting, but when we look to hash transactions we'll
want to use raw unformatted JSON to make sure we get consistent results.

So, you can think of hashing a transaction as:

```
SHA256( json-serialized( transaction ) )
```

For the hash of the example transaction above, this would look like (in ruby):

```ruby
require "digest"
require "json"
txn = [
        [
          [
		    "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
            0,
            "psO/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="]
	      ]
	    ],
	    [
	      [
		    5,
            "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
          ]
	    ]
     ]
txn_json = txn.to_json
=> "[[[\"9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e\",0,\"psO/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg==\"]],[[5,\"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\\nPsn/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe/Mnyr\\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\\nuwIDAQAB\\n-----END PUBLIC KEY-----\\n\"]]]"
txn_hash = Digest::SHA256.hexdigest(txn_json)
=> "7fc7ff0e187867a8820ae3e6561c9dd84bcf97e9c6b9c54a64a232546693d894"
```

### Signing Transaction Inputs

Recall that to generate a valid Transaction Input, the sender needs to include a
valid RSA signature of a Hash of the contents of the transaction into which they
are trying to embed the signature.

This presents a small problem, since you can't include in the signature a hash
whose contents depend on the signature in the first place.

To get around this, let's sign inputs with a Hash of only the *Transaction Outputs*
included in the transaction. This still guarantees that an attacker could not take
your signature and use it to validate the same input in the context of a different
transaction, and it removes the chicken-and-egg problem around signing inputs.

Thus, we can think of the signature for a Transaction Input as:

```
RSA-signature-with-SHA256( json-serialized( transaction-outputs ) )
```

So, for our sample transaction above, this would look like:

```ruby
require "digest"
require "json"
require "openssl"

txn = [
        [
          [
		    "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
            0,
            "psO/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="
	      ]
	    ],
	    [
	      [
		    5,
            "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
          ]
	    ]
     ]
outputs = txn.last
outputs_json = outputs.to_json

private_key = OpenSSL::PKey.read("/Path/to/my/key.pem")
=> #<OpenSSL::PKey::RSA:0x007f9218991270>

signature = private_key.sign(OpenSSL::Digest::SHA256.new, outputs_json)
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
