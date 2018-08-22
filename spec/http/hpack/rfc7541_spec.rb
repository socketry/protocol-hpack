
require 'http/hpack/compressor'
require 'http/hpack/decompressor'

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
	
	context HTTP::HPACK::Decompressor do
		fixtures(:decompressor) do |example|
			context example[:title] do
				example[:streams].size.times do |nth|
					context "request #{nth + 1}" do
						let(:context) {HTTP::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:decompressor) {HTTP::HPACK::Decompressor.new(buffer, context)}
						
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
	
	context HTTP::HPACK::Compressor do
		fixtures(:compressor) do |example|
			context example[:title] do
				example[:streams].size.times do |nth|
					context "request #{nth + 1}" do
						let(:context) {HTTP::HPACK::Context.new(huffman: example[:huffman], table_size: example[:table_size])}
						let(:buffer) {String.new.b}
						
						let(:compressor) {HTTP::HPACK::Compressor.new(buffer, context)}
						
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
							expect(subject.unpack('H*').first).to eq example[:streams][nth][:wire].gsub(/\s/, '')
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