# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.
# Copyright, 2024, by Maruth Goyal.

require "protocol/hpack/compressor"
require "protocol/hpack/decompressor"

require "yaml"

describe "RFC7541" do
	def self.fixtures(mode)
		Dir.glob(File.expand_path("rfc7541/*.yaml", __dir__)) do |path|
			fixture = YAML::load_file(path)
			
			if only = fixture[:only]
				next unless only == mode
			end
			
			yield fixture
		end
	end
	
	with Protocol::HPACK::Decompressor do
		fixtures(:decompressor) do |example|
			with example[:title] do
				example[:streams].size.times do |nth|
					with "request #{nth + 1}" do
						let(:context) {Protocol::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:decompressor) {Protocol::HPACK::Decompressor.new(buffer, context)}
						
						before do
							(0...nth).each do |i|
								buffer << [example[:streams][i][:wire].gsub(/\s/, "")].pack("H*")
								decompressor.decode
							end
							
							bytes = [example[:streams][nth][:wire].gsub(/\s/, "")].pack("H*")
							buffer << bytes
							
							@output = decompressor.decode
						end
						
						it "should emit expected headers" do
							expect(@output).to be == example[:streams][nth][:emitted]
						end
						
						it "should update header table" do
							expect(context.table).to be == example[:streams][nth][:table]
						end
						
						it "should compute header table size" do
							expect(context.compute_current_table_size).to be == example[:streams][nth][:table_size]
						end
					end
				end
			end
		end
	end
	
	with Protocol::HPACK::Compressor do
		fixtures(:compressor) do |example|
			with example[:title] do
				example[:streams].size.times do |nth|
					with "request #{nth + 1}" do
						let(:context) {Protocol::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:compressor) {Protocol::HPACK::Compressor.new(buffer, context)}
						
						before do
							(0...nth).each do |i|
								compressor.encode(example[:streams][i][:emitted])
							end
							
							buffer.clear
							
							compressor.encode(example[:streams][nth][:emitted])
						end
						
						it "should emit expected bytes" do
							expect(buffer.unpack1("H*")).to be == example[:streams][nth][:wire].gsub(/\s/, "")
						end
						
						it "should update header table" do
							expect(context.table).to be == example[:streams][nth][:table]
						end
						
						it "should compute header table size" do
							expect(context.compute_current_table_size).to be == example[:streams][nth][:table_size]
						end
					end
				end
			end
		end
	end
end
