# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Kaoru Maeda.
# Copyright, 2014-2016, by Ilya Grigorik.
# Copyright, 2015, by Tamir Duberstein.
# Copyright, 2016, by Kien Nguyen Trung.
# Copyright, 2018-2024, by Samuel Williams.

require "protocol/hpack/compressor"
require "protocol/hpack/decompressor"

require "json"

describe Protocol::HPACK::Decompressor do
	folders = %w(
		go-hpack
		haskell-http2-diff
		haskell-http2-diff-huffman
		haskell-http2-linear
		haskell-http2-linear-huffman
		haskell-http2-naive
		haskell-http2-naive-huffman
		haskell-http2-static
		haskell-http2-static-huffman
		nghttp2
		nghttp2-16384-4096
		nghttp2-change-table-size
		node-http2-hpack
	)
	
	let(:buffer) {String.new.b}
	
	folders.each do |folder|
		root = File.expand_path("fixtures/#{folder}", __dir__)
		
		with folder.to_s, if: File.directory?(root) do
			Dir.glob(File.join(root, "*.json")) do |path|
				it "should decode #{File.basename(path)}" do
					story = JSON.parse(File.read(path))
					
					cases = story["cases"]
					table_size = cases[0]["header_table_size"] || 4096
					
					context = Protocol::HPACK::Context.new(table_size: table_size)
					decompressor = Protocol::HPACK::Decompressor.new(buffer, context)
					
					cases.each do |c|
						buffer << [c["wire"]].pack("H*").force_encoding(Encoding::BINARY)
						headers = c["headers"].flat_map(&:to_a)
						
						emitted = decompressor.decode
						expect(emitted).to be == headers
					end
				end
			end
		end
	end
end

describe Protocol::HPACK::Compressor do
	root = File.expand_path("fixtures/raw-data", __dir__)
	
	let(:buffer) {String.new.b}
	
	Protocol::HPACK::MODES.each do |mode, encoding_options|
		[4096, 512].each do |table_size|
			options = {table_size: table_size}
			options.update(encoding_options)
			
			with "#{mode} mode and table_size #{table_size}" do
				Dir.glob(File.join(root, "*.json")) do |path|
					it "should encode #{File.basename(path)}" do
						story = JSON.parse(File.read(path))
						cases = story["cases"]
						
						context = Protocol::HPACK::Context.new(**options)
						compressor = Protocol::HPACK::Compressor.new(buffer, context)
						decompressor = Protocol::HPACK::Decompressor.new(buffer)
						
						cases.each do |c|
							headers = c["headers"].flat_map(&:to_a)
							compressor.encode(headers)
							
							decoded = decompressor.decode
							expect(decoded).to be == headers
						end
					end
				end
			end
		end
	end
end
