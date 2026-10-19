// ~Homebrew~ Word-O
// #ID = 45319
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $C0C6: Puzzle Row [8 bit] (0-6)
//        6 = entered word in last row
function guesses() => byte(0xC0C6)

// $C0C7: Game Won [8 bit] (0/1)
function game_won() => byte(0xC0C7)

// $C0C9: Win Count [8 bit]
function win_count() => byte(0xC0C9)

// $C0CA: Lose Count [8 bit]
function lose_count() => byte(0xC0CA)

// $C0CD: Streak [8 bit]
function streak() => byte(0xC0CD)

// $C0CE: Win Ratio [8 bit]
function win_ratio() => byte(0xC0CE)

// $C0D5: Viewing Options [8 bit] (0/1)
function viewing_options() => byte(0xC0D5)

// $C0D6: Dictionary Type [8 bit]
//        0 = Easy
//        1 = Full
function dictionary_type() => byte(0xC0D6)

// $C0D7: Difficulty [8 bit]
//        0 = Simple (guess any word)
//        1 = Strict (must use revealed letters)
function difficulty() => byte(0xC0D7)

// $C0D8: Extra Mode Enabled [8 bit]
//        0 = Normal
//        1 = Extra Mode Enabled (may not use grey letters)
function extra_mode() => byte(0xC0D8)

// $C0D9: Alphabet Colors [26 bytes]
//        0x00 = No Color
//        0x01 = Grey (unused letter)
//        0x02 = Yellow (wrong location)
//        0x03 = Green (correct location)
function alphabet_colors(i) => byte(0xC0D9 + i)

// $C10D: Board - Letters Guessed [30 bytes]
//        0x00 = A
//        0x01 = B
//        0x02 = C
//        ...
//        0xFF = none
//        
//        the only time that the first letter can be 0xFF is on the title screen, so this works for a rudimentary check
function board_letters_guessed(r, i) => byte(0xC10D + r*5 + i)

// $C12B: Board - Feedback Colors [30 bytes]
//        0x01 = Grey (unused letter)
//        0x02 = Yellow (wrong location)
//        0x03 = Green (correct location)
function board_feedback_colors(r, i) => byte(0xC12B + r*5 + i)

// $C149: Correct Word [5 bytes]
CORRECT_WORD = 0xC149

// --- MAIN DATA -------------------------------------------------------------------

_A = 0x00
_B = 0x01
_C = 0x02
_D = 0x03
_E = 0x04
_F = 0x05
_G = 0x06
_H = 0x07
_I = 0x08
_J = 0x09
_K = 0x0A
_L = 0x0B
_M = 0x0C
_N = 0x0D
_O = 0x0E
_P = 0x0F
_Q = 0x10
_R = 0x11
_S = 0x12
_T = 0x13
_U = 0x14
_V = 0x15
_W = 0x16
_X = 0x17
_Y = 0x18
_Z = 0x19

LETTERS = {
	0x00: "A",
	0x01: "B",
	0x02: "C",
	0x03: "D",
	0x04: "E",
	0x05: "F",
	0x06: "G",
	0x07: "H",
	0x08: "I",
	0x09: "J",
	0x0A: "K",
	0x0B: "L",
	0x0C: "M",
	0x0D: "N",
	0x0E: "O",
	0x0F: "P",
	0x10: "Q",
	0x11: "R",
	0x12: "S",
	0x13: "T",
	0x14: "U",
	0x15: "V",
	0x16: "W",
	0x17: "X",
	0x18: "Y",
	0x19: "Z",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => board_letters_guessed(0, 0) < 26

// --- RICH PRESENCE -------------------------------------------------------------------

rp_dict = rich_presence_lookup("DICT", dictionary_type(), {0: "Easy"}, fallback="Full")
rp_diff = rich_presence_lookup("DIFF", difficulty(), {0: "Simple"}, fallback="Strict")
rp_extra = rich_presence_lookup("EXTRA", extra_mode(), {1: ", EXTRA mode"}, fallback="")

rich_presence_conditional_display(in_game(),
	"Playing Word-O ({0} dictionary, {1} difficulty{2}) [Streak={3}] · Guesses: {4}",
	rp_dict,
	rp_diff,
	rp_extra,
	rich_presence_number(streak()),
	rich_presence_number(guesses())
)

rich_presence_display(
	"Setting up Word-O ({0} dictionary, {1} difficulty{2}) [Wins={3}, Losses={4}, Streak={5}, Ratio={6}%]",
	rp_dict,
	rp_diff,
	rp_extra,
	rich_presence_number(win_count()),
	rich_presence_number(lose_count()),
	rich_presence_number(streak()),
	rich_presence_number(win_ratio())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Word-O the Magnificent",
	description="Guess the correct word using the Full dictionary",
	type="win_condition",
	points=2,
	trigger=(
		in_game() &&
		dictionary_type() == 1 && 
		prev(game_won()) == 0 && game_won() == 1
	)
)

achievement(
	title="Strictly Come Spelling",
	description="Guess the correct word using the Full dictionary and Strict difficulty. All revealed letters must now be used!",
	points=3,
	trigger=(
		in_game() &&
		dictionary_type() == 1 && difficulty() == 1 &&
		prev(game_won()) == 0 && game_won() == 1
	)
)

achievement(
	title="And Word-O Was It's Name-o",
	description="Guess the correct word in Extra Mode using the Full dictionary and Strict difficulty. Activate Extra Mode by pressing A+Start on the title screen. Eliminated letters are now banned!",
	points=5,
	trigger=(
		in_game() &&
		dictionary_type() == 1 && difficulty() == 1 && extra_mode() == 1 &&
		prev(game_won()) == 0 && game_won() == 1
	)
)

achievement(
	title="You Did It",
	description="Guess the correct word using the Full dictionary in 4 or fewer guesses",
	points=5,
	trigger=(
		in_game() &&
		dictionary_type() == 1 && guesses() <= 4 &&
		prev(game_won()) == 0 && game_won() == 1
	)
)

achievement(
	title="Good Guessing",
	description="Guess the correct word using the Full dictionary in 2 or fewer guesses",
	points=10,
	trigger=(
		in_game() &&
		dictionary_type() == 1 && guesses() <= 2 &&
		prev(game_won()) == 0 && game_won() == 1
	)
)

achievement(
	title="A Perfect Week of Word-O",
	description="Guess the correct word 7 times in a row",
	points=5,
	trigger=(
		in_game() &&
		game_won() == 1 &&
		prev(streak()) == 6 && streak() == 7
	)
)

achievement(
	title="Are You Smarter Than a NYT Reader?",
	description="Guess the correct word 25 times or more with a win ratio of 80% or higher",
	points=10,
	trigger=(
		in_game() && game_won() == 1 &&
		win_count() >= lose_count() * 4 &&
		win_count() >= 25 &&
		win_count() == prev(win_count()) + 1
	)
)

achievement(
	title="So Now We're Just Making Up Words?",
	description="Guess the correct word having used words containing the letters Q, X, Z, and J",
	points=5,
	trigger=(
		in_game() &&
		alphabet_colors(_Q) != 0 &&
		alphabet_colors(_X) != 0 &&
		alphabet_colors(_Z) != 0 &&
		alphabet_colors(_J) != 0 &&
		prev(game_won()) == 0 && game_won() == 1
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Longest Streak",
	description="Longest streak in a single session of Word-O",

	start=in_game() && game_won() == 1 && streak() > prev(streak()),
	cancel=always_false(),
	submit=always_true(),

	value=measured(streak()),
	format="VALUE",
	lower_is_better=false
)