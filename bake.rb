# frozen_string_literal: true

# Generate the huffman state table.
def generate_huffman_table
	require_relative "lib/protocol/hpack/huffman/generator"

	Protocol::HPACK::Huffman::Generator::Node.generate_state_table
end
