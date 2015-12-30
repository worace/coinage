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

## Identifying Unspent Transaction Outputs

* "Index" outputs with coordinates (include tx id hash and index)
* Search collection of inputs to see which ones reference your outputs
* Outputs that have no inputs referencing them are unspent

## Checking Balances

* take in the Key you want to check
* select all the outputs assigned to that key
* select all of those outputs which are also unspent
* add up the amount of each output
* => balance

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
