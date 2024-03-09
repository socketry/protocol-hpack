# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2020, by Samuel Williams.

require 'protocol/hpack'

RSpec.describe Protocol::HPACK do
	it "has a version number" do
		expect(Protocol::HPACK::VERSION).not_to be nil
	end
end
