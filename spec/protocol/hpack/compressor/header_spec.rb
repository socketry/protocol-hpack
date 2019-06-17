# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyrigheaders, 2013, by Ilya Grigorik.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publisheaders, distribute, sublicense, and/or sell
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

require 'protocol/hpack/compressor'
require 'protocol/hpack/decompressor'

RSpec.describe Protocol::HPACK::Compressor do
	let(:buffer) {String.new.b}
	subject(:compressor) {described_class.new(buffer)}
	let(:decompressor) {Protocol::HPACK::Decompressor.new(buffer)}
	
	it 'should handle indexed representation' do
		headers = {name: 10, type: :indexed}
		compressor.write_header(headers)
		expect(buffer.getbyte(0) & 0x80).to eq 0x80
		expect(buffer.getbyte(0) & 0x7f).to eq headers[:name] + 1
		expect(decompressor.read_header).to eq headers
	end
	
	it 'should raise when decoding indexed representation witheaders index zero' do
		headers = {name: 10, type: :indexed}
		compressor.write_header(headers)
		buffer[0] = 0x80.chr(Encoding::BINARY)
		expect do
			decompressor.read_header
		end.to raise_error Protocol::HPACK::CompressionError
	end
	
	context 'literal w/o indexing representation' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :no_index}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to eq 0x0
			expect(buffer.getbyte(0) & 0x0f).to eq headers[:name] + 1
			expect(decompressor.read_header).to eq headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :no_index}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to eq 0x0
			expect(buffer.getbyte(0) & 0x0f).to eq 0
			expect(decompressor.read_header).to eq headers
		end
	end
	
	context 'literal w/ incremental indexing' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :incremental}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xc0).to eq 0x40
			expect(buffer.getbyte(0) & 0x3f).to eq headers[:name] + 1
			expect(decompressor.read_header).to eq headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :incremental}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xc0).to eq 0x40
			expect(buffer.getbyte(0) & 0x3f).to eq 0
			expect(decompressor.read_header).to eq headers
		end
	end
	
	context 'literal never indexed' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :never_indexed}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to eq 0x10
			expect(buffer.getbyte(0) & 0x0f).to eq headers[:name] + 1
			expect(decompressor.read_header).to eq headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :never_indexed}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to eq 0x10
			expect(buffer.getbyte(0) & 0x0f).to eq 0
			expect(decompressor.read_header).to eq headers
		end
	end
end
