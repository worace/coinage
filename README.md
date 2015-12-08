## Turing Cryptocurrency Elective

This module, I am going to try an experiment in offering a more focused,
long-running alternative to DSA. We'll be learning about BitCoin and
other cryptocurrencies by building our own simplistic cryptocurrency at Turing.

Some main points:

* Continuing participation depends on completing required iterations and assignments
* We will meet twice a week in organized sessions, but most of the work will be
done on your own time outside of class

### Course Materials

These will be some of our main reference materials throughout the course.
We can probably get Turing to order some class copies to share around.

* [Minimum Viable Blockchain](https://www.igvita.com/2014/05/05/minimum-viable-block-chain/) -
This article by Ilya Grigorik gives a great, fairly short overview of the main concepts in bitcoin
* [Working with TCP Sockets](http://www.jstorimer.com/products/working-with-tcp-sockets) - For the
peer-to-peer networking portions of our system, we'll need to use TCP sockets to communicate between
nodes in the network. This book has a good overview of these techniques, focused on ruby
* [Bitcoin for the Befuddled](https://www.nostarch.com/bitcoinforthebefuddled) - Another good high level
overview of bitcoin that goes more in depth than Ilya's article.
* [Mastering Bitcoin: Unlocking Digital Cryptocurrencies](http://www.amazon.com/gp/product/1449374042)
This is a great in-depth look at the technical systems behind Bitcoin. This will be our main reference point
when we get stuck on technical questions.
* [Understanding Elliptic Curve Cryptography](https://blog.cloudflare.com/a-relatively-easy-to-understand-primer-on-elliptic-curve-cryptography/)

### Schedule

We'll meet as a group twice a week. My current plan is for these to happen
Mondays from 4:15 - 6:00 and on Fridays from 9:00 - 11:00, with the
Friday session being in place of normal Friday review sessions.

### Knowns and Unknowns

Anyone who's spent much time at Turing knows we try to be very comfortable
"operating in uncertainty." This is definitely an experiment and there will
certainly be hiccups along the way. Most importantly, there will be much less
handholding throughout the process than in standard Turing projects.

I have a general plan and rough design for how each system will work, but
it's going to be up to all of us to collectively work out the details along
the way. I'll be directing lots of questions to the group and relying on
our collective problem-solving ability to resolve them.

### Conceptual Overview

This [notes doc](https://github.com/worace/coinage/blob/master/notes.md) has
a high-level overview of many of the issues we'll need to solve during the
project.

### Participation / Admission

Currently I'm planning to open the course to 10 - 12 students from Modules 2 - 4. Once
I assess interest we'll figure out if some sort of selection system is needed.

### Project Iterations

* **[Iteration 0](https://github.com/worace/coinage/blob/master/iterations/iteration_0.markdown)** - Creating Wallets and Signing/Serializing Transactions
* **[Iteration 1](https://github.com/worace/coinage/blob/master/iterations/iteration_1.markdown)** - Creating Blocks
* **Iteration 2** - Networking Basics and Publishing Transactions to Single Peer
* **Iteration 3** - Publishing Blocks to Single Peer
* **Iteration 4** - Validating Incoming Transactions and Blocks
* **Iteration 5** - Extended Networking: Discovering Additional Peers and Forwarding Valid Blocks and Transactions
* **Iteration 6** - Mining: Aggregating Transactions and Solving Blocks
* **Iterations 7+** - Advanced Topics - Mining optimizations, Base58-Check encoding, multi-address wallets,
Wallet GUI, Node DNS Server, etc.
