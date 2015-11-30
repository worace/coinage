## Unknowns / TODOs (Numerous and Deep)

__Q:__ How do network nodes communicate?

* Needs to be peer-to-peer
* Working only LAN keeps things simple and works for our
intended educational purpose

__Q:__ How do nodes discover one another?

* To keep it truly decentralized it needs to do without
any bootstrap server
* UDP Multicast seems promising -- on connecting to network
(and certain other events), peers can broadcast to network to
find other nodes

__Q:__ What does each block contain

* list of transactions
* Signature of generating node
* Hash of previous block
* [More Info](https://www.igvita.com/2014/05/05/minimum-viable-block-chain/)
* timestamp?

__Q:__ What does bootstrapping a client/node look like?

* Needs public/private keypair?
* Needs to pull existing blockchain from multiple peers

__Q:__ How current balances get calculated?

* Replay ledger from beginning to now; miners
are identified by their...(public key? some signature?)

__Q:__ How does a transaction get signed?

__Q:__ How does a block get signed?

__Q:__ How do nodes distribute log updates?

__Q:__ How do nodes agree on current target?

* Generate next target as function of frequency of
recent blocks
* Desired block frequency is coded into clients?
* is it ok for this to be static?

__Q:__ Is RSA ok for signing?

* ECDSA needed?

__Q:__ What would be required to take it out of LAN?

* TCP punching?
* What is the bootstrapping/discovery mechanism?

## License

Copyright © 2015 Horace Williams

Distributed under the Eclipse Public License either version 1.0 or (at
your option) any later version.
