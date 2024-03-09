# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require_relative 'context'
require_relative 'huffman'

module Protocol
	module HPACK
		# Responsible for decoding received headers and maintaining compression
		# context of the opposing peer. Decompressor must be initialized with
		# appropriate starting context based on local role: client or server.
		class Decompressor
			def initialize(buffer, context = Context.new, table_size_limit: nil)
				@buffer = buffer
				@context = context
				@offset = 0
				
				@table_size_limit = table_size_limit
			end

			attr :buffer
			attr :context
			attr :offset
			
			attr :table_size_limit
			
			def end?
				@offset >= @buffer.bytesize
			end

			def read_byte
				if byte = @buffer.getbyte(@offset)
					@offset += 1
				end
				
				return byte
			end
			
			def peek_byte
				@buffer.getbyte(@offset)
			end

			def read_bytes(length)
				slice = @buffer.byteslice(@offset, length)
				
				@offset += length
				
				return slice
			end

			# Decodes integer value from provided buffer.
			#
			# @param bits [Integer] number of available bits
			# @return [Integer]
			def read_integer(bits)
				limit = 2**bits - 1
				value = bits.zero? ? 0 : (read_byte & limit)
				
				shift = 0
				
				while byte = read_byte
					value += ((byte & 127) << shift)
					shift += 7
					
					break if (byte & 128).zero?
				end if (value == limit)
				
				return value
			end

			# Decodes string value from provided buffer.
			#
			# @return [String] UTF-8 encoded string
			# @raise [CompressionError] when input is malformed
			def read_string
				huffman = (peek_byte & 0x80) == 0x80
				
				length = read_integer(7)
				
				raise CompressionError, "Invalid string length!" unless length
				
				string = read_bytes(length)
				
				raise CompressionError, "Invalid string length, got #{string.bytesize}, expecting #{length}!" unless string.bytesize == length
				
				string = Huffman.new.decode(string) if huffman
				
				return string.force_encoding(Encoding::UTF_8)
			end

			# Decodes header command from provided buffer.
			#
			# @param buffer [Buffer]
			# @return [Hash] command
			def read_header
				pattern = peek_byte

				header = {}
				header[:type], type = HEADER_REPRESENTATION.find do |_t, desc|
					mask = (pattern >> desc[:prefix]) << desc[:prefix]
					mask == desc[:pattern]
				end

				raise CompressionError unless header[:type]

				header[:name] = read_integer(type[:prefix])

				case header[:type]
				when :indexed
					raise CompressionError if header[:name].zero?
					header[:name] -= 1
				when :change_table_size
					header[:value] = header[:name]
					
					if @table_size_limit and header[:value] > @table_size_limit
						raise CompressionError, "Table size #{header[:value]} exceeds limit #{@table_size_limit}!"
					end
				else
					if (header[:name]).zero?
						header[:name] = read_string
					else
						header[:name] -= 1
					end
					
					header[:value] = read_string
				end

				return header
			end

			# Decodes and processes header commands within provided buffer.
			#
			# @param buffer [Buffer]
			# @return [Array] +[[name, value], ...]+
			def decode(list = [])
				while !end?
					command = read_header
					
					if pair = @context.decode(command)
						list << pair
					end
				end
				
				if command and command[:type] == :change_table_size
					raise CompressionError, "Trailing table size update!"
				end
				
				return list
			end
		end
	end
end
