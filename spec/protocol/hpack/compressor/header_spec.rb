# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

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
