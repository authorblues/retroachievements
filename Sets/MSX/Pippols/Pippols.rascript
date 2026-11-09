// Pippols
// #ID = 26625

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function score_wrap(score, max, n=20, reset=always_false()) => (
	max_of(array_map(range(0,n), i => measured(max*i+score, when=if_else(i == 0, always_true(), tally(i, score < 4000000 && prev(score) > 6000000) && never(reset)))))
)

function commas(x)
{
	x = format("{0}", x)
	if (length(x) <= 3) return x
	return commas(substring(x, 0, -3)) + "," + substring(x, -3)
}

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $2000: Game State [8 bit]
//        0x00 = Konami Software
//        0x01 = Title Screen
//        0x02 = Demo
//        0x03 = Start New Game
//        0x04 = Loading Map
//        0x05 = Playing
//        0x06 = Unload? Game Over?
//        0x07 = Game Over
function game_state() => byte(addr_offset() + 0x002000)

// $2004: General Purpose Timer [8 bit]
//        loading a new zone gives a 0x40 (64f) timer for the player to enter the new zone
//        
//        waiting at the end of a room for too long will cause the screen to scroll the opposite direction (the choices at the other end are the same choices)
//        as we approach the end of the room, this value becomes 0xC0 (192f), then when the scrolling stops, it counts down to 0, where walking resumes the opposite direction
function general_timer() => byte(addr_offset() + 0x002004)

// $2009: Player Input [8 bit]
//        bit0 | up
//        bit1 | down
//        bit2 | left
//        bit3 | right
//        bit4 | btn1
//        bit5 | btn2
function player_input() => byte(addr_offset() + 0x002009)

// $2043: High Score [24 bit BCD]
// $2046: Score [24 bit BCD]
function high_score() => bcd(tbyte(addr_offset() + 0x002043)) * 10
function p1_score() => bcd(tbyte(addr_offset() + 0x002046)) * 10

// $2050: Lives [8 bit BCD] - "rest"
function lives() => bcd(byte(addr_offset() + 0x002050))

// $2102: Direction [8 bit]
//        0 = up
//        1 = down
function direction() => byte(addr_offset() + 0x002102)

// $2105: Paths Walked [8 bit]
//        increments when entering a new zone (same frame)
//        increments when waiting/turning around in current zone
function paths_walked() => byte(addr_offset() + 0x002105)

// $2113: Stage Scrolling [8 bit]
//        bit7 | freeze due to clock
//        bit0 | freeze at end of path
function stage_freeze_clock() => bit7(addr_offset() + 0x002113)
function stage_freeze_path_end() => bit0(addr_offset() + 0x002113)

// $2132: Zone [8 bit]
//        way out:
//        0x00 = flowers #1
//        0x01 = blue deadwood
//        0x02 = green tree #1
//        0x03 = red moai
//        0x04 = blue tree
//        0x05 = red deadwood
//        0x06 = green moai
//        0x07 = green tree #2
//        0x08 = flowers #2
//        
//        way back:
//        0x09 = flowers #1
//        0x0a = red moai
//        0x0b = blue deadwood
//        0x0c = green tree
//        0x0d = red deadwood #2
//        0x0e = green moai
//        0x0f = blue tree
//        0x10 = red deadwood #1
//        0x11 = flowers #2
function zone() => byte(addr_offset() + 0x002132)

// $2133: Stage [8 bit]
//        0 = way out
//        1 = way back
//        loop ends when 1->0
function has_orb() => byte(addr_offset() + 0x002133)

// $219A: Yellow Coin Counter [8 bit]
//        counts to 3, resets to 0 on a fourth coin, spawning red boots
//        resets to 0 on death as well, so unreliable for item spawning
function yellow_coins() => byte(addr_offset() + 0x00219A)

// $219B: Yellow Coin Continuous Counter [8 bit]
//        counts total yellow coins since last death, stops counting at 4
function yellow_coins_continuous() => byte(addr_offset() + 0x00219B)

// $21A0: White Coin Counter [8 bit]
//        counts to 3, resets to 0 on a fourth coin, spawning blue boots
//        resets to 0 on death as well, so unreliable for item spawning
function white_coins() => byte(addr_offset() + 0x0021A0)

// $21A1: White Coin Continuous Counter [8 bit]
//        counts total white coins since last death, stops counting at 4
function white_coins_continuous() => byte(addr_offset() + 0x0021A1)

// $21A7: Stage Freeze Timer [8 bit]
//        when collecting a clock, this gets set to 0x80 and counts down until unfreezing
//        enemies are frozen when this is non-zero
//        also sets bit7 of 0x2113 for the duration of the timer, freezing stage scrolling
function stage_freeze_timer() => byte(addr_offset() + 0x0021A7)

// $21A8: Item - Red Boots [8 bit] (0/1)
//        makes the player move faster
function item_red_boots() => byte(addr_offset() + 0x0021A8)

// $21A9: Item - Blue Boots [8 bit] (0/1)
//        player can jump over hedges/barriers
function item_blue_boots() => byte(addr_offset() + 0x0021A9)

// $2200: Enemy Table [256 bytes]
//        16 x 16 byte structs
//        +0 | enemy type/state
//        .. 0x00 = (empty)
//        .. 0x01 = yellow fuzzy "pitton"
//        .. 0x02 = blue ghost/fairy
//        .. 0x03 = thorns
//        .. 0x04 = rat
//        .. 0x05 = white ghost
//        .. 0x06 = yellow ghost
//        .. 0x08 = red fuzzy hopping "pitton"
//        .. 0x09 = skeleton head
//        .. 0x0a = butterfly
//        .. 0xFF = dead (enters this state temporarily before becoming 0x00)
function enemy_type(i) => byte(addr_offset() + 0x002200 + 0x10*i)

// --- MAIN DATA -------------------------------------------------------------------

STATE_KONAMI = 0x00
STATE_TITLE = 0x01
STATE_DEMO = 0x02
STATE_NEWGAME = 0x03
STATE_LOADING = 0x04
STATE_PLAYING = 0x05
STATE_UNLOADING = 0x06
STATE_GAMEOVER = 0x07

ICON_FLOWERS = "🌼🌷"
ICON_MOAI = "🗿"
ICON_TREE = "🌳"
ICON_DEADWOOD = "🪾"

ICON_RED = "🟥"
ICON_BLUE = "🟦"
ICON_GREEN = "🟩"

ZONE_ICONS = {
	// way out
	0x00: ICON_FLOWERS,
	0x01: ICON_BLUE + ICON_DEADWOOD,
	0x02: ICON_GREEN + ICON_TREE,
	0x03: ICON_RED + ICON_MOAI,
	0x04: ICON_BLUE + ICON_TREE,
	0x05: ICON_RED + ICON_DEADWOOD,
	0x06: ICON_GREEN + ICON_MOAI,
	0x07: ICON_GREEN + ICON_TREE,
	0x08: ICON_FLOWERS,

	// way back
	0x09: ICON_FLOWERS,
	0x0a: ICON_RED + ICON_MOAI,
	0x0b: ICON_BLUE + ICON_DEADWOOD,
	0x0c: ICON_GREEN + ICON_TREE,
	0x0d: ICON_RED + ICON_DEADWOOD,
	0x0e: ICON_GREEN + ICON_MOAI,
	0x0f: ICON_BLUE + ICON_TREE,
	0x10: ICON_RED + ICON_DEADWOOD,
	0x11: ICON_FLOWERS,
}

ZONE_NAMES = {
	// way out
	0x00: "the country of flowers",
	0x01: "the country of old trees",
	0x02: "the country of forest",
	0x03: "stone country",
	0x04: "the country of forest",
	0x05: "the country of old trees",
	0x06: "stone country",
	0x07: "the country of forest",
	0x08: "the country of flowers",

	// way back
	0x09: "the country of flowers",
	0x0a: "stone country",
	0x0b: "the country of old trees",
	0x0c: "the country of forest",
	0x0d: "the country of old trees",
	0x0e: "stone country",
	0x0f: "the country of forest",
	0x10: "the country of old trees",
	0x11: "the country of flowers",
}

ALL_ZONES = range(0x00, 0x11)
ALL_ENEMIES = range(0, 15)

ROUTES = {
	0x00: "on the way out to retrieve the Holy Gem",
	0x01: "on the way back to bring light to the world",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() == STATE_PLAYING,
	"{0} Pippols is in {1}, {2} · 🏃 {3} · 💯 {4}",
	rich_presence_lookup("RoomIcon", zone(), ZONE_ICONS, fallback=ZONE_ICONS[0x00]),
	rich_presence_lookup("RoomName", zone(), ZONE_NAMES, fallback="the world of magic"),
	rich_presence_lookup("Route", has_orb(), ROUTES, fallback=ROUTES[0]),
	rich_presence_number(lives()),
	rich_presence_value("Score", score_wrap(p1_score(), 10000000, n=20, reset=game_state() < STATE_PLAYING), "SCORE")
)

rich_presence_display(
	"Pippols | © Konami 1985"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Land of Old Bay and Crab Cakes",
	description="Reach Merryland and steal back the Holy Gem from the fairies of darkness",
	type="progression",
	points=10,
	trigger=game_state() == STATE_PLAYING && prev(zone()) == 0x08 && prev(has_orb()) == 0 && zone() == 0x09 && has_orb() == 1
)

achievement(
	title="There and Back Again",
	description="Return the Holy Gem to Neverland and bring back light to the world",
	type="win_condition",
	points=25,
	trigger=game_state() == STATE_PLAYING && prev(zone()) == 0x11 && prev(has_orb()) == 1 && zone() == 0x00 && has_orb() == 0
)

achievement(
	title="The Cartography Zone",
	description="In one run, visit all 18 zones in the world of magic",
	points=25,
	trigger=(
		// keep track of each zone, add a hit if we are ever in that zone
		measured(tally_of(ALL_ZONES, length(ALL_ZONES), z => once(zone() == z))) &&
		// reset if we aren't in-game
		never(game_state() != STATE_PLAYING)
	)
)

achievement(
	title="Speed Runner",
	description="Collect four yellow coins without dying or missing any and collect the red boots",
	points=3,
	trigger=game_state() == STATE_PLAYING && is_set(item_red_boots())
)

achievement(
	title="Over the Hedge",
	description="Collect four white coins without dying or missing any and collect the blue boots",
	points=3,
	trigger=game_state() == STATE_PLAYING && is_set(item_blue_boots())
)

achievement(
	title="False Dichotomy",
	description="Pippols, you have to make up your mind! Travel up and down the same path three times due to your own indecision",
	points=3,
	trigger=(
		measured(repeated(3, (
			// staying in the same zone
			prev(zone()) == zone() &&
			// Pippols starts moving again
			prev(stage_freeze_path_end()) == 1 && stage_freeze_path_end() == 0 &&
			// in the opposite direction
			prev(direction()) != direction()
		))) &&
		// reset if we change zones
		never(zone() != prev(zone())) &&
		// reset if we aren't in-game
		never(game_state() != STATE_PLAYING)
	)
)

achievement(
	title="Toki wo Tomare",
	description="Defeat eight or more enemies while time is stopped",
	points=5,
	trigger=(
		measured(tally_of(ALL_ENEMIES, 8, i => once(
			// enemy slot wasn't empty
			prev(enemy_type(i)) != 0x00 &&
			// enemy wasn't already dead
			prev(enemy_type(i)) != 0xFF &&
			// enemy is now dead
			enemy_type(i) == 0xFF
		))) &&
		// reset if the clock runs out
		never(stage_freeze_timer() == 0) &&
		// reset if we aren't in-game
		never(game_state() != STATE_PLAYING)
	)
)

achievement(
	title="Pippols Champion",
	description="Defeat 150 enemies without dying",
	points=10,
	trigger=(
		measured(tally_of(ALL_ENEMIES, 150, i => (
			// enemy slot wasn't empty
			prev(enemy_type(i)) != 0x00 &&
			// enemy wasn't already dead
			prev(enemy_type(i)) != 0xFF &&
			// enemy is now dead
			enemy_type(i) == 0xFF
		))) &&
		// reset if the player dies
		never(lives() < prev(lives())) &&
		// reset if we aren't in-game
		never(game_state() != STATE_PLAYING)
	)
)

SCORE_ACHIEVEMENTS = [
	{ "score": 20000, "title": "Magic to Do", "points": 1, },
	{ "score": 100000, "title": "Morning Glow", "points": 5, },
	{ "score": 500000, "title": "Extraordinary", "points": 10, },
]

for ach in SCORE_ACHIEVEMENTS
	achievement(
		title=ach["title"],
		description=format("Earn {0} points", commas(ach["score"])),
		points=ach["points"],
		trigger=game_state() == STATE_PLAYING && prev(p1_score()) < ach["score"] && p1_score() >= ach["score"]
	)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="High Score",
	description="Highest score in one playthrough. Score submits on game over",

	start=prev(game_state()) == STATE_LOADING && game_state() == STATE_PLAYING && p1_score() == 0,
	cancel=game_state() < STATE_PLAYING, // might be worth scrapping this and just having all non-playing states submit
	submit=game_state() == STATE_GAMEOVER,

	value=score_wrap(p1_score(), 10000000, n=20, reset=game_state() == STATE_TITLE),
	format="SCORE",
	lower_is_better=false
)