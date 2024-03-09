# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'protocol/hpack/context'

RSpec.describe Protocol::HPACK::Context do
	let(:context) {Protocol::HPACK::Context.new(table_size: 2048)}

	it 'should be initialized with empty headers' do
		expect(context.table).to be_empty
	end

	context 'processing' do
		[
			['no indexing', :no_index],
			['never indexed', :never_indexed],
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

			context.decode(type: :change_table_size, value: 1500)
			expect(context.table.size).to be 1
			expect(context.table.first[0]).to eq 'test2'
		end
	end
end
