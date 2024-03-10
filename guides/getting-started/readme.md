# Getting Started

This guide explains how to use the `protocol-hpack` gem to compress and decompress HTTP/2 headers using HPACK.

## Installation

Add the gem to your project:

``` shell
$ bundle add protocol-hpack
```

Or install it yourself as:

``` shell
$ gem install protocol-hpack
```

## Core Concepts

The `protocol-hpack` gem provides a {ruby Protocol::HPACK::Compressor} and {ruby Protocol::HPACK::Decompressor} for HTTP 2 headers, HPACK, as defined by [RFC7541](https://tools.ietf.org/html/rfc7541).

HPACK is a compression format designed specifically for HTTP/2 to reduce header size and improve performance by minimizing overhead. It addresses the redundancy and repetitive nature of HTTP/1.x headers by employing a static table of common header fields and a dynamic table that evolves based on the headers seen in a particular connection. Headers are encoded into a more compact format, using Huffman coding for literal values and indexing to refer to previously transmitted headers. This approach significantly reduces the amount of data transmitted between client and server, especially in contexts where headers are similar or identical across multiple requests and responses. HPACK's design directly tackles the inefficiencies of HTTP/1.x headers, providing a more bandwidth-efficient and faster web experience by optimizing the way headers are transmitted in HTTP/2 connections.

### Compressing Headers

``` ruby
require 'protocol/hpack'

buffer = String.new.b
compressor = Protocol::HPACK::Compressor.new(buffer)

compressor.encode([['content-length', '5']])
=> "\\\x015"
```

### Decompressing Headers

Reusing `buffer` from above:

``` ruby
require 'protocol/hpack'

# Buffer from above...
buffer = "\\\x015"
decompressor = Protocol::HPACK::Decompressor.new(buffer)

decompressor.decode
=> [["content-length", "5"]]
```
