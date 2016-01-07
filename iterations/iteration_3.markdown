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

So how will all this work from a technical perspective? For our network, we'll
be using [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) as a
*transit protocol* to send data over the network between nodes. Each node will
need to run a simple TCP Server in order to field requests from other nodes.
Additionally, for every *peer* to which a node wants to connect, they will need
to create a TCP Client that connects to that node at the appropriate IP Address
and Port.

As for the actual messages themselves, we'll be using JSON as a serialization
format. In fact, all messages will follow a simple JSON format including a
`message_type` that identifies the kind of message being sent and an optional `payload`
that includes any necessary information.

So an example message might look like:

```json
{
  "message_type": "add_peer",
  "payload": "10.0.1.2:3000"
}
```

__Why these technologies?__

There are a variety of transit protocols and serialization formats out there that
we could choose from. We choose TCP because it has great built-in procedures for
ensuring reliability of the messages -- for example the protocol is able to intelligently
retry certain packets if they fail due to network issues, etc. Additionally, TCP defines
robust procedures for splitting arbitrary messages across packets and guaranteeing that
these packets will arrive in the proper order to avoid garbling our data.
Finally TCP is a very common and well-supported protocol, and you'll find reliable tools
for working with it in any major programming language.

As for JSON, it's an extremely popular serialization format these days, and has the
additional advantage of being extremely human-readable. If we were more concerned with
efficiency and performance (both from a speed and bandwidth perspective), we might want
to investigate a dedicated binary protocol (as the actual Bitcoin protocol uses), but
for our purposes we are more interested in clarity and ease of use.

## Accepting and Sending Messages

To start, our node will want to be able to accept messages from other nodes. To do
this, we'll open a TCP Server on a port -- say, `8334` -- and accept connections
on it. Fortunately most programming languages include a library to make this
fairly straightforward. In ruby, it looks like:

```ruby
require "socket"
Socket.tcp_server_loop(8334) do |conn|
  puts conn.read
  conn.close
end
```

Then, to send data to this socket, we would need to open a TCP socket
and write to it (you can try this in a separate pry terminal if you like):

```ruby
require "socket"
s = TCPSocket.new("localhost",8334)
s.write("hi there")
s.close
```

If you were running both processes, you should see your message show up!

## Sending Actual Messages

As we mentioned, we'll use JSON to format and transmit our messages. We
can easily use this to serialize and parse the messages we send and receive,
but there's one more thing to consider. A common problem with communication
over TCP is determining when a client is done sending data.

In our previous example, the `write` line transmits data over the socket, but
the server's `read` call won't actually complete until the client is finished
sending information. In this case, we signify that by closing the socket --
this sends a special `EOF` message indicating the stream is closed, so our server
knows to stop reading and process the information that has been sent so far.

That works well when we don't need to do anything else with the socket, but in
our case we'll likely want to *receive* data from the socket in response to
the data we just sent. To do that we need to keep the socket open until the
server is done sending, and thus we can't rely on closing the socket to
signify end of transmission.

Instead, we'll adopt the convention of ending all messages with a double
newline: `\n\n`. This allows peers to read our messages line by line.
When a completely blank line is discovered, they will know to stop reading
and process our message.

So...to send an actual message we need to do 2 things:

1. Encode our message as json
2. Append the end-sequence (`\n\n`) to the end of the message

When receiving messages, we'll also need to process them appropriately.
This entails:

1. Read from the incoming socket line by line
2. When a blank line (only containing `\n`) is encountered, stop reading

#### Example

__Server:__

```ruby
require "socket"
require "json"

Socket.tcp_server_loop(8334) do |conn|
  while line = conn.gets
    break if line == "\n"
    puts JSON.parse(line.chomp).inspect
  end
  conn.write("response goes here")
  conn.close
end
```

__Client:__

```ruby
require "socket"
require "json"
s = TCPSocket.new("localhost",8334)
message = {message_type: "free_form_text", payload: "hi again"}
s.write(message.to_json + "\n\n")
puts s.read
s.close
```

Now your clients can send structured messages to the server and the
server can use JSON to parse them and determine the intent.

__Note__

Don't forget that when using the terms "client" and "server" we're really
describing the "sending" role or the "receiving" role of our 2-way
peer-to-peer communication model.

Our actual client programs will engage alternately as both clients and servers,
depending on whether they are trying to send a message or receive one.

## Message Types

## Automated TCP Protocol Spec

##
