#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'yaml'

spec_examples = [
	{title: 'D.3. Request Examples without Huffman',
		type: :request,
		table_size: 4096,
		huffman: :never,
		streams: [
			{wire: "8286 8441 0f77 7777 2e65 7861 6d70 6c65 2e63 6f6d",
				emitted: [
					[':method', 'GET'],
					[':scheme', 'http'],
					[':path', '/'],
					[':authority', 'www.example.com'],
			 ],
				table: [
					[':authority', 'www.example.com'],
			 ],
				table_size: 57,
		 },
			{wire: '8286 84be 5808 6e6f 2d63 6163 6865',
				emitted: [
					[':method', 'GET'],
					[':scheme', 'http'],
					[':path', '/'],
					[':authority', 'www.example.com'],
					['cache-control', 'no-cache'],
			 ],
				table: [
					['cache-control', 'no-cache'],
					[':authority', 'www.example.com'],
			 ],
				table_size: 110,
		 },
			{wire: "8287 85bf 400a 6375 7374 6f6d 2d6b 6579 0c63 7573 746f 6d2d 7661 6c75 65",
				emitted: [
					[':method', 'GET'],
					[':scheme', 'https'],
					[':path', '/index.html'],
					[':authority', 'www.example.com'],
					['custom-key', 'custom-value'],
			 ],
				table: [
					['custom-key', 'custom-value'],
					['cache-control', 'no-cache'],
					[':authority', 'www.example.com'],
			 ],
				table_size: 164,
		 },
	 ],
 },
	{title: 'D.4. Request Examples with Huffman',
		type: :request,
		table_size: 4096,
		huffman: :always,
		streams: [
			{wire: '8286 8441 8cf1 e3c2 e5f2 3a6b a0ab 90f4 ff',
				emitted: [
					[':method', 'GET'],
					[':scheme', 'http'],
					[':path', '/'],
					[':authority', 'www.example.com'],
			 ],
				table: [
					[':authority', 'www.example.com'],
			 ],
				table_size: 57,
		 },
			{wire: '8286 84be 5886 a8eb 1064 9cbf',
				emitted: [
					[':method', 'GET'],
					[':scheme', 'http'],
					[':path', '/'],
					[':authority', 'www.example.com'],
					['cache-control', 'no-cache'],
			 ],
				table: [
					['cache-control', 'no-cache'],
					[':authority', 'www.example.com'],
			 ],
				table_size: 110,
		 },
			{wire: "8287 85bf 4088 25a8 49e9 5ba9 7d7f 8925 a849 e95b b8e8 b4bf",
				emitted: [
					[':method', 'GET'],
					[':scheme', 'https'],
					[':path', '/index.html'],
					[':authority', 'www.example.com'],
					['custom-key', 'custom-value'],
			 ],
				table: [
					['custom-key', 'custom-value'],
					['cache-control', 'no-cache'],
					[':authority', 'www.example.com'],
			 ],
				table_size: 164,
		 },
	 ],
 },
	{title: 'D.5. Response Examples without Huffman',
		type: :response,
		table_size: 256,
		huffman: :never,
		streams: [
			{wire: "4803 3330 3258 0770 7269 7661 7465 611d 4d6f 6e2c 2032 3120 4f63 7420 3230 3133 2032 303a 3133 3a32 3120 474d 546e 1768 7474 7073 3a2f 2f77 7777 2e65 7861 6d70 6c65 2e63 6f6d",
				emitted: [
					[':status', '302'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['location', 'https://www.example.com'],
			 ],
				table: [
					['location', 'https://www.example.com'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['cache-control', 'private'],
					[':status', '302'],
			 ],
				table_size: 222,
		 },
			{wire: '4803 3330 37c1 c0bf',
				emitted: [
					[':status', '307'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['location', 'https://www.example.com'],
			 ],
				table: [
					[':status', '307'],
					['location', 'https://www.example.com'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['cache-control', 'private'],
			 ],
				table_size: 222,
		 },
			{wire: "88c1 611d 4d6f 6e2c 2032 3120 4f63 7420 3230 3133 2032 303a 3133 3a32 3220 474d 54c0 5a04 677a 6970 7738 666f 6f3d 4153 444a 4b48 514b 425a 584f 5157 454f 5049 5541 5851 5745 4f49 553b 206d 6178 2d61 6765 3d33 3630 303b 2076 6572 7369 6f6e 3d31",
				emitted: [
					[':status', '200'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:22 GMT'],
					['location', 'https://www.example.com'],
					['content-encoding', 'gzip'],
					['set-cookie', 'foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1'],
			 ],
				table: [
					['set-cookie', 'foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1'],
					['content-encoding', 'gzip'],
					['date', 'Mon, 21 Oct 2013 20:13:22 GMT'],
			 ],
				table_size: 215,
		 },
	 ],
 },
	{title: 'D.6. Response Examples with Huffman',
		type: :response,
		table_size: 256,
		huffman: :always,
		streams: [
			{
				wire: "4882 6402 5885 aec3 771a 4b61 96d0 7abe 9410 54d4 44a8 2005 9504 0b81 66e0 82a6 2d1b ff6e 919d 29ad 1718 63c7 8f0b 97c8 e9ae 82ae 43d3",
				emitted: [
					[':status', '302'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['location', 'https://www.example.com'],
			 ],
				table: [
					['location', 'https://www.example.com'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['cache-control', 'private'],
					[':status', '302'],
			 ],
				table_size: 222,
			},
			{
				wire: '4883 640e ffc1 c0bf',
				emitted: [
					[':status', '307'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['location', 'https://www.example.com'],
			 ],
				table: [
					[':status', '307'],
					['location', 'https://www.example.com'],
					['date', 'Mon, 21 Oct 2013 20:13:21 GMT'],
					['cache-control', 'private'],
			 ],
				table_size: 222,
			},
			{
				wire: "88c1 6196 d07a be94 1054 d444 a820 0595 040b 8166 e084 a62d 1bff c05a 839b d9ab 77ad 94e7 821d d7f2 e6c7 b335 dfdf cd5b 3960 d5af 2708 7f36 72c1 ab27 0fb5 291f 9587 3160 65c0 03ed 4ee5 b106 3d50 07",
				emitted: [
					[':status', '200'],
					['cache-control', 'private'],
					['date', 'Mon, 21 Oct 2013 20:13:22 GMT'],
					['location', 'https://www.example.com'],
					['content-encoding', 'gzip'],
					['set-cookie', 'foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1'],
				],
				table: [
					['set-cookie', 'foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1'],
					['content-encoding', 'gzip'],
					['date', 'Mon, 21 Oct 2013 20:13:22 GMT'],
				],
				table_size: 215,
			},
		],
	},
]

spec_examples.each do |example|
	name = example[:title].downcase.gsub(/[\.\s]+/, "-") + ".yaml"
	
	File.open(File.expand_path(name, __dir__), "w") do |file|
		file.write(YAML.dump(example))
	end
end
