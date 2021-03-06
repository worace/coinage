## ClarkeCoin -- Cryptocurrency for normal programmers

This is an ongoing project to implement a simplistic cryptocurrency
network modeled after Bitcoin but streamlined for the purpose of
being easier to follow (and build). As we go we'll be learning about
the core ideas that make Bitcoin work, and getting a lot of practice
with some interesting algorithmic and cryptographic problems.

### Background Reading

If you're new to the ideas of cryptocurrencies in general, these
are some great resources to get you started. The **Minimum Viable
Blockchain** article especially is a great crash course for someone
new to the ideas.

* [Minimum Viable Blockchain](https://www.igvita.com/2014/05/05/minimum-viable-block-chain/) -
This article by Ilya Grigorik gives a great, fairly short overview of the main concepts in bitcoin
* [Bitcoin for the Befuddled](https://www.nostarch.com/bitcoinforthebefuddled) - Another good high level
overview of bitcoin that goes more in depth than Ilya's article.
* [Mastering Bitcoin: Unlocking Digital Cryptocurrencies](http://www.amazon.com/gp/product/1449374042)
This is a great in-depth look at the technical systems behind Bitcoin. This will be our main reference point
when we get stuck on technical questions.
* [Understanding Elliptic Curve Cryptography](https://blog.cloudflare.com/a-relatively-easy-to-understand-primer-on-elliptic-curve-cryptography/)
* [Working with TCP Sockets](http://www.jstorimer.com/products/working-with-tcp-sockets) - For the
peer-to-peer networking portions of our system, we'll need to use TCP sockets to communicate between
nodes in the network. This book has a good overview of these techniques, focused on ruby

### Conceptual Overview

This [notes doc](https://github.com/worace/coinage/blob/master/notes.md) has
a high-level overview of many of the issues we'll need to solve during the
project.

### Project Iterations

* **[Iteration 0](https://github.com/worace/coinage/blob/master/iterations/iteration_0.markdown)** - Creating Wallets and Signing/Serializing Transactions
* **[Iteration 1](https://github.com/worace/coinage/blob/master/iterations/iteration_1.markdown)** - Creating and Mining Blocks
* **[Iteration 2](https://github.com/worace/coinage/blob/master/iterations/iteration_2.markdown)** - Working with the BlockChain -- checking balances and generating payment transactions
* **[Iteration 3](https://github.com/worace/coinage/blob/master/iterations/iteration_3.markdown)** - Networking Basics -- connecting with TCP and handling basic message types
* **Iteration 4** - Validating Incoming Transactions and Blocks
* **Iteration 5** - Extended Networking: Discovering Additional Peers and Forwarding Valid Blocks and Transactions
* **Iteration 6** - Mining: Aggregating Transactions and Solving Blocks
* **Iterations 7+** - Advanced Topics - Mining optimizations, Base58-Check encoding, multi-address wallets,
Wallet GUI, Node DNS Server, etc.

### Knowns and Unknowns

Anyone who's spent much time at Turing knows we try to be very comfortable
"operating in uncertainty." This is definitely an experiment and there will
certainly be hiccups along the way. Most importantly, there will be much less
handholding throughout the process than in standard Turing projects.

I have a general plan and rough design for how each system will work, but
it's going to be up to all of us to collectively work out the details along
the way. I'll be directing lots of questions to the group and relying on
our collective problem-solving ability to resolve them.

