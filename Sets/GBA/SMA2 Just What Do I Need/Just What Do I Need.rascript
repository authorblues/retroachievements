// ~Hack~ Just What Do I Need
// #ID = 26383

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $3FD0: Player X [16 bit]
function player_x() => word(0x3FD0)

// $3FD4: Player Y [16 bit]
function player_y() => word(0x3FD4)

// $3FF6: Is Grounded? [8 bit] (0/1)
function is_grounded() => byte(0x3FF6)

// $424C: Yoshi's Island 4 Flags [8 bit]
//        bit5 | All dragon coins collected
function collected_dcoins(x) => bit5(0x414A + x)

// $42BC: Lives [16 bit] (offset by 1)
//        0x0005 = 6 lives
//        0xFFFF = game over
function lives() => word(0x42BC)

// $42D2: World 1 Completion Flags [8 bit]
//        bit1 | Iggy's Castle
//        bit2 | Yoshi's Island 4
//        bit3 | Yoshi's Island 3
//        bit4 | Yoshi's Island 2
//        bit5 | Yellow Switch Palace
//        bit6 | Yoshi's Island 1
function world_1_completion_flags() => byte(0x42D2)

// $42F4: Switches [8 bit]
//        bit6 | Yellow Switch pressed
//        bit7 | Green Switch pressed
function switch_yellow() => bit6(0x42F4)
function switch_green() => bit7(0x42F4)

// $42F7: Unlocked Yoshis [8 bit]
//        bit3 | Green Yoshi
//        bit2 | Red Yoshi (yi1)
//        bit1 | Blue Yoshi (yi3)
//        bit0 | Yellow Yoshi (yi2)
function unlocked_yoshi_green() => bit3(0x42F7)
function unlocked_yoshi_red() => bit2(0x42F7)
function unlocked_yoshi_blue() => bit1(0x42F7)
function unlocked_yoshi_yellow() => bit0(0x42F7)

// $42FC: Character [8 bit]
//        0 = Mario
//        1 = Luigi
function character() => byte(0x42FC)

// $4300: Powerup State [8 bit]
//        0 = small
//        1 = super
//        2 = cape
//        3 = fire
function powerup_state() => byte(0x4300)

// $4302: Riding Yoshi [8 bit]
//        0 = not riding
//        1 = riding Yoshi
function riding_yoshi() => byte(0x4302)

// $4303: Yoshi Color [8 bit]
//        0x00 = (no yoshi)
//        0x04 = Yellow
//        0x06 = Blue
//        0x08 = Red
//        0x0a = Green
function _yoshi_color() => byte(0x4303)

// $4328: Coins in Current Stage [8 bit]
//        used for bonus block, need 30 to spawn 1up
function coins_in_current_stage() => byte(0x4328)

// $4350: Moons [8 bit]
//        bit1 | Yoshi's Island 4 moon
function moon_yi4() => bit1(0x4350)

// $4C66: Level ID [16 bit]
//        0x0000 = (not in level)
//        0x0014 = Yellow Switch Palace
//        0x0015 = Donut Plains 1
//        0x0101 = Iggy's Castle
//        0x0102 = Yoshi's Island 4
//        0x0103 = Yoshi's Island 3
//        0x0104 = Yoshi's House
//        0x0105 = Yoshi's Island 1
//        0x0106 = Yoshi's Island 2
function level_id() => word(0x4C66)

// $54BA: Stage Clear Flag [8 bit]
function stage_clear_flag() => byte(0x54BA)

// $54CB: Dragon Coin Count [8 bit]
//        5 = all
function dragon_coin_count() => byte(0x54CB)

// $5597: Reason for Returning to Overworld [8 bit]
//        0x00 = no clear
//        0x01 = normal exit
//        0x02 = secret exit
//        0x80 = died
function exit_flag() => byte(0x5597)

// --- MAIN DATA -------------------------------------------------------------------

LEVEL_NONE = 0
LEVEL_YSP = 0x0014
LEVEL_DP1 = 0x0015
LEVEL_C1  = 0x0101
LEVEL_YI4 = 0x0102
LEVEL_YI3 = 0x0103
LEVEL_YH  = 0x0104
LEVEL_YI1 = 0x0105
LEVEL_YI2 = 0x0106

LEVEL_DESCRIPTIONS = {
	LEVEL_YH:  "visiting Yoshi's House",
	LEVEL_YSP: "in Yellow Switch Palace",
	LEVEL_YI1: "running through Yoshi's Island 1",
	LEVEL_YI2: "climbing through Yoshi's Island 2",
	LEVEL_YI3: "scrolling through Yoshi's Island 3",
	LEVEL_YI4: "sliding through Yoshi's Island 4",
	LEVEL_C1:  "storming Iggy's Castle",
	LEVEL_DP1: "celebrating in Donut Plains 1",
}

POWERUPS = {
	0: "Small",
	1: "Super",
	2: "Cape",
	3: "Fire",
}

CHARACTER = {
	0: "Mario",
	1: "Luigi",
}

YOSHI_COLOR = {
	0x00: "is",
	0x04: "and Yellow Yoshi are",
	0x06: "and Blue Yoshi are",
	0x08: "and Red Yoshi are",
	0x0a: "and Green Yoshi are",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function complete_level(level, exit) => (
	prev(level_id()) == level && level_id() == 0 &&
	prev(stage_clear_flag()) == 1 && stage_clear_flag() == 0 &&
	exit_flag() == exit
)

function collect_all_dcoins(x) => (
	once(prev(dragon_coin_count()) == 4 && dragon_coin_count() == 5) &&
	dragon_coin_count() == 5 &&
	prev(stage_clear_flag()) == 0 && stage_clear_flag() == 1 &&
	never(level_id() != x)
)

function yoshi_color() => riding_yoshi() * _yoshi_color()

// --- RICH PRESENCE -------------------------------------------------------------------

rp_powerup = rich_presence_lookup("POWERUP", powerup_state(), POWERUPS, fallback="Small")
rp_character = rich_presence_lookup("CHAR", character(), CHARACTER, fallback="Mario")
rp_yoshi = rich_presence_lookup("YOSHI", yoshi_color(), YOSHI_COLOR, fallback="is")
rp_level = rich_presence_lookup("LEVEL", level_id(), LEVEL_DESCRIPTIONS, fallback="traveling around Dinosaur Land")

rich_presence_conditional_display(level_id() == 0x00c7,
	"On the Title Screen"
)

rich_presence_display(
	"{0} {1} {2} {3}",
	rp_powerup, rp_character, rp_yoshi, rp_level
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Just Reach Out and Touch It",
	description="Press the Yellow Switch",
	type="progression",
	points=2,
	trigger=level_id() == LEVEL_YSP && is_set(switch_yellow())
)

achievement(
	title="A Devious Contraption",
	description="Press the Green Switch",
	type="progression",
	points=2,
	trigger=level_id() == LEVEL_YH && is_set(switch_green())
)

achievement(
	title="Yet Another P-Switch Run",
	description="Complete Yoshi's Island 1",
	type="progression",
	points=3,
	trigger=complete_level(LEVEL_YI1, 1)
)

achievement(
	title="Under Pressure",
	description="Collect all dragon coins in Yoshi's Island 1 and complete the level",
	points=3,
	trigger=collect_all_dcoins(LEVEL_YI1)
)

achievement(
	title="Just Hanging Around",
	description="Complete Yoshi's Island 2",
	type="progression",
	points=3,
	trigger=complete_level(LEVEL_YI2, 1)
)

achievement(
	title="Through the Tight Spaces",
	description="Collect all dragon coins in Yoshi's Island 2 and complete the level",
	points=2,
	trigger=collect_all_dcoins(LEVEL_YI2)
)

achievement(
	title="Baby's First Autoscroller",
	description="Complete Yoshi's Island 3",
	type="progression",
	points=3,
	trigger=complete_level(LEVEL_YI3, 1)
)

achievement(
	title="Strawberry Moon",
	description="Collect the moon in Yoshi's Island 4",
	points=1,
	trigger=level_id() == LEVEL_YI4 && is_set(moon_yi4())
)

achievement(
	title="Super Mario World, featuring The Other Brother",
	description="Complete Yoshi's Island 4",
	type="progression",
	points=5,
	trigger=complete_level(LEVEL_YI4, 1)
)

achievement(
	title="Putting It All Together",
	description="Complete Iggy's Castle",
	type="win_condition",
	points=10,
	trigger=complete_level(LEVEL_C1, 1)
)

achievement(
	title="Fiery Friend on the Footbridge",
	description="Unlock Red Yoshi",
	points=2,
	trigger=level_id() == LEVEL_YI1 && is_set(unlocked_yoshi_red())
)

achievement(
	title="Caped Companion in the Canal",
	description="Unlock Blue Yoshi",
	points=2,
	trigger=level_id() == LEVEL_YI3 && is_set(unlocked_yoshi_blue())
)

achievement(
	title="Quaking Acquaintance in the Quay",
	description="Unlock Yellow Yoshi",
	points=2,
	trigger=level_id() == LEVEL_YI2 && is_set(unlocked_yoshi_yellow())
)

// --- LEADERBOARDS -------------------------------------------------------------------
