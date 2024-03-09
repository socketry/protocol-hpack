# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'protocol/hpack/context'
require 'protocol/hpack/compressor'
require 'protocol/hpack/decompressor'

RSpec.describe Protocol::HPACK::Context do
	let(:context) {Protocol::HPACK::Context.new}
	
	xit "should decode headers" do
		context.table.replace([["forwarded", "for=::ffff:104.154.113.151;proto=https"], ["x-forwarded-for", "::ffff:104.154.113.151"], ["forwarded", "for=::ffff:107.22.138.64;proto=https"], ["x-forwarded-for", "::ffff:107.22.138.64"], ["if-modified-since", "Sat, 22 Jun 2019 10:40:42 GMT"], ["accept-encoding", "gzip,deflate"], ["user-agent", "Slackbot 1.0 (+https://api.slack.com/robots)"], [":method", "HEAD"], ["forwarded", "for=::ffff:35.184.226.236;proto=https"], ["x-forwarded-for", "::ffff:35.184.226.236"], ["forwarded", "for=::ffff:35.184.96.71;proto=https"], ["x-forwarded-for", "::ffff:35.184.96.71"], ["accept-encoding", "gzip, identity"], ["forwarded", "for=::ffff:54.194.39.149;proto=https"], ["x-forwarded-for", "::ffff:54.194.39.149"], ["user-agent", "Go-http-client/2.0"], ["accept-encoding", "gzip"], [":path", "/journal/atom"], ["forwarded", "for=::ffff:207.254.16.35;proto=https"], ["x-forwarded-for", "::ffff:207.254.16.35"], ["forwarded", "for=::ffff:35.224.112.202;proto=https"], ["x-forwarded-for", "::ffff:35.224.112.202"], ["forwarded", "for=::ffff:35.193.7.13;proto=https"], ["x-forwarded-for", "::ffff:35.193.7.13"], ["via", "h2 Falcon::Proxy"], ["forwarded", "for=::ffff:35.188.1.99;proto=https"], ["x-forwarded-proto", "https"], ["x-forwarded-for", "::ffff:35.188.1.99"], ["user-agent", "async-http"], ["accept", "*/*"], [":authority", "www.codeotaku.com"], [":path", "/index"]])
		
		data = "\x87\x82\xDD\xDC\xDB\xDA\xD1\xD8\xD0\xD6"
		
		pp Protocol::HPACK::Decompressor.new(data, context).decode
	end
	
	xit "should decode headers" do
		context.table.replace([["via", " Falcon::Proxy"], ["forwarded", "for=::ffff:199.59.150.182;proto=https"], ["x-forwarded-for", "::ffff:199.59.150.182"], ["x-b3-traceid", "00a67e0e007a9eed"], ["x-b3-parentspanid", "b879b4d1180fe465"], ["x-b3-flags", "2"], ["x-b3-sampled", "false"], [":authority", "www.codeotaku.com"], [":path", "*/*"], [":method", "Accept:"], ["forwarded", "for=::ffff:216.244.66.248;proto=https"], ["x-forwarded-for", "::ffff:216.244.66.248"], ["accept-charset", "utf-8;q=0.7,iso-8859-1;q=0.2,*;q=0.1"], ["user-agent", "Mozilla/5.0 (compatible; DotBot/1.1; http://www.opensiteexplorer.org/dotbot, help@moz.com)"], [":path", "/robots.txt"], ["forwarded", "for=2600:3c03::f03c:91ff:fe74:ffce;proto=https"], ["x-forwarded-for", "2600:3c03::f03c:91ff:fe74:ffce"], ["user-agent", "Feed Wrangler/1.0 (1 subscriber; feed-id=479901; http://feedwrangler.net; Allow like Gecko)"], ["via", "HTTP/1.1 Falcon::Proxy"], ["forwarded", "for=::ffff:34.228.7.66;proto=https"], ["x-forwarded-for", "::ffff:34.228.7.66"], ["user-agent", "http.rb/2.2.2 (rubyland aggregator)"], [":path", "/journal/atom"], ["forwarded", "for=::ffff:2.234.120.219;proto=https"], ["x-forwarded-for", "::ffff:2.234.120.219"], ["te", "trailers"], ["cache-control", "no-cache"], ["pragma", "no-cache"], ["referer", "https://www.jqueryscript.net/demo/jQuery-Plugin-For-Checking-Content-Has-Been-Loaded-is-loading/doc-sample/"], ["dnt", "1"], ["accept-encoding", "gzip, deflate, br"], ["accept-language", "it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3"], ["user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0"], [":path", "/_static/jquery-syntax/jquery.syntax.min.js"], ["origin", "https://www.codeotaku.com"], ["accept", "*/*"], ["content-type", "application/x-www-form-urlencoded; charset=UTF-8"], [":path", "/journal/2019-02/falcon-early-hints/comments/preview"], [":path", "/_components/jquery-syntax/base/jquery.syntax.brush.ruby.css?0.5324190477338245"], ["x-requested-with", "XMLHttpRequest"], ["accept", "text/html, */*; q=0.01"], [":path", "/journal/comments?node=/journal/2019-02/falcon-early-hints/index&_=1561202335609"], [":path", "/_components/jquery-syntax/paper/jquery.syntax.core.css?0.6647004838485858"], [":path", "/_components/jquery-syntax/bright/jquery.syntax.core.css?0.3520827623296918"], ["referer", "https://www.codeotaku.com/journal/2019-02/falcon-early-hints/index"], ["accept", "text/css,*/*;q=0.1"], ["cookie", "_ga=GA1.2.792841438.1560131922; _gid=GA1.2.1178560158.1561163892; _gat=1; __cfduid=d35427abef1ca87775a40da95d9a04cf61338222314; __cfduid=d35427abef1ca87775a40da95d9a04cf61338222314"], [":path", "/_components/jquery-syntax/base/jquery.syntax.core.css?0.7762324696928005"], ["via", "h2 Falcon::Proxy"], ["forwarded", "for=2406:e000:69b8:3601:608e:a93f:d3c1:22e0;proto=https"], ["x-forwarded-proto", "https"], ["x-forwarded-for", "2406:e000:69b8:3601:608e:a93f:d3c1:22e0"]])
		
		data = "\x87B\x85\x84\x84-i\xB9D\x03*/*A\x8D\xF1\xE3\xC2\xE4<\x85:G\xD6\xD5\xC8z\x7F@\x89\xF2\xB4l\xAC\x81\xD3]\x05\x93\x84\x94t \xBF@\x88\xF2\xB4l\xAD-\x03\x99\x1F\x012@\x8D\xF2\xB4l\xADX\xEC-IEc\xA8\xD2\x7F\x8C\x8D\xE7_\x8D\xA9\x02\x17\x81)Zq\xBF\x90@\x89\xF2\xB4l\xAC\x9B\x06B\x9AO\x8B\x00\x06\xE3\xA5\x01@\aF\xF9K'\x7F\a\x90\xB9rYe\x96\xE0_}v\xDF\\-\x81p\xBC/\xEE\x7F\a\x9B\x94\xF6Ar\xE4\xB2\xCB-\xC0\xBE\xFA\xED\xBE\xB8[\x02\xE1x_u\xD8t\x9E\t\xD2\x9A\xD1|\x8BS\b\xE8!\xEA\xB9s]\x87\xF3\xEB"
		
		pp Protocol::HPACK::Decompressor.new(data, context).decode
	end
	
	let(:initial_table) {[
		["forwarded", "for=::ffff:216.244.66.248;proto=https"],
		["x-forwarded-for", "::ffff:216.244.66.248"],
		["accept-charset", "utf-8;q=0.7,iso-8859-1;q=0.2,*;q=0.1"],
		["user-agent", "Mozilla/5.0 (compatible; DotBot/1.1; http://www.opensiteexplorer.org/dotbot, help@moz.com)"],
		[":path", "/robots.txt"],
		["forwarded", "for=2600:3c03::f03c:91ff:fe74:ffce;proto=https"],
		["x-forwarded-for", "2600:3c03::f03c:91ff:fe74:ffce"],
		["user-agent", "Feed Wrangler/1.0 (1 subscriber; feed-id=479901; http://feedwrangler.net; Allow like Gecko)"],
		["via", "HTTP/1.1 Falcon::Proxy"],
		["forwarded", "for=::ffff:34.228.7.66;proto=https"],
		["x-forwarded-for", "::ffff:34.228.7.66"],
		["user-agent", "http.rb/2.2.2 (rubyland aggregator)"],
		[":path", "/journal/atom"],
		["forwarded", "for=::ffff:2.234.120.219;proto=https"],
		["x-forwarded-for", "::ffff:2.234.120.219"],
		["te", "trailers"],
		["cache-control", "no-cache"],
		["pragma", "no-cache"],
		["referer", "https://www.jqueryscript.net/demo/jQuery-Plugin-For-Checking-Content-Has-Been-Loaded-is-loading/doc-sample/"],
		["dnt", "1"],
		["accept-encoding", "gzip, deflate, br"],
		["accept-language", "it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3"],
		["user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0"],
		[":path", "/_static/jquery-syntax/jquery.syntax.min.js"],
		["origin", "https://www.codeotaku.com"],
		["accept", "*/*"],
		["content-type", "application/x-www-form-urlencoded; charset=UTF-8"],
		[":path", "/journal/2019-02/falcon-early-hints/comments/preview"],
		[":path", "/_components/jquery-syntax/base/jquery.syntax.brush.ruby.css?0.5324190477338245"],
		["x-requested-with", "XMLHttpRequest"],
		["accept", "text/html, */*; q=0.01"],
		[":path", "/journal/comments?node=/journal/2019-02/falcon-early-hints/index&_=1561202335609"],
		[":path", "/_components/jquery-syntax/paper/jquery.syntax.core.css?0.6647004838485858"],
		[":path", "/_components/jquery-syntax/bright/jquery.syntax.core.css?0.3520827623296918"],
		["referer", "https://www.codeotaku.com/journal/2019-02/falcon-early-hints/index"],
		["accept", "text/css,*/*;q=0.1"],
		["cookie", "_ga=GA1.2.792841438.1560131922; _gid=GA1.2.1178560158.1561163892; _gat=1; __cfduid=d35427abef1ca87775a40da95d9a04cf61338222314; __cfduid=d35427abef1ca87775a40da95d9a04cf61338222314"],
		[":path", "/_components/jquery-syntax/base/jquery.syntax.core.css?0.7762324696928005"],
		["via", "h2 Falcon::Proxy"],
		["forwarded", "for=2406:e000:69b8:3601:608e:a93f:d3c1:22e0;proto=https"],
		["x-forwarded-proto", "https"],
		["x-forwarded-for", "2406:e000:69b8:3601:608e:a93f:d3c1:22e0"],
		["referer", "https://www.codeotaku.com/journal/index"],
		["accept-language", "en-us"],
		["user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.1 Safari/605.1.15"],
		["accept-encoding", "br, gzip, deflate"],
		["accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"]
	]}
	
	let(:headers) {[
		[":scheme", "https"],
		[":method", "GET"],
		[":path", "/"],
		[":authority", "www.codeotaku.com"],
		["x-b3-sampled", "false"],
		["x-b3-flags", "2"],
		["x-b3-parentspanid", "b879b4d1180fe465"],
		["accept-encoding", "gzip, deflate"],
		["x-b3-traceid", "00a67e0e007a9eed"],
		["x-forwarded-for", "::ffff:199.59.150.182"],
		["x-forwarded-proto", "https"],
		["forwarded", "for=::ffff:199.59.150.182;proto=https"],
		["via", " Falcon::Proxy"]
	]}
	
	it "should encode headers" do
		context.table.replace(initial_table.dup)
		
		# Encoding these headers produces wrong results?
		pp Protocol::HPACK::Compressor.new(String.new.b, context).encode(headers)
		
		pp context.table
	end
	
	it "should decode headers" do
		context.table.replace(initial_table.dup)
		
		data = "\x87B\x85\x84\x84-i\xB9D\x03*/*A\x8D\xF1\xE3\xC2\xE4<\x85:G\xD6\xD5\xC8z\x7F@\x89\xF2\xB4l\xAC\x81\xD3]\x05\x93\x84\x94t \xBF@\x88\xF2\xB4l\xAD-\x03\x99\x1F\x012@\x8D\xF2\xB4l\xADX\xEC-IEc\xA8\xD2\x7F\x8C\x8D\xE7_\x8D\xA9\x02\x17\x81)Zq\xBF\x90@\x89\xF2\xB4l\xAC\x9B\x06B\x9AO\x8B\x00\x06\xE3\xA5\x01@\aF\xF9K'\x7F\a\x90\xB9rYe\x96\xE0_}v\xDF\\-\x81p\xBC/\xEE\x7F\a\x9B\x94\xF6Ar\xE4\xB2\xCB-\xC0\xBE\xFA\xED\xBE\xB8[\x02\xE1x_u\xD8t\x9E\t\xD2\x9A\xD1|\x8BS\b\xE8!\xEA\xB9s]\x87\xF3\xEB"
		
		pp Protocol::HPACK::Decompressor.new(data, context).decode
		
		# pp context.table
	end
end
