# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'protocol/hpack/compressor'
require 'protocol/hpack/decompressor'

describe Protocol::HPACK::Compressor do
	let(:buffer) {String.new.b}
	let(:compressor) {subject.new(buffer)}
	let(:decompressor) {Protocol::HPACK::Decompressor.new(buffer)}
	
	it 'should handle indexed representation' do
		headers = {name: 10, type: :indexed}
		compressor.write_header(headers)
		expect(buffer.getbyte(0) & 0x80).to be == 0x80
		expect(buffer.getbyte(0) & 0x7f).to be == headers[:name] + 1
		expect(decompressor.read_header).to be == headers
	end
	
	it 'should raise when decoding indexed representation witheaders index zero' do
		headers = {name: 10, type: :indexed}
		compressor.write_header(headers)
		buffer[0] = 0x80.chr(Encoding::BINARY)
		expect do
			decompressor.read_header
		end.to raise_exception Protocol::HPACK::CompressionError
	end
	
	with 'literal w/o indexing representation' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :no_index}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to be == 0x0
			expect(buffer.getbyte(0) & 0x0f).to be == headers[:name] + 1
			expect(decompressor.read_header).to be == headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :no_index}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to be == 0x0
			expect(buffer.getbyte(0) & 0x0f).to be == 0
			expect(decompressor.read_header).to be == headers
		end
	end
	
	with 'literal w/ incremental indexing' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :incremental}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xc0).to be == 0x40
			expect(buffer.getbyte(0) & 0x3f).to be == headers[:name] + 1
			expect(decompressor.read_header).to be == headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :incremental}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xc0).to be == 0x40
			expect(buffer.getbyte(0) & 0x3f).to be == 0
			expect(decompressor.read_header).to be == headers
		end
	end
	
	with 'literal never indexed' do
		it 'should handle indexed header' do
			headers = {name: 10, value: 'my-value', type: :never_indexed}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to be == 0x10
			expect(buffer.getbyte(0) & 0x0f).to be == headers[:name] + 1
			expect(decompressor.read_header).to be == headers
		end
		
		it 'should handle literal header' do
			headers = {name: 'x-custom', value: 'my-value', type: :never_indexed}
			compressor.write_header(headers)
			expect(buffer.getbyte(0) & 0xf0).to be == 0x10
			expect(buffer.getbyte(0) & 0x0f).to be == 0
			expect(decompressor.read_header).to be == headers
		end
	end
end
