# frozen_string_literal: true

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
	
	gem "bake-modernize"
end
