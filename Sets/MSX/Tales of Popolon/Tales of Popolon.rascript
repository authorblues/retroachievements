// ~Homebrew~ Tales of Popolon
// #ID = 34005

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $0000: Position X [16 bit]
// $0002: Position Y [16 bit]
// $0004: Current Facing Angle [8 bit]
function position_x() => word(addr_offset() + 0x000000)
function position_y() => word(addr_offset() + 0x000002)
function current_facing_angle() => byte(addr_offset() + 0x000004)

// $0005: Game Cycle [8 bit]
function clock() => byte(addr_offset() + 0x000005)

// $0006: Current Floor [8 bit]
function current_floor() => byte(addr_offset() + 0x000006)

// $0009: Health [8 bit] (max = 0x10)
function health() => byte(addr_offset() + 0x000009)

// $000B: Left Hand - Sword [8 bit] (1 = have, 0 = don't)
//        found on floor 0x00
// $000C: Left Hand - Gold Sword [8 bit] (1 = have, 0 = don't)
//        found on floor 0x05
function have_left(x) => byte(addr_offset() + 0x00000A + x)

// $000E: Right Hand - Bow & Arrows [8 bit] (1 = have, 0 = don't)
//        found on floor 0x03
// $000F: Right Hand - Ice Arrows [8 bit] (1 = have, 0 = don't)
//        found on floor 0x05
// $0010: Right Hand - Hourglass [8 bit] (1 = have, 0 = don't)
//        found on floor 0x00
function have_right(x) => byte(addr_offset() + 0x00000D + x)

// $0012: Armor - Silver Armor [8 bit] (1 = have, 0 = don't)
//        found on floor 0x04
// $0013: Armor - Gold Armor [8 bit] (1 = have, 0 = don't)
//        found on floor 0x07
function have_armor(x) => byte(addr_offset() + 0x000011 + x)

// $003A: Game State [8 bit]
//        0 = Splash
//        1 = Title
//        2 = Story
//        3 = Game Playing
//        4 = Game Over
//        5 = Enter Map
//        6 = Ending
function game_state() => byte(addr_offset() + 0x00003A)

// $003F: God Power [8 bit] (max = 0x1f)
function god_power() => byte(addr_offset() + 0x00003F)

// $0040: Key Count [8 bit]
function key_count() => byte(addr_offset() + 0x000040)

// $0140: Boss Killed - Dungeon Ker [8 bit]
// $0141: Boss Killed - Gorgon [8 bit]
// $0142: Boss Killed - Boss Ker #1 [8 bit]
// $0143: Boss Killed - Boss Ker #2 [8 bit]
//        0 = not defeated, 1 = defeated
function boss_killed(i) => byte(addr_offset() + 0x000140 + i)

// $0144: Current Left Hand Item [8 bit]
//        0x00 = Bare Hand
//        0x01 = Sword
//        0x02 = Gold Sword
function current_left_hand() => byte(addr_offset() + 0x000144)

// $0145: Current Right Hand Item [8 bit]
//        0x00 = Bare Hand
//        0x01 = Bow & Arrows
//        0x02 = Ice Arrows
//        0x03 = Hourglass
function current_right_hand() => byte(addr_offset() + 0x000145)

// $0146: Current Armor [8 bit]
//        0x00 = Iron Armor
//        0x01 = Silver Armor
//        0x02 = Gold Armor
function current_armor() => byte(addr_offset() + 0x000146)

// $015C: Hourglass Timer [8 bit]
//        set to 40 frames on use
function hourglass_timer() => byte(addr_offset() + 0x00015C)

// $2D61: Number of Enemies/Objects [8 bit]
function enemy_count() => byte(addr_offset() + 0x002D61)

// $2D62: Enemies/Objects [16 x 9 byte structs]
//        
//        +0 | enemy type [8 bit]
//        +1 | x coordinate [8 bit]
//        +2 | y coordinate [8 bit]
//        +3 | sprite pattern [8 bit]
//        +4 | color [8 bit]
//        +5 | hit points [8 bit]
//        +6 | state 1 [8 bit]
//        +7 | state 2 [8 bit]
//        +8 | state 3 [8 bit]
//        
//        colors:
//        0x07 = frozen
//        0x0e = stone (Gorgon)
//        
//        health:
//        Ker - 12 max (room = 0x04)
//        Gorgon - 48 max (floor = 0x06)
//        2x Keres Bosses - 48 max (floor = 0x08)
MAX_ENEMIES = 16
function enemy(i) => addr_offset() + 0x002D62 + 9 * i

// --- MAIN DATA -------------------------------------------------------------------

GAME_STATE_SPLASH = 0
GAME_STATE_TITLE = 1
GAME_STATE_STORY = 2
GAME_STATE_PLAYING = 3
GAME_STATE_GAME_OVER = 4
GAME_STATE_ENTER_MAP = 5
GAME_STATE_ENDING = 6

FLOOR_NAMES = {
	0x00: "tunnel",
	0x01: "main halls",
	0x02: "main halls",
	0x03: "catacombs",
	0x04: "dungeon",
	0x05: "Gorgon's lair",
	0x06: "Gorgon's lair",
	0x07: "Keres' hall",
	0x08: "Keres' great hall",
}

LEFT_BARE = 0x00
LEFT_SWORD = 0x01
LEFT_GOLD_SWORD = 0x02

LEFT_ITEMS = {
	LEFT_BARE: "Empty",
	LEFT_SWORD: "Sword",
	LEFT_GOLD_SWORD: "Gold Sword",
}

RIGHT_BARE = 0x00
RIGHT_ARROWS = 0x01
RIGHT_ICE_ARROWS = 0x02
RIGHT_HOURGLASS = 0x03

RIGHT_ITEMS = {
	RIGHT_BARE: "Empty",
	RIGHT_ARROWS: "Bow & Arrows",
	RIGHT_ICE_ARROWS: "Ice Arrows",
	RIGHT_HOURGLASS: "Hourglass",
}

ARMOR_IRON = 0x00
ARMOR_SILVER = 0x01
ARMOR_GOLD = 0x02

ARMOR_NAMES = {
	ARMOR_IRON: "Iron Armor",
	ARMOR_SILVER: "Silver Armor",
	ARMOR_GOLD: "Gold Armor",
}

BOSS_DUNGEON_KER = 0
BOSS_GORGON = 1
BOSS_FINAL_KER_A = 2
BOSS_FINAL_KER_B = 3

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => prev(game_state()) == GAME_STATE_PLAYING && game_state() == GAME_STATE_PLAYING
function in_game_check() => game_state() == GAME_STATE_PLAYING || game_state() == GAME_STATE_ENTER_MAP

function enter_floor(x) => current_floor() == x && prev(game_state()) == GAME_STATE_ENTER_MAP && game_state() == GAME_STATE_PLAYING

function enemy_id(i) => byte(enemy(i) + 0)
function enemy_died(i) => prev(byte(enemy(i) + 5)) > 0 && byte(enemy(i) + 5) == 0
function enemy_hurt(i) => byte(enemy(i) + 5) < prev(byte(enemy(i) + 5))
function enemy_frozen(i) => byte(enemy(i) + 4) == 0x07 && byte(enemy(i) + 8) > 0

// awful heuristic - but you can't resume from a password on floor 0, so the only way to be here would be
// to have actually started here. no way to come back from a previous floor because prior game state would be ENTER_MAP
function new_game() => (
	game_state() == GAME_STATE_PLAYING && prior(game_state()) == GAME_STATE_TITLE &&
	prev(position_x()) == 6144 && prev(position_y()) == 14336 && prev(current_facing_angle()) == 0x00 && current_floor() == 0x00 &&
	prev(clock()) == 0 && clock() > 0
)

function win_game() => current_floor() == 0x08 && prev(game_state()) == GAME_STATE_PLAYING && game_state() == GAME_STATE_ENDING

// --- RICH PRESENCE -------------------------------------------------------------------

rp_location = rich_presence_lookup("Location", current_floor(), FLOOR_NAMES, fallback="evil fortress")

rich_presence_conditional_display(game_state() == GAME_STATE_PLAYING || game_state() == GAME_STATE_ENTER_MAP,
	"🏰 Popolon is in the {0} ❤️ {1} HP 💙 {2} god power 🫲 {3} 🫱 {4} 🛡️ {5} 🗝️ {6}",
	rp_location,
	rich_presence_number(health()),
	rich_presence_number(god_power()),
	rich_presence_lookup("LeftHand", current_left_hand(), LEFT_ITEMS, fallback="Empty"),
	rich_presence_lookup("RightHand", current_right_hand(), RIGHT_ITEMS, fallback="Empty"),
	rich_presence_lookup("Armor", current_armor(), ARMOR_NAMES, fallback="Iron Armor"),
	rich_presence_number(key_count())
)

rich_presence_conditional_display(game_state() == GAME_STATE_STORY,
	"Popolon is listening to the story of Olympus"
)

rich_presence_conditional_display(game_state() == GAME_STATE_ENDING,
	"Popolon has saved the land from the evil Keres"
)

rich_presence_conditional_display(game_state() == GAME_STATE_GAME_OVER,
	"Popolon has succumbed to the forces of evil in the {0}",
	rp_location
)

rich_presence_display(
	"Popolon is preparing to enter the evil fortress on Olympus"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Favor of the Gods",
	description="Max out the god meter",
	points=5,
	trigger=in_game() && prev(god_power()) < 0x1f && god_power() == 0x1f
)

achievement(
	title="Rat and Snake Sushimi",
	description="Find the sword in the tunnels",
	points=2,
	trigger=in_game() && current_floor() == 0x00 && is_set(have_left(LEFT_SWORD))
)

achievement(
	title="Bow of the Silent Spirit",
	description="Find the bow and arrows in the catacombs",
	points=3,
	trigger=in_game() && current_floor() == 0x03 && is_set(have_right(RIGHT_ARROWS))
)

achievement(
	title="Fits Like a Glove",
	description="Defeat the Ker in the dungeons and collect the Silver Armor",
	type="progression",
	points=5,
	trigger=in_game() && current_floor() == 0x04 && is_set(have_armor(ARMOR_SILVER))
)

// TODO: get the Silver Armor without killing the Ker??? can you get a key there?

achievement(
	title="Unarmed and Dangerous",
	description="Defeat the Ker in the dungeons with nothing in your hands",
	points=10,
	trigger=(
		in_game() &&
		once(enter_floor(0x04) && boss_killed(BOSS_DUNGEON_KER) == 0) &&
		trigger_when(is_set(boss_killed(BOSS_DUNGEON_KER))) &&
		never(enemy_hurt(0) && current_left_hand() + current_right_hand() != 0) &&
		never(!in_game_check()) &&
		never(current_floor() != 0x04)
	)
)

achievement(
	title="Ice and Easy",
	description="Find the ice arrows in the Gorgon's lair",
	points=3,
	trigger=in_game() && current_floor() == 0x05 && is_set(have_right(RIGHT_ICE_ARROWS))
)

achievement(
	title="Gor-Gone",
	description="Defeat the Gorgon in the Gorgon's lair",
	type="progression",
	points=10,
	trigger=in_game() && current_floor() == 0x06 && is_set(boss_killed(BOSS_GORGON))
)

achievement(
	title="Better than Perseus",
	description="Defeat the Gorgon without freezing it with ice arrows",
	points=5,
	trigger=(
		in_game() &&
		once(enter_floor(0x06) && boss_killed(BOSS_GORGON) == 0) &&
		trigger_when(is_set(boss_killed(BOSS_GORGON))) &&
		never(enemy_frozen(0)) &&
		never(!in_game_check()) &&
		never(current_floor() != 0x06)
	)
)

achievement(
	title="Perfectly Balanced, As All Things Should Be",
	description="Defeat the evil Keres at the top of the fortress and earn the favor of Thanatos",
	type="win_condition",
	points=25,
	trigger=win_game()
)

achievement(
	title="Zubora's Gift",
	description="Find the gold sword hidden somewhere within the evil fortress",
	points=5,
	trigger=in_game() && current_floor() == 0x05 && is_set(have_left(LEFT_GOLD_SWORD))
)

achievement(
	title="Radiant Armor",
	description="Find the gold armor hidden somewhere within the evil fortress",
	points=5,
	trigger=in_game() && current_floor() == 0x07 && is_set(have_armor(ARMOR_GOLD))
)

achievement(
	title="So Are the Days of Our Lives",
	description="Find the hourglass hidden somewhere within the evil fortress",
	points=5,
	trigger=in_game() && current_floor() == 0x00 && is_set(have_right(RIGHT_HOURGLASS))
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Fastest Clear",
	description="In one session, complete the game as quickly as possible. No passwords",

	start=new_game(),
	cancel=game_state() == GAME_STATE_TITLE || health() == 0,
	submit=win_game(),

	value=measured(tally(0, prev(clock()) != clock())),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Least Damage",
	description="In one session, complete the game taking the least damage. No passwords",

	start=new_game(),
	cancel=game_state() == GAME_STATE_TITLE || health() == 0,
	submit=win_game(),

	value=measured(tally_of(range(1,15), 0, (i) => health() <= prev(health()) - i)),
	format="VALUE",
	lower_is_better=true
)