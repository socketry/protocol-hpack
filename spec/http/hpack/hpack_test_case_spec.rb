# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyrigh, 2013, by Ilya Grigorik.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'http/hpack/compressor'
require 'http/hpack/decompressor'

require 'json'

RSpec.describe HTTP::HPACK::Decompressor do
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
		path = File.expand_path("hpack-test-case/#{folder}", __dir__)
		
		context folder.to_s, if: File.directory?(path) do
			Dir.glob(File.join(path, "*.json")) do |path|
				it "should decode #{File.basename(path)}" do
					story = JSON.parse(File.read(path))
					
					cases = story['cases']
					table_size = cases[0]['header_table_size'] || 4096
					
					context = HTTP::HPACK::Context.new(table_size: table_size)
					decompressor = HTTP::HPACK::Decompressor.new(buffer, context)
					
					cases.each do |c|
						buffer << [c['wire']].pack('H*').force_encoding(Encoding::BINARY)
						headers = c['headers'].flat_map(&:to_a)
						
						emitted = decompressor.decode
						expect(emitted).to eq headers
					end
				end
			end
		end
	end
end

RAW_DATA_PATH = File.expand_path('hpack-test-case/raw-data', __dir__)

RSpec.describe HTTP::HPACK::Compressor, if: File.directory?(RAW_DATA_PATH) do
	let(:buffer) {String.new.b}
	
	HTTP::HPACK::MODES.each do |mode, encoding_options|
		[4096, 512].each do |table_size|
			options = {table_size: table_size}
			options.update(encoding_options)

			context "with #{mode} mode and table_size #{table_size}" do
				Dir.glob(File.join(RAW_DATA_PATH, "*.json")) do |path|
					it "should encode #{File.basename(path)}" do
						story = JSON.parse(File.read(path))
						cases = story['cases']
						
						context = HTTP::HPACK::Context.new(**options)
						compressor = HTTP::HPACK::Compressor.new(buffer, context)
						decompressor = HTTP::HPACK::Decompressor.new(buffer)
						
						cases.each do |c|
							headers = c['headers'].flat_map(&:to_a)
							compressor.encode(headers)
							
							decoded = decompressor.decode
							expect(decoded).to eq headers
						end
					end
				end
			end
		end
	end
end
