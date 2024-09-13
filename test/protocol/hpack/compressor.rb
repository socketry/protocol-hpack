# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2015, by Ilya Grigorik.
# Copyright, 2014, by Kaoru Maeda.
# Copyright, 2015, by Tamir Duberstein.
# Copyright, 2018, by Tiago Cardoso.
# Copyright, 2018, by Byron Formwalt.
# Copyright, 2018-2024, by Samuel Williams.
# Copyright, 2018, by Kenichi Nakamura.
# Copyright, 2019, by Jingyi Chen.

require "protocol/hpack/compressor"
require "protocol/hpack/decompressor"

require "json"

describe Protocol::HPACK::Compressor do
	with "#write_integer" do
		let(:buffer) {String.new.b}
		let(:compressor) {subject.new(buffer)}
		
		with "0-bit prefix" do
			it "can encode the value 10" do
				compressor.write_integer(10, 0)
				expect(buffer).to be == [10].pack("C")
			end
			
			it "can encode the value 1337" do
				compressor.write_integer(1337, 0)
				expect(buffer).to be == [128 + 57, 10].pack("C*")
			end
		end
		
		with "5-bit prefix" do
			it "can encode the value 10" do
				compressor.write_integer(10, 5)
				expect(buffer).to be == [10].pack("C")
			end
			
			it "can encode the value 1337" do
				compressor.write_integer(1337, 5)
				expect(buffer).to be == [31, 128 + 26, 10].pack("C*")
			end
		end
	end
	
	with "#write_string" do
		[
			["with huffman", :always, 0x80],
			["without huffman", :never, 0],
		].each do |description, huffman, msb|
			with description do
				let(:context) {Protocol::HPACK::Context.new(huffman: huffman)}
				let(:buffer) {String.new.b}
				
				let(:compressor) {Protocol::HPACK::Compressor.new(buffer, context)}
				let(:decompressor) {Protocol::HPACK::Decompressor.new(buffer, context)}
				
				[
					["ascii codepoints", "abcdefghij"],
					["utf-8 codepoints", "éáűőúöüó€"],
					["long utf-8 strings", "éáűőúöüó€" * 100],
				].each do |datatype, plain|
					it "should handle #{datatype} #{description}" do
						compressor.write_string(plain)
						expect(buffer.getbyte(0) & 0x80).to be == msb
						
						expect(decompressor.read_string).to be == plain
					end
				end
			end
		end
		
		with "choosing shorter representation" do
			let(:context) {Protocol::HPACK::Context.new(huffman: :shorter)}
			let(:buffer) {String.new.b}
			
			let(:compressor) {Protocol::HPACK::Compressor.new(buffer, context)}
			
			[
				["日本語", :plain],
				["200", :huffman],
				["xq", :plain],   # prefer plain if equal size
			].each do |string, choice|
				it "should return #{choice} representation" do
					compressor.write_string(string)
					expect(buffer.getbyte(0) & 0x80).to be == (choice == :plain ? 0 : 0x80)
				end
			end
		end
	end
	
	with "#encode" do
		let(:path) {File.expand_path("sequence1.json", __dir__)}
		let(:sequence) {JSON.parse(File.read(path))}
		
		let(:encoder) {Protocol::HPACK::Context.new}
		let(:decoder) {Protocol::HPACK::Context.new}
		
		it "can encode with small table size" do
			sequence.each do |headers|
				data = Protocol::HPACK::Compressor.new(String.new.b, encoder, table_size_limit: 512).encode(headers)
				
				expect(Protocol::HPACK::Decompressor.new(data, decoder).decode).to be == headers
				
				expect(encoder.table).to be == decoder.table
			end
			
			expect(decoder.table_size).to be == 512
		end
		
		it "can encode with default table size" do
			sequence.each do |headers|
				data = Protocol::HPACK::Compressor.new(String.new.b, encoder).encode(headers)
				
				expect(Protocol::HPACK::Decompressor.new(data, decoder).decode).to be == headers
				
				expect(encoder.table).to be == decoder.table
			end
		end
		
		it "can encode with large table size" do
			sequence.each do |headers|
				data = Protocol::HPACK::Compressor.new(String.new.b, encoder, table_size_limit: 65536).encode(headers)
				
				expect(Protocol::HPACK::Decompressor.new(data, decoder).decode).to be == headers
				
				expect(encoder.table).to be == decoder.table
			end
			
			expect(decoder.table_size).to be == 65536
		end
		
		it "can encode with random table sizes" do
			sequence.each do |headers|
				table_size = rand(128..65536)
				
				data = Protocol::HPACK::Compressor.new(String.new.b, encoder, table_size_limit: table_size).encode(headers)
				
				expect(Protocol::HPACK::Decompressor.new(data, decoder).decode).to be == headers
				
				expect(encoder.table).to be == decoder.table
			end
		end
	end
end
