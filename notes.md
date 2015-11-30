# BlockChain

What would it take to make a simplistic but functional
crypto currency?

## Wallets

* Generates private/public key/address pairs
* Stores key pairs on filesystem so that they can be re-used
on subsequent sessions
* Can generate a new transaction to send money to a specified address
by signing the *from* address with the associated private key
* *optional:* using fresh keypairs for new transactions
* Serializing keys: When sending over the network, we'll
use [Base58 Check Encoding](https://en.bitcoin.it/wiki/Base58Check_encoding)

## Transactions

* Signed authorization to transfer coins from one address to
another
* Consists of transaction Input(s) and Output(s)
* Inputs represent allotments of currency that were assigned to
a given address using that address as a public key
* As the owner of the addres, you can use the associated
key to "unlock" the specified allotment of coins and thus send these
to another address
* Generally there will be 1 output for the amount you are trying to
send, and frequently an additional 1 output to send "change" back
to the spending address

### Verifying transactions

As transactions get propagated to the network, clients will need to verify
several things about the transaction:

1. All transaction inputs must have a valid signature proving
that the sender has authority to use those inputs
2. All outputs must be assigned to valid addresses
3. All inputs must still be available for spending

## Transaction Outputs

The system is designed around transferring currency in discrete chunks
or allotments, called "outputs". To spend currency, a user really spends
"outputs" of previous transactions by transferring them to a new address.

We will sometimes use the term "input" to refer to the outputs that are
going into a transaction, but remember that every transaction input is ultimately
just an output of a previous transaction.

### Change

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

## Blocks

Blocks form the "entries" into the shared, public ledger that our
currency depends on. Or perhaps more accurately, blocks form "pages"
in the ledger, with transactions making up the individual entries.

This is because a block is basically a collection of transactions
that get committed to the ledger (aka the blockchain). This process
is a bit involved but it provides the fundamental assurances on which
the whole system is based, so it's very important.

### Block Ingredients

There are a few pieces that go into a block

1. A list of transactions (up to some maximum limit)
2. The overall length of the block (so other nodes know how much
data will be received as part of the block)
3. A hash of the previous (parent) block's hash, linking this
block to the previous one
4. A timestamp
5. A "nonce"
6. The difficulty target against which the block was mined
7. The Block hash, representing an un-changeable fingerprint of all of the
included block data

### Block Headers & Hashing

One of the main purposes of Blocks is to embed transactions in the shared
public ledger in such a way that it's very difficult to tamper with them.
The system accomplishes this largely through the frequent use of Cryptographic
Hashing functions.

You can read up on [hashing basics](https://en.wikipedia.org/wiki/Cryptographic_hash_function),
but as a brief summary, you can think of a hash as a special digital fingerprint
of some body of data. Significantly the hash is:

1. Unique for all data input (change even 1 bit of the input data and you'll get a totally new hash)
2. Unpredictable -- there's no way to predict what hash value will be generated
by a given input
3. Non-reversible -- given a hash, there's no way to guess the input value
that generated it (beyond simply brute-forcing all of the possible inputs)

This is tremendously useful for working with blocks, because we can use hashes
to fingerprint all of the ingredients of each block. If anyone makes even 1 small
change to the block, the fingerprint will be invalidated, and other nodes will be
able to identify that something fishy is going on.

### Parent Blocks and the Block Chain

What's even better is that we can extend this tamper-proofing to the chain as a whole.
We noted above that each block includes the block hash of the previous block (its parent)
as part of its data. If that parent block were to be modified, it would generate a totally
new hash. And since that parent hash is included as part of the current block's hash,
it would cause that block's hash to be re-generated as well.

Thus even a minor change to a block causes not just the invalidation of that block but also
the invalidation of any blocks following it in the chain.

## Mining Blocks

So how do blocks get generated? The obvious answer might be for us to define a simple
algorithm by which nodes can bundle some transactions into a block, hash it, and
propagate it to the network.

However without some careful thought, this approach might leave the system vulnerable
to nefarious activity. In particular, if the process of creating a valid block is _easy_,
an attacker would be able to manipulate the blockchain ledger to advance
their interests.

For this reason, we want the process of generating blocks to be difficult.
To do this, we will establish some rules around what constitutes a valid block.

When creating a block, the network will establish a "target" number. To be accepted,
the block must generate a hash value **smaller than** the specified target.
Since it's infeasible to predict what hash value will be generated by a given input,
miners are forced to simply try numerous combinations of values until they find
one that meets the target.

### Nonces

But if the block hash is generated by hashing all of the block's contents, how can miners
search for a valid block value without changing the block's contents (and thus breaking
the whole thing)?

This is where the special "nonce" value comes in. The nonce is a number that miners will
include in a block when they are trying to mine it. The miner simply hashes all the intended
contents of the block + some nonce. If the resulting hash is smaller than the target, then they
win. If not, then they change the nonce (usually by incrementing it) and try again.

To restate, we can think of a block hash as:

```
block_hash(transactions + block length + timestamp + parent hash + difficulty target + <YOUR NONCE GOES HERE>)
```

The process of mining coins is trying to find a suitable Nonce value that can be combined
with the remaining ingredients to produce a block hash smaller than the target.

### Difficulty Targets

## Node Communication

## Account Tracking

* Monitor blockchain for transactions relevant to your wallet

## License

Copyright © 2015 Horace Williams

Distributed under the Eclipse Public License either version 1.0 or (at
your option) any later version.
