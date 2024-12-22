const Console = Object.freeze({
	// Nintendo
	GB: { id: 4, name: "Game Boy", icon: "gb", },
	GBC: { id: 6, name: "Game Boy Color", icon: "gbc", },
	GBA: { id: 5, name: "Game Boy Advance", icon: "gba", },
	NES: { id: 7, name: "NES/Famicom", icon: "nes", },
	SNES: { id: 3, name: "SNES/Super Famicom", icon: "snes", },
	N64: { id: 2, name: "Nintendo 64", icon: "n64", },
	GCN: { id: 16, name: "GameCube", icon: "gc", },
	DS: { id: 18, name: "Nintendo DS", icon: "ds", },
	DSI: { id: 78, name: "Nintendo DSi", icon: "dsi", },
	PKMN: { id: 24, name: "Pokemon Mini", icon: "mini", },
	VB: { id: 28, name: "Virtual Boy", icon: "vb", },

	// Sony
	PSX: { id: 12, name: "PlayStation", icon: "ps1", },
	PS2: { id: 21, name: "PlayStation 2", icon: "ps2", },
	PSP: { id: 41, name: "PlayStation Portable", icon: "psp", },
	
	// Atari
	A2600: { id: 25, name: "Atari 2600", icon: "2600", },
	A7800: { id: 51, name: "Atari 7800", icon: "7800", },
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
	ELEK: { id: 75, name: "Elektor TV Games Computer", icon: "elek", },
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
});

const ConsoleMap = Object.fromEntries(
	Object.entries(Console).map(([k, v]) => [v.id, v])
);

const AssetState = Object.freeze({
	CORE: { rank: 0, name: 'core', marker: '', },
	UNOFFICIAL: { rank: 1, name: 'unofficial', marker: '🚧 '},
	LOCAL: { rank: 2, name: 'local', marker: '✏️ '},
});

class Achievement
{
	id = -1;
	title;
	desc;
	points = 5;
	author;
	achtype = "";
	badge;
	state;
	logic;

	constructor() {  }
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

		ach.logic = Logic.fromString(json.MemAddr, false);
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
		ach.badge = `https://media.retroachievements.org/Badge/${row[13]}.png`
		
		ach.state = AssetState.LOCAL;
		ach.logic = Logic.fromString(row[1], false);
		return ach;
	}
}

FAST_WORDS = ["fast", "quick", "speed", "rush", "hurry", "rapid"];
class Leaderboard
{
	id = -1;
	title;
	desc;
	format;
	lower_is_better = true;
	state = null;
	components = {};

	constructor() {  }
	static fromJSON(json)
	{
		let lb = new Leaderboard();
		lb.id = json.ID;
		lb.title = json.Title;
		lb.desc = json.Description;
		lb.format = FormatTypeMap[json.Format];
		lb.lower_is_better = json.LowerIsBetter;

		lb.components = {};
		for (let part of json.Mem.split("::"))
		{
			let tag = part.substring(0, 3);
			let mem = part.substring(4);
			lb.components[tag] = Logic.fromString(mem, tag == 'VAL');
		}
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

		lb.components = {
			'STA': Logic.fromString(row[1], false),
			'CAN': Logic.fromString(row[2], false),
			'SUB': Logic.fromString(row[3], false),
			'VAL': Logic.fromString(row[4], true),
		}
		lb.state = AssetState.LOCAL;
		return lb;
	}

	#usesFastWords()
	{ return FAST_WORDS.some(x => this.desc.toLowerCase().includes(x) || this.title.toLowerCase().includes(x)); }

	isTime() { return this.format.category == "time" || this.#usesFastWords(); }
	getType()
	{
		if (this.#usesFastWords()) return "speedrun";
		if (this.isTime()) return this.lower_is_better ? "speedrun" : "survival";
		return this.lower_is_better ? "min score" : "high score";
	}
}

class AchievementSet
{
	id;
	title = null;
	icon = null;
	console = null;
	achievements = [];
	leaderboards = [];

	constructor() {  }
	static fromJSON(json)
	{
		let achset = new AchievementSet();
		achset.id = json.ID;
		achset.title = json.Title;
		achset.icon = json.ImageIconURL;
		achset.console = json.ConsoleID in ConsoleMap ? ConsoleMap[json.ConsoleID] : null;

		achset.achievements = json.Achievements
			.filter((x) => !x.Title.toUpperCase().includes('[VOID]'))
			.map((x) => Achievement.fromJSON(x));
		achset.leaderboards = json.Leaderboards
			.filter((x) => !x.Hidden)
			.filter((x) => !x.Title.toUpperCase().includes('[VOID]'))
			.map((x) => Leaderboard.fromJSON(x));
		
		return achset;
	}

	static fromLocal(txt)
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
		let achset = new AchievementSet();
		achset.title = lines[1];
		for (let i = 2; i < lines.length; i++)
		{
			const row = parseColons(lines[i]);
			let asset;
			switch (row[0][0])
			{
				case 'N': // TODO: this is a local code note
					break;
				case 'L': // leaderboard
					asset = Leaderboard.fromLocal(row);
					if (!asset.title.toUpperCase().includes('[VOID]'))
						achset.leaderboards.push(asset);
					break;
				default: // achievement
					asset = Achievement.fromLocal(row);
					if (!asset.title.toUpperCase().includes('[VOID]'))
						achset.achievements.push(asset);
					break;
			}
		}
		return achset;
	}
}

class CodeNote
{
	addr;
	size = 1;
	type = null; // null means unknown, otherwise MemSize object
	note = "";
	author = "";
	constructor(addr, note, author)
	{
		this.addr = +addr;
		this.note = note;
		this.author = author;

		[this.type, this.size] = CodeNote.getSize(note);
	}

	isArray() { return this.size >= (this.type ? this.type.bytes : 1) * 2; }

	contains(addr)
	{
		return addr >= this.addr && addr < this.addr + this.size;
	}

	// transliterated closely from CodeNoteModel::ExtractSize for maximum compatability
	// https://github.com/RetroAchievements/RAIntegration/blob/8a26afb6adb27e22c737a6006344abce8f24c21f/src/data/models/CodeNoteModel.cpp#L242
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
				// deviation from ExtractSize() - identify lower4/upper4 as 8-bit
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

			if (word != ' ' && word != '-')
			{
				prevWordIsSize = wordIsSize;
				prevWordIsNumber = wordIsNumber;
				prevWord = word;
			}
		}

		return [memSize, bytes];
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
					let parts = line.match(/^\?(.+?)\?(.+)$/);
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