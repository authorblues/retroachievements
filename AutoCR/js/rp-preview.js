// ─── Rich Presence Preview ────────────────────────────────────────────────────
// Drop this file into the project and add one line to RichPresenceOverview:
//
//   <RichPresencePreview />
//
// Place it immediately above the existing <AssetFeedback ... /> line.
// No other changes needed.

function RichPresencePreview()
{
	// ── Placeholder labels for numeric / time macros ──────────────────────────

	function macroPlaceholder(fmt)
	{
		if (!fmt) return '(CHAR)'; // null = ASCIIChar / UnicodeChar

		if (fmt.category === 'time') return '(TIME)';

		switch (fmt.type)
		{
			case 'VALUE':      return '(INT)';
			case 'UNSIGNED':   return '(UINT)';
			case 'SCORE':
			case 'POINTS':     return '(SCORE)';
			case 'TENS':       return '(INT0)';
			case 'HUNDREDS':   return '(INT00)';
			case 'THOUSANDS':  return '(INT000)';
			case 'FIXED1':     return '(DEC.1)';
			case 'FIXED2':     return '(DEC.2)';
			case 'FIXED3':     return '(DEC.3)';
			default:           return '(' + fmt.name + ')'; // Float1–Float6 etc.
		}
	}

	// ── Resolve one display string ────────────────────────────────────────────

	function resolveRPString(str)
	{
		return str.replace(/@([ _a-zA-Z][ _a-zA-Z0-9]*)\((.+?)\)/g, (match, rawName) =>
		{
			const name = rawName.trim();

			// Lookup table?
			if (current.rp.lookups.has(name))
			{
				const ranges = current.rp.lookups.get(name);
				// Prefer non-fallback (*) entries so we show real label text.
				const pool = ranges.filter(r => !r.isFallback());
				const source = pool.length ? pool : ranges;
				return (source[Math.floor(Math.random() * source.length)]?.value ?? '');
			}

			// Known macro (built-in or declared Format:)?
			if (Object.prototype.hasOwnProperty.call(current.rp.macros, name))
				return macroPlaceholder(current.rp.macros[name]);

			// Completely unknown — leave raw so it's obvious.
			return match;
		});
	}

	// ── Partition display entries into dynamic vs. static ─────────────────────
	// A display string is "dynamic" if it contains at least one @Macro() call.
	// Static strings are fixed — they show exactly once and are never rerolled.

	const MACRO_RE = /@[ _a-zA-Z][ _a-zA-Z0-9]*\(.+?\)/;

	const display = current.rp ? current.rp.display : [];
	const dynamicPool  = display.filter(d => MACRO_RE.test(d.string));
	const staticLines  = display.filter(d => !MACRO_RE.test(d.string)).map(d => d.string);

	// ── Generate 10 lines from the dynamic pool ───────────────────────────────

	function generateLines()
	{
		if (!dynamicPool.length) return [];
		return Array.from({ length: 10 }, () => {
			const entry = dynamicPool[Math.floor(Math.random() * dynamicPool.length)];
			return resolveRPString(entry.string);
		});
	}

	// ── Component state ───────────────────────────────────────────────────────

	const [lines, setLines] = React.useState(() => generateLines());

	if (!current.rp || !display.length) return null;

	function PreviewLine({ text })
	{
		return text
			? <>{text}</>
			: <em className="rp-preview-empty">(empty string)</em>;
	}

	return (
		<div className="rp-preview">
			<h1>Preview</h1>
			<ul className="rp-preview-list">
				{lines.map((line, i) => (
					<li key={i}><PreviewLine text={line} /></li>
				))}
				{staticLines.map((line, i) => (
					<li key={'s' + i} className="rp-preview-static">
						<PreviewLine text={line} />
					</li>
				))}
			</ul>
			{dynamicPool.length > 0 &&
				<button onClick={() => setLines(generateLines())}>&#x1F3B2; Reroll</button>
			}
		</div>
	);
}
