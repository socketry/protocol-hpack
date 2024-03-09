# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Kaoru Maeda.
# Copyright, 2015, by Tamir Duberstein.
# Copyright, 2015, by Ilya Grigorik.
# Copyright, 2018-2024, by Samuel Williams.

require 'protocol/hpack/huffman'

RSpec.describe Protocol::HPACK::Huffman do
	huffman_examples = [ # plain, encoded
		['www.example.com', 'f1e3c2e5f23a6ba0ab90f4ff'],
		['no-cache',        'a8eb10649cbf'],
		['Mon, 21 Oct 2013 20:13:21 GMT', 'd07abe941054d444a8200595040b8166e082a62d1bff'],
	]
	
	context 'encode' do
		huffman_examples.each do |plain, encoded|
			it "should encode #{plain} into #{encoded}" do
				expect(subject.encode(plain).unpack1('H*')).to eq encoded
			end
		end
	end
	
	context 'decode' do
		huffman_examples.each do |plain, encoded|
			it "should decode #{encoded} into #{plain}" do
				expect(subject.decode([encoded].pack('H*'))).to eq plain
			end
		end

		[
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0',
			'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'http://www.craigslist.org/about/sites/',
			'cl_b=AB2BKbsl4hGM7M4nH5PYWghTM5A; cl_def_lang=en; cl_def_hp=shoals',
			'image/png,image/*;q=0.8,*/*;q=0.5',
			'BX=c99r6jp89a7no&b=3&s=q4; localization=en-us%3Bus%3Bus',
			'UTF-8でエンコードした日本語文字列',
		].each do |string|
			it "should encode then decode '#{string}' into the same" do
				encoded = subject.encode(string.b)
				expect(subject.decode(encoded)).to eq string.b
			end
		end
		
		it 'should encode/decode all_possible 2-byte sequences' do
			(2**16).times do |n|
				string = [n].pack('V')[0, 2].b
				
				expect(subject.decode(subject.encode(string))).to eq string
			end
		end
		
		it 'should raise when input is shorter than expected' do
			encoded = huffman_examples.first.last
			encoded = [encoded].pack('H*')
			
			expect do
				subject.decode(encoded[0...-1].b)
			end.to raise_error(/EOS invalid/)
		end
		
		it 'should raise when input is not padded by 1s' do
			# note the fe at end
			encoded = 'f1e3c2e5f23a6ba0ab90f4fe'
			encoded = [encoded].pack('H*')
			
			expect do
				subject.decode(encoded.b)
			end.to raise_error(/EOS invalid/)
		end
		
		it 'should raise when exceedingly padded' do
			# note the extra ff
			encoded = 'e7cf9bebe89b6fb16fa9b6ffff'
			encoded = [encoded].pack('H*')
			
			expect do
				subject.decode(encoded.b)
			end.to raise_error(/EOS invalid/)
		end
		
		it 'should raise when EOS is explicitly encoded' do
			# a b EOS
			encoded = ['1c7fffffffff'].pack('H*')
			
			expect do
				subject.decode(encoded.b)
			end.to raise_error(/EOS found/)
		end
	end
end
