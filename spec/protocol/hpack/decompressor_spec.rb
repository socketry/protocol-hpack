# frozen_string_literal: true

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
