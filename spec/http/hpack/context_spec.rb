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

require 'http/hpack/context'

RSpec.describe HTTP::HPACK::Context do
	let(:context) {HTTP::HPACK::Context.new(table_size: 2048)}

	it 'should be initialized with empty headers' do
		expect(context.table).to be_empty
	end

	context 'processing' do
		[
			['no indexing', :noindex],
			['never indexed', :neverindexed],
		].each do |desc, type|
			context "#{desc}" do
				it 'should process indexed header with literal value' do
					original_table = context.table.dup

					emit = context.decode(name: 4, value: '/path', type: type)
					expect(emit).to eq [':path', '/path']
					expect(context.table).to eq original_table
				end

				it 'should process literal header with literal value' do
					original_table = context.table.dup

					emit = context.decode(name: 'x-custom', value: 'random', type: type)
					expect(emit).to eq ['x-custom', 'random']
					expect(context.table).to eq original_table
				end
			end
		end

		context 'incremental indexing' do
			it 'should process indexed header with literal value' do
				original_table = context.table.dup

				emit = context.decode(name: 4, value: '/path', type: :incremental)
				expect(emit).to eq [':path', '/path']
				expect(context.table - original_table).to eq [[':path', '/path']]
			end

			it 'should process literal header with literal value' do
				original_table = context.table.dup

				context.decode(name: 'x-custom', value: 'random', type: :incremental)
				expect(context.table - original_table).to eq [['x-custom', 'random']]
			end
		end

		context 'size bounds' do
			it 'should drop headers from end of table' do
				context.instance_eval do
					add_to_table(['test1', '1' * 1024])
					add_to_table(['test2', '2' * 500])
				end

				original_table = context.table.dup
				original_size = original_table.join.bytesize + original_table.size * 32

				context.decode(
					name: 'x-custom',
					value: 'a' * (2048 - original_size),
					type: :incremental
				)

				expect(context.table.first[0]).to eq 'x-custom'
				expect(context.table.size).to eq original_table.size # number of entries
			end
		end

		it 'should clear table if entry exceeds table size' do
			context.instance_eval do
				add_to_table(['test1', '1' * 1024])
				add_to_table(['test2', '2' * 500])
			end

			h = {name: 'x-custom', value: 'a', index: 0, type: :incremental}
			e = {name: 'large', value: 'a' * 2048, index: 0}

			context.decode(h)
			context.decode(e.merge(type: :incremental))
			expect(context.table).to be_empty
		end

		it 'should shrink table if set smaller size' do
			context.instance_eval do
				add_to_table(['test1', '1' * 1024])
				add_to_table(['test2', '2' * 500])
			end

			context.decode(type: :changetablesize, value: 1500)
			expect(context.table.size).to be 1
			expect(context.table.first[0]).to eq 'test2'
		end
	end
end
