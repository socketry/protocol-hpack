# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'protocol/hpack/compressor'
require 'protocol/hpack/decompressor'

require 'yaml'

RSpec.describe "RFC7541" do
	def self.fixtures(mode)
		Dir.glob(File.expand_path("rfc7541/*.yaml", __dir__)) do |path|
			fixture = YAML::load_file(path)
			
			if only = fixture[:only]
				next unless only == mode
			end
			
			yield fixture
		end
	end
	
	context Protocol::HPACK::Decompressor do
		fixtures(:decompressor) do |example|
			context example[:title] do
				example[:streams].size.times do |nth|
					context "request #{nth + 1}" do
						let(:context) {Protocol::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:decompressor) {Protocol::HPACK::Decompressor.new(buffer, context)}
						
						before do
							(0...nth).each do |i|
								buffer << [example[:streams][i][:wire].gsub(/\s/, '')].pack('H*')
								decompressor.decode
							end
						end
						
						let(:bytes) {[example[:streams][nth][:wire].gsub(/\s/, '')].pack('H*')}
						
						subject! do
							buffer << bytes
							decompressor.decode
						end
						
						it 'should emit expected headers' do
							expect(subject).to eq example[:streams][nth][:emitted]
						end
						
						it 'should update header table' do
							expect(context.table).to eq example[:streams][nth][:table]
						end
						
						it 'should compute header table size' do
							expect(context.current_table_size).to eq example[:streams][nth][:table_size]
						end
					end
				end
			end
		end
	end
	
	context Protocol::HPACK::Compressor do
		fixtures(:compressor) do |example|
			context example[:title] do
				example[:streams].size.times do |nth|
					context "request #{nth + 1}" do
						let(:context) {Protocol::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:compressor) {Protocol::HPACK::Compressor.new(buffer, context)}
						
						before do
							(0...nth).each do |i|
								compressor.encode(example[:streams][i][:emitted])
							end
						end
						
						subject! do
							buffer.clear
							
							compressor.encode(example[:streams][nth][:emitted])
							
							buffer
						end
						
						it 'should emit expected bytes' do
							expect(subject.unpack1('H*')).to eq example[:streams][nth][:wire].gsub(/\s/, '')
						end
						
						it 'should update header table' do
							expect(context.table).to eq example[:streams][nth][:table]
						end
						
						it 'should compute header table size' do
							expect(context.current_table_size).to eq example[:streams][nth][:table_size]
						end
					end
				end
			end
		end
	end
end
