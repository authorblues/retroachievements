function make_title_case(phrase)
{
	const TITLE_CASE_MINORS = new Set([
		'a', 'an', 'and', 'as', 'at', 'but', 'by', 'en', 'for', 'from', 'how', 'if', 'in', "n'", "'n'",
		'neither', 'nor', 'of', 'on', 'only', 'onto', 'out', 'or', 'over', 'per', 'so', 'than', 
		'the', 'to', 'until', 'up', 'upon', 'v', 'v.', 'versus', 'vs', 'vs.', 'via', 'when', 
		'with', 'without', 'yet',
	]);
	function tc_minor(word) { return TITLE_CASE_MINORS.has(word); }
	function tc(s) { return s.charAt(0).toUpperCase() + s.substring(1); }
	return phrase.replace(/[0-9'\u2018\u2019\p{Script=Latin}]+/gu, function(x, i)
	{
		// if the word is presented in allcaps, assume it is done so intentionally
		if (x == x.toUpperCase()) return x;
		// first and last word of a phrase should be capitalized
		if (i == 0 || i + x.length == phrase.length) return tc(x);
		// if this is part of a hyphenated word, don't change it
		if (phrase[i-1] == '-') return x;
		// first word of a new sentence should be capitalized again
		for (let j = i - 1; j >= 0; j--)
		{
			if ('.!?:;-'.includes(phrase[j])) return tc(x);
			else if (!phrase[j].match(/[\s"]/)) break;
		}
		// otherwise, just base it off of the minors rule
		return tc_minor(x.toLowerCase()) ? x.toLowerCase() : tc(x);
	});
}

function toDisplayHex(addr)
{ return '0x' + addr.toString(16).padStart(8, '0'); }

const FeedbackSeverity = Object.freeze({
	PASS: 0,
	INFO: 1,
	WARN: 2,
	FAIL: 3,
	ERROR: 4,
});

const SEVERITY_TO_CLASS = ['pass', 'info', 'warn', 'fail', 'fail'];

const Feedback = Object.freeze({
	// writing policy feedback
	TITLE_CASE: { severity: FeedbackSeverity.INFO, desc: "Titles should be written in title case according to the Chicago Manual of Style.",
		ref: ["https://en.wikipedia.org/wiki/Title_case#Chicago_Manual_of_Style",], },
	TITLE_PUNCTUATION: { severity: FeedbackSeverity.INFO, desc: "Asset titles are not full sentences, and should not end with punctuation (exception: ?, !, or ellipses).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation",], },
	DESC_SENTENCE_CASE: { severity: FeedbackSeverity.INFO, desc: "Asset descriptions should not be in title case, but rather sentence case.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#capitalization-1",], },
	DESC_PUNCT_CONSISTENCY: { severity: FeedbackSeverity.INFO, desc: "Asset descriptions should be consistent about whether or not they end with punctuation.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#punctuation-1",], },
	DESC_BRACKETS: { severity: FeedbackSeverity.INFO, desc: "Asset descriptions should avoid brackets where possible.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#brackets-parentheses",], },
	DESC_SYMBOLS: { severity: FeedbackSeverity.INFO, desc: "Asset descriptions are discouraged from using symbols to describe conditions.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	DESC_QUOTES: { severity: FeedbackSeverity.INFO, desc: "Asset descriptions should only use double quotation marks, except for quotes inside quotes.",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",], },
	NUM_FORMAT: { severity: FeedbackSeverity.INFO, desc: "Numbers should be formatted to conform to English standards (period for decimal separation, commas for grouping).",
		ref: ["https://docs.retroachievements.org/guidelines/content/writing-policy.html#number-formatting",], },
	NO_EMOJI: { severity: FeedbackSeverity.WARN, desc: "Asset titles and descriptions may not contain emoji.",
		ref: [
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#emojis",
			"https://docs.retroachievements.org/guidelines/content/writing-policy.html#symbols-and-emojis",
		], },
	SPECIAL_CHARS: { severity: FeedbackSeverity.WARN, desc: "Avoid using accented/special characters, as they can have rendering issues.",
		ref: [
		//	"https://docs.retroachievements.org/guidelines/content/naming-conventions.html",
			"https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#naming-convention-tips",
		], },
	FOREIGN_CHARS: { severity: FeedbackSeverity.INFO, desc: `Asset titles and descriptions should be written in English and should avoid special characters, unless given special approval.`,
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
	PROGRESSION_ONLY: { severity: FeedbackSeverity.FAIL, desc: "Progression-only sets should be avoided. Consider adding custom challenge achievements to improve it.",
		ref: ["https://retroachievements.org/game/5442",], },
	DUPLICATE_TITLES: { severity: FeedbackSeverity.FAIL, desc: "Assets should all have unique titles to distinguish them from one another.",
		ref: [], },
	DUPLICATE_DESCRIPTIONS: { severity: FeedbackSeverity.FAIL, desc: "Assets should have unique descriptions. Duplicate descriptions likely indicate redundant assets.",
		ref: [], },

	// code notes
	NOTE_EMPTY: { severity: FeedbackSeverity.INFO, desc: "Empty code note.",
		ref: [], },
	NOTE_NO_SIZE: { severity: FeedbackSeverity.FAIL, desc: "Code notes must have size information.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#specifying-memory-addresses-size",], },
	NOTE_ENUM_HEX: { severity: FeedbackSeverity.FAIL, desc: "Enumerated hex values in code notes should be prefixed with \"0x\" to avoid being misinterpreted as decimal values.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels",], },
	NOTE_ENUM_TOO_LARGE: { severity: FeedbackSeverity.FAIL, desc: "Enumerated values too large for code note size information.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels",], },
	BAD_REGION_NOTE: { severity: FeedbackSeverity.INFO, desc: "Some memory regions are unsafe, redundant, or should otherwise be avoided.",
		ref: ['https://docs.retroachievements.org/developer-docs/console-specific-tips.html',], },
	UNALIGNED_NOTE: { severity: FeedbackSeverity.INFO, desc: "16- and 32-bit data is often word-aligned.",
		ref: [], },

	// rich presence
	NO_DYNAMIC_RP: { severity: FeedbackSeverity.FAIL, desc: "Dynamic rich presence is required for all sets.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#introduction',], },
	NO_CONDITIONAL_DISPLAY: { severity: FeedbackSeverity.WARN, desc: "The use of conditional displays can improve the quality of rich presence by showing specific information based on the game mode.",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings',], },
	NO_DEFAULT_RP: { severity: FeedbackSeverity.ERROR, desc: "Rich presence requires a default display (without a condition).",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings',], },
	MULTIPLE_DEFAULT_RP: { severity: FeedbackSeverity.ERROR, desc: "There should only be one default rich presence display (without a condition).",
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings',], },
	DYNAMIC_DEFAULT_RP: { severity: FeedbackSeverity.WARN, desc: "The default display for rich presence should be static.",
		ref: [], },
	MISSING_NOTE_RP: { severity: FeedbackSeverity.FAIL, desc: "All addresses used in rich presence require a code note.",
		ref: [], },

	// NEW RP RULES (Ported from RARP Editor)
	RP_MACRO_NAME_INVALID: { severity: FeedbackSeverity.ERROR, desc: "Macro name should not be empty or contain spaces.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#lookups'] },
	RP_MACRO_BUILTIN_SHADOW: { severity: FeedbackSeverity.WARN, desc: "Macro name shadows a built-in macro.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#built-in-macros'] },
	RP_MACRO_CASE_COLLISION: { severity: FeedbackSeverity.WARN, desc: "Macro names should be unique. Macros with the same name but different cases hurts readability.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#lookups'] },
	RP_LOOKUP_OVERLAP: { severity: FeedbackSeverity.WARN, desc: "Lookup keys overlap.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#lookups'] },
	RP_FORMATTER_DUPLICATE: { severity: FeedbackSeverity.INFO, desc: "Format type is already used by another formatter.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#tips-and-tricks'] },
	RP_LOOKUP_EMPTY: { severity: FeedbackSeverity.ERROR, desc: "A Lookup must have at least one entry or a non-empty default value.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#lookups'] },
	RP_MACRO_UNUSED: { severity: FeedbackSeverity.INFO, desc: "Unused lookups or formatters should be removed.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#lookups'] },
	RP_CONDITION_MISSING_OPERATOR: { severity: FeedbackSeverity.ERROR, desc: "Condition line must have a comparison operator.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings'] },
	RP_CONDITION_UNNECESSARY_FLAG: { severity: FeedbackSeverity.WARN, desc: "Certain flags have no effect on display conditions and are unnecessary.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#conditional-display-strings'] },
	RP_MACRO_INVALID_REFERENCE: { severity: FeedbackSeverity.ERROR, desc: "Macros must match with a built-in or user-defined lookup or formatter.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#parse-errors'] },
	RP_MACRO_EMPTY: { severity: FeedbackSeverity.ERROR, desc: "Macro has no logic defined.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#macros'] },
	RP_MACRO_SYNTAX_ERROR: { severity: FeedbackSeverity.ERROR, desc: "Invalid macro logic syntax.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#macros'] },
	RP_MACRO_SYNTAX_WARN: { severity: FeedbackSeverity.WARN, desc: "Macro logic warning.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#macros'] },
	RP_LIMIT_EXCEEDED: { severity: FeedbackSeverity.WARN, desc: "Comparison value exceeds the maximum value for the memory size.", 
		ref: ['https://docs.retroachievements.org/developer-docs/rich-presence.html#condition-syntax'] },
		
	// code errors
	BAD_CHAIN: { severity: FeedbackSeverity.ERROR, desc: "The last requirement of a group cannot have a chaining flag.",
		ref: [], },
	MISSING_NOTE: { severity: FeedbackSeverity.FAIL, desc: "All addresses used in asset logic require a code note.",
		ref: ["https://docs.retroachievements.org/guidelines/content/code-notes.html",], },
	ONE_CONDITION: { severity: FeedbackSeverity.FAIL, desc: "One-condition achievements are dangerous and should be avoided.",
		ref: ["https://docs.retroachievements.org/developer-docs/tips-and-tricks.html#achievement-creation-tips",], },
	MISSING_DELTA: { severity: FeedbackSeverity.FAIL, desc: "Logic must contain a Delta to isolate the specific moment that an asset should trigger.",
		ref: ['https://docs.retroachievements.org/developer-docs/delta-values.html',], },
	IMPROPER_DELTA: { severity: FeedbackSeverity.WARN, desc: "Proper use of Delta can help identify the precise moment that an asset should trigger.",
		ref: ['https://docs.retroachievements.org/developer-docs/delta-values.html',], },
	BAD_PRIOR: { severity: FeedbackSeverity.FAIL, desc: "Questionable use of Prior. See below for more information.",
		ref: ['https://docs.retroachievements.org/developer-docs/prior-values.html',], },
	COMMON_ALT: { severity: FeedbackSeverity.WARN, desc: "If every alt group contains the same bit of logic in common, it can be refactored back into the Core group.",
		ref: [], },
	STALE_ADDADDRESS: { severity: FeedbackSeverity.INFO, desc: "Stale references with AddAddress can be dangerous. Use caution when reading a pointer from the previous frame (AddAddress + Delta).",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/addaddress.html#using-delta-with-chained-pointers',], },
	NEGATIVE_OFFSET: { severity: FeedbackSeverity.WARN, desc: "Negative pointer offsets are wrong in the vast majority of cases.",
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
	MISSING_ENUMERATION: { severity: FeedbackSeverity.FAIL, desc: "A value was used that doesn't match any of the enumerated values in the code note.",
		ref: ['https://docs.retroachievements.org/guidelines/content/code-notes.html#adding-values-and-labels',], },
	SOURCE_MOD_MEASURED: { severity: FeedbackSeverity.ERROR, desc: "Placing a source modification on a Measured requirement can cause faulty values in older versions of RetroArch (pre-1.10.1).",
		ref: ['https://discord.com/channels/310192285306454017/386068797921951755/1247501391908307027',], },
	PAUSELOCK_NO_RESET: { severity: FeedbackSeverity.FAIL, desc: "PauseLocks require a reset, either via ResetNextIf, or a ResetIf in another group.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html#pauseif-with-hit-counts',], },
	HIT_NO_RESET: { severity: FeedbackSeverity.FAIL, desc: "Hit counts require a reset, either via ResetIf or ResetNextIf.",
		ref: ['https://docs.retroachievements.org/developer-docs/hit-counts.html',], },
	USELESS_ANDNEXT: { severity: FeedbackSeverity.WARN, desc: "Combining requirements with AND is the default behavior. Useless AndNext flags should be removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/andnext-ornext.html',], },
	USELESS_ALT: { severity: FeedbackSeverity.ERROR, desc: "A Reset-only Alt group is considered satisfied, making all other Alt groups useless.",
		ref: [], },
	UUO_RESET: { severity: FeedbackSeverity.FAIL, desc: "ResetIf should only be used with requirements containing hit targets.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	UUO_RNI: { severity: FeedbackSeverity.FAIL, desc: "ResetNextIf should only be used with requirements containing hit targets, and must be placed immediately before the requirement with the hit target.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetnextif.html',], },
	UUO_PAUSE: { severity: FeedbackSeverity.FAIL, desc: "PauseIf should only be used with requirements containing hit targets.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/pauseif.html',], },
	ADDHITS_WITHOUT_TARGET: { severity: FeedbackSeverity.ERROR, desc: "AddHits in a chain should end in a hit target. Without a hit target, AddHits does nothing.",
		ref: [], },
	PAUSING_MEASURED: { severity: FeedbackSeverity.PASS, desc: "PauseIf should only be used with requirements containing hit targets, unless being used to freeze updates to a Measured requirement.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/measured.html#measured',], },
	RESET_HITCOUNT_1: { severity: FeedbackSeverity.WARN, desc: "A ResetIf or ResetNextIf with a hitcount of 1 does not require a hitcount. The hitcount can be safely removed.",
		ref: ['https://docs.retroachievements.org/developer-docs/flags/resetif.html',], },
	USELESS_ADDSUB: { severity: FeedbackSeverity.FAIL, desc: "Using AddSource and SubSource is better supported in old emulators, and should be preferred where possible.",
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
	severity;
	detail = [];
	constructor(type, target, detail = null)
	{
		this.type = type;
		this.severity = type.severity;
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
	status() { return Math.max(FeedbackSeverity.PASS, ...this.#allissues().map(x => x.severity)); }
	pass() { return this.status() < FeedbackSeverity.FAIL; }
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
				if (!prev_addaddress && !current.notes.get(operand.value))
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

	// count of requirements with hit counts
	stats.hit_targets = flat.filter(x => x.hits > 0).length;
	stats.checkpoint_hits = flat.filter(x => !PAUSERESET.has(x.flag) && x.hits == 1).length;
	stats.hit_target_many = flat.filter(x => x.hits > 1).length;

	// count of requirements with PauseIf
	stats.pause_ifs = flat.filter(x => x.flag == ReqFlag.PAUSEIF).length;
	stats.pause_locks = flat.filter(x => x.flag == ReqFlag.PAUSEIF && x.hits > 0).length;

	// count of requirements with ResetIf
	stats.reset_ifs = flat.filter(x => x.flag == ReqFlag.RESETIF).length;
	stats.reset_with_hits = flat.filter(x => x.flag == ReqFlag.RESETIF && x.hits > 0).length;

	// count of requirements with Deltas and Prior
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

	// is Remember/Recall used in this logic?
	stats.remember_recall = (
		flat.some(x => x.flag == ReqFlag.REMEMBER) || 
		[...operands].some(x => x.type == ReqType.RECALL)
	);

	// count of achievements with mixed AndNext and OrNext
	stats.mixed_andor_chains = chains.filter(ch => (
		ch.some(req => req.flag == ReqFlag.ANDNEXT) && ch.some(req => req.flag == ReqFlag.ORNEXT)
	)).length;

	// count of achievements with AddHits as a complex-OR
	stats.addhits_complex_or = chains.filter(ch => (
		ch.some(req => req.flag == ReqFlag.ADDHITS) && ch[ch.length-1].hits == 1
	)).length;

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
	let asset_addresses = [
		...current.set.getAchievements().map(e => ({asset: e, addrs: e.logic.getAddresses()})),
		...current.set.getLeaderboards().map(e => ({asset: e, addrs: Object.values(e.components).flatMap(cmp => cmp.getAddresses())})),
	];

	if (current.rp) {
		const display_cond_addrs = current.rp.display.map(display => display.condition).filter(cond => cond !== null).flatMap(cond => cond.getAddresses());
		const lookup_addrs = current.rp.display.flatMap(display => display.lookups).flatMap(lookup => lookup.calc.getAddresses());
		asset_addresses.push({asset: "Rich Presence", addrs: [...display_cond_addrs, ...lookup_addrs]});
	}

	notes.forEach(note => {
		note.assetList = asset_addresses.filter(e => e.addrs.includes(note.addr)).map(e => e.asset);
	});

	let used_notes = notes.filter(x => x.assetList.length > 0);

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
	stats.using_hitcounts = achievements.filter(ach => ach.feedback.stats.hit_target_many > 0);
	stats.using_checkpoint_hits = achievements.filter(ach => ach.feedback.stats.checkpoint_hits > 0);
	stats.using_pauselock = achievements.filter(ach => ach.feedback.stats.pause_locks > 0);
	stats.using_pauselock_alt_reset = achievements.filter(ach => ach.feedback.stats.pauselock_alt_reset > 0);
	stats.using_remember_recall = achievements.filter(ach => ach.feedback.stats.remember_recall);

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
		let chain = [];
		let chainIsDynamic = false;

		for (const [ri, req] of g.entries())
		{
			// Pointer Chain Logic:
			// If this requirement is an Add Address, we build up the chain context
			// and skip validation, as these are intermediate steps.
			if (req.flag == ReqFlag.ADDADDRESS)
			{
				// If the AddAddress uses a Recall operand, the pointer becomes dynamic/unknown at static analysis time.
				// We mark the chain as dynamic so we can skip validating the subsequent leaf.
				if (req.lhs && req.lhs.type == ReqType.RECALL) {
					chainIsDynamic = true;
				}

				// If the chain starts with a memory read that has NO matching code note,
				// it is likely an Array Indexing operation (Index + Base) rather than a Pointer (Base + Offset).
				// In this case, we do not add it to the pointer chain context, so the next line is validated 
				// as a standalone Base address. We must still validate the Index address itself here.
				if (chain.length === 0 && (!req.lhs || !req.lhs.type.addr || !ConditionFormatter.getEffectiveNote(current.notes, req.lhs.value))) {
					if (req.lhs && req.lhs.type.addr) {
						yield new Issue(Feedback.MISSING_NOTE, req,
							<ul>
								<li>Address {toDisplayHex(req.lhs.value)} missing note</li>
							</ul>);
					}
					// Do not add to chain; treat as index adjustment
					continue;
				}

				if (chain.length === 0 && req.lhs && req.lhs.type.addr) {
					chain.push({ type: 'base', value: req.lhs.value });
				} else if (req.lhs && req.lhs.type.addr) { 
					chain.push({ type: 'offset', value: req.lhs.value });
				}
				if (req.rhs && req.rhs.type.addr) {
					chain.push({ type: 'offset', value: req.rhs.value });
				}
				continue;
			}

			// Processing Leaf (or non-pointer instruction).
			// If the chain involves dynamic components (Recall), we cannot statically verify notes.
			if (chainIsDynamic) {
				chain = [];
				chainIsDynamic = false;
				continue;
			}

			let lastreport = null;
			for (const operand of [req.lhs, req.rhs])
			{
				if (!operand || !operand.type || !operand.type.addr) continue;

				// Use the existing note parsing logic to see if this address (with chain context)
				// resolves to any note text.
				const noteText = current.notes.get_text(operand.value, chain);
				if (noteText) continue;

				if (lastreport == operand.value) continue;
				lastreport = operand.value;
				
				let msg = `Address ${toDisplayHex(operand.value)} missing note`;
				if (chain.length > 0) msg += " (or pointer base missing)";

				yield new Issue(Feedback.MISSING_NOTE, req,
					<ul>
						<li>{msg}</li>
					</ul>);
			}
			
			// Reset chain after processing the leaf
			chain = [];
			chainIsDynamic = false;
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
				const note = current.notes.get(operand.value);
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
			const note = current.notes.get(req.lhs.value);
			if (!note) continue;

			if (note.isProbablePointer() && req.isComparisonOperator() && req.rhs.type == ReqType.VALUE && req.rhs.value != 0)
				yield new Issue(Feedback.POINTER_COMPARISON, req); // TODO: provide better feedback
		}
	}
}

function* check_valid_offsets(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		let isOffset = false;
		for (const [ri, req] of g.entries())
		{
			if (isOffset)
			{
				for (const op of [req.lhs, req.rhs])
					if (op && op.type.addr && op.value >= 0x80000000)
						yield new Issue(Feedback.NEGATIVE_OFFSET, req);
			}
			isOffset = req.flag == ReqFlag.ADDADDRESS;
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
		yield new Issue(Feedback.ONE_CONDITION, null,
			<ul>
				<li>Trigger logic should make use of, at minimum, two different memory requirements to avoid misfires.</li>
				<li><code>Mem 0xADDR</code> and <code>Delta 0xADDR</code> are considered to be one memory requirement.</li>
			</ul>);
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
	{
		let has_addhits = false;
		for (const [ri, req] of g.entries())
		{
			if (!has_addhits && req.flag == ReqFlag.RESETIF && req.hits == 1)
				yield new Issue(Feedback.RESET_HITCOUNT_1, req);

			if (req.flag == ReqFlag.ADDHITS) has_addhits = true;
			else if (!req.flag || !req.flag.chain) has_addhits = false;
		}
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

					// ResetNextIf with any Add/SubHits should always be valid
					if ([ReqFlag.ADDHITS, ReqFlag.SUBHITS].includes(g[i].flag)) break;

					// ResetNextIf with a measured should be fine in a value
					if (logic.value && [ReqFlag.MEASURED, ReqFlag.MEASUREDP].includes(g[i].flag)) break;
					
					// RNI(1+)->PauseIf(0) is `Pause Until`
					// ref: https://docs.retroachievements.org/developer-docs/achievement-templates.html#pause-until-using-pauseif-to-prevent-achievement-processing-until-some-condition-is-met
					if (req.hits > 0 && g[i].flag == ReqFlag.PAUSEIF) break;
					
					// otherwise, RNI was not valid
					yield new Issue(Feedback.UUO_RNI, req);
					break;
				}
			}
		}
}

function* check_uuo_addhits(logic)
{
	for (const [gi, g] of logic.groups.entries())
	{
		let has_addhits = false;
		for (const [ri, req] of g.entries())
		{
			has_addhits ||= (req.flag == ReqFlag.ADDHITS || req.flag == ReqFlag.SUBHITS);
			if (!req.flag || !req.flag.chain)
			{
				if (!logic.value && has_addhits && req.hits == 0)
					yield new Issue(Feedback.ADDHITS_WITHOUT_TARGET, req);
				has_addhits = false;
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
				<li>Additional suggestions (links below take have been auto-filled with this title)</li>
				<ul>
					<li><a href={`https://titlecaseconverter.com/?style=CMOS&showExplanations=1&keepAllCaps=1&multiLine=1&highlightChanges=1&convertOnPaste=1&straightQuotes=1&title=${q}`}>titlecaseconverter.com</a> &mdash; preferred by Writing Team</li>
					<li><a href={`https://capitalizemytitle.com/style/Chicago/?title=${q}`}>capitalizemytitle.com</a> &mdash; for backup feedback</li>
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

function* check_notes_bad_regions(notes)
{
	const regions = current.set?.console?.regions || [];
	let ri = 0;
	for (let note of notes)
	{
		while (ri < regions.length && note.addr > regions[ri].end) ri++;
		if (ri >= regions.length) return;

		const r = regions[ri];
		if (note.addr >= r.start)
		{
			let issue = new Issue(Feedback.BAD_REGION_NOTE, note,
				<ul>
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code>: <code>{note.getHeader()}</code></li>
					<li>Appears in the {r.name} region (<code>{toDisplayHex(r.start)}-{toDisplayHex(r.end)}</code>)</li>
					{
						r.isError ? <></> : (<ul>
							<li><em>This is only a warning based on the way memory on {current.set?.console?.name} is commonly used. This is not necessarily an error, if memory is being used in a non-standard way.</em></li>
						</ul>)
					}
					{
						!r.transform ? <></> : (<ul>
							<li><strong>Suggested fix:</strong> Move this note to the address <code>{toDisplayHex(r.transform(note.addr))}</code></li>
						</ul>)
					}
				</ul>);
			// dynamically adjust severity of the issue depending on the region
			issue.severity = r.isError ? FeedbackSeverity.FAIL : FeedbackSeverity.INFO;
			yield issue;
		}
	}
}

function* check_notes_missing_size(notes)
{
	for (const note of notes)
		if (note.type == null && note.size == 1)
			yield new Issue(Feedback.NOTE_NO_SIZE, note,
				<ul>
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code>: <code>{note.getHeader()}</code></li>
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
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code>: <code>{note.getHeader()}</code></li>
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
					<li>Code note at <code className="ref-link" data-ref={note.addr}>{toDisplayHex(note.addr)}</code>: <code>{note.getHeader()}</code></li>
					<li>The code note is listed as <code>{note.type.name}</code>, which has a max value of <code>0x{(note.type.maxvalue.toString(16).toUpperCase())}</code></li>
					<li>The following enumerated values are too large for this code note: {found.map((x, i) => <React.Fragment key={i}>
						{i == 0 ? '' : ', '} <code>{x}</code>
					</React.Fragment>)}</li>
				</ul>
			);
	}
}

function* validate_condition_values(logic, context) {
	let memTypes = new Set([ReqType.MEM, ReqType.DELTA, ReqType.PRIOR, ReqType.BCD, ReqType.INVERT]);
	
	for (let group of logic.groups) {
		let hasAccumulator = false;
		
		for (let req of group) {
			// If this requirement is an accumulator, mark the chain as active
			if (req.flag && ['AddSource', 'SubSource'].includes(req.flag.name)) {
				hasAccumulator = true;
			}

			if (req.op && ['=', '!=', '<', '<=', '>', '>='].includes(req.op) && req.lhs && req.rhs) {
				// Only perform the limit check if we are NOT at the end of an accumulator chain
				if (!hasAccumulator) {
					if (memTypes.has(req.lhs.type) && req.rhs.type === ReqType.VALUE) {
						let limit = req.lhs.maxValue();
						if (limit !== null && limit !== Number.POSITIVE_INFINITY && req.rhs.value > limit) {
							yield new Issue(Feedback.RP_LIMIT_EXCEEDED, req, <ul><li>In {context}: Comparison value <code>{req.rhs.value}</code> exceeds max value for <code>{req.lhs.size?.name}</code> ({limit}). This comparison will unlikely behave as expected.</li></ul>);
						}
					} else if (memTypes.has(req.rhs.type) && req.lhs.type === ReqType.VALUE) {
						let limit = req.rhs.maxValue();
						if (limit !== null && limit !== Number.POSITIVE_INFINITY && req.lhs.value > limit) {
							yield new Issue(Feedback.RP_LIMIT_EXCEEDED, req, <ul><li>In {context}: Comparison value <code>{req.lhs.value}</code> exceeds max value for <code>{req.rhs.size?.name}</code> ({limit}). This comparison will unlikely behave as expected.</li></ul>);
						}
					}
				}
			}

			// Reset the accumulator chain tracker if the current requirement does not logically carry the math forward
			if (!req.flag || !['AddSource', 'SubSource', 'AddAddress'].includes(req.flag.name)) {
				hasAccumulator = false;
			}
		}
	}
}

function* validate_macro_logic(part, ds) {
	let logic = part.logic;
	if (!logic) return;
	
	yield* validate_condition_values(logic, `macro '{${part.text}}'`);
	
	let allSingletons = [];
	let conditionalLines = [];
	let totalValueProviders = 0;
	
	for (let group of logic.groups) {
		let groupValueProviders = 0;
		let isGroupChain = false;

		for (let req of group) {
			if (req.flag && ['AddAddress', 'AddSource', 'SubSource', 'Remember'].includes(req.flag.name)) isGroupChain = true;
			
			let isCmp = ['=', '!=', '<', '<=', '>', '>='].includes(req.op);
			if (isCmp) {
				conditionalLines.push(req);
				if (req.flag && (req.flag.name === 'Measured' || req.flag.name === 'Measured%')) {
					yield new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, req, <ul><li>In macro '{part.text}', 'Measured' cannot be combined with a comparison operator.</li></ul>);
					yield new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, req, <ul><li>In macro <code>{part.text}</code>, <code>Measured</code> cannot be combined with a comparison operator.</li></ul>);
				}
			} else {
				allSingletons.push(req);
				if (req.flag && (req.flag.name === 'Measured' || req.flag.name === 'Measured%')) {
					groupValueProviders++;
					totalValueProviders++;
				}
			}
			
			if (req.flag && req.flag.name === 'Trigger') {
				yield new Issue(Feedback.RP_MACRO_SYNTAX_WARN, req, <ul><li>In macro <code>{part.text}</code>, the <code>Trigger</code> flag has no effect here.</li></ul>);
			}
		}

		// Validation 1: Per-group Measured limit
		if (groupValueProviders > 1) {
			let issue = new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, ds, <ul><li>In macro <code>{part.text}</code>, a Value Group cannot have more than one <code>Measured</code> value.</li></ul>);
			issue.macro = part.text;
			yield issue;
		}

		// Validation 2: Per-group chain endpoint check
		if (isGroupChain) {
			let lastReq = group.length > 0 ? group[group.length - 1] : null;
			if (lastReq && (!lastReq.flag || (lastReq.flag.name !== 'Measured' && lastReq.flag.name !== 'Measured%'))) {
				yield new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, lastReq, <ul><li>In macro <code>{part.text}</code>, the arithmetic chain does not end with a <code>Measured</code> flag.</li></ul>);
			}
		}
	}
	
	// Validation 3: Conditional macros must provide a value
	if (conditionalLines.length > 0 && totalValueProviders === 0) {
		let issue = new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, ds, <ul><li>In macro <code>{part.text}</code>, conditional logic exists but is missing a <code>Measured</code> flag to specify the return value.</li></ul>);
		issue.macro = part.text;
		yield issue;
	}
	
	// Validation 4: If returning a Measured value, all non-chain lines MUST be conditions
	if (totalValueProviders > 0) {
		for (let group of logic.groups) {
			for (let req of group) {
				if (req.flag && (req.flag.name === 'Measured' || req.flag.name === 'Measured%')) continue;
				if (req.flag && ['AddAddress', 'AddSource', 'SubSource', 'Remember'].includes(req.flag.name)) continue;
				
				let isCmp = ['=', '!=', '<', '<=', '>', '>='].includes(req.op);
				if (!isCmp) {
					yield new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, req, <ul><li>In macro <code>{part.text}</code>, this line is treated as a condition (since a <code>Measured</code> value exists) and must have a comparison operator.</li></ul>);
				}
			}
		}
	}
	
	// Validation 5: Multiple raw addresses without comparisons/Measured flags
	if (allSingletons.length > 1) {
		let trueEndpoints = allSingletons.filter(c => !c.flag || !['AddAddress', 'AddSource', 'SubSource', 'Remember'].includes(c.flag.name));
		if (trueEndpoints.length === 0 && allSingletons.length > 0) {
			trueEndpoints.push(allSingletons[allSingletons.length - 1]);
		}
		if (trueEndpoints.length > 1) {
			let hasMeasured = trueEndpoints.some(c => c.flag && (c.flag.name === 'Measured' || c.flag.name === 'Measured%'));
			if (!hasMeasured) {
				let issue = new Issue(Feedback.RP_MACRO_SYNTAX_ERROR, ds, <ul><li>In macro <code>{part.text}</code>, multiple memory addresses are provided without a comparison. One must be marked with a <code>Measured</code> flag.</li></ul>);
				issue.macro = part.text;
				yield issue;
			}
		}
	}
}

function* check_rp_lookups(rp) {
	const builtInMacros = new Set(['Number', 'Unsigned', 'Score', 'Centiseconds', 'Seconds', 'Minutes', 'Fixed1', 'Fixed2', 'Fixed3', 'Float1', 'Float2', 'Float3', 'Float4', 'Float5', 'Float6', 'ASCIIChar', 'UnicodeChar']);
	
	let usedMacros = new Set();
	rp.displayStrings.forEach(ds => ds.parts.filter(p => p.isMacro).forEach(p => usedMacros.add(p.text)));

	for (let i = 0; i < rp.scriptLookups.length; i++) {
		let lookup = rp.scriptLookups[i];
		
		if (!lookup.name || lookup.name.includes(" ")) {
			yield new Issue(Feedback.RP_MACRO_NAME_INVALID, lookup, <ul>
				<li>Name <code>{lookup.name}</code> should not be empty or contain spaces.</li>
			</ul>);
		}
		if (builtInMacros.has(lookup.name)) {
			yield new Issue(Feedback.RP_MACRO_BUILTIN_SHADOW, lookup, <ul><li><code>{lookup.name}</code> is a built-in formatter name.</li></ul>);
		}
		
		let caseCollisions = rp.scriptLookups.filter(x => x !== lookup && x.name.toLowerCase() === lookup.name.toLowerCase() && x.name !== lookup.name);
		if (caseCollisions.length > 0 && caseCollisions.every(x => lookup.name < x)) {
			let conflictList = <React.Fragment>{caseCollisions.map((x, i) => 
				<React.Fragment key={i}>{i == 0 ? '' : ', '} <code>{x}</code></React.Fragment>
			)}</React.Fragment>;
			yield new Issue(Feedback.RP_MACRO_CASE_COLLISION, lookup, <ul>
				<li>Macro <code>{lookup.name}</code> conflicts with {conflictList}</li>
			</ul>);
		}
		
		for (let a = 0; a < lookup.entries.length; a++) {
			let entryA = lookup.entries[a];
			let startA = entryA.keyValue;
			let endA = entryA.keyValueEnd !== null ? entryA.keyValueEnd : startA;
			for (let b = a + 1; b < lookup.entries.length; b++) {
				let entryB = lookup.entries[b];
				let startB = entryB.keyValue;
				let endB = entryB.keyValueEnd !== null ? entryB.keyValueEnd : startB;
				if (startA <= endB && endA >= startB) {
					yield new Issue(Feedback.RP_LOOKUP_OVERLAP, lookup, <ul>
						<li>Key <code>{entryA.keyString}</code> overlaps with key <code>{entryB.keyString}</code> in <code>{lookup.name}</code>. The first entry will take precedence.</li>
					</ul>);
				}
			}
		}
		
		if (lookup.isFormatter()) {
			/* // noop for now because this is often done for readability purposes
			let duplicateFormatters = rp.scriptLookups.filter(x => x !== lookup && x.isFormatter() && x.format.toLowerCase() === lookup.format.toLowerCase());
			if (duplicateFormatters.length > 0) {
				yield new Issue(Feedback.RP_FORMATTER_DUPLICATE, lookup, <ul>
					<li>The format type <code>{lookup.format}</code> is already used by another formatter.</li>
				</ul>);
			}
			*/
		} else if (lookup.format === "VALUE" && lookup.defaultVal !== null) {
			if (lookup.entries.length === 0 && !lookup.defaultVal) {
				yield new Issue(Feedback.RP_LOOKUP_EMPTY, lookup, <ul>
					<li>Lookup <code>{lookup.name}</code> is empty.</li>
				</ul>);
			}
		}
		
		if (!usedMacros.has(lookup.name)) {
			yield new Issue(Feedback.RP_MACRO_UNUSED, lookup, <ul>
				<li>Lookup/Formatter <code>{lookup.name}</code> is not currently used in any display string.</li>
			</ul>);
		}
	}
}

function* check_rp_display_strings(rp) {
	const builtInMacros = new Set(['Number', 'Unsigned', 'Score', 'Centiseconds', 'Seconds', 'Minutes', 'Fixed1', 'Fixed2', 'Fixed3', 'Float1', 'Float2', 'Float3', 'Float4', 'Float5', 'Float6', 'ASCIIChar', 'UnicodeChar']);
	
	for (let i = 0; i < rp.displayStrings.length; i++) {
		let ds = rp.displayStrings[i];
		
		if (!ds.isDefault) {
			if (!ds.conditionStr || ds.conditionStr.trim() === "") {
				yield new Issue(Feedback.RP_CONDITION_MISSING_OPERATOR, ds, <ul><li>Conditional string should have a condition.</li></ul>);
			} else if (ds.condition) {
				yield* validate_condition_values(ds.condition, "the display condition");
				
				let warningFlags = new Set(["Measured", "Measured%", "MeasuredIf", "Trigger"]);
				let arithmeticFlags = new Set(["AddAddress", "AddSource", "SubSource", "Remember"]);
				let cmpOps = new Set(["=", "!=", "<", "<=", ">", ">="]);
				
				for (let group of ds.condition.groups) {
					for (let req of group) {
						if (req.flag && warningFlags.has(req.flag.name)) {
							yield new Issue(Feedback.RP_CONDITION_UNNECESSARY_FLAG, req, <ul>
								<li>The <code>{req.flag.name}</code> flag is not typically used in a display condition.</li>
							</ul>);
						}
						if ((!req.flag || !arithmeticFlags.has(req.flag.name)) && !cmpOps.has(req.op)) {
							yield new Issue(Feedback.RP_CONDITION_MISSING_OPERATOR, req, <ul>
								<li>Condition line must have a comparison operator (e.g., <code>=</code>, <code>!=</code>, <code>&lt;</code>).</li>
							</ul>);
						}
					}
				}
			}
		}
		
		for (let part of ds.parts.filter(p => p.isMacro)) {
			if (builtInMacros.has(part.text)) {
				if (!part.parameter || part.parameter.trim() === "") {
					let issue = new Issue(Feedback.RP_MACRO_EMPTY, ds, <ul><li>Built-in formatter <code>&#123;{part.text}&#125;</code> has no logic defined.</li></ul>);
					issue.macro = part.text;
					yield issue;
				} else {
					yield* validate_macro_logic(part, ds);
				}
				continue;
			}
			
			let exactMatch = rp.scriptLookups.some(x => x.name === part.text);
			if (!exactMatch) {
				let suggestion = <React.Fragment></React.Fragment>;
				let caseMatch = rp.scriptLookups.find(x => x.name.toLowerCase() === part.text.toLowerCase());
				if (caseMatch) suggestion = <ul>
						<li><em>Did you mean <code>&#123;{caseMatch.name}&#125;</code>? Macro names are case-sensitive.</em></li>
					</ul>;
				let issue = new Issue(Feedback.RP_MACRO_INVALID_REFERENCE, ds, <ul>
					<li>Macro <code>&#123;{part.text}&#125;</code> does not point to any defined Lookup or Formatter.</li>
					{suggestion}
				</ul>);
			}
			
			if (!part.parameter || part.parameter.trim() === "") {
				let issue = new Issue(Feedback.RP_MACRO_EMPTY, ds, <ul><li>Macro <code>&#123;{part.text}&#125;</code> has no logic defined.</li></ul>);
				issue.macro = part.text;
				yield issue;
			} else {
				yield* validate_macro_logic(part, ds);
			}
		}
	}
}

function* check_rp_dynamic(rp)
{
	if (!rp.displayStrings.some(x => !x.isDefault))
	{
		if (!rp.displayStrings.some(ds => ds.parts.some(p => p.isMacro)))
			yield new Issue(Feedback.NO_DYNAMIC_RP, null);
		else
			yield new Issue(Feedback.NO_CONDITIONAL_DISPLAY, null);
	}
}

function* check_rp_default(rp)
{
	let defaults = rp.displayStrings.filter(x => x.isDefault);
	if (defaults.length == 0) {
		yield new Issue(Feedback.NO_DEFAULT_RP, null);
	} else if (defaults.length > 1) {
		yield new Issue(Feedback.MULTIPLE_DEFAULT_RP, null);
	} else {
		if (defaults[0].parts.some(x => x.isMacro)) {
			yield new Issue(Feedback.DYNAMIC_DEFAULT_RP, defaults[0],
				<ul>
					<li>Unknown state may produce unreliable output with memory lookups.</li>
					<li>Consider <code>Playing {get_game_title() ?? "<Game Name>"}</code></li>
				</ul>);
		}
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
					const note = current.notes.get(operand.value);

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
	check_valid_offsets,
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
	check_uuo_addhits,
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
	check_notes_bad_regions,
	check_notes_missing_size,
	check_notes_enum_hex,
	check_notes_enum_size_mismatch,
];

const RICH_PRESENCE_TESTS = [
	check_rp_dynamic,
	check_rp_default,
	check_rp_notes,
    check_rp_lookups,
	check_rp_display_strings,
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