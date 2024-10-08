# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "protocol/hpack/decompressor"
require "protocol/hpack/compressor"

describe Protocol::HPACK::Decompressor do
	let(:buffer) {String.new.b}
	let(:compressor) {Protocol::HPACK::Compressor.new(buffer)}
	
	with "limited table size" do
		let(:decompressor) {subject.new(buffer, table_size_limit: 256)}
		
		it "should reject table size update if exceed limit" do
			expect(decompressor.table_size_limit).to be == 256
			
			compressor.write_header({type: :change_table_size, value: 512})
			
			expect do
				decompressor.read_header
			end.to raise_exception(Protocol::HPACK::CompressionError,  message: be =~ /limit/)
		end
	end
	
	with "#read_integer" do
		let(:decompressor) {subject.new(buffer)}
		
		with "0-bit prefix" do
			it "can decode the value 10" do
				buffer << [10].pack("C")
				expect(decompressor.read_integer(0)).to be == 10
			end
			
			it "can decode the value 1337" do
				buffer << [128 + 57, 10].pack("C*")
				expect(decompressor.read_integer(0)).to be == 1337
			end
		end
		
		with "5-bit prefix" do
			it "can decode the value 10" do
				buffer << [10].pack("C")
				expect(decompressor.read_integer(5)).to be == 10
			end
			
			it "can decode the value 1337" do
				buffer << [31, 128 + 26, 10].pack("C*")
				expect(decompressor.read_integer(5)).to be == 1337
			end
		end
	end
	
	with "with trailing table size command" do
		let(:decompressor) {subject.new(buffer, table_size_limit: 256)}
		
		it "should raise error" do
			compressor.write_header({type: :change_table_size, value: 256})
			
			expect do
				decompressor.decode
			end.to raise_exception(Protocol::HPACK::CompressionError, message: be =~ /Trailing table size update/)
		end
	end
end
