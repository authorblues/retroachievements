const ReqType = Object.freeze({
	MEM:    { name: "Mem",    prefix: "",         addr: true, },
	DELTA:  { name: "Delta",  prefix: "d",        addr: true, },
	PRIOR:  { name: "Prior",  prefix: "p",        addr: true, },
	BCD:    { name: "BCD",    prefix: "b",        addr: true, },
	INVERT: { name: "Invert", prefix: "~",        addr: true, },
	
	VALUE:  { name: "Value",  prefix: "v",        addr: false, },
	FLOAT:  { name: "Float",  prefix: "f",        addr: false, },

	RECALL: { name: "Recall", prefix: "{recall}", addr: false, },
});

const ReqFlag = Object.freeze({
	PAUSEIF:     { name: "PauseIf",      prefix: "P:", chain: false, scalable: false, },
	RESETIF:     { name: "ResetIf",      prefix: "R:", chain: false, scalable: false, },
	RESETNEXTIF: { name: "ResetNextIf",  prefix: "Z:", chain: true,  scalable: false, },
	ADDSOURCE:   { name: "AddSource",    prefix: "A:", chain: true,  scalable: true , },
	SUBSOURCE:   { name: "SubSource",    prefix: "B:", chain: true,  scalable: true , },
	ADDHITS:     { name: "AddHits",      prefix: "C:", chain: true,  scalable: false, },
	SUBHITS:     { name: "SubHits",      prefix: "D:", chain: true,  scalable: false, },
	ADDADDRESS:  { name: "AddAddress",   prefix: "I:", chain: true,  scalable: true , },
	ANDNEXT:     { name: "AndNext",      prefix: "N:", chain: true,  scalable: false, },
	ORNEXT:      { name: "OrNext",       prefix: "O:", chain: true,  scalable: false, },
	MEASURED:    { name: "Measured",     prefix: "M:", chain: false, scalable: false, },
	MEASUREDP:   { name: "Measured%",    prefix: "G:", chain: false, scalable: false, },
	MEASUREDIF:  { name: "MeasuredIf",   prefix: "Q:", chain: false, scalable: false, },
	TRIGGER:     { name: "Trigger",      prefix: "T:", chain: false, scalable: false, },
	REMEMBER:    { name: "Remember",     prefix: "K:", chain: false, scalable: true , },
});

const MemSize = Object.freeze({
	BYTE:     { name: "8-bit",        prefix: "0xH", bytes: 1, maxvalue: 0xFF, },
	WORD:     { name: "16-bit",       prefix: "0x",  bytes: 2, maxvalue: 0xFFFF, },
	TBYTE:    { name: "24-bit",       prefix: "0xW", bytes: 3, maxvalue: 0xFFFFFF, },
	DWORD:    { name: "32-bit",       prefix: "0xX", bytes: 4, maxvalue: 0xFFFFFFFF, },
	WORD_BE:  { name: "16-bit BE",    prefix: "0xI", bytes: 2, maxvalue: 0xFFFF, },
	TBYTE_BE: { name: "24-bit BE",    prefix: "0xJ", bytes: 3, maxvalue: 0xFFFFFF, },
	DWORD_BE: { name: "32-bit BE",    prefix: "0xG", bytes: 4, maxvalue: 0xFFFFFFFF, },
	
	LOWER4:   { name: "Lower4",       prefix: "0xL", bytes: 1, maxvalue: 0xF, },
	UPPER4:   { name: "Upper4",       prefix: "0xU", bytes: 1, maxvalue: 0xF, },

	FLOAT:    { name: "Float",        prefix: "fF", bytes: 4, maxvalue: Number.POSITIVE_INFINITY, },
	FLOAT_BE: { name: "Float BE",     prefix: "fB", bytes: 4, maxvalue: Number.POSITIVE_INFINITY, },
	DBL32:    { name: "Double32",     prefix: "fH", bytes: 8, maxvalue: Number.POSITIVE_INFINITY, },
	DBL32_BE: { name: "Double32 BE",  prefix: "fI", bytes: 8, maxvalue: Number.POSITIVE_INFINITY, },
	MBF32:    { name: "MBF32",        prefix: "fM", bytes: 4, maxvalue: Number.POSITIVE_INFINITY, },
	MBF32_LE: { name: "MBF32 LE",     prefix: "fL", bytes: 4, maxvalue: Number.POSITIVE_INFINITY, },

	BIT0:     { name: "Bit0",         prefix: "0xM", bytes: 1, maxvalue: 1, },
	BIT1:     { name: "Bit1",         prefix: "0xN", bytes: 1, maxvalue: 1, },
	BIT2:     { name: "Bit2",         prefix: "0xO", bytes: 1, maxvalue: 1, },
	BIT3:     { name: "Bit3",         prefix: "0xP", bytes: 1, maxvalue: 1, },
	BIT4:     { name: "Bit4",         prefix: "0xQ", bytes: 1, maxvalue: 1, },
	BIT5:     { name: "Bit5",         prefix: "0xR", bytes: 1, maxvalue: 1, },
	BIT6:     { name: "Bit6",         prefix: "0xS", bytes: 1, maxvalue: 1, },
	BIT7:     { name: "Bit7",         prefix: "0xT", bytes: 1, maxvalue: 1, },
	BITCOUNT: { name: "BitCount",     prefix: "0xK", bytes: 1, maxvalue: 8, },
});

const FormatType = Object.freeze({
	POINTS:        { name: "Score", type: "POINTS", category: "value", },
	SCORE:         { name: "Score", type: "SCORE", category: "value", },
	FRAMES:        { name: "Frames", type: "FRAMES", category: "time", },
	TIME:          { name: "Frames", type: "TIME", category: "time", },
	MILLISECS:     { name: "Centiseconds", type: "MILLISECS", category: "time", },
	TIMESECS:      { name: "Seconds", type: "TIMESECS", category: "time", },
	SECS:          { name: "Seconds", type: "SECS", category: "time", },
	MINUTES:       { name: "Minutes", type: "MINUTES", category: "time", },
	SECS_AS_MINS:  { name: "Seconds", type: "SECS_AS_MINS", category: "time", },
	VALUE:         { name: "Value", type: "VALUE", category: "value", },
	UNSIGNED:      { name: "Unsigned", type: "UNSIGNED", category: "value", },
	TENS:          { name: "Value &times; 10", type: "TENS", category: "value", },
	HUNDREDS:      { name: "Value &times; 100", type: "HUNDREDS", category: "value", },
	THOUSANDS:     { name: "Value &times; 1000", type: "THOUSANDS", category: "value", },
	FIXED1:        { name: "Fixed1", type: "FIXED1", category: "value", },
	FIXED2:        { name: "Fixed2", type: "FIXED2", category: "value", },
	FIXED3:        { name: "Fixed3", type: "FIXED3", category: "value", },
	FLOAT1:        { name: "Float1", type: "FLOAT1", category: "value", },
	FLOAT2:        { name: "Float2", type: "FLOAT2", category: "value", },
	FLOAT3:        { name: "Float3", type: "FLOAT3", category: "value", },
	FLOAT4:        { name: "Float4", type: "FLOAT4", category: "value", },
	FLOAT5:        { name: "Float5", type: "FLOAT5", category: "value", },
	FLOAT6:        { name: "Float6", type: "FLOAT6", category: "value", },
});

const ReqTypeMap = Object.fromEntries(
	Object.entries(ReqType).map(([k, v]) => [v.prefix, v])
);
const ReqFlagMap = Object.fromEntries(
	Object.entries(ReqFlag).map(([k, v]) => [v.prefix, v])
);
const MemSizeMap = Object.fromEntries(
	Object.entries(MemSize).map(([k, v]) => [v.prefix, v])
);
const FormatTypeMap = Object.fromEntries(
	Object.entries(FormatType).map(([k, v]) => [v.type, v])
);

const BitProficiency = new Set([
	MemSize.BIT0,
	MemSize.BIT1,
	MemSize.BIT2,
	MemSize.BIT3,
	MemSize.BIT4,
	MemSize.BIT5,
	MemSize.BIT6,
	MemSize.BIT7,
	MemSize.BITCOUNT,
]);

const PartialAccess = new Set([
	MemSize.BIT0,
	MemSize.BIT1,
	MemSize.BIT2,
	MemSize.BIT3,
	MemSize.BIT4,
	MemSize.BIT5,
	MemSize.BIT6,
	MemSize.BIT7,
	MemSize.BITCOUNT,
	MemSize.LOWER4,
	MemSize.UPPER4,
]);

const ValueWidth = 10;
const ReqTypeWidth = Math.max(...Object.values(ReqType).map((x) => x.name.length));
const ReqFlagWidth = Math.max(...Object.values(ReqFlag).map((x) => x.name.length));
const MemSizeWidth = Math.max(...Object.values(MemSize).map((x) => x.name.length));

class LogicParseError extends Error {
	constructor(type, mem) {
		super(`Failed to parse ${type}: ${mem}`);
		this.name = 'LogicParseError';
	}
}

const OPERAND_RE = /^(([~dpbvf]?)((?:0x)+[G-Z ]?|f[A-Z])([0-9A-F]{1,8}))|(([fv]?)([-+]?\d+(?:\.\d+)?))|([G-Z ]?([0-9A-F]+))|({recall})$/i;
class ReqOperand
{
	type;
	value;
	size;
	constructor({ value = null, type, size = null })
	{
		this.value = value;
		this.type = type;
		this.size = size;
	}

	static fromString(def)
	{
		try
		{
			let match = def.match(OPERAND_RE);
			// address for memory read
			if (match[1])
				return new ReqOperand({
					value: parseInt(match[4].trim(), 16), 
					type: ReqTypeMap[match[2].trim()], 
					size: MemSizeMap[match[3].trim()],
				});
			// value in decimal/float
			else if (match[5])
			{
				// force Value type if no prefix
				let rtype = match[6].trim();
				if (rtype == '') rtype = 'v';

				return new ReqOperand({
					value: +match[7].trim(), 
					type: ReqTypeMap[rtype.toLowerCase()],
				});
			}
			// value in hex with size info
			else if (match[8])
				return new ReqOperand({
					value: parseInt(match[9], 16), 
					type: ReqType.VALUE,
				});
			// recall
			else if (match[10])
				return new ReqOperand({ type: ReqType.RECALL, });
		}
		catch (e) { throw new LogicParseError('operand', def); }
	}

	canonicalize()
	{
		if (this.rhs == null || !FLIP_CMP.has(this.op)) return;
		if (!this.lhs.type.addr && this.rhs.type.addr) // this is backwards
		{
			[this.lhs, this.rhs] = [this.rhs, this.lhs];
			this.op = FLIP_CMP.get(this.op);
		}
	}

	static sameValue(a, b)
	{
		if (a == b || a == null || b == null) return a == b;
		return a.size == b.size && a.value == b.value;
	}
	static equals(a, b) { return ReqOperand.sameValue(a, b) && a.type == b.type; }

	maxValue()
	{
		if (this.type && !this.type.addr) return +this.value;
		if (this.type == ReqType.RECALL) return Number.POSITIVE_INFINITY;
		return this.size.maxvalue;
	}

	toValueString() { return this.type && this.type.addr ? ('0x' + this.value.toString(16).padStart(8, '0')) : this.value.toString(); }
	toString() { return this.type == ReqType.RECALL ? this.type.prefix : this.toValueString(); }
	toAnnotatedString() { return (this.type.addr ? `${this.type.name} ` : "") + this.toString(); }

	toMarkdown(wReqType = ReqTypeWidth, wMemSize = MemSizeWidth, wValue = ValueWidth)
	{
		let value = "" + (this.value == null ? "" : this.value);
		let size = this.size ? this.size.name : "";
		return this.type.name.padEnd(wReqType + 1, " ") +
			size.padEnd(wMemSize + 1, " ") +
			this.toValueString().padEnd(wValue + 1);
	}
	toObject() { return {...this}; }
}

// original regex failed on "v-1"
// const REQ_RE = /^([A-Z]:)?(.+?)(?:([!<>=+\-*/&\^%]{1,2})(.+?))?(?:\.(\d+)\.)?$/;
const OPERAND_PARSING = "[~dpbvf]?(?:(?:0x)+[G-Z ]?|f[A-Z])[0-9A-F]{1,8}|[fv]?[-+]?\\d+(?:\\.\\d+)?|[G-Z ]?[0-9A-F]+|{recall}";
const REQ_RE = new RegExp(`^([A-Z]:)?(${OPERAND_PARSING})(?:([!<>=+\\-*/&\\^%]{1,2})(${OPERAND_PARSING}))?(?:\\.(\\d+)\\.)?$`, "i");
class Requirement
{
	flag = null;
	lhs;
	op = null;
	rhs = null;
	hits = 0;
	constructor({ flag = null, lhs, op = null, rhs = null, hits = 0 })
	{
		this.flag = flag;
		this.lhs = lhs;
		this.op = op;
		this.rhs = rhs;
		this.hits = 0;
	}

	clone() { return new Requirement({...this}); }
	hasHits() { return !this.flag || !this.flag.scalable; }

	isAlwaysTrue() { return this.op == '=' && ReqOperand.equals(this.lhs, this.rhs); }
	isAlwaysFalse()
	{ 
		return this.op == '=' // equals cmp
			&& this.lhs && !this.lhs.type.addr // lhs is a static value
			&& this.rhs && !this.rhs.type.addr // rhs is a static value
			&& !ReqOperand.equals(this.lhs, this.rhs); // values cant be equal
	}

	isComparisonOperator() { return ['=', '!=', '>', '>=', '<', '<='].includes(this.op); }
	isModifyingOperator() { return this.op && !this.isComparisonOperator(); }

	static fromString(def)
	{
		let req = new Requirement({});
		try
		{
			let match = def.match(REQ_RE);
			req.lhs = ReqOperand.fromString(match[2]);
			if (match[1]) req.flag = ReqFlagMap[match[1]];

			if (match[3])
			{
				req.op = match[3];
				if (req.flag && req.flag.scalable && req.isComparisonOperator())
					req.op = null;
				else req.rhs = ReqOperand.fromString(match[4]);
			}

			if (match[5]) req.hits = +match[5];
		}
		catch (e) { throw new LogicParseError('requirement', def); }
		return req;
	}

	toAnnotatedString() { return this.lhs.toAnnotatedString() + (this.op ? ` ${this.op} ${this.rhs.toAnnotatedString()}` : "") }
	toMarkdown(wReqType, wMemSize, wValue)
	{
		let flag = this.flag ? this.flag.name : "";
		let res = flag.padEnd(ReqFlagWidth + 1, " ");
		res += this.lhs.toMarkdown(wReqType, wMemSize, wValue);
		if (this.op)
		{
			res += this.op.padEnd(4, " ");
			res += this.rhs.toMarkdown(wReqType, wMemSize, wValue);
			if (!this.flag || !this.flag.scalable) res += "(" + this.hits + ")";
		}
		return res;
	}
}

class Logic
{
	groups = [];
	mem = null;
	value = false;
	constructor()
	{

	}

	static fromString(def, value = null)
	{
		let logic = new Logic();
		try
		{
			logic.value = value == null ? def.includes('$') : !!value;
			for (const [i, g] of def.split(logic.value ? "$" : /(?<!0x)S/).entries())
			{
				let group = [];
				if (g.length > 0) // some sets have empty core groups
					for (const [j, req] of g.split(/_/).entries())
						group.push(Requirement.fromString(req));
				logic.groups.push(group);
			}
			logic.mem = def;
		}
		catch (e) { throw new LogicParseError('logic', def); }
		return logic;
	}

	getOperands()
	{
		return this.groups.reduce((ia, ie) => ia.concat(
			ie.reduce((ja, je) => ja.concat(je.lhs, je.rhs), [])
		), []).filter(x => x);
	}

	getAddresses()
	{
		return this.groups.reduce((ia, ie) => ia.concat(
			ie.reduce((ja, je, i, a) => {
				let p = i == 0 ? null : a[i-1].flag;
				return ja.concat({ opd: je.lhs, pre: p }, { opd: je.rhs, pre: p });
			}, [])
		), [])
			.filter(({ pre }) => pre != ReqFlag.ADDADDRESS) // remove everything following an AddAddress
			.filter(({ opd }) => opd && opd.type && opd.type.addr) // keep only address reads
			.map(({ opd }) => opd.value);
	}

	getTypes()     { return this.getOperands().map(x => x.type).filter(x => x); }
	getMemSizes()  { return this.getOperands().map(x => x.size).filter(x => x); }
	getFlags()     { return this.groups.reduce((ia, ie) => ia.concat(ie.map(x => x.flag)), []).filter(x => x); }

	toMarkdown()
	{
		let output = "";
		let i = 0;

		const wValue = Math.max(...this.getOperands().map((x) => x.toValueString().length));
		const wReqType = Math.max(...this.getTypes().map((x) => x.name.length));
		const wMemSize = Math.max(...this.getMemSizes().map((x) => x.name.length));

		for (const g of this.groups)
		{
			output += i == 0 ? "### Core\n" : `### Alt ${i}\n`;
			output += "```\n";
			let j = 1;
			for (const req of g)
			{
				output += new String(j).padStart(3, " ") + ": ";
				output += req.toMarkdown(wReqType, wMemSize, wValue);
				output += "\n";
				j += 1;
			}
			output += "```\n";
			i += 1;
		}
		return output;
	}
}