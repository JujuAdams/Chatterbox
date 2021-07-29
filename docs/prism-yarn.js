(function (Prism) {
	Prism.languages.yarn = {
		comment: [
			{
				pattern: /(^|[^\\:])\/\/.*/,
				greedy: true,
				lookbehind: true,
			},
			{
				pattern: /#([^\/\/]).*/,
				greedy: true,
				lookbehind: false,
			},
		],
		prolog: {
			pattern: /(<<).*(?=>>)/,
			lookbehind: true,
			inside: {
				keyword: [
					{
						pattern: /^(set|declare|if|elseif|jump|stop|else|endif|wait)/,
					},
					{
						pattern: /\b(is|to|not|ne|eq|le|ge|gt|lt|and|or)\b/,
					},
				],
				function: [
					{
						pattern: /^\w+/,
					},
					{
						pattern: /\w+(?=\()/,
						lookbehind: true,
					},
				],
				operator: [
					// { pattern: /\$\w+/ },
					{ pattern: /(:)\w+/, lookbehind: true },
					{ pattern: /([^jump\s]\w+$)/ },
				],
				variable: /\$\w+/,
				boolean: /(true|false)/,
				number: /\b0x[\da-f]+\b|(?:\b\d+(?:\.\d*)?|\B\.\d+)(?:e[+-]?\d+)?/i,
				string: {
					pattern: /(?:"(?:\\(?:\r\n|[\s\S])|[^"\\\r\n])*"|'(?:\\(?:\r\n|[\s\S])|[^'\\\r\n])*')/,
					greedy: true,
				},
			},
		},
		symbol: /->/,
		name: /\w+:/,
	};
})(Prism);
