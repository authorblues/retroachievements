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
	PAUSEIF:     { name: "PauseIf",      prefix: "P:", chain: false, hits: true,  },
	RESETIF:     { name: "ResetIf",      prefix: "R:", chain: false, hits: true,  },
	RESETNEXTIF: { name: "ResetNextIf",  prefix: "Z:", chain: true,  hits: true,  },
	ADDSOURCE:   { name: "AddSource",    prefix: "A:", chain: true,  hits: false, },
	SUBSOURCE:   { name: "SubSource",    prefix: "B:", chain: true,  hits: false, },
	ADDHITS:     { name: "AddHits",      prefix: "C:", chain: true,  hits: true,  },
	SUBHITS:     { name: "SubHits",      prefix: "D:", chain: true,  hits: true,  },
	ADDADDRESS:  { name: "AddAddress",   prefix: "I:", chain: true,  hits: false, },
	ANDNEXT:     { name: "AndNext",      prefix: "N:", chain: true,  hits: true,  },
	ORNEXT:      { name: "OrNext",       prefix: "O:", chain: true,  hits: true,  },
	MEASURED:    { name: "Measured",     prefix: "M:", chain: false, hits: true,  },
	MEASUREDP:   { name: "Measured%",    prefix: "G:", chain: false, hits: true,  },
	MEASUREDIF:  { name: "MeasuredIf",   prefix: "Q:", chain: false, hits: true,  },
	TRIGGER:     { name: "Trigger",      prefix: "T:", chain: false, hits: true,  },
	REMEMBER:    { name: "Remember",     prefix: "K:", chain: false, hits: true,  },
});

const MemSize = Object.freeze({
	BYTE:     { name: "8-bit",        prefix: "0xH", bytes: 1, },
	WORD:     { name: "16-bit",       prefix: "0x",  bytes: 2, },
	TBYTE:    { name: "24-bit",       prefix: "0xW", bytes: 3, },
	DWORD:    { name: "32-bit",       prefix: "0xX", bytes: 4, },
	WORD_BE:  { name: "16-bit BE",    prefix: "0xI", bytes: 2, },
	TBYTE_BE: { name: "24-bit BE",    prefix: "0xJ", bytes: 3, },
	DWORD_BE: { name: "32-bit BE",    prefix: "0xG", bytes: 4, },

	FLOAT:    { name: "Float",        prefix: "fF", bytes: 4, },
	FLOAT_BE: { name: "Float BE",     prefix: "fB", bytes: 4, },
	DBL32:    { name: "Double32",     prefix: "fH", bytes: 8, },
	DBL32_BE: { name: "Double32 BE",  prefix: "fI", bytes: 8, },
	MBF32:    { name: "MBF32",        prefix: "fM", bytes: 4, },
	MBF32_LE: { name: "MBF32 LE",     prefix: "fL", bytes: 4, },

	BIT0:     { name: "Bit0",         prefix: "0xM", bytes: 1, },
	BIT1:     { name: "Bit1",         prefix: "0xN", bytes: 1, },
	BIT2:     { name: "Bit2",         prefix: "0xO", bytes: 1, },
	BIT3:     { name: "Bit3",         prefix: "0xP", bytes: 1, },
	BIT4:     { name: "Bit4",         prefix: "0xQ", bytes: 1, },
	BIT5:     { name: "Bit5",         prefix: "0xR", bytes: 1, },
	BIT6:     { name: "Bit6",         prefix: "0xS", bytes: 1, },
	BIT7:     { name: "Bit7",         prefix: "0xT", bytes: 1, },
	BITCOUNT: { name: "BitCount",     prefix: "0xK", bytes: 1, },
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

const ValueWidth = 10;
const ReqTypeWidth = Math.max(...Object.values(ReqType).map((x) => x.name.length));
const ReqFlagWidth = Math.max(...Object.values(ReqFlag).map((x) => x.name.length));
const MemSizeWidth = Math.max(...Object.values(MemSize).map((x) => x.name.length));

const OPERAND_RE = RegExp("^(([~a-z]?)(0x[G-Z ]?|f[A-Z])([0-9a-fA-F]{2,8}))|(([fv]?)(\\d+(?:.\\d+)?))|({recall})$");
class ReqOperand
{
	type;
	value;
	size;
	constructor(value, type, size)
	{
		this.value = value;
		this.type = type;
		this.size = size;
	}

	static fromString(def)
	{
		let match = def.match(OPERAND_RE);
		if (match[1])
			return new ReqOperand(
				match[4].trim(), 
				ReqTypeMap[match[2].trim()], 
				MemSizeMap[match[3].trim()]
			);
		else if (match[5])
		{
			// force Value type if no prefix
			let rtype = match[6].trim();
			if (rtype == '') rtype = 'v';

			return new ReqOperand(
				match[7].trim(), 
				ReqTypeMap[rtype], 
				null
			);
		}
		else if (match[8])
			return new ReqOperand('', ReqType.RECALL, null);
	}

	toString()
	{
		if (this.type == ReqType.RECALL) return this.type.prefix;
		return this.type && this.type.addr ? ('0x' + this.value.toString(16)) : this.value.toString();
	}

	toMarkdown(wReqType = ReqTypeWidth, wMemSize = MemSizeWidth, wValue = ValueWidth)
	{
		let value = this.value || "";
		let size = this.size ? this.size.name : "";
		return this.type.name.padEnd(wReqType + 1, " ") +
			size.padEnd(wMemSize + 1, " ") +
			((this.type.addr ? "0x" : "") + value).padEnd(wValue + 1);
	}
	toObject() { return {...this}; }
}

const REQ_RE = RegExp("^([A-Z]:)?(.+?)(?:([!<>=+\\-*/&\\^%]{1,2})(.+?))?(?:\\.(\\d+)\\.)?$");
class Requirement
{
	lhs;
	flag = null;
	op = null;
	rhs = null;
	hits = 0;
	constructor()
	{

	}

	static fromString(def)
	{
		let match = def.match(REQ_RE);
		let req = new Requirement();

		req.lhs = ReqOperand.fromString(match[2]);
		if (match[1]) req.flag = ReqFlagMap[match[1]];

		if (match[3])
		{
			req.op = match[3];
			req.rhs = ReqOperand.fromString(match[4]);
		}

		if (match[5]) req.hits = +match[5];
		return req;
	}

	toMarkdown(wReqType, wMemSize, wValue)
	{
		let flag = this.flag ? this.flag.name : "";
		let res = flag.padEnd(ReqFlagWidth + 1, " ");
		res += this.lhs.toMarkdown(wReqType, wMemSize, wValue);
		if (this.op)
		{
			res += this.op.padEnd(4, " ");
			res += this.rhs.toMarkdown(wReqType, wMemSize, wValue);
			if (!this.flag || this.flag.hits) res += "(" + this.hits + ")";
		}
		return res;
	}
}

class Logic
{
	groups = [];
	constructor()
	{

	}

	static fromString(def)
	{
		let logic = new Logic();
		for (const [i, g] of def.split(/(?<!0x)S/).entries())
		{
			let group = [];
			for (const [j, req] of g.split("_").entries())
				group.push(Requirement.fromString(req));
			logic.groups.push(group);
		}
		return logic;
	}

	toMarkdown()
	{
		let output = "";
		let i = 0;

		const wValue = Math.max(...[...this.getOperands()].map((x) => x.value ? x.value.length : 0));
		const wReqType = Math.max(...[...this.getTypes()].map((x) => x.name.length));
		const wMemSize = Math.max(...[...this.getMemSizes()].map((x) => x.name.length));

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