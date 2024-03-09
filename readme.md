# Protocol::HPACK

Provides a compressor and decompressor for HTTP 2.0 headers, HPACK, as defined by [RFC7541](https://tools.ietf.org/html/rfc7541).

[![Development Status](https://github.com/socketry/protocol-hpack/workflows/Test/badge.svg)](https://github.com/socketry/protocol-hpack/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'protocol-hpack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install protocol-hpack

## Usage

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

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
