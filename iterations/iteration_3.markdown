# Iteration 3 - Networking Basics

The previous iterations have been focused on developing the core
data structures and algorithms of our currency system. We're now going
to take a bit of a detour and dive into another very important aspect
of the project -- networking.

One of Bitcoin's fundamental design principles is decentralization.
When we talk about "Bitcoin" as a whole, we're really talking about the emergent behavior of a vast,
worldwide network of computers all running bitcoin client software
and working independently to guide the development of the block chain
and its related data.

The ability of the network to function in this way is one of the most
fundamental strengths of a system like Bitcoin -- since the network
as a whole determines what happens with regard to the block chain,
processing transactions, etc, we don't have to rely on trust in one
single entity to ensure that our system functions properly. However
it also imposes some heavy constraints on the system, as the protocol
and core processes need to be carefully designed to protect the
network from getting into trouble (or from being exploited by attackers).

In this section, we'll learn about some of these network principles
and dig into the nitty gritty of our communication protocol.

## P2P Basics

The first point to emphasize about our networking approach is that it
requires full **peer-to-peer** communication. This may be different from
other network programming you have done in the past, where an asymmetrical,
client/server model tends to be more common.

In a traditional client/server model, the server responds to requests from the
client by sending relevant information, but does not *initiate* requests of its own.
Peer-to-Peer (P2P) networks, by contrast, emphasize symmetrical, bi-directional
communication between nodes. Node A might send a message to Node B and receive
a response, while a few moments later Node B might send a completely unrelated
message to Node A and get a response of its own.

To make another analogy to a traditional client/server model, this means that
in a P2P network each node behaves as both a server *and* a client. As a server
the node will receive messages from other nodes and send appropriate responses,
but as a client it will initiate its own requests as needed.

## Transit Mechanism and Formats (TCP / JSON)

## Message Types

## Automated TCP Protocol Spec

##
