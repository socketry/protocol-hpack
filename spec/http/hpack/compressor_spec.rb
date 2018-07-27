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

require 'http/hpack/compressor'
require 'http/hpack/decompressor'

RSpec.describe HTTP::HPACK::Compressor do
	describe '#write_integer' do
		let(:buffer) {String.new.b}
		subject {described_class.new(buffer)}
		
		context '0-bit prefix' do
			it "can encode the value 10" do
				subject.write_integer(10, 0)
				expect(buffer).to be == [10].pack('C')
			end
			
			it "can encode the value 1337" do
				subject.write_integer(1337, 0)
				expect(buffer).to be == [128 + 57, 10].pack('C*')
			end
		end
		
		context '5-bit prefix' do
			it "can encode the value 10" do
				subject.write_integer(10, 5)
				expect(buffer).to be == [10].pack('C')
			end
			
			it "can encode the value 1337" do
				subject.write_integer(1337, 5)
				expect(buffer).to be == [31, 128 + 26, 10].pack('C*')
			end
		end
	end
	
	describe '#write_string' do
		[
			['with huffman', :always, 0x80],
			['without huffman', :never, 0],
		].each do |description, huffman, msb|
			context description do
				[
					['ascii codepoints', 'abcdefghij'],
					['utf-8 codepoints', 'éáűőúöüó€'],
					['long utf-8 strings', 'éáűőúöüó€' * 100],
				].each do |datatype, plain|
					let(:context) {HTTP::HPACK::Context.new(huffman: huffman)}
					let(:buffer) {String.new.b}
					
					subject {HTTP::HPACK::Compressor.new(buffer, context)}
					let(:decompressor) {HTTP::HPACK::Decompressor.new(buffer, context)}
					
					it "should handle #{datatype} #{description}" do
						subject.write_string(plain)
						expect(buffer.getbyte(0) & 0x80).to eq msb
						
						expect(decompressor.read_string).to eq plain
					end
				end
			end
		end
		
		context 'choosing shorter representation' do
			let(:context) {HTTP::HPACK::Context.new(huffman: :shorter)}
			let(:buffer) {String.new.b}
			
			subject {HTTP::HPACK::Compressor.new(buffer, context)}
			
			[
				['日本語', :plain],
				['200', :huffman],
				['xq', :plain],   # prefer plain if equal size
			].each do |string, choice|
				it "should return #{choice} representation" do
					subject.write_string(string)
					expect(buffer.getbyte(0) & 0x80).to eq(choice == :plain ? 0 : 0x80)
				end
			end
		end
	end
end
