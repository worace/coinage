## Transaction Signing and Verifying

(Misc. notes pulled from iteration 0 in order to separate dealing with txn inputs
from dealing with txn output)

__Looking up Transaction Outputs__

One thing to note about this structure is that within a transaction,
we simply stack the outputs (and inputs) back to back in an array.

Thus if we want to refer back to a specific output in a subsequent
transaction, we'll need to first identify which transaction it is
contained in, and then identify the _index_ of that output within
the sequence of that transaction's outputs.

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
