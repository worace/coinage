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

### Balance Algorithm

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

### Identifying Unspent Transaction Outputs

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

## Transferring Funds

Now that we can check the balance for a key, the next thing we might like
to do is transfer some of these funds to another address (i.e. make a payment).

We have all the pieces in place required to make this happen, but the process
is somewhat involved, so let's step through it.

### Payment Outline

In broad strokes, the process of setting up a payment transaction looks
like this:

1. Determine the amount to send as well as any transaction fees to include
as incentive to miners
2. Find all Unspent Transaction Outputs assigned to your wallet (key), and select
enough of these to cover *at least* the payment amount + transaction fee (it's ok
if you end up going over, since any excess can be returned to you as change)
3. Generate 1 Transaction Input for each of these *sources*. Remember
that inputs identify the transaction output they spend by providing the source transaction
hash and output index
4. Generate the payment output, which assigns the desired amount to the address
you want to pay
5. If the total value of inputs being included in the transaction is greater than the
sum of your payment amount plus the transaction fee, add an additional *change* output
that assigns the remaining value back to your own public key.
6. Add the transaction hash
7. Sign the transaction inputs

### Required Information

In order to generate a payment transaction, we'll need to have access to
a few pieces of data:

* The Block Chain -- We need to be able to gather source outputs from
the chain in order to use them as inputs to our payment transaction
* Paying Keypair -- We need the private key in order to sign our inputs,
proving our ability to spend them. Additionally we may need the public key
to use as a *change address* if we end up sourcing more outputs than are needed
* Receiving Address -- This will be the `address` for the actual payment output in our
transaction
* Amount -- We need to know how much to pay!

### Payment Walkthrough

Let's look at a more detailed example by walking through this process with a hypothetical
block chain. To demonstrate, we'll imagine we had a block chain represented by this JSON
structure:

```json
[{
  "transactions": [
    {
      "hash": "a98f3d",
      "timestamp": 1450584386520,
      "outputs": [{"address": "Public-Key-A", "amount": 25 }],
      "inputs": []
    }
  ],
  "header": {
    "hash": "00000ba50a43011e1a556e52f7eb30850bb4af40b773719e6de93dae4fe24c6a",
    "nonce": 286743,
    "timestamp": 1450584386,
    "target": "0000100000000000000000000000000000000000000000000000000000000000",
    "transactions_hash": "some-hash",
    "parent_hash": "0000000000000000000000000000000000000000000000000000000000000000"
  }
}]
```

Our chain here contains a single block which contains a single transaction (the coinbase).
**Note** that for this example block I'll be filling in many of the fields with placeholder values
(such as the hashes and public keys) in order to keep things simple. While the structure
is accurate, the individual fields may not be.

### Checking Balance

Let's start with a quick balance check. We'll refer to the public/private keypair contained
in our wallet as `Wallet-A`, so in order to find the corresponding balance, we need
to find all Unspent Transaction Outputs addressed to `Public-Key-A`.

Searching through the chain we find 1 output -- the output contained in transaction `a98f3d`
at index `0` that is assigned to our key. Looking through the inputs in the chain, we find there
are none, so we can safely assume that our output is unspent -- our wallet contains a
balance of `25` coins.

### Making a Payment

## Including Change

## Including Transaction Fees
