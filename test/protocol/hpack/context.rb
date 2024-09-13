# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "protocol/hpack/context"

describe Protocol::HPACK::Context do
	let(:context) {Protocol::HPACK::Context.new(table_size: 2048)}

	it "should be initialized with empty headers" do
		expect(context.table).to be(:empty?)
	end
	
	with "#dup" do
		it "duplicates mutable table state" do
			context.instance_eval do
				add_to_table(["test1", "1"])
				add_to_table(["test2", "2"])
			end

			dup = context.dup
			expect(dup.table).to be == context.table
			expect(dup.table).not.to be_equal(context.table)
		end
	end
	
	with "#dereference" do
		it "raises an error if the index is out of bounds" do
			expect do
				context.dereference(1024)
			end.to raise_exception(Protocol::HPACK::Error)
		end
	end
	
	with "#decode" do
		it "raises an error if the command is invalid" do
			expect do
				context.decode(name: 0, value: "test", type: :invalid)
			end.to raise_exception(Protocol::HPACK::Error)
		end
	end
	
	with "processing" do
		[
			["no indexing", :no_index],
			["never indexed", :never_indexed],
		].each do |description, type|
			with description do
				it "should process indexed header with literal value" do
					original_table = context.table.dup

					emit = context.decode(name: 4, value: "/path", type: type)
					expect(emit).to be == [":path", "/path"]
					expect(context.table).to be == original_table
				end

				it "should process literal header with literal value" do
					original_table = context.table.dup

					emit = context.decode(name: "x-custom", value: "random", type: type)
					expect(emit).to be == ["x-custom", "random"]
					expect(context.table).to be == original_table
				end
			end
		end

		with "incremental indexing" do
			it "should process indexed header with literal value" do
				original_table = context.table.dup

				emit = context.decode(name: 4, value: "/path", type: :incremental)
				expect(emit).to be == [":path", "/path"]
				expect(context.table - original_table).to be == [[":path", "/path"]]
			end

			it "should process literal header with literal value" do
				original_table = context.table.dup

				context.decode(name: "x-custom", value: "random", type: :incremental)
				expect(context.table - original_table).to be == [["x-custom", "random"]]
			end
		end

		with "size bounds" do
			it "should drop headers from end of table" do
				context.instance_eval do
					add_to_table(["test1", "1" * 1024])
					add_to_table(["test2", "2" * 500])
				end

				original_table = context.table.dup
				original_size = original_table.join.bytesize + original_table.size * 32

				context.decode(
					name: "x-custom",
					value: "a" * (2048 - original_size),
					type: :incremental
				)

				expect(context.table.first[0]).to be == "x-custom"
				expect(context.table.size).to be == original_table.size # number of entries
			end
		end

		it "should clear table if entry exceeds table size" do
			context.instance_eval do
				add_to_table(["test1", "1" * 1024])
				add_to_table(["test2", "2" * 500])
			end

			h = {name: "x-custom", value: "a", index: 0, type: :incremental}
			e = {name: "large", value: "a" * 2048, index: 0}

			context.decode(h)
			context.decode(e.merge(type: :incremental))
			expect(context.table).to be(:empty?)
		end

		it "should shrink table if set smaller size" do
			context.instance_eval do
				add_to_table(["test1", "1" * 1024])
				add_to_table(["test2", "2" * 500])
			end

			context.decode(type: :change_table_size, value: 1500)
			expect(context.table.size).to be == 1
			expect(context.table.first[0]).to be == "test2"
		end
	end
end
