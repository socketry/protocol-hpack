# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "protocol/hpack"

describe Protocol::HPACK do
	it "has a version number" do
		expect(Protocol::HPACK::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
