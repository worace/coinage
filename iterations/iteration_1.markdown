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

When encoding a transaction output into a transaction, we'll use
the following format:

1. `8 bytes` - **Amount** - Value of the output
2. `65 bytes` - **Receiving Address** - ECDSA Public Key to
which the transaction is being assigned. In order to spend
the output as an input to a subsequent transaction, the owner
will have to produce a valid signature for this transaction.

#### Transaction Input Strucutre

When we want to "spend" a chunk of bitcoin that was transferred
to us in a previous transaction, we'll use it as an "input"
to a new transaction. When doing this, we'll talk about transaction
"inputs", but it's important to remember that transaction inputs
are really just outputs generated in previous transactions.

1. `32 bytes` - **Transaction Hash** - SHA256 hash of the transaction
that contains the trnasaction Output beign spent in this input
2. `4 bytes` - **Transaction Output Index** - The numeric index of
the specific output within the identified transaction which is being
spent
3. `70 bytes` - **Output Signature** - ECDSA Signature of the Public Key
(address) to which the original output was assigned. Other users can verify
this signature thus proving that the signing user has the authority to spend
the specified output.

### Transaction Example

__TODO__ - Include detailed walkthrough of an example transaction

* [Reference](http://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx)
* [Ruby Reference](https://gist.github.com/Sjors/5574485)

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
