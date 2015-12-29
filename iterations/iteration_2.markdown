# Iteration 2 - Working with the BlockChain

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
