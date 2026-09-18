// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// --- MAIN DATA -------------------------------------------------------------------

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------

NULL = 0
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function ptr(x) => dword(x)

function score_wrap(score, max, n=20, reset=always_false()) => (
	max_of(array_map(range(0,n), i => measured(max*i+score, when=if_else(i == 0, always_true(), tally(i, score < prev(score)) && never(reset)))))
)

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

function rich_presence_condition_table(lookupname, list)
{ // highest priority needs to be listed first in the pairs list
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

function rp_hex(x) => rich_presence_lookup("Hex", x, {
	00: "0", 01: "1", 02: "2", 03: "3", 04: "4", 05: "5", 06: "6", 07: "7",
	08: "8", 09: "9", 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F",
}, fallback="0")

function rp_zpad(x) => rich_presence_lookup("_Z", x, {
	0: "0", 1: "0", 2: "0", 3: "0", 4: "0",
	5: "0", 6: "0", 7: "0", 8: "0", 9: "0",
}, fallback="")

function millis_to_timestamp(x) => format("{0}'{1}\"{2}", 
	x / (60 * 1000),
	substring(format("0{0}", (x / 1000) % 60), -2, 2),
	substring(format("00{0}", x), -3, 3)
)

function zfill(num, c)
{
	if (length(format("{0}", num)) >= c) return format("{0}", num)
	return substring(format("0000000000000000000{0}", num), -c, c)
}

function commas(x)
{
	x = format("{0}", x)
	if (length(x) <= 3) return x
	return commas(substring(x, 0, -3)) + "," + substring(x, -3)
}