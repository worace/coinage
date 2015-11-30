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

We'll follow Bitcoin's lead and use a Public/Private Cryptographic
algorith called the "Elliptic Curve Digital Signature Algorithm" or
ECDSA. There's actually some pretty interesting math behind this which
you can [read up on](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm),
but what we need to know is that it's becoming a go-to algorithm for
public-private key cryptography (as a replacement for RSA which had been the dominant
standard since the 1970's).

To start with a basic wallet implementation, write a program which, when run, will
look for a special hidden file on the user's computer (perhaps `~/.clarke` ?).
If the file exists, the program will expect a valid wallet to exist there in
the form of a public/private key pair. It should read this into memory and print
the public key (in general, we want to avoid printing a private key).

If the program doesn't find this file, it should create it by first generating
a keypair and then writing them to the wallet file.

### Generating a Keypair

To generate keys, we'll want to use a library that implements ECDSA.
In Ruby, [this gem](https://github.com/DavidEGrayson/ruby_ecdsa) is a great
option (Ruby's OpenSSL library does include this, but the API is not very well documented).

Other languages will almost certainly have a convenient library providing
this algorithm as well.

__A Note on Curves:__ One trick with ECDSA is that we need to agree on which
"curve" we're going to use for exchanging keys. Bitcoin uses a curve
called "secp256k1", and we'll follow this convention as well. When
you're generating keypairs with ECDSA make sure you specify this curve.

### 2 - Generating a Transaction

A "transaction" represents a transfer of currency from one address to another.
As we'll see, we use our private key to _sign_ this transfer,
mathematically proving that we are authorized to transfer this money.

Fundamental to creating a Transaction is the idea of "Transaction Outputs" --
individual chunks of currency that are available to be transferred.
When we "spend" coins in Bitcoin, we are actually transferring Transaction Outputs. This
transfer will in turn generate new Transaction Outputs that could
later be spent by the new owner as an input to a different transaction.

Thus we can think of a transaction as a collection of inputs on
one side and outputs on the other.

Where do the original outputs come from? Ultimately we'll be generating
them through the mining process. However for now (since we're starting
at the "bottom" with just wallets and transactions), we'll want
to figure out some way to mock that part out.

#### Transaction Structure

We'll use a modified version of Bitcoin's format for structuring a transaction.
The important pieces of information to include here are the individual transaction
inputs followed by the individual transaction outputs. However since we want
to be able to send a transaction around as an easily-interpreted series
of bits, we'll also need to encode in the message how many inputs and
outputs are included (that way a receiver) knows how many bytes to read for
the transaction.

This breaks the transaction down based on the following sequence:

1. `4 bytes` - **Input Counter** - How many inputs are included
2. `Variable` - **Inputs** - One or more transaction inputs
3. `4 bytes` **Output Counter** - How many outputs are included
4. `Variable` **Outputs** - One or more transaction outputs

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

[Reference](http://bitcoin.stackexchange.com/questions/3374/how-to-redeem-a-basic-tx)
[Ruby Reference](https://gist.github.com/Sjors/5574485)

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
