// Dream Shopper
// #ID = 15774

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function _score(x) => (
	byte(x+0) * 100000 +
	byte(x+1) * 10000 +
	byte(x+2) * 1000 +
	byte(x+3) * 100 +
	byte(x+4) * 10 +
	byte(x+5)
)

// --- MEMORY -------------------------------------------------------------------


// $0001: Game State [8 bit]
//        bit5 | Current Player (0 = player one, 1 = player two)
//        bit6 | Player Count (0 = single, 1 = two players)
function current_player() => bit5(0x0001) + 1
function player_count() => bit6(0x0001) + 1

// $0002: Game State [8 bit]
//        bit5 | Dead on Board
//        bit7 | In-game
function dead_state() => bit5(0x0002)
function in_game() => bit7(0x0002)

// $0005: Credits [8 bit]
function credit_count() => byte(0x0005)

// $0008: Hi Score [6 bytes]
function hi_score() => _score(0x0008)

// $000E: 1P Score [6 bytes]
// $0014: 2P Score [6 bytes]
function score_1p() => _score(0x000E)
function score_2p() => _score(0x0014)

function score_1p_tens() => byte(0x000F)
function score_2p_tens() => byte(0x0015)

// $0042: Player X Position [8 bit]
//        0x30 = board left
//        0xE0 = board right
// $0044: Player Y Position [8 bit]
//        bonus game ends at 0x38
//        0x40 = board top
//        0xF0 = board bottom
function player_xpos() => byte(0x0042)
function player_ypos() => byte(0x0044)

function player_col() => high4(0x0042) - 0x3
function player_row() => 0xF - high4(0x0044)

// $0066: Mode [8 bit]
//        0 = Board
//        1 = Bonus/Act
//        
//        seems to take on other values during the demo, so maybe only reliable during an actual game
function mode() => bit0(0x0066)

// $0068: Board State [144 bytes] [12x12 array]
//        counting starts in the bottom left corner and counts up, then across to the right
//        
//        bits0-2 | Value (1 = 500, 2 = 250, 3 = 100, 4 = 50)
//        bit3 | Flashing (0 = no, 1 = yes) (in proximity of bomb)
//        bit4 | Frog (0 = no, 1 = yes)
//        bit5 | Hole (0 = no, 1 = yes)
//        bit6 | Bomb (0 = no, 1 = yes)
//        bit7 | Flipped (0 = no, 1 = yes)
function _bndx(row, col) => 0x0068 + col*12 + row
function board_value(r, c) => bit0(_bndx(r,c)) + 2*bit1(_bndx(r,c)) + 4*bit2(_bndx(r,c))
function board_is_flashing(r, c) => bit3(_bndx(r,c))
function board_is_frog(r, c) => bit4(_bndx(r,c))
function board_is_hole(r, c) => bit5(_bndx(r,c))
function board_is_bomb(r, c) => bit6(_bndx(r,c))
function board_is_flipped(r, c) => bit7(_bndx(r,c))


// $0189: Round Score [5 bytes]
//        target is always 10000 at start of round
function round_score() => _score(0x0188)
function round_tens() => byte(0x0189)

// $01A5: Center Tile State [8 bit]
//        0 = Apple
//        1 = Grapes
//        2 = Melon
//        3 = Banana
//        4 = (None)
function center_tile_state() => byte(0x01A5)

// $01A7: Lives [8 bit]
function lives() => byte(0x01A7)

// $01AA: Board Round [8 bit]
function board_round() => byte(0x01AA)

// $01AB: "Play Game" Act [8 bit] (0-6)
//        0 = Act 1
//        6 = Act 7 (final act, rolls over to 0)
function bonus_act() => byte(0x01AB) + 1

// $01D8: Board Reveal Timer [8 bit] (frames)
//        set to 240 when player touches the fruit tile in center
//        board is revealed until timer reaches 0
function board_reveal_timer() => byte(0x01D8)

// $0220: Spawn Counter [8 bit]
//        first enemy spawns when counter reaches 1
//        unclear how future enemies are triggered
function spawn_counter() => byte(0x0220)

// $0221: Number of Monsters [8 bit]
function monster_count() => byte(0x0221)

// $0227: Enemy #1 Type [8 bit]
//        1 = Monsters Arriving
//        2 = Vulnerable Monsters
//        3 = Active Monsters
//        4 = Dead Monsters
// $022C: Enemy #1 X Position [8 bit]
// $022D: Enemy #1 Data [8 bit]
//        
//        Lower4: Palette
//        2 = Active Shopper
//        3 = Vulnerable Shopper
// $022E: Enemy #1 Y Position [8 bit]
function _monster_struct(i) => 0x0227 + i*14
function monster_type(i) => byte(_monster_struct(i) + 0)
function monster_x(i) => byte(_monster_struct(i) + 5)
function monster_y(i) => byte(_monster_struct(i) + 7)
function monster_palette(i) => low4(_monster_struct(i) + 6)

function monster_col(i) => high4(_monster_struct(i) + 5) - 0x3
function monster_row(i) => 0xF - high4(_monster_struct(i) + 7)

// $02A5: Bomb Timer [8 bit]
function bomb_timer() => byte(0x02A5)

// $02A8: Bomb Explosion Meta [16 bit]
//        this and a few values around here are used for the post-explosion blast. 
//        this is non-zero when the blast is happening, which is when enemies are killed (3->4).
//        specifically, enemies die 2f after the bomb timer at 0x02a5 reaches 0
function bomb_explosion_meta() => word(0x02A8)

// $0300: Bonus - Ring Collected [8 bit] (0/1)
// $0306: Bonus - Necklace Collected [8 bit] (0/1)
// $030C: Bonus - Handbag Collected [8 bit] (0/1)
// $0312: Bonus - Shoes Collected [8 bit] (0/1)
function bonus_ring_collected() => byte(0x0300)
function bonus_necklace_collected() => byte(0x0306)
function bonus_handbag_collected() => byte(0x030C)
function bonus_shoes_collected() => byte(0x0312)

// --- MAIN DATA -------------------------------------------------------------------

MAX_ENEMIES = 4

MODE_SHOPPING = 0
MODE_BONUS = 1

BONUS_ITEMS = [
	bonus_ring_collected(),
	bonus_necklace_collected(),
	bonus_handbag_collected(),
	bonus_shoes_collected(),
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function score_current_player() => _score(0x0008 + current_player()*6)

function in_shopping() => in_game() == 1 && mode() == MODE_SHOPPING
function clear_shopping() => prev(round_tens()) == 0 && round_tens() > 0

function in_bonus() => in_game() == 1 && mode() == MODE_BONUS
function clear_bonus() => prev(player_ypos()) > 0x38 && player_ypos() == 0x38

function monster_exploded(i) => prev(monster_type(i)) == 3 && monster_type(i) == 4

// --- RICH PRESENCE -------------------------------------------------------------------

rp_player_count = rich_presence_lookup("PCOUNT", player_count(), {2: " · Two Players"}, fallback="")
rp_current_player = rich_presence_lookup("CPLAYER", current_player(), {2: "P2"}, fallback="P1")
rp_lifeword = rich_presence_lookup("LIFEWORD", lives(), {1: "Life"}, fallback="Lives")

function rich_presence_score(x) => rich_presence_value("_S", x, "SCORE")

rich_presence_conditional_display(in_game() == 1 && mode() == MODE_SHOPPING,
	"🏬 Board {0} (🏠 {1}) [{7}] · {2} {3} · {4} Score: {5}{6}",
	rich_presence_number(board_round()),
	rich_presence_number(bonus_act()),
	rich_presence_number(lives()), rp_lifeword,
	rp_current_player,
	rich_presence_score(score_current_player()),
	rp_player_count,
	rich_presence_score(round_score())
)

rich_presence_conditional_display(in_game() == 1 && mode() == MODE_BONUS,
	"🏠 Act {1} (🏬 {0}) [💍 {7}] · {2} {3} · {4} Score: {5}{6}",
	rich_presence_number(board_round()),
	rich_presence_number(bonus_act()),
	rich_presence_number(lives()), rp_lifeword,
	rp_current_player,
	rich_presence_score(score_current_player()),
	rp_player_count,
	rich_presence_number(sum_of(BONUS_ITEMS, x => x))
)

rich_presence_display(
	"Playing Dream Shopper"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// clear a round on the shopping board
// acts 1-7
// collect all treasure in acts 1-5
// score 50,000 points
// uncover a frog on the shopping board
// kill two enemies at once with a bomb
// in one life, kill five enemies with a fruit powerup on the same board

achievement(
	title="Let's Go to the Mall",
	description="Clear any round on the shopping board. Any dip switch settings are allowed for all achievements. Starting with 6 lives is allowed!",
	type="progression",
	points=2,
	trigger=in_shopping() && clear_shopping()
)

achievement(
	title="Handbag Havoc",
	description="Clear the Act 1 bonus game",
	type="progression",
	points=2,
	trigger=(
		in_bonus() && bonus_act() == 1 && 
		clear_bonus()
	)
)

achievement(
	title="My Love Language is Gift-Giving",
	description="Clear the Act 1 bonus game after collecting all four bonus items",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 1 &&
		all_of(BONUS_ITEMS, x => x == 1) &&
		trigger_when(clear_bonus())
	)
)

achievement(
	title="So Here's My Love Song",
	description="Clear the Act 2 bonus game",
	type="progression",
	points=3,
	trigger=(
		in_bonus() && bonus_act() == 2 && 
		clear_bonus()
	)
)

achievement(
	title="Not Fancy or Fine",
	description="Clear the Act 2 bonus game after collecting all four bonus items",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 2 &&
		all_of(BONUS_ITEMS, x => x == 1) &&
		trigger_when(clear_bonus())
	)
)

achievement(
	title="The Path to My Lover's House",
	description="Clear the Act 3 bonus game",
	type="progression",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 3 && 
		clear_bonus()
	)
)

achievement(
	title="A Few of Her Favorite Things",
	description="Clear the Act 3 bonus game after collecting all four bonus items",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 3 &&
		all_of(BONUS_ITEMS, x => x == 1) &&
		trigger_when(clear_bonus())
	)
)

achievement(
	title="Ring Around the Rosie",
	description="Clear the Act 4 bonus game",
	type="progression",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 4 && 
		clear_bonus()
	)
)

achievement(
	title="Gordian Knot",
	description="Clear the Act 4 bonus game after collecting all four bonus items",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 4 &&
		all_of(BONUS_ITEMS, x => x == 1) &&
		trigger_when(clear_bonus())
	)
)

achievement(
	title="By the Snickets and Alleyways",
	description="Clear the Act 5 bonus game",
	type="progression",
	points=10,
	trigger=(
		in_bonus() && bonus_act() == 5 && 
		clear_bonus()
	)
)

achievement(
	title="Popping Into the Shops",
	description="Clear the Act 5 bonus game after collecting all four bonus items",
	points=5,
	trigger=(
		in_bonus() && bonus_act() == 5 &&
		all_of(BONUS_ITEMS, x => x == 1) &&
		trigger_when(clear_bonus())
	)
)

achievement(
	title="A Busy Lane",
	description="Clear the Act 6 bonus game",
	type="progression",
	points=25,
	trigger=(
		in_bonus() && bonus_act() == 6 && 
		clear_bonus()
	)
)

achievement(
	title="Avoiding the Hustle and Bustle",
	description="Clear the Act 7 bonus game",
	type="win_condition",
	points=50,
	trigger=(
		in_bonus() && bonus_act() == 7 && 
		clear_bonus()
	)
)

achievement(
	title="Personal Shopper",
	description="Score 50,000 points",
	points=5,
	trigger=in_game() == 1 && (
		(prev(score_1p_tens()) < 5 && score_1p_tens() >= 5) ||
		(prev(score_2p_tens()) < 5 && score_2p_tens() >= 5)
	)
)

achievement(
	title="The Frog for Whom the Bell Tolls",
	description="Uncover a frog on the shopping board",
	points=2,
	trigger=(
		// on the shopping board
		in_shopping() &&
		// the player hasn't moved
		// necessary because Delta on flipped state was giving previous row/col, so walking could mistrigger
		player_xpos() == prev(player_xpos()) &&
		player_ypos() == prev(player_ypos()) &&
		// tile is a frog
		board_is_frog(player_row(), player_col()) == 1 &&
		// tile was flipped
		prev(board_is_flipped(player_row(), player_col())) == 0 &&
		board_is_flipped(player_row(), player_col()) == 1
	)
)

achievement(
	title="Black Friday",
	description="Kill two or more yellow shoppers at the same time with a bomb explosion",
	points=5,
	trigger=(
		in_shopping() &&
		any_of(range(0,MAX_ENEMIES-2), 
			i => any_of(range(i+1,MAX_ENEMIES-1), 
				j => (
					bomb_timer() == 0 && bomb_explosion_meta() != 0 &&
					monster_exploded(i) && monster_exploded(j)
				)
			)
		)
	)
)

achievement(
	title="Produce Department",
	description="In one life, kill four yellow shoppers with fruit powerups on the same board",
	points=5,
	trigger=(
		measured(tally_of(range(0,MAX_ENEMIES-1), 4, 
			i => (
				prev(monster_type(i)) == 2 && 
				monster_type(i) == 4
			)
		)) &&
		never(lives() < prev(lives())) &&
		never(current_player() != prev(current_player())) &&
		never(board_round() != prev(board_round())) &&
		never(!in_shopping())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Highest Score",
	description="Highest score earned in 1 Player mode",

	start=in_game() == 1 && player_count() == 1 && prev(lives()) == 1 && lives() == 0,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score_1p()),
	format="SCORE",
	lower_is_better=false
)

leaderboard(
	title="Furthest Round",
	description="Furthest board round reached in 1 Player mode",

	start=in_game() == 1 && player_count() == 1 && prev(lives()) == 1 && lives() == 0,
	cancel=always_false(),
	submit=always_true(),

	value=measured(board_round()),
	format="VALUE",
	lower_is_better=false
)