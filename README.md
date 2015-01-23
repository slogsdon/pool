# Pool
[![Build Status](https://img.shields.io/travis/slogsdon/pool.svg?style=flat)](https://travis-ci.org/slogsdon/pool)
[![Coverage Status](https://img.shields.io/coveralls/slogsdon/pool.svg?style=flat)](https://coveralls.io/r/slogsdon/pool)
[![Hex.pm Version](http://img.shields.io/hexpm/v/pool.svg?style=flat)](https://hex.pm/packages/pool)

> Socket acceptor pool for Elixir

This is in-line with the goals of [Ranch][ranch]
or [barrel][barrel], with the implementations written in
Elixir as opposed to Erlang.

## Hey, Listen!

This isn't ready to be used! I'm hoping for the best,
but don't expect a working version to come out of the
next few commit. I expect this to be an involved
process to get something that works properly and
efficiently.

## TODO

- Listener
- Acceptor
- Transports
  - TCP
  - SSL
  - UDP (?)
  - others?
- Protocol examples

### Listener

- Leverages transport to listen on a port.
  Transport returns the listening socket.
- Creates a list of acceptors for handling
  connections.

### Acceptor

- Utilizes protocol to handle connection.
- Should message listener on start/end of
  accepting connection.

### Protocol

- Interacts with connection via transport.

### Transport

- Interacts with the network transport layers
  by leveraging Erlang built-in modules or by
  constructing raw packets.

## License

Pool is release under the MIT license.

See [LICENSE][license] for details.

[ranch]: https://github.com/ninenines/ranch
[barrel]: https://github.com/benoitc/barrel
[license]: https://github.com/slogsdon/pool/blob/master/LICENSE
