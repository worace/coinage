# Iteration 2 - Working with the Block Chain

Now that we have a way to generate blocks containing (so far)
fresh coinbase transactions, and mine those blocks to produce
a valid nonce and satisfy the network's Proof-of-Work requirements,
let's look at some of the basic questions we will want to ask of the
information contained in the block chain.

## Checking Balances

An obvious first thing you'd like to know is "how much money do I have
available?" To answer this, we need to remember 2 key things:

1. *A Person* only has money insofar as they hold the private key for
a keypair which has transactions assigned to it in the block chain. Technically
all value in the network is assigned to public keys through transactions, so when
we want to look at a "balance", we'll be looking for all the value assigned to
a given public key.
2. Value on the network is only ever transferred in the form of **Transaction Outputs**.
Determining the amount of money available to a given key is really a question of
determining the value of all Outputs that are assigned to it.

With these ideas in mind, we can determine the balance available to a given public
key using the following steps:

1. Search the block chain for all Transaction Outputs assigned to the given key
2. Of these outputs, pull out only those that are still *unspent*
3. Add up the amounts of all of these remaining unspent outputs

Remember that Transaction Outputs are simple data structures with this format:

```json
{
  "amount": 5,
  "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
}
```

So we can determine if an output is assigned to a key by comparing the `"address"` field
of the output with the key's PEM representation. And we can simply read the value
of the output from its `"amount"` field.

## Identifying Unspent Transaction Outputs

So how do we know which of the outputs assigned to a key can still
be considered "unspent"?

Outputs of a transaction are spent by inputs to other, subsequent
transactions. When spending an output, an input identifies it using
the hash of the transaction to which it belongs and its numeric index
within the list of outputs contained in that transaction.

Thus when checking the status of an output, we'll need to have these
identifying "coordinates" -- transaction hash and index. Once we have these,
we can again search the block chain to check for any transaction
inputs which claim our output's coordinates as their `source_hash` and `source_index`.

If we find a match, we know that the output in question has been spent.
Otherwise, it is unspent. When checking the balance of a key, you will need
to use this process against each output to determine whether it has been
spent or not.

## Generating payment Transactions

__Required Information:__

* Access to block chain
* paying key (in order to provide signatures)
* receiving public key (to serve as address for txn outputs)
* amount to send


1. Check balance as above to make sure the paying key has
sufficient funds
2. Select enough txn outputs to fund the requested amount
3. Generate a transaction that includes those as its inputs
4. Include an output transferring specified amount to specified address
5. Sign the inputs with the provided paying key
6. Hash the transaction

## Including Change

## Including Transaction Fees
