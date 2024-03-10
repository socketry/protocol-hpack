# frozen_string_literal: true

require_relative "lib/protocol/hpack/version"

Gem::Specification.new do |spec|
	spec.name = "protocol-hpack"
	spec.version = Protocol::HPACK::VERSION
	
	spec.summary = "A compresssor and decompressor for HTTP/2's HPACK format."
	spec.authors = ["Samuel Williams", "Ilya Grigorik", "Tamir Duberstein", "Kaoru Maeda", "Tiago Cardoso", "Byron Formwalt", "Cyril Roelandt", "Daniel Morrison", "Felix Yan", "George Ulmer", "Jingyi Chen", "Justin Mazzocchi", "Kenichi Nakamura", "Kien Nguyen Trung", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/http-hpack"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/protocol-hpack/",
	}
	
	spec.files = Dir.glob(['{lib,tasks}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.0"
end
