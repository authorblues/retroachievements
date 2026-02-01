class MemRegion
{
	start;
	end;
	name;
	isError = false;
	transform = null;

	constructor(start, end, name, isError, transform=null)
	{
		this.start = start;
		this.end = end;
		this.name = name;
		this.isError = isError;
		this.transform = transform;
	}
}

// region data should be cross-referenced with
// https://github.com/RetroAchievements/rcheevos/blob/develop/src/rcheevos/consoleinfo.c
const Console = Object.freeze({
	// Nintendo
	GB: { id: 4, name: "Game Boy", icon: "gb", 
		regions: [
			new MemRegion(0x0000, 0x7FFF, "ROM Data", true),
			new MemRegion(0x8000, 0x9FFF, "Graphics Data", false),
			new MemRegion(0xE000, 0xFDFF, "Echo RAM", true, (x) => x - 0x2000),
			new MemRegion(0xFE00, 0xFE9F, "Graphics Data", false),
			new MemRegion(0xFEA0, 0xFF7F, "Unusable Memory", true),
		]},
	GBC: { id: 6, name: "Game Boy Color", icon: "gbc", 
		regions: [
			new MemRegion(0x0000, 0x3FFF, "ROM Bank", true),
			new MemRegion(0x4000, 0x7FFF, "Switchable ROM Bank", true),
			new MemRegion(0x8000, 0x9FFF, "Graphics Data", false),
			new MemRegion(0xE000, 0xFDFF, "Echo RAM", true, (x) => x - 0x2000),
			new MemRegion(0xFE00, 0xFE9F, "Graphics Data", false),
			new MemRegion(0xFEA0, 0xFF7F, "Unusable Memory", true),
		]},
	GBA: { id: 5, name: "Game Boy Advance", icon: "gba", },
	NES: { id: 7, name: "NES/Famicom", icon: "nes", 
		regions: [
    		new MemRegion(0x0800, 0x0FFF, "Mirror RAM", true, (x) => x - 0x0800),
    		new MemRegion(0x1000, 0x17FF, "Mirror RAM", true, (x) => x - 0x1000),
    		new MemRegion(0x1800, 0x1FFF, "Mirror RAM", true, (x) => x - 0x1800),
    		new MemRegion(0x2008, 0x3FFF, "Mirrored PPU Registers", true),
		]},
	SNES: { id: 3, name: "SNES/Super Famicom", icon: "snes", },
	N64: { id: 2, name: "Nintendo 64", icon: "n64", },
	GCN: { id: 16, name: "GameCube", icon: "gc", },
	WII: { id: 19, name: "Wii", icon: "wii", },
	DS: { id: 18, name: "Nintendo DS", icon: "ds", },
	DSI: { id: 78, name: "Nintendo DSi", icon: "dsi", },
	PKMN: { id: 24, name: "Pokemon Mini", icon: "mini",
		regions: [
			new MemRegion(0x0000, 0x0FFF, "BIOS RAM", false),
		]},
	VB: { id: 28, name: "Virtual Boy", icon: "vb", },

	// Sony
	PSX: { id: 12, name: "PlayStation", icon: "ps1", 
		regions: [
			new MemRegion(0x0000000, 0x000FFFF, "Kernel RAM", true),
		]},
	PS2: { id: 21, name: "PlayStation 2", icon: "ps2",
		regions: [
			new MemRegion(0x0000000, 0x00FFFFF, "Kernel RAM", true),
			new MemRegion(0x1FE0000, 0x1FFFFFF, "Probable Stack", false),
		]},
	PSP: { id: 41, name: "PlayStation Portable", icon: "psp",
		regions: [
			new MemRegion(0x0000000, 0x07FFFFF, "Kernel RAM", true),
		]},
	
	// Atari
	A2600: { id: 25, name: "Atari 2600", icon: "2600", },
	A7800: { id: 51, name: "Atari 7800", icon: "7800", 
		regions: [
    		new MemRegion(0x002800, 0x002FFF, "Mirror RAM", true, (x) => x - 0x0800),
    		new MemRegion(0x003000, 0x0037FF, "Mirror RAM", true, (x) => x - 0x1000),
    		new MemRegion(0x003800, 0x003FFF, "Mirror RAM", true, (x) => x - 0x1800),
		]},
	JAG: { id: 17, name: "Atari Jaguar", icon: "jag", },
	JCD: { id: 77, name: "Atari Jaguar CD", icon: "jcd", },
	LYNX: { id: 13, name: "Atari Lynx", icon: "lynx", },

	// Sega
	SG1K: { id: 33, name: "SG-1000", icon: "sg1k", },
	SMS: { id: 11, name: "Master System", icon: "sms", },
	GG: { id: 15, name: "Game Gear", icon: "gg", },
	GEN: { id: 1, name: "Genesis/Mega Drive", icon: "md", },
	SEGACD: { id: 9, name: "Sega CD", icon: "scd", },
	_32X: { id: 10, name: "32X", icon: "32x", },
	SAT: { id: 39, name: "Saturn", icon: "sat", },
	DC: { id: 40, name: "Dreamcast", icon: "dc", },

	// NEC
	TG16: { id: 8, name: "PC Engine/TurboGrafx-16", icon: "pce", },
	TGCD: { id: 76, name: "PC Engine CD/TurboGrafx-CD", icon: "pccd", },
	PC8088: { id: 47, name: "PC-8000/8800", icon: "8088", },
	PCFX: { id: 49, name: "PC-FX", icon: "pc-fx", },

	// SNK
	NGCD: { id: 56, name: "Neo Geo CD", icon: "ngcd", },
	NGP: { id: 14, name: "Neo Geo Pocket", icon: "ngp", },

	// Other
	_3DO: { id: 43, name: "3DO Interactive Multiplayer", icon: "3do", },
	CPC: { id: 37, name: "Amstrad CPC", icon: "cpc", },
	APPLEII: { id: 38, name: "Apple II", icon: "a2", },
	ARC: { id: 27, name: "Arcade", icon: "arc", },
	A2001: { id: 73, name: "Arcadia 2001", icon: "a2001", },
	ARD: { id: 71, name: "Arduboy", icon: "ard", },
	CV: { id: 44, name: "ColecoVision", icon: "cv", },
	ELEK: { id: 75, name: "Elektor TV Games Computer", icon: "elek",
		regions: [
    		new MemRegion(0x001400, 0x0014FF, "Unused / Mirror", true),
		]},
	CHF: { id: 57, name: "Fairchild Channel F", icon: "chf", },
	INTV: { id: 45, name: "Intellivision", icon: "intv", },
	VC4000: { id: 74, name: "Interton VC 4000", icon: "vc4000", },
	ODY2: { id: 23, name: "Magnavox Odyssey 2", icon: "mo2", },
	DUCK: { id: 69, name: "Mega Duck", icon: "duck", },
	MSX: { id: 29, name: "MSX", icon: "msx", },
	EXE: { id: 102, name: "Standalone", icon: "exe", },
	UZE: { id: 80, name: "Uzebox", icon: "uze", },
	VECT: { id: 46, name: "Vectrex", icon: "vect", },
	WASM4: { id: 72, name: "WASM-4", icon: "wasm4", },
	WSV: { id: 63, name: "Watara Supervision", icon: "wsv", },
	WS: { id: 53, name: "WonderSwan", icon: "ws", },
	ZXS: { id: 59, name: "ZX Spectrum", icon: "zxs", },
});

const ConsoleMap = Object.fromEntries(
	Object.entries(Console).map(([k, v]) => [v.id, v])
);

const AssetState = Object.freeze({
	CORE: { rank: 0, name: 'core', marker: '', },
	UNOFFICIAL: { rank: 1, name: 'unofficial', marker: '🚧 '},
	LOCAL: { rank: 2, name: 'local', marker: '✏️ '},
});

class Asset
{
	id = -1;
	index = -1;
	author = null;
	title;
	desc;
	#ref = '';
	constructor()
	{
		this.#ref = crypto.randomUUID();
	}

	needsFeedback()
	{
		if (this.title.toUpperCase().includes('[VOID]')) return false;
		if (this.id >= 101000000 && this.id < 111000000) return false; // emulator warnings
		return true;
	}

	toRefString(){ return `asset-${this.#ref}`; }
}

class Achievement extends Asset
{
	points = 5;
	achtype = "";
	badge;
	state;
	logic;

	constructor() { super(); }
	static fromJSON(json)
	{
		let ach = new Achievement();
		ach.id = json.ID;
		ach.title = json.Title;
		ach.desc = json.Description;
		ach.points = json.Points;
		ach.author = json.Author;
		ach.achtype = json.Type;
		ach.badge = json.BadgeURL;

		ach.state = AssetState.CORE;
		if (json.Flags == 5) ach.state = AssetState.UNOFFICIAL;

		try {
			ach.logic = Logic.fromString(json.MemAddr, false);
		}
		catch (e) { console.error(e); return null; }
		return ach;
	}
	
	static fromLocal(row)
	{
		let ach = new Achievement();
		ach.id = +row[0];
		ach.title = row[2];
		ach.desc = row[3];
		ach.points = +row[8];
		ach.author = row[7];
		ach.achtype = row[6];

		if (!row[13] || row[13].startsWith('local\\')) row[13] = '00000';
		ach.badge = `https://media.retroachievements.org/Badge/${row[13]}.png`
		
		ach.state = AssetState.LOCAL;
		try {
			ach.logic = Logic.fromString(row[1], false);
		}
		catch (e) { console.error(e); return null; }
		return ach;
	}
}

class Leaderboard extends Asset
{
	static COMPONENT_TAGS = ['STA', 'CAN', 'SUB', 'VAL'];

	format;
	lower_is_better = true;
	state = null;
	components = {};

	constructor() { super(); }
	static fromJSON(json)
	{
		let lb = new Leaderboard();
		lb.id = json.ID;
		lb.title = json.Title;
		lb.desc = json.Description;
		lb.format = FormatTypeMap[json.Format];
		lb.lower_is_better = json.LowerIsBetter;

		lb.components = {};
		try {
			for (let part of json.Mem.split("::"))
			{
				let tag = part.substring(0, 3);
				let mem = part.substring(4);
				lb.components[tag] = Logic.fromString(mem, tag == 'VAL');
			}
		}
		catch (e) { console.error(e); return null; }

		lb.state = AssetState.CORE;
		return lb;
	}
	
	static fromLocal(row)
	{
		let lb = new Leaderboard();
		lb.id = +row[0].substring(1);
		lb.title = row[6];
		lb.desc = row[7];
		lb.format = FormatTypeMap[row[5]];
		lb.lower_is_better = row[8] == '1';

		try {
			lb.components = {
				'STA': Logic.fromString(row[1], false),
				'CAN': Logic.fromString(row[2], false),
				'SUB': Logic.fromString(row[3], false),
				'VAL': Logic.fromString(row[4], true),
			}
		}
		catch (e) { console.error(e); return null; }

		lb.state = AssetState.LOCAL;
		return lb;
	}

	#usesFastWords()
	{
		const FAST_WORDS = ["fast", "quick", "speed", "rush", "hurry", "rapid"];
		return FAST_WORDS.some(x => this.desc.toLowerCase().includes(x) || this.title.toLowerCase().includes(x));
	}

	getType()
	{
		if (this.#usesFastWords()) return "speedrun";
		if (this.format.category == "time") return this.lower_is_better ? "speedrun" : "survival";
		return this.lower_is_better ? "min score" : "high score";
	}
}

class AchievementSet
{
	id;
	title = null;
	icon = null;
	console = null;
	achievements = new Map();
	leaderboards = new Map();

	constructor() {  }
	addJSON(json)
	{
		this.id = json.ID;
		this.title = json.Title;
		this.icon = json.ImageIconUrl || json.ImageIconURL;

		let cid = json.ConsoleId || json.ConsoleID;
		this.console = cid in ConsoleMap ? ConsoleMap[cid] : null;

		let achJson = [], ldbJson = [];
		if ('Achievements' in json) achJson.push(...json.Achievements);
		if ('Leaderboards' in json) ldbJson.push(...json.Leaderboards);
		if ('Sets' in json) for (let set of json.Sets)
		{
			achJson.push(...set.Achievements);
			ldbJson.push(...set.Leaderboards);
		}

		for (const [i, x] of achJson.entries())
		{
			let asset = Achievement.fromJSON(x);
			if (!asset || !asset.needsFeedback()) continue;
			asset.index = i; // to preserve order from json file
			this.achievements.set(asset.id || asset.index, asset);
		}

		for (let [i, x] of ldbJson.entries())
		{
			let asset = Leaderboard.fromJSON(x);
			if (x.Hidden || !asset || !asset.needsFeedback()) continue;
			asset.index = i; // to preserve order from json file
			this.leaderboards.set(asset.id || asset.index, asset);
		}
		
		return this;
	}

	addLocal(txt, notes)
	{
		function parseColons(line)
		{
			let res = [];
			let start = 0, inquotes = false;

			let chars = Array.from(line + ':');
			for (let [ci, ch] of chars.entries())
			{
				if (start > ci) continue;
				else if (start == ci && !inquotes && ch == '"')
				{
					inquotes = true;
					continue;
				}
				else if ((inquotes && ch == '"' && line[ci-1] != '\\') || (!inquotes && ch == ':'))
				{
					if (inquotes) ci += 1;
					let x = chars.slice(start, ci).join('');
					if (inquotes) x = JSON.parse(x);

					res.push(x);
					start = ci + 1;
					inquotes = false;
				}
			}
			return res;
		}

		const lines = txt.match(/[^\r\n]+/g);
		this.title = lines[1];
		for (let i = 2; i < lines.length; i++)
		{
			const row = parseColons(lines[i]);
			let asset;
			switch (row[0][0])
			{
				case 'N': // local code note
					notes.add(new CodeNote(row[1], row[2], null))
					break;
				case 'L': // leaderboard
					asset = Leaderboard.fromLocal(row);
					asset.index = i + 1000000; // preserve order from file
					if (!asset || !asset.needsFeedback()) continue;
					this.leaderboards.set(asset.id || asset.index, asset);
					break;
				default: // achievement
					asset = Achievement.fromLocal(row);
					asset.index = i + 1000000; // preserve order from file
					if (!asset || !asset.needsFeedback()) continue;
					this.achievements.set(asset.id || asset.index, asset);
					break;
			}
		}
		return this;
	}

	getAchievements() { return [...this.achievements.values()]; }
	getLeaderboards() { return [...this.leaderboards.values()]; }
}

// Represents a node in the pointer tree structure (e.g., +0x4).
class NoteNode
{
	offset = "";
	description = "";
	size = 1; // Size in bytes covered by this note (default 1)
	rawLineIndex = 0;
	indentLevel = 0;
	content = "";
	parent = null;
	children = [];

	constructor() { }

	toString()
	{
		if (!this.description || this.description.trim() === "") return this.offset;
		return `${this.offset} | ${this.description}`;
	}
}

// Parses raw Code Note text into a hierarchical tree of NoteNodes.
// Handles standard RetroAchievements pointer notation (indentation with dots/pluses).
class PointerTreeParser
{
	// Main entry point: Converts a multiline string into a flat list of nodes
	// preserving hierarchy via Parent/Children references.
	static parseNoteText(noteText)
	{
		if (!noteText) return [];

		const lines = noteText.split(/\r\n|\r|\n/);
		const flatList = [];

		// Create a root node that represents the "Base" of the note.
		// IndentLevel -2 signifies it is the absolute root container.
		const root = new NoteNode();
		root.offset = "(Default)";
		root.description = "Full Note";
		root.indentLevel = -2;
		root.content = noteText;

		// Attempt to parse the size of the root data from the first line
		if (lines.length > 0) root.size = PointerTreeParser.parseSizeFromDescription(lines[0]);

		flatList.push(root);

		// Always attempt to parse, even if "Pointer" isn't strictly in text, 
		// because structure is determined by symbols.
		// Stack used to track the current parent at each indentation level.
		const stack = [];

		// Logical Root acts as the parent for top-level pointer offsets (Indent 0).
		const logicalRoot = new NoteNode();
		logicalRoot.indentLevel = -1;
		stack.push(logicalRoot);

		let lastAddedNode = null;

		// Regex to parse specific pointer lines.
		// Group 1: Indentation (e.g., "+", ".+", "..", "++")
		// Group 2: Sign (+ or -). Optional capture.
		// Group 3: Hex value (0x...).
		// Group 4: Separator (|, =, :). Optional capture.
		// Group 5: Description/Remainder.
		const offsetRegex = /^([.\+\s]*)([-+]?)(0x[0-9A-Fa-f]+)\s*([|=:])?\s*(.*)$/;

		// Helper regex to strip indentation characters from description lines.
		const prefixStripRegex = /^([.\+\s]+)/;

		for (let i = 0; i < lines.length; i++)
		{
			const line = lines[i].trim(); // Trim for regex matching but handle indent carefully
			if (!line) continue;

			// We need raw indentation from original line logic, but regex handles it via capture group 1
			const match = lines[i].trim().match(offsetRegex);
			let isNode = false;

			if (match)
			{
				const indentStr = match[1];
				const sign = match[2];
				const separator = match[4];

				const hasSign = !!sign; // e.g. +0x10 is definitely an offset
				const hasIndent = indentStr.includes(".") || indentStr.includes("+");

				if (hasSign)
				{
					isNode = true;
				}
				else if (indentStr.includes("+"))
				{
					// Treat any indentation with '+' as a node
					isNode = true;
				}
				else if (hasIndent)
				{
					// Indented with dots only, no sign (e.g. "..0x04").
					// If separator is '|', it is a description -> Node.
					if (separator === "|")
					{
						isNode = true;
					}
					// If separator is '=' or ':', it is a value definition -> Content.
				}
			}

			if (isNode)
			{
				const indentStr = match[1];
				let indent = 0;

				if (indentStr.includes("+"))
				{
					// Standard/Mixed format
					if (indentStr.includes("."))
					{
						// Dot-based (e.g., ".+") -> count dots
						indent = (indentStr.match(/\./g) || []).length;
					}
					else
					{
						// Pure plus-based (e.g., "++") -> count pluses minus 1
						indent = (indentStr.match(/\+/g) || []).length - 1;
						if (indent < 0) indent = 0;
					}
				}
				else
				{
					// Non-standard format: just dots.
					indent = (indentStr.match(/\./g) || []).length;
				}

				const sign = match[2];
				const hex = match[3];
				let desc = match[5];

				// Strip leading separators (- : =) just in case
				while (desc.length > 0 && (desc[0] === '-' || desc[0] === ':' || desc[0] === '=' || /\s/.test(desc[0])))
				{
					desc = desc.substring(1);
				}
				desc = desc.trim();

				// Normalization
				let offset = sign + hex;
				if (!offset.startsWith("+") && !offset.startsWith("-")) offset = "+" + offset;

				const size = PointerTreeParser.parseSizeFromDescription(desc);

				const node = new NoteNode();
				node.offset = offset;
				node.description = desc;
				node.rawLineIndex = i;
				node.indentLevel = indent;
				node.size = size;

				// Tree Construction
				while (stack.length > 0 && stack[stack.length - 1].indentLevel >= indent)
				{
					stack.pop();
				}

				if (stack.length === 0) stack.push(logicalRoot);

				const parent = stack[stack.length - 1];
				node.parent = parent;
				parent.children.push(node);

				stack.push(node);
				lastAddedNode = node;
			}
			else
			{
				// Append to content of most recent node
				if (lastAddedNode)
				{
					if (lastAddedNode.content.length > 0) lastAddedNode.content += "\n";
					const cleanContentLine = lines[i].trim().replace(prefixStripRegex, "");
					lastAddedNode.content += cleanContentLine;
				}
			}
		}

		// Flatten the tree for the list, excluding the logical root
		PointerTreeParser.collectAllNodes(logicalRoot, flatList);
		
		// Add the base 'root' node we created at the start (Indent -2)
		// But ensure it's not duplicated if logicalRoot children cover everything.
		// Reconstruct final list: Root, then all children of LogicalRoot recursively.
		const resultList = [root];
		const parsedNodes = [];
		PointerTreeParser.collectAllNodes(logicalRoot, parsedNodes);
		resultList.push(...parsedNodes);

		return resultList;
	}

	static parseSizeFromDescription(desc)
	{
		if (!desc) return 1;

		// 1. Check for explicit byte count
		const bytesMatch = desc.match(/\[.*?(\d+)\s*[-]?\s*bytes?.*?\]/i);
		if (bytesMatch && bytesMatch[1])
		{
			const bSize = parseInt(bytesMatch[1], 10);
			if (!isNaN(bSize)) return bSize;
		}

		// 2. Check for standard type tags
		if (desc.includes("[32-bit") || desc.includes("[Float")) return 4;
		if (desc.includes("[24-bit")) return 3;
		if (desc.includes("[16-bit")) return 2;
		if (desc.includes("[8-bit")) return 1;

		return 1;
	}

	static collectAllNodes(node, flatList)
	{
		if (node.indentLevel !== -1) flatList.push(node);
		for (const child of node.children)
		{
			PointerTreeParser.collectAllNodes(child, flatList);
		}
	}
}

class CodeNote
{
	addr;
	size = 1;
	type = null; // null means unknown, otherwise MemSize object
	note = "";
	author = "";
	enum = null;
	assetCount = 0;
	
	// Holds the parsed tree structure of the note
	noteNodes = [];

	constructor(addr, note, author)
	{
		this.addr = +addr;
		this.note = note;
		this.author = author;

		[this.type, this.size] = CodeNote.getSize(note);
		if (!this.isProbablePointer())
			this.enum = CodeNote.parseEnumerations(note);

		// Parse the note into a structure tree for the explainer
		this.noteNodes = PointerTreeParser.parseNoteText(note);
	}

	getHeader() { return this.note.split('\n')[0]; }
	toRefString() { return `note-${this.addr}`; }

	isArray() { return this.size >= (this.type ? this.type.bytes : 1) * 2; }

	contains(addr)
	{
		return addr >= this.addr && addr < this.addr + this.size;
	}

	isProbablePointer()
	{
		const lines = this.note.toLowerCase().split('\n');
		if (['ptr', 'pointer'].some(x => lines[0].includes(x))) return true;
		if (lines.filter((x, i) => i > 0 && x.trim().startsWith('+')).length >= 2) return true;
		return false;
	}

	static getSize(note)
	{
		let bytes = 1;
		let memSize = null;

		const sNote = note.split('\n', 1)[0].toLowerCase();
		if (sNote.length < 4) return [null, 1];

		let bytesFromBits = false;
		let foundSize = false;
		let prevWordIsSize = false;
		let prevWordIsNumber = false;

		let prevWord = "";
		for (const m of sNote.matchAll(/((\d+)|([a-z]+)|.)/gi))
		{
			let word = m[1];
			let wordIsNumber = m[1] == m[2]
			let wordIsSize = false;
			
			if (wordIsNumber)
			{
				let num = +word;
				if (prevWord == 'mbf')
				{
					if (num == 32 || num == 40)
					{
						bytes = num / 8;
						memSize = MemSize.MBF32;
						wordIsSize = true;
						foundSize = true;
					}
				}
				else if (prevWord == 'double' && num == 32)
				{
					bytes = num / 8;
					memSize = MemSize.DBL32;
					wordIsSize = true;
					foundSize = true;
				}
				else if (num == 4 && ['lower', 'upper'].includes(prevWord))
				{
					bytes = 1;
					memSize = MemSize.BYTE;
					wordIsSize = true;
					foundSize = true;
				}
			}
			else if (prevWordIsSize)
			{
				if (word == 'float')
				{
					if (memSize == MemSize.DWORD)
					{
						memSize = MemSize.FLOAT;
						wordIsSize = true;
					}
				}
				else if (word == 'double')
				{
					if (memSize == MemSize.DWORD || bytes == 8)
					{
						memSize = MemSize.DBL32;
						wordIsSize = true;
					}
				}
				else if (word == 'be' || word == 'bigendian')
				{
					switch (memSize)
					{
						case MemSize.WORD:  memSize = MemSize.WORD_BE;  break;
						case MemSize.TBYTE: memSize = MemSize.TBYTE_BE; break;
						case MemSize.DWORD: memSize = MemSize.DWORD_BE; break;
						case MemSize.FLOAT: memSize = MemSize.FLOAT_BE; break;
						case MemSize.DBL32: memSize = MemSize.DBL32_BE; break;
						default: break;
					}
				}
				else if (word == 'le')
				{
					if (memSize == MemSize.MBF32)
						memSize = MemSize.MBF32_LE;
				}
				else if (word == 'mbf')
				{
					if (bytes == 4 || bytes == 5)
						memSize = MemSize.MBF32;
				}
			}
			else if (prevWordIsNumber)
			{
				let num = +prevWord;
				if (word == 'bit' || word == 'bits')
				{
					if (!foundSize)
					{
						bytes = Math.floor((num + 7) / 8);
						memSize = null;
						bytesFromBits = true;
						wordIsSize = true;
						foundSize = true;
					}
				}
				else if (word == 'byte' || word == 'bytes')
				{
					if (!foundSize || bytesFromBits)
					{
						bytes = num;
						memSize = null;
						bytesFromBits = false;
						wordIsSize = true;
						foundSize = true;
					}
				}

				if (wordIsSize)
				{
					switch (bytes)
					{
						case 0: bytes = 1; break;
						case 1: memSize = MemSize.BYTE; break;
						case 2: memSize = MemSize.WORD; break;
						case 3: memSize = MemSize.TBYTE; break;
						case 4: memSize = MemSize.DWORD; break;
						default: memSize = null; break;
					}
				}
			}
			else if (word == 'float')
			{
				if (!foundSize)
				{
					bytes = 4;
					memSize = MemSize.FLOAT;
					wordIsSize = true;

					if (prevWord == 'be' || prevWord == 'bigendian')
						memSize = MemSize.FLOAT_BE;
				}
			}
			else if (word == 'double')
			{
				if (!foundSize)
				{
					bytes = 8;
					memSize = MemSize.DBL32;
					wordIsSize = true;

					if (prevWord == 'be' || prevWord == 'bigendian')
						memSize = MemSize.DBL32_BE;
				}
			}
			else if (word.startsWith('bitflag') || word.startsWith('bitfield'))
			{
				if (!foundSize)
				{
					memSize = MemSize.BYTE;
					wordIsSize = true;
				}
			}

			if (word != ' ' && word != '-')
			{
				prevWordIsSize = wordIsSize;
				prevWordIsNumber = wordIsNumber;
				prevWord = word;
			}
		}

		return [memSize, bytes];
	}

	static parseEnumerations(note)
	{
        // Allow dots in values (e.g., 0.5)
        // Group 1: 0x1234 OR 0.5 OR -1.0
		const ENUMERATION_RE = /((?:(?:0x)?[0-9a-f]+|[-+]?[0-9]*\.?[0-9]+)+)([^\w\d]*[^\w\d\s][^\w\d]*).+$/i;

		const lines = note.split('\n');
		let delim_count = new Map();
		for (let i = 1; i < lines.length; i++)
		{
			const m = lines[i].trim().match(ENUMERATION_RE);
			if (m == null) continue;
			delim_count.set(m[2], (delim_count.get(m[2]) ?? 0) + 1);
		}

		if (delim_count.size == 0) return null;
		let [delim, dcount] = [...delim_count.entries()].sort(([a, av], [b, bv]) => bv - av)[0];

		let enumerations = [];
		let isHex = false;
		let linecount = 0;
		for (let i = 1; i < lines.length; i++)
		{
			if (!lines[i].includes(delim)) continue;
			linecount++;

			let [lhs, ...rhs] = lines[i].split(delim);
			rhs = rhs.join(delim).trim();

            // Match Hex OR Float
			for (const m of lhs.matchAll(/\b(?:(0x[0-9a-f]+)|([-+]?[0-9]*\.?[0-9]+))\b/gi))
			{
                // m[0] is full match, m[1] is hex, m[2] is float/dec
				enumerations.push({literal: m[0], meaning: rhs});
				isHex ||= !!m[1]; // if 0x captured, it's hex
			}
		}

		if (dcount == 1 || linecount < 3) return null;

		for (let e of enumerations) {
            if (e.literal.includes('.') && !e.literal.startsWith('0x')) {
                e.value = parseFloat(e.literal);
            } else {
			    e.value = Number.parseInt(e.literal, isHex ? 16 : 10);
            }
        }
		
        enumerations = enumerations.filter(x => !Number.isNaN(x.value));
		return enumerations.length ? enumerations : null;
	}
}

class CodeNoteSet extends Array
{
	clear() { this.length = 0; }

	add(note)
	{
		for (let i = 0; i < this.length; i++)
			if (this[i].addr == note.addr) return this[i] = note;

		this.push(note);
		for (let i = this.length - 1; i > 0 && this[i].addr < this[i-1].addr; i--)
		{ let t = this[i]; this[i] = this[i-1]; this[i-1] = t; }
	}

	get(addr)
	{
		for (let i = this.length - 1; i >= 0; i--)
			if (this[i].contains(addr)) return this[i];
		return null;
	}

	get_text(addr, chainInfo = [])
	{
		// 1. Determine Chain Context
		let baseAddr;
		let offsets = [];

		if (chainInfo.length > 0) {
			// Chain Logic: Base -> Intermediate Offsets -> Final Offset (addr)
			const baseObj = chainInfo[0];
			baseAddr = baseObj.value;
			offsets = chainInfo.slice(1).map(c => c.value);
			offsets.push(addr);
		} else {
			// Direct Lookup
			const note = this.get(addr);
			if (note) return note.note;
			return null; 
		}

		// 2. Resolve Base Note & Redirects
		let note = this.get(baseAddr);
        
        // Handle "refer to" Redirects
        let redirects = 0;
        while (note && redirects < 5) {
             const match = note.note.match(/refer to \$0x([0-9a-fA-F]+)/i);
             if (match) {
                 const target = parseInt(match[1], 16);
                 const targetNote = this.get(target);
                 if (targetNote) {
                     note = targetNote;
                     redirects++;
                     continue;
                 }
             }
             break;
        }

		if (!note) return null;

        // 3. Traverse Note Node Tree
        let currentNodes = null;
        if (note.noteNodes) {
             // Filter for nodes attached to the Logical Root (Indent -1).
             // This correctly captures top-level nodes even if they start with indentation (e.g. ".+0x10").
             currentNodes = note.noteNodes.filter(n => n.parent && n.parent.indentLevel === -1);
        }

        if (!currentNodes || currentNodes.length === 0) {
            return null;
        }

        // Helper to parse offset string like "+0x10" or "-0x4" -> integer
        const parseOff = (s) => {
            let clean = s.replace(/[+\-\s]/g, '');
            if (clean.toLowerCase().startsWith("0x")) clean = clean.substring(2);
            let v = parseInt(clean, 16);
            if (s.includes('-')) v = -v;
            return isNaN(v) ? 0 : v;
        };

        let foundNode = null;

        // Header for tooltip display
		const base_hex = '0x' + baseAddr.toString(16);
		const offsets_str = offsets.map(o => `+0x${o.toString(16)}`).join(' ');
		const header = `[Indirect from ${base_hex} ${offsets_str}]\n`;

        // Iterate through offsets (Intermediates -> Leaf)
        for (let i = 0; i < offsets.length; i++) {
            const offVal = offsets[i];
            const isLeaf = (i === offsets.length - 1);
            let match = null;

            for (const n of currentNodes) {
                const nOff = parseOff(n.offset);
                
                // Range check: Is the offset within [NodeStart, NodeStart + NodeSize)?
                // n.size defaults to 1 if not specified, or parses from e.g. "[32 bytes]"
                if (offVal >= nOff && offVal < nOff + n.size) {
                    match = n;
                    break;
                }
            }

            if (match) {
                if (isLeaf) {
                    // We found the node covering the final offset
                    foundNode = match;
                } else {
                    // Intermediate offset: drill down to children
                    if (match.children && match.children.length > 0) {
                        currentNodes = match.children;
                    } else {
                        // Node matches, but has no children to satisfy deeper offsets.
                        // We must return null to allow "missing note" feedback to fire.
                        // Returning the parent node causes misleading tooltips and suppresses warnings.
                        return null;
                    }
                }
            } else {
                // No node at this level covers the offset
                return null;
            }
        }

        if (foundNode) {
             let desc = foundNode.description || "";
             // Append content (enumerations/details) if available, rather than choosing one or the other
             if (foundNode.content) {
                 if (desc.length > 0) desc += "\n";
                 desc += foundNode.content;
             }
             return header + desc;
        }

		return null;
	}

	static find_relevant_note_text(full_note, offsets) {
		let lines = full_note.split(/\r\n|\n/);
		let current_search_space = lines;
		let last_found_block = lines; 

		if (offsets.length === 0) {
			return last_found_block.join('\n');
		}

		const offset_line_re = /^(\s*[\s\.+-]*)\+0x([a-f0-9]+)(.*)$/i;
		let context_indentation = -1;

		for (const target_offset of offsets) {
			let best_match = { index: -1, indent: Infinity };

			for (let i = 0; i < current_search_space.length; i++) {
				const line = current_search_space[i];
				const match = line.match(offset_line_re);

				if (match) {
					const current_indentation = (match[1] || '').length;
					const line_offset_val = parseInt(match[2], 16);

					if (line_offset_val === target_offset && current_indentation > context_indentation) {
						if (current_indentation < best_match.indent) {
							best_match = { index: i, indent: current_indentation };
						}
					}
				}
			}

			if (best_match.index === -1) return null;

			const start_index = best_match.index;
			const start_indentation = best_match.indent;
			let end_of_block_index = start_index + 1;

			while (end_of_block_index < current_search_space.length) {
				const next_line = current_search_space[end_of_block_index];
				const next_match = next_line.match(offset_line_re);
				if (next_match) {
					const next_indentation = (next_match[1] || '').length;
					if (next_indentation <= start_indentation) {
						break; 
					}
				}
				end_of_block_index++;
			}

			const found_block = current_search_space.slice(start_index, end_of_block_index);
			last_found_block = found_block;
			current_search_space = found_block;
			context_indentation = start_indentation;
		}
		
		return last_found_block.join('\n');
	}
}

// https://github.com/RetroAchievements/RAIntegration/blob/8a26afb6adb27e22c737a6006344abce8f24c21f/tests/data/models/CodeNoteModel_Tests.cpp#L53
function testCodeNotes()
{
	let count = 0, fails = 0;
	function _testNote(note, size, type)
	{
		let cn = new CodeNote(0x0, note);
		let res = cn.size == size && cn.type == type ? "PASS" : "FAIL";
		
		console.log(note, '-->', size, type);
		console.log(res, cn);

		count += 1;
		if (!(cn.size == size && cn.type == type)) fails += 1;
	}

	_testNote("", 1, null);
	_testNote("Test", 1, null);
	_testNote("16-bit Test", 2, MemSize.WORD);
	_testNote("Test 16-bit", 2, MemSize.WORD);
	_testNote("Test 16-bi", 1, null);
	_testNote("[16-bit] Test", 2, MemSize.WORD);
	_testNote("[16 bit] Test", 2, MemSize.WORD);
	_testNote("[16 Bit] Test", 2, MemSize.WORD);
	_testNote("[24-bit] Test", 3, MemSize.TBYTE);
	_testNote("[32-bit] Test", 4, MemSize.DWORD);
	_testNote("[32 bit] Test", 4, MemSize.DWORD);
	_testNote("[32bit] Test", 4, MemSize.DWORD);
	_testNote("Test [16-bit]", 2, MemSize.WORD);
	_testNote("Test (16-bit)", 2, MemSize.WORD);
	_testNote("Test (16 bits)", 2, MemSize.WORD);
	_testNote("[64-bit] Test", 8, null);
	_testNote("[128-bit] Test", 16, null);
	_testNote("[17-bit] Test", 3, MemSize.TBYTE);
	_testNote("[100-bit] Test", 13, null);
	_testNote("[0-bit] Test", 1, null);
	_testNote("[1-bit] Test", 1, MemSize.BYTE);
	_testNote("[4-bit] Test", 1, MemSize.BYTE);
	_testNote("[8-bit] Test", 1, MemSize.BYTE);
	_testNote("[9-bit] Test", 2, MemSize.WORD);
	_testNote("bit", 1, null);
	_testNote("9bit", 2, MemSize.WORD);
	_testNote("-bit", 1, null);

	_testNote("[16-bit BE] Test", 2, MemSize.WORD_BE);
	_testNote("[24-bit BE] Test", 3, MemSize.TBYTE_BE);
	_testNote("[32-bit BE] Test", 4, MemSize.DWORD_BE);
	_testNote("Test [32-bit BE]", 4, MemSize.DWORD_BE);
	_testNote("Test (32-bit BE)", 4, MemSize.DWORD_BE);
	_testNote("Test 32-bit BE", 4, MemSize.DWORD_BE);
	_testNote("[16-bit BigEndian] Test", 2, MemSize.WORD_BE);
	_testNote("[16-bit-BE] Test", 2, MemSize.WORD_BE);
	_testNote("[4-bit BE] Test", 1, MemSize.BYTE);

	_testNote("8 BYTE Test", 8, null);
	_testNote("Test 8 BYTE", 8, null);
	_testNote("Test 8 BYT", 1, null);
	_testNote("[2 Byte] Test", 2, MemSize.WORD);
	_testNote("[4 Byte] Test", 4, MemSize.DWORD);
	_testNote("[4 Byte - Float] Test", 4, MemSize.FLOAT);
	_testNote("[8 Byte] Test", 8, null);
	_testNote("[100 Bytes] Test", 100, null);
	_testNote("[2 byte] Test", 2, MemSize.WORD);
	_testNote("[2-byte] Test", 2, MemSize.WORD);
	_testNote("Test (6 bytes)", 6, null);
	_testNote("[2byte] Test", 2, MemSize.WORD);

	_testNote("[float] Test", 4, MemSize.FLOAT);
	_testNote("[float32] Test", 4, MemSize.FLOAT);
	_testNote("Test float", 4, MemSize.FLOAT);
	_testNote("Test floa", 1, null);
	_testNote("is floating", 1, null);
	_testNote("has floated", 1, null);
	_testNote("16-afloat", 1, null);
	_testNote("[float be] Test", 4, MemSize.FLOAT_BE);
	_testNote("[float bigendian] Test", 4, MemSize.FLOAT_BE);
	_testNote("[be float] Test", 4, MemSize.FLOAT_BE);
	_testNote("[bigendian float] Test", 4, MemSize.FLOAT_BE);
	_testNote("[32-bit] pointer to float", 4, MemSize.DWORD);

	_testNote("[64-bit double] Test", 8, MemSize.DBL32);
	_testNote("[64-bit double BE] Test", 8, MemSize.DBL32_BE);
	_testNote("[double] Test", 8, MemSize.DBL32);
	_testNote("[double BE] Test", 8, MemSize.DBL32_BE);
	_testNote("[double32] Test", 4, MemSize.DBL32);
	_testNote("[double32 BE] Test", 4, MemSize.DBL32_BE);
	_testNote("[double64] Test", 8, MemSize.DBL32);

	_testNote("[MBF32] Test", 4, MemSize.MBF32);
	_testNote("[MBF40] Test", 5, MemSize.MBF32);
	_testNote("[MBF32 float] Test", 4, MemSize.MBF32);
	_testNote("[MBF80] Test", 1, null);
	_testNote("[MBF320] Test", 1, null);
	_testNote("[MBF-32] Test", 4, MemSize.MBF32);
	_testNote("[32-bit MBF] Test", 4, MemSize.MBF32);
	_testNote("[40-bit MBF] Test", 5, MemSize.MBF32);
	_testNote("[MBF] Test", 1, null);
	_testNote("Test MBF32", 4, MemSize.MBF32);
	_testNote("[MBF32 LE] Test", 4, MemSize.MBF32_LE);
	_testNote("[MBF40-LE] Test", 5, MemSize.MBF32_LE);

	_testNote("42=bitten", 1, null);
	_testNote("42-bitten", 1, null);
	_testNote("bit by bit", 1, null);
	_testNote("bit1=chest", 1, null);

	_testNote("Bite count (16-bit)", 2, MemSize.WORD);
	_testNote("Number of bits collected (32 bits)", 4, MemSize.DWORD);

	_testNote("100 32-bit pointers [400 bytes]", 400, null);
	_testNote("[400 bytes] 100 32-bit pointers", 400, null);

	_testNote("[lower4] score digit 1", 1, MemSize.BYTE);
	_testNote("[upper4] score digit 2", 1, MemSize.BYTE);
	_testNote("lower 4-byte value", 1, MemSize.BYTE);
	_testNote("lower (4-byte) value", 4, MemSize.DWORD);

	console.log(fails + "/" + count + " failed")
}

class LookupRange
{
	start = null;
	end = null;
	value;
	constructor(start, end, value)
	{
		this.start = start;
		this.end = end;
		this.value = value;
	}

	isFallback() { return this.start == null && this.end == null; }
}
class RichPresence
{
	text = "";
	macros = {
		// built-in macros
		'Number': FormatType.VALUE,
		'Unsigned': FormatType.UNSIGNED,
		'Score': FormatType.SCORE,
		'Centiseconds': FormatType.MILLISECS,
		'Seconds': FormatType.SECS,
		'Minutes': FormatType.MINUTES,
		'Fixed1': FormatType.FIXED1,
		'Fixed2': FormatType.FIXED2,
		'Fixed3': FormatType.FIXED3,
		'Float1': FormatType.FLOAT1,
		'Float2': FormatType.FLOAT2,
		'Float3': FormatType.FLOAT3,
		'Float4': FormatType.FLOAT4,
		'Float5': FormatType.FLOAT5,
		'Float6': FormatType.FLOAT6,
		'ASCIIChar': null,
		'UnicodeChar': null,
	};
	custom_macros = new Set();
	lookups = new Map();
	display = [];
	constructor() {  }

	static fromText(txt)
	{
		let richp = new RichPresence();
		richp.text = txt;

		let obj = null;
		function structCleanup(next)
		{
			if (obj && obj.type == 'display')
				return;
			else if (obj && obj.type == 'macro')
			{
				richp.custom_macros.add(obj.name);
				richp.macros[obj.name] = obj.param;
			}
			else if (obj && obj.type == 'lookup')
				richp.lookups.set(obj.name, obj.param);
			obj = next;
		}
		
		const lines = txt.match(/[^\r\n]+/g);
		for (let line of lines)
		{
			line = line.split('//', 1)[0].trim();

			if (line.length == 0) continue; // blank lines skipped
			else if (obj && obj.type == 'display')
			{ // display must be last, so no need to parse other line starts
				if (line.startsWith('?'))
				{
					let parts = line.match(/^\?(.+?)\?(.*)$/);
					if (parts == null)
						throw new LogicParseError('rich presence (malformed conditional display)', line);
					richp.display.push({
						condition: Logic.fromString(parts[1], false),
						string: parts[2],
					});
				}
				else richp.display.push({
					condition: null, 
					string: line,
				});
			}
			else if (line.startsWith('Format:'))
				structCleanup({ type: 'macro', name: line.substring(7), param: null, });
			else if (line.startsWith('Lookup:'))
				structCleanup({ type: 'lookup', name: line.substring(7), param: [], });
			else if (line.startsWith('Display:'))
				structCleanup({ type: 'display', });
			else if (obj && obj.type == 'macro')
			{
				if (line.startsWith('FormatType'))
					obj.param = FormatTypeMap[line.substring(11).toUpperCase()];
			}
			else if (obj && obj.type == 'lookup')
			{
				let [inps, val] = line.split('=');
				for (const inp of inps.split(','))
				{
					if (inp == '*') obj.param.push(new LookupRange(null, null, val));
					else
					{
						let rv = inp.split('-');
						obj.param.push(new LookupRange(rv[0], rv[rv.length - 1], val));
					}
				}
			}
		}

		// process all lookups in each display
		for (let d of richp.display)
			d.lookups = [...d.string.matchAll(/@([ _a-z][ _a-z0-9]*)\((.+?)\)/gi).map((x) => ({
				name: x[1],
				calc: Logic.fromString(x[2], true),
			}))];
		return richp;
	}
}