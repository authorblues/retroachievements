// title case helpers
const TITLE_CASE_MINORS = new Set([
	'a', 'an', 'and', 'as', 'at', 'but', 'by', 'en', 'for', 'from', 'how', 'if', 'in', "n'", "'n'",
	'neither', 'nor', 'of', 'on', 'only', 'onto', 'out', 'or', 'over', 'per', 'so', 'than', 
	'the', 'to', 'until', 'up', 'upon', 'v', 'v.', 'versus', 'vs', 'vs.', 'via', 'when', 
	'with', 'without', 'yet',
]);
function tc_minor(word) { return TITLE_CASE_MINORS.has(word); }
function make_title_case(phrase)
{
	function tc(s) { return s.charAt(0).toUpperCase() + s.substring(1); }
	return phrase.replace(/[0-9'\u2018\u2019\p{Script=Latin}\-]+/gu, function(x, i)
	{
		if (x == x.toUpperCase()) return x; // assume allcaps for a reason
		if (i == 0 || i + x.length == phrase.length) return tc(x);
		return tc_minor(x.toLowerCase()) ? x.toLowerCase() : tc(x);
	});
}

function toDisplayHex(addr)
{ return '0x' + addr.toString(16).padStart(8, '0'); }

const FeedbackSeverity = Object.freeze({
	PASS: 0,
	INFO: 1,
	WARN: 2,
	ERROR: 3,
});
const Feedback = Object.freeze({
	// writing policy feedback
	TITLE_CASE: { severity: FeedbackSeverity.WARN, desc: "Titles should be written in title case according to the Chicago Manual of Style.",
		ref: ["https://en.wikipedia.org/wiki/Title_case#Chicago_Manual_of_Style",], },
	TITLE_PUNCTUATION: { severity: FeedbackSeverity.WARN, desc: "Achievement titles are not full sentences, and should not end with punctuation (exception: ?, !, or ellipses).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation",], },
	DESC_SENTENCE_CASE: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should not be in title case, but rather sentence case.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#capitalization-1",], },
	DESC_PUNCT_CONSISTENCY: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should be consistent about whether or not they end with punctuation.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation-1",], },
	DESC_BRACKETS: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should avoid brackets where possible.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#brackets-parentheses",], },
	DESC_SYMBOLS: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions are discouraged from using symbols to describe conditions.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	DESC_QUOTES: { severity: FeedbackSeverity.INFO, desc: "Achievement descriptions should only use double quotation marks, except for quotes inside quotes.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	NUM_FORMAT: { severity: FeedbackSeverity.INFO, desc: "Numbers should be formatted to conform to English standards (period for decimal separation, commas for grouping).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#number-formatting",], },
	NO_EMOJI: { severity: FeedbackSeverity.WARN, desc: "Achievement titles and descriptions may not contain emoji.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#emojis",
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",
		], },
	SPECIAL_CHARS: { severity: FeedbackSeverity.WARN, desc: "Avoid using accented/special characters, as they can have rendering issues.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/naming-conventions.html",
			"https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#naming-convention-tips",
		], },
	FOREIGN_CHARS: { severity: FeedbackSeverity.INFO, desc: `Achievement titles and descriptions should be written in English and should avoid special characters.`,
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#language",], },

	// set design errors
	NO_PROGRESSION: { severity: FeedbackSeverity.INFO, desc: "Set lacks progression achievements (win conditions found). This might be unavoidable, depending on the game, but progression achievements should be added when possible.",
		ref: ["https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#progression-conditions",], },
	NO_TYPING: { severity: FeedbackSeverity.WARN, desc: "Set lacks progression and win condition typing.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#progression-conditions",
			"https://docs.retroachievements.org/guidelines/content/progression-and-win-condition-guidelines.html#win-conditions",
		], },
	ACHIEVEMENT_DIFFICULTY: { severity: FeedbackSeverity.INFO, desc: "A good spread of achievement difficulties is important.",
		ref: ["https://docs.retroachievements.org/developer-docs/difficulty-scale-and-balance.html",], },
	PROGRESSION_ONLY: { severity: FeedbackSeverity.WARN, desc: "Progression-only sets should be avoided. Consider adding custom challenge achievements to improve it.",
		ref: ["https://retroachievements.org/game/5442",], },
	DUPLICATE_TITLES: { severity: FeedbackSeverity.WARN, desc: "Assets should all have unique titles to distinguish them from one another.",
		ref: [], },
	DUPLICATE_DESCRIPTIONS: { severity: FeedbackSeverity.INFO, desc: "Assets should have unique descriptions. Duplicate descriptions likely indicate redundant assets.",
		ref: [], },

	// code notes
	NOTE_EMPTY: { severity: FeedbackSeverity.WARN, desc: "Empty code note.",
		ref: [], },
	NOTE_NO_SIZE: { severity: FeedbackSeverity.WARN, desc: "Code notes must have size information.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#specifying-memory-addresses-size",], },
	NOTE_ENUM_HEX: { severity: FeedbackSeverity.WARN, desc: "Enumerated hex values in code notes should be prefixed with \"0x\" to avoid being misinterpreted as decimal values.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels",], },
	NOTE_ENUM_TOO_LARGE: { severity: FeedbackSeverity.WARN, desc: "Enumerated values too large for code note size information.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels",], },
	BAD_REGION_NOTE: { severity: FeedbackSeverity.WARN, desc: "Some memory regions are unsafe, redundant, or should not otherwise be used.",
		ref: ['https://docs.retroachievements.org/developer-docs/console-specific-tips.html',], },
	UNALIGNED_NOTE: { severity: FeedbackSeverity.INFO, desc: "16- and 32-bit data is often word-aligned.",
		ref: [], },

	// rich presence
	NO_DYNAMIC_RP: { severity: FeedbackSeverity.WARN, desc: "Dynamic rich presence is required for all sets.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#introduction',], },
	NO_CONDITIONAL_DISPLAY: { severity: FeedbackSeverity.INFO, desc: "The use of conditional displays can improve the quality of rich presence by showing specific information based on the game mode.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings',], },
	MISSING_NOTE_RP: { severity: FeedbackSeverity.WARN, desc: "All addresses used in rich presence require a code note.",
		ref: [], },
		
	// code errors
	BAD_CHAIN: { severity: FeedbackSeverity.ERROR, desc: "The last requirement of a group cannot have a chaining flag.",
		ref: [], },
	MISSING_NOTE: { severity: FeedbackSeverity.WARN, desc: "All addresses used in achievement logic require a code note.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html",], },
	ONE_CONDITION: { severity: FeedbackSeverity.WARN, desc: "One-condition achievements are dangerous and should be avoided.",
		ref: ["https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#achievement-creation-tips",], },
	MISSING_DELTA: { severity: FeedbackSeverity.WARN, desc: "Achievements must contain a Delta to isolate the specific moment that an achievement should trigger.",
		ref: ['https://docs.retroachievements.org/developer-docs/delta-values.html',], },
	IMPROPER_DELTA: { severity: FeedbackSeverity.INFO, desc: "Proper use of Delta can help identify the precise moment that an achievement should trigger.",
		ref: ['https://docs.retroachievements.org/developer-docs/delta-values.html',], },
	BAD_PRIOR: { severity: FeedbackSeverity.WARN, desc: "Questionable use of Prior. See below for more information.",
		ref: ['https://docs.retroachievements.org/developer-docs/prior-values.html',], },
	COMMON_ALT: { severity: FeedbackSeverity.INFO, desc: "If every alt group contains the same bit of logic in common, it can be refactored back into the Core group.",
		ref: [], },
	STALE_ADDADDRESS: { severity: FeedbackSeverity.INFO, desc: "Stale references with AddAddress can be dangerous. Use caution when reading a pointer from the previous frame (AddAddress + Delta).",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/addaddress.html#using-delta-with-chained-pointers',], },
	NEGATIVE_OFFSET: { severity: FeedbackSeverity.WARN, desc: "Negative pointer offsets are wrong in the vast majority of cases and are incompatible with the way pointers actually work.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/addaddress.html#calculating-your-offset'], },
	BAD_REGION_LOGIC: { severity: FeedbackSeverity.ERROR, desc: "Some memory regions are unsafe, redundant, or should not otherwise be used for achievement logic.",
		ref: ['https://docs.retroachievements.org/developer-docs/console-specific-tips.html'], },
	TYPE_MISMATCH: { severity: FeedbackSeverity.INFO, desc: "Memory accessor doesn't match size listed in code note.",
		ref: [
			'https://docs.retroachievements.org/developer-docs/memory-inspector.html',
			'https://docs.retroachievements.org/guidelines/content/code-notes.html',
		], },
	POINTER_COMPARISON: { severity: FeedbackSeverity.INFO, desc: "Comparison between pointer and non-zero value is usually incorrect, unless pointing to data in ROM.",
		ref: [], },
	MISSING_ENUMERATION: { severity: FeedbackSeverity.WARN, desc: "A value was used that doesn't match any of the enumerated values in the code note.",
		ref: ['https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels',], },
	SOURCE_MOD_MEASURED: { severity: FeedbackSeverity.ERROR, desc: "Placing a source modification on a Measured requirement can cause faulty values in older versions of RetroArch (pre-1.10.1).",
		ref: ['https://discord.com/channels/310192285306454017/386068797921951755/1247501391908307027',], },
	PAUSELOCK_NO_RESET: { severity: FeedbackSeverity.WARN, desc: "PauseLocks require a reset, either via ResetNextIf, or a ResetIf in another group.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html#pauseif-with-hit-counts',], },
	HIT_NO_RESET: { severity: FeedbackSeverity.WARN, desc: "Hit counts require a reset, either via ResetIf or ResetNextIf.",
		ref: ['https://docs.retroachievements.org/developer-docs/hit-counts.html',], },
	USELESS_ANDNEXT: { severity: FeedbackSeverity.WARN, desc: "Combining requirements with AND is the default behavior. Useless AndNext flags should be removed.",
	USELESS_ANDNEXT: { severity: FeedbackSeverity.INFO, desc: "Combining requirements with AND is the default behavior. Useless AndNext flags should be removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/andnext-ornext.html',], },
	USELESS_ALT: { severity: FeedbackSeverity.ERROR, desc: "A Reset-only Alt group is considered satisfied, making all other Alt groups useless.",
		ref: [], },
	UUO_RESET: { severity: FeedbackSeverity.WARN, desc: "ResetIf should only be used with achievements that have hitcounts.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	UUO_RNI: { severity: FeedbackSeverity.WARN, desc: "ResetNextIf should only be used with requirements that have hitcounts, and must be placed immediately before the requirement with the hits.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetnextif.html',], },
	UUO_PAUSE: { severity: FeedbackSeverity.WARN, desc: "PauseIf should only be used with requirements that have hitcounts.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html',], },
	PAUSING_MEASURED: { severity: FeedbackSeverity.PASS, desc: "PauseIf should only be used with requirements that have hitcounts, unless being used to freeze updates to a Measured requirement.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/measured.html#measured',], },
	RESET_HITCOUNT_1: { severity: FeedbackSeverity.INFO, desc: "A ResetIf or ResetNextIf with a hitcount of 1 does not require a hitcount. The hitcount can be safely removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	USELESS_ADDSUB: { severity: FeedbackSeverity.WARN, desc: "Using AddSource and SubSource is better supported in old emulators, and should be preferred where possible.",
		ref: [
			'https://docs.retroachievements.org/developer-docs/flags/addsource.html',
			'https://docs.retroachievements.org/developer-docs/flags/subsource.html',
		], },
	UNSATISFIABLE: { severity: FeedbackSeverity.ERROR, desc: "Requirement can never be satisfied (always-false).",
		ref: [], },
	UNNECESSARY: { severity: FeedbackSeverity.INFO, desc: "Requirement will always be satisfied (always-true).",
		ref: [], },
});

class Issue
{
	type;
	target;
	detail = [];
	constructor(type, target, detail = null)
	{
		this.type = type;
		this.target = target;
		this.detail = detail;
	}
}

class IssueGroup extends Array
{
	label = null;

	constructor(label = null)
	{ super(); this.label = label; }

	add(x) { return this.push(x); }

	static fromTests(label, tests, param)
	{
		let res = new IssueGroup(label);
		for (const test of tests)
			for (const issue of test(param))
				res.add(issue);
		return res;
	}
}

class Assessment
{
	issues = [];
	stats = {};
	constructor() {  }

	#allissues() { return [].concat(...this.issues); }
	status() { return Math.max(FeedbackSeverity.PASS, ...this.#allissues().map(x => x.type.severity)); }
	pass() { return this.status() < FeedbackSeverity.WARN; }
}

function get_note(addr, notes = [])
{
	const _notes = notes ?? [];
	// reverse loop because in the case of overlapping code notes,
	// the later one is likely more specific
	for (let i = _notes.length - 1; i >= 0; i--)
		if (_notes[i].contains(addr)) return _notes[i];
	return null;
}

function* missing_notes(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		let prev_addaddress = false;
		for (const [ri, req] of g.entries())
		{
			let lastreport = null;
			for (const operand of [req.lhs, req.rhs])
			{
				if (!operand || !operand.type || !operand.type.addr) continue;
				if (!prev_addaddress && !get_note(operand.value, current.notes))
				{
					if (lastreport == operand.value) continue;
					yield { addr: operand.value, req: req, };
					lastreport = operand.value;
				}
			}
			prev_addaddress = req.flag == ReqFlag.ADDADDRESS;
		}
	}
}

function invert_chain(group, ri)
{
	function invert_req(req)
	{
		let copy = req.clone();
		if      (copy.flag == ReqFlag.ANDNEXT) copy.flag = ReqFlag.ORNEXT;
		else if (copy.flag == ReqFlag.ORNEXT ) copy.flag = ReqFlag.ANDNEXT;
		copy.reverseComparison();
		return copy;
	}

	let target = invert_req(group[ri]);
	target.flag = null;
	target.hits = 0;

	let res = target.toMarkdown();
	for (let i = ri - 1; i >= 0; i--)
	{
		if (group[i].isTerminating()) break;
		res = invert_req(group[i]).toMarkdown() + '\n' + res;
	}
	return res;
}

function generate_logic_stats(logic)
{
	let stats = {};
	stats.mem_length = -1;

	// flattened version of the logic
	const flat = [].concat(...logic.groups);
	const operands = new Set(logic.getOperands());
	const comparisons = flat.filter(req => req.isComparisonOperator()).map(req => req.op);

	// number of groups (number of alt groups is this minus 1)
	stats.group_count = logic.groups.length;
	stats.alt_groups = stats.group_count - 1;

	// size of the largest group
	stats.group_maxsize = Math.max(...logic.groups.map((x) => x.length));

	// total number of conditions
	stats.cond_count = logic.groups.reduce((a, e) => a + e.length, 0);

	// set of unique flags, comparisons, and sizes used in the achievement
	stats.unique_flags = new Set(logic.getFlags());
	stats.unique_cmps = new Set(comparisons);
	stats.unique_sizes = new Set(logic.getMemSizes().map(x => BitProficiency.has(x) ? MemSize.BYTE : x));
	stats.unique_sizes_all = new Set(logic.getMemSizes());

	// list of all chained requirements
	let chains = [];
	for (const [gi, g] of logic.groups.entries())
	{
		let curr_chain = [];
		for (const [ri, req] of g.entries())
		{
			curr_chain.push(req);
			if (!req.flag || !req.flag.chain)
			{ chains.push(curr_chain); curr_chain = []; }
		}
	}

	// length of longest requirement chain
	stats.max_chain = Math.max(...chains.map(x => x.length));

	// count of achievements with hit counts
	stats.hit_counts_one = flat.filter(x => x.hits == 1).length;
	stats.hit_counts_many = flat.filter(x => x.hits > 1).length;

	// count of achievements with PauseIf
	stats.pause_ifs = flat.filter(x => x.flag == ReqFlag.PAUSEIF).length;
	stats.pause_locks = flat.filter(x => x.flag == ReqFlag.PAUSEIF && x.hits > 0).length;

	// count of achievements with ResetIf
	stats.reset_ifs = flat.filter(x => x.flag == ReqFlag.RESETIF).length;
	stats.reset_with_hits = flat.filter(x => x.flag == ReqFlag.RESETIF && x.hits > 0).length;

	// count of achievements with Deltas and Prior
	stats.deltas = [...operands].filter(x => x.type == ReqType.DELTA).length;
	stats.priors = [...operands].filter(x => x.type == ReqType.PRIOR).length;
	
	// list of addresses & virtual addresses
	stats.addresses = new Set(logic.getAddresses());
	stats.memlookups = logic.getMemoryLookups();

	// check for Mem>Del Counter
	stats.mem_del = flat.filter(x => x.hits > 0 && x.isComparisonOperator() && x.op != '=' 
		&& x.rhs && x.lhs.value == x.rhs.value
		&& [x.lhs.type, x.rhs.type].includes(ReqType.MEM) 
		&& [x.lhs.type, x.rhs.type].includes(ReqType.DELTA)).length;

	let groups_with_reset = new Set();
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.flag == ReqFlag.RESETIF)
				groups_with_reset.add(gi);

	stats.pauselock_alt_reset = 0;
	for (const [gi, g] of logic.groups.entries())
		reqloop: for (const [ri, req] of g.entries())
		{
			// this is a pauselock
			if (req.hits > 0 && req.flag == ReqFlag.PAUSEIF)
			{
				for (let i = ri - 1; i >= 0; i--)
				{
					if (g[i].flag == ReqFlag.RESETNEXTIF) continue reqloop;
					if (g[i].isTerminating()) break;
				}

				if (groups_with_reset.difference(new Set([gi])).size != 0)
					stats.pauselock_alt_reset += 1;
			}
		}

	let smod = stats.source_modification = new Map(['*', '/', '&', '^', '%', '+', '-'].map(x => [x, 0]));
	for (let req of flat) if (smod.has(req.op)) smod.set(req.op, smod.get(req.op) + 1);

	return stats;
}

function generate_leaderboard_stats(lb)
{
	let stats = {};

	stats.is_instant_submission = lb.components['SUB'].groups.every(
		g => g.every(req => req.isAlwaysTrue()));
	stats.conditional_value = lb.components['VAL'].groups.length > 1 &&
		lb.components['VAL'].groups.slice(1).some(
			g => 
				g.some(req => req.flag == ReqFlag.MEASUREDIF) && 
				g.some(req => req.flag == ReqFlag.MEASURED || req.flag == ReqFlag.MEASUREDP)
		);

	for (let block of ["START", "CANCEL", "SUBMIT", "VALUE"])
	{
		const tag = block.substring(0, 3);
		stats[tag] = generate_logic_stats(lb.components[tag]);
	}

	return stats;
}

function generate_code_note_stats(notes)
{
	let stats = {};

	stats.size_counts = new Map();
	stats.author_counts = new Map();
	for (const note of notes)
	{
		stats.author_counts.set(note.author, 1 + (stats.author_counts.get(note.author) ?? 0));
		if (note.type != null || note.size != 1)
		{
			let type = note.type ? note.type.name : 'Unknown';
			stats.size_counts.set(type, 1 + (stats.size_counts.get(type) ?? 0));
		}
	}

	stats.notes_count = notes.length;
	let asset_addresses = [...current.set.getAchievements().map(e => e.logic.getAddresses()),
		...current.set.getLeaderboards().map(e => e.components).flatMap(cmps => Object.values(cmps)).map(cmp => cmp.getAddresses())
	];

	if (current.rp) {
		const display_cond_addrs = current.rp.display.map(display => display.condition).filter(cond => cond !== null).flatMap(cond => cond.getAddresses());
		const lookup_addrs = current.rp.display.flatMap(display => display.lookups).flatMap(lookup => lookup.calc.getAddresses());
		asset_addresses.push([...display_cond_addrs, ...lookup_addrs]);
	}

	notes.forEach(note => {
		note.assetCount = asset_addresses.filter(addrs => addrs.includes(note.addr)).length;
	});

	let used_notes = notes.filter(x => x.assetCount > 0);

	stats.notes_used = used_notes.length;
	stats.notes_unused = stats.notes_count - stats.notes_used;

	return stats;
}

function generate_rich_presence_stats(rp)
{
	let stats = {};

	stats.mem_length = rp.text.length;
	stats.custom_macros = new Map([...Object.entries(rp.macros)]
		.filter(([k, v]) => rp.custom_macros.has(k))
	);
	stats.lookups = rp.lookups;

	stats.display_groups = rp.display.length;
	stats.cond_display = rp.display.filter(x => x.condition != null).length;
	stats.max_lookups = Math.max(...rp.display.map(x => x.lookups.length));
	stats.min_lookups = Math.min(...rp.display.map(x => x.lookups.length));

	stats.is_dynamic_rp = stats.max_lookups > 0 || stats.cond_display > 0;

	return stats;
}

function generate_set_stats(set)
{
	let stats = {};
	stats.achievement_count = set.achievements.size;
	stats.leaderboard_count = set.leaderboards.size;

	const achievements = set.getAchievements();
	const leaderboards = set.getLeaderboards();
	
	let all_logic_stats = [];
	for (const ach of achievements) all_logic_stats.push(ach.feedback.stats);
	for (const lb of leaderboards) all_logic_stats.push(...Leaderboard.COMPONENT_TAGS.map(x => lb.feedback.stats[x]));

	// counts of achievement types
	let achstate = stats.achievement_state = new Map(Object.values(AssetState).map(x => [x, 0]));
	for (const ach of achievements) achstate.set(ach.state, achstate.get(ach.state) + 1);

	let achtype = stats.achievement_type = new Map(['', 'progression', 'win_condition', 'missable'].map(x => [x, []]));
	for (const ach of achievements) achtype.get(ach.achtype ?? '').push(ach);

	// points total and average
	stats.total_points = achievements.reduce((a, e) => a + e.points, 0);
	stats.avg_points = stats.achievement_count > 0 ? (stats.total_points / stats.achievement_count) : 0;

	// all components used across all achievements
	stats.all_flags = all_logic_stats.reduce((a, e) => a.union(e.unique_flags), new Set());
	stats.all_cmps = all_logic_stats.reduce((a, e) => a.union(e.unique_cmps), new Set());
	stats.all_sizes = all_logic_stats.reduce((a, e) => a.union(e.unique_sizes), new Set());

	// number of achievements using bit operations, such as BitX and BitCount
	stats.using_bit_ops = achievements.filter(ach => new Set(ach.feedback.stats.unique_sizes_all).intersection(BitProficiency).size > 0);

	// number of achievements using each feature
	stats.using_alt_groups = achievements.filter(ach => ach.feedback.stats.alt_groups > 0);
	stats.using_delta = achievements.filter(ach => ach.feedback.stats.deltas > 0);
	stats.using_hitcounts = achievements.filter(ach => ach.feedback.stats.hit_counts_many > 0);
	stats.using_checkpoint_hits = achievements.filter(ach => ach.feedback.stats.hit_counts_one > 0);
	stats.using_pauselock = achievements.filter(ach => ach.feedback.stats.pause_locks > 0);
	stats.using_pauselock_alt_reset = achievements.filter(ach => ach.feedback.stats.pauselock_alt_reset > 0);

	// count of achievements using each flag type
	stats.using_flag = new Map(Object.values(ReqFlag).map(x => [x, new Set()]));
	for (const ach of achievements)
		for (const flag of ach.feedback.stats.unique_flags)
			stats.using_flag.get(flag).add(ach);

	// count leaderboard types
	let lbtype = stats.leaderboard_type = new Map();
	for (const lb of leaderboards)
	{
		let t = lb.getType();
		if (!lbtype.has(t)) lbtype.set(t, []);
		lbtype.get(t).push(lb);
	}

	// number of leaderboards using each feature
	stats.lb_instant_submission = leaderboards.filter(lb => lb.feedback.stats.is_instant_submission).length;
	stats.lb_conditional_value = leaderboards.filter(lb => lb.feedback.stats.conditional_value).length;

	if (current.notes.length > 0)
	{
		let addrs = new Map();
		function _attach_source(addr, val)
		{
			if (!addrs.has(addr)) addrs.set(addr, []);
			addrs.get(addr).push(val);
		}

		for (const ach of achievements)
			for (const addr of new Set(ach.logic.getAddresses()))
				_attach_source(addr, `🏆 Achievement: ${ach.title}`);
		for (const lb of leaderboards)
			for (const [tag, logic] of Object.entries(lb.components))
				for (const addr of new Set(logic.getAddresses()))
					_attach_source(addr, `📊 Leaderboard (${tag}): ${lb.title}`);

		let displayMode = false, clause = 0;
		if (current.rp && current.rp.text)
			for (const line of current.rp.text.split(/\r\n|(?!\r\n)[\n-\r\x85\u2028\u2029]/g))
			{
				if (line.toLowerCase().startsWith('Display:')) displayMode = true;
				if (displayMode) for (const m of line.matchAll(/^(\?(.+)\?)?(.+)$/g))
				{
					clause++;
					if (m[1] != '') // check the condition
						for (const addr of Logic.fromString(m[2]).getAddresses())
							_attach_source(addr, `🎮 Rich Presence Display Condition #${clause}`)
					for (const m2 of m[3].matchAll(/@([ _a-z][ _a-z0-9]*)\((.+?)\)/gi))
						for (const addr of Logic.fromString(m2[2]).getAddresses())
							_attach_source(addr, `🎮 Rich Presence Display Lookup(${m2[1]}) in Clause #${clause}`)
				}
			}

		stats.missing_notes = new Map([...addrs.entries()].filter(([x, _]) => !current.notes.some(note => note.contains(x))));
	}

	return stats;
}

function* check_deltas(logic)
{
	const DELTA_FEEDBACK = (
		<ul>
			<li><a href="https://docs.retroachievements.org/developer-docs/why-delta.html">Why should all achievements use Deltas?</a></li>
			<li>Appropriate use of Delta includes all of the following conditions:</li>
			<ul>
				<li>There should be a <code>Delta</code> that is not part of <code>ResetIf</code>, <code>ResetNextIf</code>, or <code>PauseIf</code>.</li>
				<li>...on a memory address for which there is a corresponding <code>Mem</code> constraint on the same address.</li>
				<li>...in the core group or in <strong>all</strong> alt groups. There should be no way for the achievement to be triggered without a <code>Delta</code> being involved in some way.</li>
			</ul>
		</ul>
	);

	if (!logic.getOperands().some(x => x.type == ReqType.DELTA))
	{
		yield new Issue(Feedback.MISSING_DELTA, null, DELTA_FEEDBACK);
		return;
	}

	let corememset = new Set();
	let _prefix = '';
	for (const [ri, req] of logic.groups[0].entries())
	{
		if (req.flag == ReqFlag.ADDADDRESS)
			_prefix += req.lhs.toString() + (!req.rhs ? '' : (req.op + req.rhs.toString())) + ':';
		else
		{
			if (req.lhs && req.lhs.type == ReqType.MEM) corememset.add(_prefix + req.lhs.toString());
			if (req.rhs && req.rhs.type == ReqType.MEM) corememset.add(_prefix + req.rhs.toString());
			_prefix = '';
		}
	}

	let deltanotes = [];

	const PAUSERESET = new Set([ReqFlag.RESETIF, ReqFlag.RESETNEXTIF, ReqFlag.PAUSEIF]);
	let delta_groups = logic.groups.map((g, gi) =>
	{
		// If the group contains an always-false condition, it can never trigger.
		// Therefore, it doesn't need a delta. Consider it "valid" for this check.
		if (g.some(req => req.isAlwaysFalse()))
			return true;

		let has_delta = false;
		let _prefix = '';

		let memset = new Set(corememset);
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.ADDADDRESS)
				_prefix += req.lhs.toString() + (!req.rhs ? '' : (req.op + req.rhs.toString())) + ':';
			else
			{
				if (req.lhs && req.lhs.type == ReqType.MEM) memset.add(_prefix + req.lhs.toString());
				if (req.rhs && req.rhs.type == ReqType.MEM) memset.add(_prefix + req.rhs.toString());
				_prefix = '';
			}
		}

		_prefix = '';
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.ADDADDRESS)
				_prefix += req.lhs.toString() + (!req.rhs ? '' : (req.op + req.rhs.toString())) + ':';
			else
			{
				// a delta only counts if it has a matching mem value
				for (let op of [req.lhs, req.rhs])
					if (op && op.type == ReqType.DELTA)
						has_delta ||= memset.has(_prefix + op.toString());
				_prefix = '';
			}
			
			if (req.isTerminating())
			{
				// this is the end of a chain that contained a delta and wasnt a reset or pause
				if (has_delta && !PAUSERESET.has(req.flag)) return true;
				has_delta = false;
			}
		}
		return false;
	});

	// either the core group must have the valid mem/delta check, or *all* alt groups
	if (delta_groups[0] || (delta_groups.length > 1 && delta_groups.slice(1).every(x => x))) return;
	
	// we know there's an issue
	yield new Issue(Feedback.IMPROPER_DELTA, null, DELTA_FEEDBACK);
}

function* check_missing_notes(logic)
{
	// skip this if notes aren't loaded
	if (!current.notes.length) return;
	
	for (const [gi, g] of logic.groups.entries())
	{
		let prev_addaddress = false;
		for (const [ri, req] of g.entries())
		{
			let lastreport = null;
			if (!prev_addaddress) for (const operand of [req.lhs, req.rhs])
			{
				if (!operand || !operand.type || !operand.type.addr) continue;
				const note = get_note(operand.value, current.notes);
				if (note) continue;

				if (lastreport == operand.value) continue;
				lastreport = operand.value;
				yield new Issue(Feedback.MISSING_NOTE, req,
					<ul>
						<li>Address <code>{toDisplayHex(operand.value)}</code> missing note</li>
					</ul>);
			}
			prev_addaddress = req.flag == ReqFlag.ADDADDRESS;
		}
	}
}

function* check_mismatch_notes(logic)
{
	// skip this if notes aren't loaded
	if (!current.notes.length) return;
	
	for (const [gi, g] of logic.groups.entries())
	{
		let prev_addaddress = false;
		for (const [ri, req] of g.entries())
		{
			let lastreport = null;
			if (!prev_addaddress) for (const operand of [req.lhs, req.rhs])
			{
				if (!operand?.type?.addr) continue;
				const note = get_note(operand.value, current.notes);
				if (!note) continue;

				// if the note size info is unknown, give up I guess
				if (note.type && operand.size && !PartialAccess.has(operand.size) && operand.size != note.type)
				yield new Issue(Feedback.TYPE_MISMATCH, req,
					<ul>
						<li>Accessing <code>{toDisplayHex(operand.value)}</code> as <code>{operand.size.name}</code></li>
						<li>Matching code note at <code>{toDisplayHex(note.addr)}</code> is marked as <code>{note.type.name}</code></li>
					</ul>);
			}
			prev_addaddress = req.flag == ReqFlag.ADDADDRESS;
		}
	}
}

function* check_pointers(logic)
{
	// check for pointer comparisons against a value that is non-zero
	for (const [gi, g] of logic.groups.entries())
	{
		for (const [ri, req] of g.entries())
		{
			if (!req.lhs?.type?.addr) continue;
			const note = get_note(req.lhs.value, current.notes);
			if (!note) continue;

			if (note.isProbablePointer() && req.isComparisonOperator() && req.rhs.type == ReqType.VALUE && req.rhs.value != 0)
				yield new Issue(Feedback.POINTER_COMPARISON, req); // TODO: provide better feedback
		}
	}
}

function* check_priors(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		for (const [ai, a] of g.entries())
			if (ReqOperand.sameValue(a.lhs, a.rhs) && a.op == '!=')
			{
				const _a = a.canonicalize();
				if (_a.lhs.type == ReqType.MEM && _a.rhs.type == ReqType.PRIOR)
					yield new Issue(Feedback.BAD_PRIOR, a,
						<ul>
							<li>A memory value will always be not-equal to its prior, unless the value has never changed.</li>
							<li>This requirement most likely does not accomplish anything and is probably safe to remove.</li>
						</ul>);
			}

		for (const [ai, a] of g.entries())
		{
			const _a = a.canonicalize();
			if (_a.op == '!=' && _a.lhs.type == ReqType.PRIOR && !_a.rhs.type.addr)
				for (const [bi, b] of g.entries()) if (ai != bi)
				{
					const _b = b.canonicalize();
					if (_b.op == '=' && _b.lhs.type == ReqType.MEM && !_b.rhs.type.addr)
					{
						if (ReqOperand.equals(_a.rhs, _b.rhs) && ReqOperand.sameValue(_a.lhs, _b.lhs))
							yield new Issue(Feedback.BAD_PRIOR, a,
								<ul>
									<li>The prior comparison will always be true when <code>{b.toAnnotatedString()}</code>, unless the value has never changed.</li>
									<li>This requirement most likely does not accomplish anything and is probably safe to remove.</li>
								</ul>);
					}
				}
		}
	}
}

function* check_bad_chains(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		const last = g[g.length-1];
		if (last && last.flag && last.flag.chain)
			yield new Issue(Feedback.BAD_CHAIN, last);
	}
}

function* check_stale_addaddress(logic)
{
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			// using AddAddress with Delta/Prior is dangerous
			if (req.flag == ReqFlag.ADDADDRESS && [ReqType.DELTA, ReqType.PRIOR].includes(req.lhs.type))
				yield new Issue(Feedback.STALE_ADDADDRESS, req);
		}
}

function* check_oca(logic)
{
	if (!logic.value && logic.getMemoryLookups().size <= 1)
		yield new Issue(Feedback.ONE_CONDITION, null);
}

function* check_pauselocks(logic)
{
	let groups_with_reset = new Set();
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.flag == ReqFlag.RESETIF)
				groups_with_reset.add(gi);

	for (const [gi, g] of logic.groups.entries())
		reqloop: for (const [ri, req] of g.entries())
		{
			// this is a pauselock
			if (req.hits > 0 && req.flag == ReqFlag.PAUSEIF)
			{
				for (let i = ri - 1; i >= 0; i--)
				{
					if (g[i].flag == ReqFlag.RESETNEXTIF) continue reqloop;
					if (g[i].isTerminating()) break;
				}

				// no RNI found, so if there isn't an alt reset, that's a problem
				if (groups_with_reset.difference(new Set([gi])).size == 0)
					yield new Issue(Feedback.PAUSELOCK_NO_RESET, req);
			}
		}
}

function* check_uncleared_hits(logic)
{
	let has_resetif = false;
	resetifloop: for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.flag == ReqFlag.RESETIF)
			{
				has_resetif = true;
				break resetifloop;
			}

	for (const [gi, g] of logic.groups.entries())
		reqloop: for (const [ri, req] of g.entries())
		{
			// a reset with hits is still a reset, and a pause with hits is a pauselock
			if (req.hits > 0 && req.flag != ReqFlag.RESETIF && req.flag != ReqFlag.PAUSEIF)
			{
				for (let i = ri - 1; i >= 0; i--)
				{
					if (g[i].flag == ReqFlag.RESETNEXTIF) continue reqloop;
					if (g[i].isTerminating()) break;
				}

				// no RNI found, so if there isn't a reset, that's a problem
				if (!has_resetif) yield new Issue(Feedback.HIT_NO_RESET, req);
			}
		}
}

function* check_uuo_andnext(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		let andnext_chain = [], valid = false;
		for (const [ri, req] of g.entries())
		{
			// add all AndNexts to a chain
			if (req.flag == ReqFlag.ANDNEXT) andnext_chain.push(req);
			// if there's an OrNext flag, I'm just going to let this go
			if (req.flag == ReqFlag.ORNEXT) valid = true;
			// if there are hitcounts *anywhere* in this chain, valid
			if (req.hits != 0) valid = true;
			
			if (req.isTerminating())
			{
				// if the chain terminates at any actual flag, valid
				if (req.flag || req.hits > 0) valid = true;

				if (andnext_chain.length && !valid)
					for (const andreq of andnext_chain)
						yield new Issue(Feedback.USELESS_ANDNEXT, andreq);
				andnext_chain = []; valid = false;
			}
		}
	}
}

function* check_uuo_pause(logic)
{
	let has_hits = false;
	hitloop: for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.hits > 0)
			{
				has_hits = true;
				break hitloop;
			}

	for (const [gi, g] of logic.groups.entries())
	{
		let group_flags = new Set(g.map(x => x.flag));
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.PAUSEIF && !has_hits)
			{
				// if the group has a Measured flag, give a slightly different warning
				if (group_flags.has(ReqFlag.MEASURED) || group_flags.has(ReqFlag.MEASUREDP))
					yield new Issue(Feedback.PAUSING_MEASURED, req);

				// pause in a value group can freeze the reported value, and therefore is fine
				else if (!logic.value)
					yield new Issue(Feedback.UUO_PAUSE, req,
						<ul>
							<li>Automated recommended change:</li>
							<pre><code>{invert_chain(g, ri)}</code></pre>
						</ul>);
			}
		}
	}
}

function* check_uuo_reset(logic)
{
	let has_hits = false;
	hitloop: for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
			if (req.hits > 0)
			{
				has_hits = true;
				break hitloop;
			}

	for (const [gi, g] of logic.groups.entries())
	{
		let group_flags = new Set(g.map(x => x.flag));
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.RESETIF && !has_hits)
			{
				// ResetIf with a measured should be fine in a value
				if (!logic.value || group_flags.has(ReqFlag.MEASURED) || group_flags.has(ReqFlag.MEASUREDP))
					yield new Issue(Feedback.UUO_RESET, req,
						<ul>
							<li>Automated recommended change:</li>
							<pre><code>{invert_chain(g, ri)}</code></pre>
						</ul>);
			}
		}
	}
}

function* check_reset_with_hits(logic)
{
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.RESETIF && req.hits == 1)
				yield new Issue(Feedback.RESET_HITCOUNT_1, req);
		}
}

function* check_uuo_resetnextif(logic)
{
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			if (req.flag == ReqFlag.RESETNEXTIF)
			{
				for (let i = ri + 1; i < g.length; i++)
				{
					// if the requirement has hits, RNI is valid
					if (g[i].hits > 0) break;

					// if this is a combining flag like AddAddress or AndNext, the chain continues
					if (!g[i].isTerminating()) continue;

					// ResetNextIf with a measured should be fine in a value
					if (logic.value && [ReqFlag.MEASURED, ReqFlag.MEASUREDP].includes(g[i].flag)) break;
					
					// RNI->PauseIf(0) is `Pause Until`
					// ref: https://docs.retroachievements.org/developer-docs/achievement-templates.html#pause-until-using-pauseif-to-prevent-achievement-processing-until-some-condition-is-met
					if (req.hits > 0 && g[i].flag == ReqFlag.PAUSEIF) break;
					
					// otherwise, RNI was not valid
					yield new Issue(Feedback.UUO_RNI, req);
					break;
				}
			}
		}
}

function* check_missing_enum(logic)
{
	for (const [gi, g] of logic.groups.entries())
		for (const [ri, req] of g.entries())
		{
			if (ri > 0 && g[ri-1].flag == ReqFlag.ADDADDRESS) continue;
			let creq = req.canonicalize();

			if (creq.lhs.type.addr && creq.rhs && creq.rhs.type == ReqType.VALUE)
				for (const note of current.notes)
					if (note.contains(creq.lhs.value) && note.enum)
			{
				let found = false;
				enumloop: for (const e of note.enum)
					if (e.value == creq.rhs.value)
					{ found = true; break enumloop; }

				if (!found)
					yield new Issue(Feedback.MISSING_ENUMERATION, req, 
						<ul>
							<li>Enumeration <code>0x{creq.rhs.value.toString(16).padStart(2, '0')}</code> not found for note at address <code>{toDisplayHex(creq.lhs.value)}</code></li>
						</ul>);
			}
		}
}

function* check_title_case(asset)
{
	let corrected_title = make_title_case(asset.title);
	if (corrected_title != asset.title)
	{
		const q = encodeURIComponent(asset.title);
		yield new Issue(Feedback.TITLE_CASE, 'title',
			<ul>
				<li>Automated suggestion: <em>{corrected_title}</em></li>
				<li>Additional suggestions</li>
				<ul>
					<li><a href={`https://titlecaseconverter.com/?style=CMOS&showExplanations=1&keepAllCaps=1&multiLine=1&highlightChanges=1&convertOnPaste=1&straightQuotes=1&title=${q}`}>titlecaseconverter.com</a></li>
					<li><a href={`https://capitalizemytitle.com/style/Chicago/?title=${q}`}>capitalizemytitle.com</a></li>
				</ul>
				<li><em>Warning: automated suggestions don't handle hyphenated or otherwise-separated words gracefully. When in doubt, please rely on the sites linked above.</em></li>
			</ul>);
	}
}

function HighlightedFeedback({text, pattern})
{
	let parts = text.split(pattern);
	for (let i = 1; i < parts.length; i += 2)
		parts[i] = <span key={i} className="warn">{parts[i]}</span>;
	return <>{parts}</>;
}

const EMOJI_RE = /(\p{Emoji_Presentation})/gu;
const TYPOGRAPHY_PUNCT = /([\u2018\u2019\u201C\u201D])/gu;
const FOREIGN_RE = /([\p{Script=Arabic}\p{Script=Armenian}\p{Script=Bengali}\p{Script=Bopomofo}\p{Script=Braille}\p{Script=Buhid}\p{Script=Canadian_Aboriginal}\p{Script=Cherokee}\p{Script=Cyrillic}\p{Script=Devanagari}\p{Script=Ethiopic}\p{Script=Georgian}\p{Script=Greek}\p{Script=Gujarati}\p{Script=Gurmukhi}\p{Script=Han}\p{Script=Hangul}\p{Script=Hanunoo}\p{Script=Hebrew}\p{Script=Hiragana}\p{Script=Inherited}\p{Script=Kannada}\p{Script=Katakana}\p{Script=Khmer}\p{Script=Lao}\p{Script=Limbu}\p{Script=Malayalam}\p{Script=Mongolian}\p{Script=Myanmar}\p{Script=Ogham}\p{Script=Oriya}\p{Script=Runic}\p{Script=Sinhala}\p{Script=Syriac}\p{Script=Tagalog}\p{Script=Tagbanwa}\p{Script=Tamil}\p{Script=Telugu}\p{Script=Thaana}\p{Script=Thai}\p{Script=Tibetan}\p{Script=Yi}]+)/gu;
const NON_ASCII_RE = /([^\x00-\x7F\xA5\xA3]+)/g;

function* check_writing_mistakes(asset)
{
	for (const elt of ['title', 'desc'])
	{
		if (EMOJI_RE.test(asset[elt]))
			yield new Issue(Feedback.NO_EMOJI, elt);
		else if (TYPOGRAPHY_PUNCT.test(asset[elt]))
		{
			let corrected = asset[elt].replace(/[\u2018\u2019]/g, "'").replace(/[\u201C\u201D]/g, '"');
			yield new Issue(Feedback.SPECIAL_CHARS, elt,
				<ul>
					<li>"Smart" quotes are great for typography, but often don't render correctly in emulators. <a href="https://en.wikipedia.org/wiki/Quotation_mark#Curved_quotes_within_and_across_applications">What are smart quotes?</a></li>
					<li><em><HighlightedFeedback text={asset[elt]} pattern={TYPOGRAPHY_PUNCT} /></em> &#x27F9; <code>{corrected}</code></li>
				</ul>);
		}
		else if (FOREIGN_RE.test(asset[elt]))
			yield new Issue(Feedback.FOREIGN_CHARS, elt,
				<ul>
					<li><em><HighlightedFeedback text={asset[elt]} pattern={FOREIGN_RE} /></em></li>
					<li>For policy exceptions regarding the use of foreign language, <a href="https://retroachievements.org/messages/create?to=QATeam">message QATeam</a></li>
				</ul>);
		else if (NON_ASCII_RE.test(asset[elt]))
			yield new Issue(Feedback.SPECIAL_CHARS, elt,
				<ul>
					<li><em><HighlightedFeedback text={asset[elt]} pattern={NON_ASCII_RE} /></em></li>
				</ul>);
	}
}

function* check_brackets(asset)
{
	if (asset.desc.trim().match(/.[\{\[\(](.+)[\}\]\)]/))
		yield new Issue(Feedback.DESC_BRACKETS, 'desc');
}

function* check_notes_missing_size(notes)
{
	for (const note of notes)
		if (note.type == null && note.size == 1)
			yield new Issue(Feedback.NOTE_NO_SIZE, note,
				<ul>
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code></li>
				</ul>);
}

const NUMERIC_RE = /\b(0x)?([0-9a-f]{2,})\b/gi;
function* check_notes_enum_hex(notes)
{
	for (const note of notes) if (note.enum)
	{
		let found = [];
		for (const {literal} of note.enum)
			for (const m of literal.matchAll(NUMERIC_RE))
				if (m[2].match(/[a-f]/i) && !m[1])
					found.push(literal);
		
		if (found.length > 0)
			yield new Issue(Feedback.NOTE_ENUM_HEX, note,
				<ul>
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code></li>
					<li>Found potential hex values: {found.map((x, i) => <React.Fragment key={i}>
						{i == 0 ? '' : ', '} <code>{x}</code>
					</React.Fragment>)}</li>
				</ul>);
	}
}

function* check_notes_enum_size_mismatch(notes)
{
	for (const note of notes) if (note.enum && note.type)
	{
		let found = [];
		for (const {literal, value} of note.enum)
			if (value > note.type.maxvalue)		
				found.push(literal);

		if (found.length > 0)
			yield new Issue(Feedback.NOTE_ENUM_TOO_LARGE, note,
				<ul>
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code></li>
					<li>The code note is listed as <code>{note.type.name}</code>, which has a max value of <code>0x{(note.type.maxvalue.toString(16).toUpperCase())}</code></li>
					<li>The following enumerated values are too large for this code note: {found.map((x, i) => <React.Fragment key={i}>
						{i == 0 ? '' : ', '} <code>{x}</code>
					</React.Fragment>)}</li>
				</ul>
			);
	}
}

function* check_rp_dynamic(rp)
{
	if (!rp.display.some(x => x.condition != null))
	{
		if (!rp.display.some(x => x.lookups.length > 0))
			yield new Issue(Feedback.NO_DYNAMIC_RP, null);
		else
			yield new Issue(Feedback.NO_CONDITIONAL_DISPLAY, null);
	}
}

function* check_rp_notes(rp)
{
	function* get_rp_notes_issues(logic, where)
	{
		for (const [gi, g] of logic.groups.entries())
		{
			let prev_addaddress = false;
			for (const [ri, req] of g.entries())
			{
				let lastreport = null;
				for (const operand of [req.lhs, req.rhs])
				{
					if (!operand || !operand.type || !operand.type.addr) continue;
					const note = get_note(operand.value, current.notes);

					if (!prev_addaddress && !note)
					{
						if (lastreport == operand.value) continue;
						yield new Issue(Feedback.MISSING_NOTE_RP, null,
							<ul>
								<li>Missing note for {where}: <code>{toDisplayHex(operand.value)}</code></li>
							</ul>);
						lastreport = operand.value;
					}

					if (!prev_addaddress && note)
					{
						// if the note size info is unknown, give up I guess
						if (note.type && operand.size && !PartialAccess.has(operand.size) && operand.size != note.type)
							yield new Issue(Feedback.TYPE_MISMATCH, req,
								<ul>
									<li>Accessing <code>{toDisplayHex(operand.value)}</code> in {where} as <code>{operand.size.name}</code></li>
									<li>Matching code note at <code>{toDisplayHex(note.addr)}</code> is marked as <code>{note.type.name}</code></li>
									<ul>
										<li>Correct accessor should be: <code>{note.type.prefix}{note.addr.toString(16).padStart(8, '0')}</code></li>
									</ul>
								</ul>);
					}
				}
				prev_addaddress = req.flag == ReqFlag.ADDADDRESS;
			}
		}
	}

	for (const [di, d] of rp.display.entries())
	{
		if (d.condition != null)
			yield* get_rp_notes_issues(d.condition, <>condition of display #{di+1}</>);
		for (const [li, look] of d.lookups.entries())
			yield* get_rp_notes_issues(look.calc, <><code>{look.name}</code> lookup of display #{di+1}</>);
	}
}

function* check_source_mod_measured(logic)
{
	if (!logic.value) return;
	for (const group of logic.groups)
		for (const [ri, req] of group.entries())
			if (req.flag == ReqFlag.MEASURED && req.isModifyingOperator())
			{
				let reqclone = req.clone();
				reqclone.flag = ReqFlag.ADDSOURCE;
				let fixed = reqclone.toMarkdown() + "\n" +
					Requirement.fromString("M:0").toMarkdown();

				for (let i = ri - 1; i >= 0; i--)
				{
					if (group[i].isTerminating()) break;
					fixed = group[i].toMarkdown() + '\n' + fixed;
				}

				yield new Issue(Feedback.SOURCE_MOD_MEASURED, req,
					<ul>
						<li>This can be fixed by using <code>AddSource</code> to add to a <code>Measured Val 0</code></li>
						<pre><code>{fixed}</code></pre>
					</ul>);
			}
}

function* check_progression_typing(set)
{
	// reflect an issue if achievement typing hasn't been added
	if (!set.getAchievements().some(ach => ach.achtype == 'win_condition') && !set.getAchievements().some(ach => ach.achtype == 'progression'))
		yield new Issue(Feedback.NO_TYPING, null);
	else if (!set.getAchievements().some(ach => ach.achtype == 'progression'))
		yield new Issue(Feedback.NO_PROGRESSION, null);
}

function* check_duplicate_text(set)
{
	let groups;

	// compare achievement titles
	groups = new Map();
	for (const asset of set.getAchievements())
	{
		if (!groups.has(asset.title)) groups.set(asset.title, []);
		groups.get(asset.title).push(asset);
	}

	for (let [title, group] of groups.entries())
		if (group.length > 1) yield new Issue(Feedback.DUPLICATE_TITLES, null,
			<ul>
				<li>{group.length} achievements share the title <code>{title}</code></li>
			</ul>
		);
	
	// compare achievement descriptions
	groups = new Map();
	for (const asset of set.getAchievements())
	{
		if (!groups.has(asset.desc)) groups.set(asset.desc, []);
		groups.get(asset.desc).push(asset);
	}

	for (let [desc, group] of groups.entries())
		if (group.length > 1) yield new Issue(Feedback.DUPLICATE_DESCRIPTIONS, null,
			<ul>
				<li>{group.length} achievements share the same description:</li>
				<ul>{group.map((asset, i) => <li key={i}>{asset.title}</li>)}</ul>
			</ul>
		);

	// compare achievement titles
	groups = new Map();
	for (const asset of set.getLeaderboards())
	{
		if (!groups.has(asset.title)) groups.set(asset.title, []);
		groups.get(asset.title).push(asset);
	}

	for (let [title, group] of groups.entries())
		if (group.length > 1) yield new Issue(Feedback.DUPLICATE_TITLES, null,
			<ul>
				<li>{group.length} leaderboards share the title <code>{title}</code></li>
			</ul>
		);
}

const BASIC_LOGIC_TESTS = [
	check_missing_notes,
	check_mismatch_notes,
	check_pointers,
	check_bad_chains,
	check_priors,
	check_stale_addaddress,
	check_uncleared_hits,
	check_uuo_andnext,
	check_pauselocks,
	check_uuo_pause,
	check_uuo_reset,
	check_reset_with_hits,
	check_uuo_resetnextif,
//	check_missing_enum,
];

const LOGIC_TESTS = [].concat(
	[
		check_deltas,
		check_oca,
	],
	BASIC_LOGIC_TESTS
);

const PRESENTATION_TESTS = [
	check_title_case,
	check_writing_mistakes,
	check_brackets,
];

const CODE_NOTE_TESTS = [
	check_notes_missing_size,
	check_notes_enum_hex,
	check_notes_enum_size_mismatch,
];

const RICH_PRESENCE_TESTS = [
	check_rp_dynamic,
	check_rp_notes,
];

const SET_TESTS = [
	check_progression_typing,
	check_duplicate_text,
];

const LEADERBOARD_TESTS = {
	'STA': LOGIC_TESTS,
	'CAN': BASIC_LOGIC_TESTS,
	'SUB': BASIC_LOGIC_TESTS,
	'VAL': BASIC_LOGIC_TESTS,
}

function get_leaderboard_issues(lb)
{
	let res = new IssueGroup("Logic & Design");
	for (let block of ["START", "CANCEL", "SUBMIT", "VALUE"])
	{
		const tag = block.substring(0, 3);
		for (const test of LEADERBOARD_TESTS[tag])
			for (const issue of test(lb.components[tag]))
				res.add(issue);
	}
	return res;
}

function assess_achievement(ach)
{
	let res = new Assessment();

	res.stats = generate_logic_stats(ach.logic);

	res.issues.push(IssueGroup.fromTests("Logic & Design", LOGIC_TESTS, ach.logic));
	res.issues.push(IssueGroup.fromTests("Presentation & Writing", PRESENTATION_TESTS, ach));

	// attach feedback to the asset
	return ach.feedback = res;
}

function assess_leaderboard(lb)
{
	let res = new Assessment();

	res.stats = generate_leaderboard_stats(lb);

	res.issues.push(get_leaderboard_issues(lb));
	res.issues.push(IssueGroup.fromTests("Presentation & Writing", PRESENTATION_TESTS, lb));

	// attach feedback to the asset
	return lb.feedback = res;
}

function assess_code_notes(notes)
{
	let res = new Assessment();

	res.stats = generate_code_note_stats(notes);

	res.issues.push(IssueGroup.fromTests("Code Notes", CODE_NOTE_TESTS, notes));

	// attach feedback to the asset
	return notes.feedback = res;
}

function assess_rich_presence(rp)
{
	let res = new Assessment();
	rp ??= new RichPresence(); // if there is no RP, just use a placeholder

	res.stats = generate_rich_presence_stats(rp);

	res.issues.push(IssueGroup.fromTests("Logic & Design", RICH_PRESENCE_TESTS, rp));

	// attach feedback to the asset
	// if this was a placeholder, it will fall off here
	return rp.feedback = res;
}

function assess_set(set)
{
	let res = new Assessment();

	res.stats = generate_set_stats(set);

	res.issues.push(IssueGroup.fromTests("Set Design", SET_TESTS, set));

	// attach feedback to the asset
	return set.feedback = res;
}
