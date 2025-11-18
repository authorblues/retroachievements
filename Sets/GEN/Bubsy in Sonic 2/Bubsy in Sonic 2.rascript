// ~Hack~ Bubsy in Sonic 2
// #ID = 17070

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

// --- MEMORY -------------------------------------------------------------------

// $B008: Bubsy X Position [16 bit]
// $B00C: Bubsy Y Position [16 bit]
function xpos() => word(0x00B008)
function ypos() => word(0x00B00C)

// $B023: Player State [8 bit]
//        bit0 | 0 = facing left, 1 = facing right
//        bit1 | in air (S2 marks this as "falling")
//        bit2 | in air (S2 marks this as "in ball")
//        bit3 | standing on object - not solid ground
//        bit4 | (S2 marks this as "rolling jump")
//        bit5 | pushing
//        bit6 | underwater
function player_state() => byte(0x00B023)

// $B029: Drown Meter [8 bit]
//        0x1E above water, decreases underwater, resets when resurface
function drown_meter() => byte(0x00B029)

// $B02A: Powerup State [8 bit]
//        bit0 | bubble shield
//        bit1 | invincibility
//        bit2 | speed shoes
function has_bubble_shield() => bit0(0x00B02A)
function has_invincibility() => bit1(0x00B02A)
function has_speed_shoes() => bit2(0x00B02A)

// $B03D: In Midair [8 bit]
//        0 = on ground
//        1 = midair
function midair() => byte(0x00B03D)

// $B433: Boss Health - Aclawtick Ruin Zone [8 bit]
//        starts at 8 -> 0
// $B460: Boss Health - Wing Furtress [8 bit]
//        starts at 8 -> 0
// $B4F3: Boss Health - Hill Tail Zone [8 bit]
//        starts at 8 -> 0
// $B520: Boss Health - Empurreld Hill Zone [8 bit]
//        starts at 8 -> 0
// $B533: Boss Health - Various Stages [8 bit]
//        Mystic Cave Zone, Oil Ocean Zone, Meclawpolis Zone
//        starts at 8 -> 0
// $B620: Boss Health - Chemicat Pant Zone [8 bit]
//        starts at 8 -> 0
// $B673: Boss Health - Clawsino Night Zone [8 bit]
//        starts at 8 -> 0
function boss_hp_ARZ() => byte(0x00B433)
function boss_hp_WFZ() => byte(0x00B460)
function boss_hp_HTZ() => byte(0x00B4F3)
function boss_hp_EHZ() => byte(0x00B520)
function boss_hp_various() => byte(0x00B533)
function boss_hp_CPZ() => byte(0x00B620)
function boss_hp_CNZ() => byte(0x00B673)

// $EE00: Camera X [16 bit]
// $EE04: Camera Y [16 bit]
function xcam() => word(0x00EE00)
function ycam() => word(0x00EE04)

// $F601: Game State [8 bit]
//        
//        following settings should be checked after masking 0x7F
//        0x00 = SEGA
//        0x04 = title screen
//        0x08 = demo/attract mode
//        0x0C = in game
//        0x10 = special stage
//        0x14 = continue screen
//        0x18 = 2P result screen
//        0x1C = 2P level select
//        0x20 = game end sequence
//        0x24 = options menu
//        0x28 = level select
//        
//        bit7 | loading for game modes
function __game_state_raw() => byte(0x00F601)
function game_state() => __game_state_raw() & 0x7F
function loading() => bit7(0x00F601)

// $F605: P1 Controller
//        bit0 | up
//        bit1 | down
//        bit2 | left
//        bit3 | right
//        bit4 | C
//        bit5 | B
//        bit6 | A
//        bit7 | Start
P1_INPUT = 0x00F605
function p1_dpad() => low4(0x00F605)

// $F632: Game Tick [16 bit]
//        increments when 0xF634 rolls over
function game_tick() => word(0x00F632)

// $F634: Frame Count to Game Tick [8 bit]
//        counts from 7 down to 0
//        on 0, resets to 7 and increments 0xF632
function frame_count_to_game_tick() => byte(0x00F634)

// $F63A: Paused [8 bit]
//        0 = unpaused
//        1 = paused
function paused() => byte(0x00F63A)

// $F65E: Super Sonic/Bubsy State [8 bit]
//        0x00 = Currently Normal Bubsy
//        0x01 = Transforming Normal -> Super
//        0x02 = Transforming Super -> Normal
//        0xFF = Currently Super Bubsy
function super_bubsy_state() => byte(0x00F65E)

// $FE10: Current Act [8 bit]
function current_act() => byte(0x00FE10)
function current_stage() => word(0x00FE10)

// $FE11: Current Zone [8 bit]
//        0x00 = Empurreld Hill Zone
//        0x0D = Chemicat Pant Zone
//        0x0F = Aclawtick Ruin Zone
//        0x0C = Clawsino Night Zone
//        0x07 = Hill Tail Zone
//        0x0B = Mystic Cave Zone
//        0x0A = Oil Ocean Zone
//        0x04 = Meclawpolis Zone 1 & 2
//        0x05 = Meclawpolis Zone 3
//        0x10 = Star Cat Zone
//        0x06 = Wing Furtress Zone
//        0x0E = Chicken Egg Zone
function current_zone() => byte(0x00FE11)

// $FE13: Lives [8 bit]
function lives() => byte(0x00FE13)

// $FE1F: Level Incomplete [8 bit]
//        0 = complete
//        1 = incomplete
function level_incomplete() => byte(0x00FE1F)

// $FE20: Current Ring Count [16 bit]
function ring_count() => word(0x00FE20)

// $FE22: Time Minutes [8 bit]
// $FE24: Time Frames [8 bit]
// $FE25: Time Seconds [8 bit]
function time_frames() => byte(0x00FE24)
function time_seconds() => byte(0x00FE25)
function time_minutes() => byte(0x00FE22)

// $FE26: Score [32 bit]
function score() => dword(0x00FE26)

// $FE31: Active Checkpoint [8 bit]
// $FE32: Checkpoint X [16 bit]
// $FE34: Checkpoint Y [16 bit]
function active_checkpoint() => byte(0x00FE31)
function checkpoint_x() => word(0x00FE32)
function checkpoint_y() => word(0x00FE34)

// $FED0: Special Stage Ring Count [8 bit]
function special_ring_count() => byte(0x00FED0)

// $FF40: Rings Remaining in Level [16 bit]
//        does not include TVs
function rings_remaining_in_level() => word(0x00FF40)

// $FF72: Character Select [8 bit]
//        0 = Bubsy
//        1 = Moar Bubsy
//        2 = Floaty the Cat
//        
//        these are all the same character
function character_select() => byte(0x00FF72)

// $FF82: Level Select Menu Selection [8 bit]
//        21 options (0x00 - 0x15)
function level_select_menu_selection() => byte(0x00FF82)

// $FF83: Sound Test Selection [8 bit]
function sound_test_selection() => byte(0x00FF83)

// $FF84: Sound Test Selection (Level Select Menu) [8 bit]
function sound_test_selection_level_select_menu() => byte(0x00FF84)

// $FF87: Mode Selected [8 bit]
//        0x00 = 1 Player (no level select)
//        0x01 = 2 Player VS (has level select, seems like 1P actually)
//        0x02 = Options (leads to level select)
function mode() => byte(0x00FF87)

// $FFB0: Emerald Count [8 bit]
function emerald_count() => byte(0x00FFB0)

// $FFD0: Slow Motion Cheat Enabled [8 bit] (0/1)
// $FFD1: Level Select Cheat Enabled [8 bit] (0/1)
// $FFD2: Debug Mode Enabled [8 bit] (0/1)
// $FFFB: Debug Mode Active [8 bit] (0/1)
function slow_motion_cheat_enabled() => byte(0x00FFD0)
function level_select_cheat_enabled() => byte(0x00FFD1)
function debug_mode_enabled() => byte(0x00FFD2)
function debug_mode_active() => byte(0x00FFFB)

// --- MAIN DATA -------------------------------------------------------------------

STATE_SEGA = 0x00
STATE_TITLE = 0x04
STATE_DEMO = 0x08
STATE_PLAYING = 0x0C
STATE_SPECIAL = 0x10
STATE_CONTINUE = 0x14
STATE_2P_RESULTS = 0x18
STATE_2P_LEVEL_SELECT = 0x1C
STATE_ENDING = 0x20
STATE_OPTIONS = 0x24
STATE_LEVEL_SELECT = 0x28

STATE_NAMES = {
	STATE_SEGA: "Title Screen",
	STATE_TITLE: "Title Screen",
	STATE_DEMO: "Demo",
	STATE_CONTINUE: "Continue?",
	STATE_2P_RESULTS: "2P Results",
	STATE_2P_LEVEL_SELECT: "Level Select",
	STATE_ENDING: "Ending",
	STATE_OPTIONS: "Title Screen",
	STATE_LEVEL_SELECT: "Level Select",
}

STAGE_EMPURRELD_HILL_ZONE_1 = 0x0000
STAGE_EMPURRELD_HILL_ZONE_2 = 0x0001
STAGE_CHEMICAT_PANT_ZONE_1 = 0x0D00
STAGE_CHEMICAT_PANT_ZONE_2 = 0x0D01
STAGE_ACLAWTICK_RUIN_ZONE_1 = 0x0F00
STAGE_ACLAWTICK_RUIN_ZONE_2 = 0x0F01
STAGE_CLAWSINO_NIGHT_ZONE_1 = 0x0C00
STAGE_CLAWSINO_NIGHT_ZONE_2 = 0x0C01
STAGE_HILL_TAIL_ZONE_1 = 0x0700
STAGE_HILL_TAIL_ZONE_2 = 0x0701
STAGE_MYSTIC_CAVE_ZONE_1 = 0x0B00
STAGE_MYSTIC_CAVE_ZONE_2 = 0x0B01
STAGE_OIL_OCEAN_ZONE_1 = 0x0A00
STAGE_OIL_OCEAN_ZONE_2 = 0x0A01
STAGE_MECLAWPOLIS_ZONE_1 = 0x0400
STAGE_MECLAWPOLIS_ZONE_2 = 0x0401
STAGE_MECLAWPOLIS_ZONE_3 = 0x0500
STAGE_STAR_CAT_ZONE = 0x1000
STAGE_WING_FURTRESS_ZONE = 0x0600
STAGE_CHICKEN_EGG_ZONE = 0x0E00

STAGE_NAMES = {
	STAGE_EMPURRELD_HILL_ZONE_1: "Empurreld Hill Zone 1",
	STAGE_EMPURRELD_HILL_ZONE_2: "Empurreld Hill Zone 1",
	STAGE_CHEMICAT_PANT_ZONE_1: "Chemicat Pant Zone 1",
	STAGE_CHEMICAT_PANT_ZONE_2: "Chemicat Pant Zone 2",
	STAGE_ACLAWTICK_RUIN_ZONE_1: "Aclawtick Ruin Zone 1",
	STAGE_ACLAWTICK_RUIN_ZONE_2: "Aclawtick Ruin Zone 2",
	STAGE_CLAWSINO_NIGHT_ZONE_1: "Clawsino Night Zone 1",
	STAGE_CLAWSINO_NIGHT_ZONE_2: "Clawsino Night Zone 2",
	STAGE_HILL_TAIL_ZONE_1: "Hill Tail Zone 1",
	STAGE_HILL_TAIL_ZONE_2: "Hill Tail Zone 2",
	STAGE_MYSTIC_CAVE_ZONE_1: "Mystic Cave Zone 1",
	STAGE_MYSTIC_CAVE_ZONE_2: "Mystic Cave Zone 2",
	STAGE_OIL_OCEAN_ZONE_1: "Oil Ocean Zone 1",
	STAGE_OIL_OCEAN_ZONE_2: "Oil Ocean Zone 2",
	STAGE_MECLAWPOLIS_ZONE_1: "Meclawpolis Zone 1",
	STAGE_MECLAWPOLIS_ZONE_2: "Meclawpolis Zone 2",
	STAGE_MECLAWPOLIS_ZONE_3: "Meclawpolis Zone 3",
	STAGE_STAR_CAT_ZONE: "Star Cat Zone",
	STAGE_WING_FURTRESS_ZONE: "Wing Furtress Zone",
	STAGE_CHICKEN_EGG_ZONE: "Chicken Egg Zone",
}

BOSSES = [
	{ "stage": STAGE_EMPURRELD_HILL_ZONE_2, "xleft": 10480, "health": boss_hp_EHZ(), }, // drill eggman I
	{ "stage": STAGE_CHEMICAT_PANT_ZONE_2, "xleft": 10784, "health": boss_hp_CPZ(), }, // water eggman
	{ "stage": STAGE_ACLAWTICK_RUIN_ZONE_2, "xleft": 10816, "health": boss_hp_ARZ(), }, // hammer eggman
	{ "stage": STAGE_CLAWSINO_NIGHT_ZONE_2, "xleft": 10336, "health": boss_hp_CNZ(), }, // catcher eggman
	{ "stage": STAGE_HILL_TAIL_ZONE_2, "xleft": 12000, "health": boss_hp_HTZ(), }, // submarine eggman I
	{ "stage": STAGE_MYSTIC_CAVE_ZONE_2, "xleft": 8432, "health": boss_hp_various(), }, // drill eggman II
	{ "stage": STAGE_OIL_OCEAN_ZONE_2, "xleft": 10368, "health": boss_hp_various(), }, // submarine eggman II
	{ "stage": STAGE_MECLAWPOLIS_ZONE_3, "xleft": 10928, "health": boss_hp_various(), }, // flying eggman
	{ "stage": STAGE_WING_FURTRESS_ZONE, "xleft": 10874, "health": boss_hp_WFZ(), }, // barrier eggman
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function cheating() => (
	slow_motion_cheat_enabled() != 0 ||
	level_select_cheat_enabled() != 0 ||
	debug_mode_enabled() != 0 ||
	debug_mode_active() != 0
)

function in_game() => __game_state_raw() == STATE_PLAYING && lives() > 0

function time_up() => (
	time_minutes() == 9 &&
	time_seconds() == 59 &&
	time_frames() == 59 &&
	prev(time_frames()) == 59
)

function start_level_no_checkpoint(x) => (
	// loaded into the level (loading+playing -> playing)
	prev(__game_state_raw()) == 0x8c && __game_state_raw() == 0x0c && 
	// on the requested stage (no active checkpoint)
	current_stage() == x && active_checkpoint() == 0
)

function complete_level(x) => in_game() && current_stage() == x && prev(level_incomplete()) == 1 && level_incomplete() == 0 && !time_up()

function range_complete(start, end) => (
	// set a checkpoint hit from being in the correct stage
	once(current_stage() == start) && 
	// trigger when reaching the end of the range
	complete_level(end) && 
	// clear checkpoint if cheating
	never(cheating()) && 
	// clear checkpoint if back to title
	never(game_state() <= STATE_DEMO)
)

function win_the_game() => prev(current_stage()) == STAGE_CHICKEN_EGG_ZONE && prev(game_state()) == STATE_PLAYING && game_state() == STATE_ENDING

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() == STATE_PLAYING,
	"Bubsy is in 🗺️ {0} · {1} {2} · ⏳ {3} · 💍 {4} ring{5} · 💎 {6}/7 emerald{7} collected",
	rich_presence_lookup("Stage", current_stage(), STAGE_NAMES, fallback="???"),
	rich_presence_number(lives()), rich_presence_lookup("LifeWord", lives(), {1: "life"}, fallback="lives"),
	rich_presence_value("_S", time_minutes() * 60 + time_seconds(), "SECS"),
	rich_presence_number(ring_count()), plural(ring_count()),
	rich_presence_number(emerald_count()), plural(emerald_count())
)

rich_presence_conditional_display(game_state() == STATE_SPECIAL,
	"Special Stage · 🗺️ {0} · {1} {2} · ⏳ {3} · 💍 {4} ring{5} · 💎 {6}/7 emerald{7} collected",
	rich_presence_lookup("Stage", current_stage(), STAGE_NAMES, fallback="???"),
	rich_presence_number(lives()), rich_presence_lookup("LifeWord", lives(), {1: "life"}, fallback="lives"),
	rich_presence_value("_S", time_minutes() * 60 + time_seconds(), "SECS"),
	rich_presence_number(special_ring_count()), plural(special_ring_count()),
	rich_presence_number(emerald_count()), plural(emerald_count())
)

rich_presence_display(
	"[Bubsy in Sonic 2] {0}",
	rich_presence_lookup("State", game_state(), STATE_NAMES, fallback="")
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="What Could Pawsibly Go Wrong?",
	description="Complete Empurrald Hill Zone from the beginning of Act 1",
	type="progression",
	points=5,
	trigger=range_complete(STAGE_EMPURRELD_HILL_ZONE_1, STAGE_EMPURRELD_HILL_ZONE_2)
)

achievement(
	title="Is the Writers' Strike Over Yet?",
	description="Complete Chemicat Pant Zone from the beginning of Act 1",
	type="progression",
	points=5,
	trigger=range_complete(STAGE_CHEMICAT_PANT_ZONE_1, STAGE_CHEMICAT_PANT_ZONE_2)
)

achievement(
	title="Who Do I Look Like? Flipper?",
	description="Complete Aclawtick Ruin Zone from the beginning of Act 1",
	type="progression",
	points=5,
	trigger=range_complete(STAGE_ACLAWTICK_RUIN_ZONE_1, STAGE_ACLAWTICK_RUIN_ZONE_2)
)

achievement(
	title="So, You Wanna Be a Video Game Star?",
	description="Complete Clawsino Night Zone from the beginning of Act 1",
	type="progression",
	points=10,
	trigger=range_complete(STAGE_CLAWSINO_NIGHT_ZONE_1, STAGE_CLAWSINO_NIGHT_ZONE_2)
)

achievement(
	title="Did I Mention I Don't Like Heights?",
	description="Complete Hill Tail Zone from the beginning of Act 1",
	type="progression",
	points=5,
	trigger=range_complete(STAGE_HILL_TAIL_ZONE_1, STAGE_HILL_TAIL_ZONE_2)
)

achievement(
	title="Hey, Whatever Blows Your Hair Back!",
	description="Complete Mystic Cave Zone from the beginning of Act 1",
	type="progression",
	points=10,
	trigger=range_complete(STAGE_MYSTIC_CAVE_ZONE_1, STAGE_MYSTIC_CAVE_ZONE_2)
)

achievement(
	title="Oh Sure, Let's All Torch the Bubster",
	description="Complete Oil Ocean Zone from the beginning of Act 1",
	type="progression",
	points=10,
	trigger=range_complete(STAGE_OIL_OCEAN_ZONE_1, STAGE_OIL_OCEAN_ZONE_2)
)

achievement(
	title="Escape from Wool.A.",
	description="Complete Meclawpolis Zone from the beginning of Act 1",
	type="progression",
	points=10,
	trigger=range_complete(STAGE_MECLAWPOLIS_ZONE_1, STAGE_MECLAWPOLIS_ZONE_3)
)

achievement(
	title="Pilot's License? What For?",
	description="Complete Star Cat Zone",
	type="progression",
	points=10,
	trigger=(
		// rough in-game check (check delta gamestate to ensure it doesn't pop on level select)
		!cheating() && prev(__game_state_raw()) == STATE_PLAYING && lives() > 0 && 
		// check for transition from star cat -> wing furtress
		prev(current_stage()) == STAGE_STAR_CAT_ZONE && current_stage() == STAGE_WING_FURTRESS_ZONE
	)
)

achievement(
	title="Anybody Got a Parachute?",
	description="Complete Wing Furtress Zone",
	type="progression",
	points=10,
	trigger=(
		// Wing Furtress Zone
		!cheating() && in_game() && current_stage() == STAGE_WING_FURTRESS_ZONE && 
		// this is the end of the cutscene chasing Eggman. RIP Bubsy
		prev(xpos()) <= 11825 && xpos() > 11825 && ypos() == 1516
	)
)

achievement(
	title="Woah, Are You Still Playing This Thing?!",
	description="Complete Chicken Egg Zone",
	type="win_condition",
	points=10,
	trigger=!cheating() && win_the_game()
)

achievement(
	title="Is There a Veterinarian in the Audience?",
	description="Reach the end of Wing Furtress Zone starting from 1 Player on the title screen",
	points=100,
	trigger=(
		// 1P mode, in Wing Furtress Zone
		!cheating() && in_game() && mode() == 0x00 && current_stage() == STAGE_WING_FURTRESS_ZONE && 
		// this is the end of the cutscene chasing Eggman. RIP Bubsy
		prev(xpos()) <= 11825 && xpos() > 11825 && ypos() == 1516
	)
)

achievement(
	title="Bubsy Smash Toolie-Woolies",
	description="Defeat any end-of-zone boss with invincibility active. Super Bubsy not allowed",
	points=5,
	trigger=(
		// have invincibility
		!cheating() && in_game() && has_invincibility() == 1 && super_bubsy_state() == 0 &&
		// for any of the bosses 
		any_of(BOSSES, b => (
			// are you in the current stage, after the x position that triggers the fight starting, and kill the boss?
			current_stage() == b["stage"] && xcam() >= b["xleft"] && b["health"] == 0 && prev(b["health"]) == 1
		))
	)
)

achievement(
	title="My Contract Does Not Mention Pain!",
	description="Keep the bubble shield to the end of an act",
	points=3,
	trigger=!cheating() && in_game() && has_bubble_shield() == 1 && prev(level_incomplete()) == 1 && level_incomplete() == 0
)

achievement(
	title="I Am a Trained Purr-fessional",
	description="Earn a *Purrfect* bonus on any stage",
	points=10,
	trigger=!cheating() && in_game() && rings_remaining_in_level() == 0 && prev(level_incomplete()) == 1 && level_incomplete() == 0
)

achievement(
	title="Press Some Buttons, Will Ya?!",
	description="Complete Aclawtick Ruin Zone 1 & 2 by reaching the boss without ever touching the dpad",
	points=10,
	trigger=(
		// starting from the start (not a checkpoint) of Aclawtick Ruin Zone 1
		once(start_level_no_checkpoint(STAGE_ACLAWTICK_RUIN_ZONE_1)) &&
		// trigger at the end of Aclawtick Ruin Zone 2
		trigger_when(current_stage() == STAGE_ACLAWTICK_RUIN_ZONE_2 && prev(xpos()) < 10816 && xpos() >= 10816) &&
		// clear on cheating
		never(cheating()) &&
		// clear on returning to the menu
		never(game_state() <= STATE_DEMO) &&
		// clear the checkpoint hit if the dpad is ever pressed
		never(__game_state_raw() == STATE_PLAYING && p1_dpad() != 0)
	)
)

achievement(
	title="A Fistful of Yarn",
	description="Earn your first chaos emerald. Why not chaos yarn balls?",
	points=5,
	trigger=!cheating() && __game_state_raw() == STATE_SPECIAL && lives() > 0 && emerald_count() > prev(emerald_count())
)

achievement(
	title="Is Water Still My Kryptonite?",
	description="Earn seven chaos emeralds and become Super Bubsy! Start from 1 Player on the title screen",
	points=25,
	trigger=(
		// just provide a tracker for emeralds to remind players what they're working toward
		measured(emerald_count() >= 7, when=!cheating() && in_game() && mode() == 0x00) &&
		// trigger the achievement on the transformation
		prev(super_bubsy_state()) == 0x01 && super_bubsy_state() == 0xFF
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

ZONES = [
	{ "start": STAGE_EMPURRELD_HILL_ZONE_1, "end": STAGE_EMPURRELD_HILL_ZONE_2, "name": "Empurreld Hill Zone", },
	{ "start": STAGE_CHEMICAT_PANT_ZONE_1, "end": STAGE_CHEMICAT_PANT_ZONE_2, "name": "Chemicat Pant Zone", },
	{ "start": STAGE_ACLAWTICK_RUIN_ZONE_1, "end": STAGE_ACLAWTICK_RUIN_ZONE_2, "name": "Aclawtick Ruin Zone", },
	{ "start": STAGE_CLAWSINO_NIGHT_ZONE_1, "end": STAGE_CLAWSINO_NIGHT_ZONE_2, "name": "Clawsino Night Zone", },
	{ "start": STAGE_HILL_TAIL_ZONE_1, "end": STAGE_HILL_TAIL_ZONE_2, "name": "Hill Tail Zone", },
	{ "start": STAGE_MYSTIC_CAVE_ZONE_1, "end": STAGE_MYSTIC_CAVE_ZONE_2, "name": "Mystic Cave Zone", },
	{ "start": STAGE_OIL_OCEAN_ZONE_1, "end": STAGE_OIL_OCEAN_ZONE_2, "name": "Oil Ocean Zone", },
	{ "start": STAGE_MECLAWPOLIS_ZONE_1, "end": STAGE_MECLAWPOLIS_ZONE_3, "name": "Meclawpolis Zone", },
	//{ "start": STAGE_STAR_CAT_ZONE, "end": STAGE_STAR_CAT_ZONE, "name": "Star Cat Zone", },
	//{ "start": STAGE_WING_FURTRESS_ZONE, "end": STAGE_WING_FURTRESS_ZONE, "name": "Wing Furtress Zone", },
	//{ "start": STAGE_CHICKEN_EGG_ZONE, "end": STAGE_CHICKEN_EGG_ZONE, "name": "Chicken Egg Zone", },
]

function leaderboard_cancel() => (
	// no cheating allowed
	cheating() || 
	// back to title menu
	game_state() <= STATE_DEMO || 
	// transform into super bubsy
	super_bubsy_state() != 0 || 
	// game over
	lives() == 0
)

for zone in ZONES
{
	z1 = zone["start"] / 0x100
	z2 = zone["end"] / 0x100
	leaderboard(
		title=zone["name"] + " Speedrun",
		description=format("Complete {0} in the fastest time without transformations", zone["name"]),
	
		start=start_level_no_checkpoint(zone["start"]),
		cancel=leaderboard_cancel() || (current_zone() != z1 && current_zone() != z2),
		submit=complete_level(zone["end"]),
	
		value=measured(tally(0, paused() == 0 && loading() == 0)),
		format="FRAMES",
		lower_is_better=true
	)
}

leaderboard(
	title="Star Cat Zone Speedrun",
	description="Complete Star Cat Zone in the fastest time without transformations",

	start=start_level_no_checkpoint(STAGE_STAR_CAT_ZONE),
	cancel=leaderboard_cancel() || prev(current_zone()) != 0x10,
	submit=prev(current_stage() == STAGE_STAR_CAT_ZONE) && current_stage() == STAGE_WING_FURTRESS_ZONE,

	value=measured(tally(0, paused() == 0 && loading() == 0)),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Wing Furtress Zone Speedrun",
	description="Complete Wing Furtress Zone in the fastest time without transformations",

	start=start_level_no_checkpoint(STAGE_WING_FURTRESS_ZONE),
	cancel=leaderboard_cancel() || current_zone() != 0x06,
	submit=(
		// Wing Furtress Zone
		!cheating() && in_game() && current_stage() == STAGE_WING_FURTRESS_ZONE && 
		// this is the end of the cutscene chasing Eggman. RIP Bubsy
		prev(xpos()) <= 11825 && xpos() > 11825 && ypos() == 1516
	),

	value=measured(tally(0, paused() == 0 && loading() == 0)),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Chicken Egg Zone Speedrun",
	description="Complete Chicken Egg Zone in the fastest time without transformations",

	start=start_level_no_checkpoint(STAGE_CHICKEN_EGG_ZONE),
	cancel=leaderboard_cancel() || current_zone() != 0x0E,
	submit=prev(game_state() == STATE_PLAYING) && game_state() == STATE_ENDING,

	value=measured(tally(0, paused() == 0 && loading() == 0)),
	format="FRAMES",
	lower_is_better=true
)