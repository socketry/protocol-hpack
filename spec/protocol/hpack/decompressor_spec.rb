# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2020, by Samuel Williams.

require 'protocol/hpack/decompressor'
require 'protocol/hpack/compressor'

RSpec.describe Protocol::HPACK::Decompressor do
	let(:buffer) {String.new.b}
	let(:compressor) {Protocol::HPACK::Compressor.new(buffer)}
	
	context "limited table size" do
		subject {described_class.new(buffer, table_size_limit: 256)}
		
		it 'should reject table size update if exceed limit' do
			expect(subject.table_size_limit).to be == 256
			
			compressor.write_header({type: :change_table_size, value: 512})
			
			expect do
				subject.read_header
			end.to raise_error(Protocol::HPACK::CompressionError, /limit/)
		end
	end
	
	describe '#read_integer' do
		subject {described_class.new(buffer)}
		
		context '0-bit prefix' do
			it "can decode the value 10" do
				buffer << [10].pack('C')
				expect(subject.read_integer(0)).to be == 10
			end
			
			it "can decode the value 1337" do
				buffer << [128 + 57, 10].pack('C*')
				expect(subject.read_integer(0)).to be == 1337
			end
		end
		
		context '5-bit prefix' do
			it "can decode the value 10" do
				buffer << [10].pack('C')
				expect(subject.read_integer(5)).to be == 10
			end
			
			it "can decode the value 1337" do
				buffer << [31, 128 + 26, 10].pack('C*')
				expect(subject.read_integer(5)).to be == 1337
			end
		end
	end
end
