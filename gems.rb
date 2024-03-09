# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

source "https://rubygems.org"

# Specify your gem's dependencies in protocol-hpack.gemspec
gemspec

gem "rake", "~> 10.0"

group :test do
	gem "rspec", "~> 3.0"
	gem "covered"
end

group :maintenance, optional: true do
	gem "bake-gem"
	
	gem "bake-modernize", path: "../../ioquatix/bake-modernize"
end
