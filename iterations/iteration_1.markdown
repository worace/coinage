## Iteration 1 - Making Blocks

### Block Basics

Now that we have some approaches for creating and representing
transactions, we can look at the next data structure in our
ledger, the **Block**. Essentially, a block is just a collection of transactions.
The block exists to bundle up multiple transactions and commit them to
the blockchain.

### Block Ingredients

The main bulk of a block will ultimately be composed
of the transactions it contains. But there are a few other
pieces of information that need to get mixed in in order to
validate the block and all ow it to be included in the chain.

We'll consider the collection of transactions as the Block's **body**,
and the additional metadata as its **header**.

The body consists of all the transactions contained in the block
in sequential order.

The header contains the following pieces of data:

1. **Previous Block Hash** - Hash of the header of the previous block (this links this block
to the previous one)
2. **Transactions Hash** - Hash of all the transactions contained in this block
3. **Block Timestamp** - Time the block was created, in seconds since Unix epoch
4. **Difficulty Target** - The hashing difficulty against which this block was mined (more
on how this target gets set later)
5. **Nonce** - A special value used to "complete" the block by causing it to generate a hash
value lower than the required difficulty target
6. **Block Hash** - A SHA256 hash of the other contents in this block's header

### The "Coinbase" Transaction

How do transactions get included in a block? For the most part they will be sourced
from the network. As a miner works to generate new blocks, they'll listen for
new transactions to be broadcasted over the network, and will include those
in the block it's working on. And these transactions will follow the standard
pattern -- transferring funds from one address to another by turning transaction
inputs to transaction outputs.

There is one exception to this pattern, called a **Coinbase** transaction.
This is a single transaction which a miner is allowed to include in the beginning
of a block that awards themself coins for mining the block. A coinbase
transaction represents the creation of new coins, and as such it has no *inputs*
and one *output*.

The coinbase transaction is especially significant because it solves 2
problems: first, it provides additional incentives for miners to generate
new blocks, since they are rewarded for doing so. Secondly, it manages the
introduction of new coins into the money supply.

It's up to other nodes on the network to ensure that checking for a proper
coinbase transaction (and ensuring that only one exists) is part of their
process for validating a block.

### Generating a Block's Hash

Just like we used hashing to validate transactions by fingerprinting them in
the last iteration, hashing is important for both uniquely identifying blocks
and for protecting them against tampering.

To generate a block's hash, we'll simply hash the concatenated
remaining contents of its header:

```
SHA256 Hash ( previous block hash + transactions hash + timestamp + difficulty target + nonce )
```

Including all of these contents in a block's hash means that tampering with any
1 piece of content will change the hash (and invalidate the block by pushing the hash
back above the allowed difficulty target). Additionally, a block's hash is what places
it in the chain, since any child blocks will refer back to it by "linking" to its
hash. Thus changing a block's hash causes it to become the site of a new "fork"
in the chain, disconnecting any children that had previously linked to it from the
newly altered block.

### Mining Your First Block
