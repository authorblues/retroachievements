// ~Hack~ Dog Collab
// #ID = 22569

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")

// --- MEMORY -------------------------------------------------------------------

// $23A146: Current Savefile [16bit]
function file() => word(0x23A146) - 1

// $089CA0: (Save 1) [Bitflags] Progression Flags
//          --- bit0 | Save File created
//          --- bit4 | Bowser 2 cleared
//          --- bit5 | Bowser 1 cleared
function save_created() => bit0(0x089CA0 + 0x40 * file())
function bowser2_cleared() => bit4(0x089CA0 + 0x40 * file())
function bowser1_cleared() => bit5(0x089CA0 + 0x40 * file())

// $089CA3: (Save 1) [Bitflags] Progresson Flags
//          --- bit5 | B3 Halfway Point

// $089CA4: (Save 1) [Bitflags] Stars Collected - C5 Peach Ruins
//          --- bit0 | Across the Fragile Bridge
//          --- bit1 | Tower Raft Ride
//          --- bit2 | Hidden Among the Ashes
//          --- bit3 | 8 Red Hot Reds
//          --- bit4 | Free the Enslaved Toads
//          --- bit5 | General Motos
//          --- bit6 | 100 Coins

// $089CA5: (Save 1) [Bitflags] Stars Collected - C6 Swirling Circus
//          --- bit0 | 1 - Carousel Climb
//          --- bit1 | 2 - Frightening Ferris Wheel
//          --- bit2 | 3 - Red Coins at Whilrigig Waypoints
//          --- bit3 | 4 - Trapeze Tumble
//          --- bit4 | 5 - Center Stage Showdown
//          --- bit5 | 6 - Closing the Circus
//          --- bit6 | 100 Coins

// $089CA6: (Save 1) [Bitflags] Stars Collected - C4 Koopa Atoll
//          --- bit0 | X Marks the Spot
//          --- bit1 | Water Race with Koopa the Quick
//          --- bit2 | You're It! Tag the Bunny Under the Tree
//          --- bit3 | Race on the Rock Face
//          --- bit4 | Red Coins In the Coral Reef
//          --- bit5 | The Arena Inside the Volcano
//          --- bit6 | 100 Coins

// $089CA7: (Save 1) [Bitflags] Stars Collected - C3 Hair-Raising High Rise
//          --- bit0 | Are Dogs Even Allowed in this Establishment?
//          --- bit1 | Move Furniture On Floor 2!
//          --- bit2 | Have A Party On Floor 3!
//          --- bit3 | Drain The Floor 4 Pool!
//          --- bit4 | Inside The Basement Sports Complex
//          --- bit5 | The Great Scavvenger Hunt
//          --- bit6 | 100 Coins
function c3_stars(x) => bit(x, 0x089CA7 + 0x40 * file())
function c3_star_count() => bitcount(0x089CA7 + 0x40 * file())

// $089CA8: (Save 1) [Bitflags] Stars Collected - C7 Awe-Inspiring Spires
//          --- bit0 | High On The Azure Tower
//          --- bit1 | Frosted Tips
//          --- bit2 | Wall-Kicking Dives
//          --- bit3 | Secrets In the Silver Tower
//          --- bit4 | The Invisible Path
//          --- bit5 | Red Tower's 8 Coins
//          --- bit6 | 100 Coins

// $089CA9: (Save 1) [Bitflags] Stars Collected - C8 Sakura Stronghold
//          --- bit0 | To the Forest's Shrine
//          --- bit1 | Top of The Fortress
//          --- bit2 | Secret Coins In Town
//          --- bit3 | Courtyard's 8 Red Coins
//          --- bit4 | Secret Entrance From The Lake
//          --- bit5 | Upstairs of the Dungeon
//          --- bit6 | 100 Coins

// $089CAA: (Save 1) [Bitflags] Stars Collected - C9 Forbidden Factory
//          --- bit0 | Turn On The Generator
//          --- bit1 | Unlock the Maintenance Room
//          --- bit2 | Red Coins with Free Shipping
//          --- bit3 | Production Line Rush
//          --- bit4 | Red Block Roundup
//          --- bit5 | King Goopa Beneath the Scenes
//          --- bit6 | 100 Coins

// $089CAB: (Save 1) [Bitflags] Stars Collected - C2 Cumulus Correctional Center [Bitflags]
//          --- bit0 | 1 - Taking the tour
//          --- bit1 | 2 - Lost in the Clouds
//          --- bit2 | 3 - Red Coins in the Facility
//          --- bit3 | 4 - Rainbow Ride to the Tower
//          --- bit4 | 5 - The Thunderous Troublemakers
//          --- bit5 | 6 - The Cumulus Breath Control Course
//          --- bit6 | 100 Coins

// $089CAD: Savefile 1 - Stars collected in Maple Markindon [8bit]
//          --- Bit0 | Bob-omb Baron atop his tall Tree Throne

// $089CAF: (Save 1) [Bitflags] Stars Collected - Desolate Reservoir
//          --- bit0 | The Lab Drain
//          --- bit1 | The Side Entrance
//          --- bit2 | The Pit
//          --- bit3 | The Overhang
//          --- bit4 | The Whirlpool
//          --- bit5 | The Coins In the Clouds
//          --- bit6 | 100 Coins

// $089CB0: (Save 1) [Bitflags] Stars Collected - Bowser's Rainbow Rings
//          --- bit0 | Red Coins

// $089CB5: (Save 1) [Bitflags] Stars Collected - Bowser's Furious Finale
//          --- bit0 | Red Coins
function b3_reds() => bit0(0x089CB5 + 0x40 * file())

// $089CB7: (Save 1) [Bitflags] Stars Collected - Bowser's Flying Fortress
//          --- bit0 | Red Coins
function b1_reds() => bit0(0x089CB7 + 0x40 * file())

// $089CCC: Savefile 1 - Dog Name [12 Bytes; ASCII]
function dog_name() => 0x089CCC + 0x40 * file()

// $15A544: Analog Stick - Y Axis (8-bit)
function analog_y() => byte(0x15A544)

// $15A545: Analog Stick - X Axis (8-bit)
function analog_x() => byte(0x15A545)

// $15A546: Controller Input (8-bit)
//          bit0 - C Right
//          bit1 - C Left
//          bit2 - C Down
//          bit3 - C Up
//          bit4 - R Trigger
//          bit5 - L Trigger

// $15A547: Controller Input (8-bit)
//          bit0 - D-Pad Right
//          bit1 - D-Pad Left
//          bit2 - D-Pad Down
//          bit3 - D-Pad Up
//          bit4 - Start Button
//          bit5 - Z Trigger
//          bit6 - B Button
//          bit7 - A Button
function button(x) => bit(x, 0x15A546)

// $23905A: Menu Mode (16-bit)
//          None - 0xffff
//          Pause Screen - 0x01
//          Course Complete Screen - 0x02
function menu_type() => word(0x23905A)

// $23906A: [16-bit] Dialog ID {gDialogID}
function dialog_id() => word(0x23906A)

// $23907B: Pause Type (8-bit)
//          Level - 0x01
//          Castle - 0x02
function pause_type() => byte(0x23907B)

// $23A140: [16-bit] Current Map ID {gCurrLevelNum}
//          0x00 | (Loading)
//          0x01 | (Title Screen)
//          0x04 | Course 2 Cumulus Correctional Center
//          0x05 | Course 5 Peach Ruins
//          0x06 | (Intro Cutscene)
//          0x07 | Course 9 Forbidden Factory
//          0x08 | Course 7 Awe-Inspiring Spires
//          0x09 | Course 3 Hair-Riasing High Rise
//          0x0a | [Course 0 Upturned Deeps]
//          0x0b | Course 1 Maple Markindon
//          0x0c | Course 6 Swirling Circus
//          0x0d | [THI]
//          0x0e | [TTC]
//          0x0f | [RR]
//          0x10 | Level Select
//          0x11 | Bowser's Rainbow Rings
//          0x12 | [VC]
//          0x13 | Bowser's Flying Fortress
//          0x14 | [AQUA]
//          0x15 | Bowser's Furious Finale
//          0x16 | Course 8 Sakura Stronghold
//          0x17 | Course 10 Desolate Reservoir
//          0x18 | Course 4 Koopa Atoll
//          0x19 | The End
//          0x1a | [COURTYARD]
//          0x1b | Bowser's Furious Finale
//          0x1c | [METAL]
//          0x1d | [WING]
//          0x1e | Bowser's Rainbow Rings
//          0x1f | [WMOTR]
//          0x21 | Bowser's Flying Fortress
//          0x22 | Bowser's Furious Finale
function map_id() => word(0x23A140)

// $23AD38: last Star - Data ID (8-bit)
//          Hair-Raising High Rise - 0x01
//          Koopa Atoll - 0x02
//          Swirling Circus - 0x03
//          Peach Ruins - 0x04
//          Cumulus Correctional Center - 0x05
//          Forbidden Factory - 0x06
//          Sakura Stronghold - 0x07
//          Awe-Inspiring Spires - 0x08
//          Desolate Reservoir - 0x09
//          Maple Markindon - 0x0b
//          Bowser's Rainbow Rings - 0x10
//          Bowser's Flying Fortress - 0x11
//          Bowser's Furious Finale - 0x13
function last_star_stage() => byte(0x23AD38)

// $23AD39: last Star ID (8-bit)
function last_star_num() => byte(0x23AD39)

// $24494E: Ground Type? (16-bit)

// $244B06: Red Coins collected (8-bit)
function red_count() => byte(0x244B06)

// $244C90: [16-bit] Current Sub-Map ID {gCurrAreaIndex}
function submap_id() => word(0x244C90)

// $244C96: [16-bit] Current Act {gCurrActNum}
function act() => word(0x244C96)

// $244C9B: Transition Screen flag (8-bit)
function transition() => byte(0x244C9B)

// $246DB0: Start of the Object-Table (183600 Bytes)
//          Object Layout (612 Bytes)
//          +0x000 | Camera Bits (16-bit)
//          +0x002 | Object Header (16-bit)
//          +0x004 | Pointer to previous object (32-bit)
//          +0x008 | Pointer to next object (32-bit)
//          +0x00C | Pointer to affected variables (32-bit)
//          +0x014 | Pointer to the object's graphics data (32-bit)
//          +0x01A | active state (8-bit)
//          +0x02C | X-Axis Scale (32-bit)
//          +0x030 | Y-Axis Scale (32-bit)
//          +0x034 | Z-Axis Scale (32-bit)
//          +0x038 | current action (32-bit)
//          +0x038 | Vertical Offset (16-bit)
//          +0x03C | Pointer to the Animation table (32-bit)
//          +0x040 | BAMS Rotation? (16-bit)
//          +0x042 | Animation Frame (16-bit)
//          +0x040 | Parent Object BAMS Rotation? (16-bit)
//          +0x042 | Parent Object Animation Frame (16-bit)
//          +0x060 | Pointer to next object (32-bit)
//          +0x064 | Pointer to previous object (32-bit)
//          +0x068 | Pointer to target Object (32-bit)
//          +0x07A | alive state (8-bit)
//          +0x07C | Pointer to the last object interacted (32-bit)
//          +0x080 | Pointer to the last object interacted (32-bit)
//          +0x084 | Pointer to the last object interacted (32-bit)
//          +0x088 | Pointer to the last object interacted (32-bit)
//          +0x08C | Pointer to the last object interacted (32-bit)
//          +0x090 | Speed Behavior (16-bit)
//          +0x092 | Mario reaction (16-bit)
//          +0x0A4 | X coordinates (32-bit)
//          +0x0A8 | Y coordinates (32-bit)
//          +0x0AC | Z coordinates (32-bit)
//          +0x0B0 | X coordinates collision? (32-bit)
//          +0x0B4 | Y coordinates collision? (32-bit)
//          +0x0B8 | Z coordinates collision? (32-bit)
//          +0x0C8 | X collision rotation? (32-bit)
//          +0x0CC | Y collision rotation? (32-bit)
//          +0x0D0 | Z collision rotation? (32-bit)
//          +0x0D4 | X rotation (32-bit)
//          +0x0D8 | Y rotation (32-bit)
//          +0x0DC | Z rotation (32-bit)
//          +0x0F4 | GFX Variation (32-bit)
//          +0x0F8 | Type (32-bit)
//          +0x0FC | Property (Float)
//          +0x100 | Timer (32-bit)
//          +0x148 | second State (8-bit)
//          +0x150 | first State (8-bit)
//          +0x158 | State Timer (32-bit)
//          +0x168 | Behavior X coordinates (32-bit)
//          +0x16C | Behavior Y coordinates (32-bit)
//          +0x170 | Behavior Z coordinates (32-bit)
//          +0x180 | Transparency Level (32-bit)
//          +0x184 | Damage (32-bit)
//          +0x188 | Health? (32-bit)
//          +0x18E | Subtype (8-bit)
//          +0x19C | Coin payout (32-bit)
//          +0x1A0 | Camera distance (Float)
//          +0x1B0 | Pointer to external Data (32-bit)
//          +0x1B4 | External Data Index (32-bit)
//          +0x1BE | copied external Data (16-bit)
//          +0x1C4 | Pointer to more external Data (32-bit)
//          +0x1D0 | Pointer to behavior script to execute (32-bit)
//          +0x1D8 | Pointer to behavior script to execute (32-bit)
//          +0x1E0 | Pointer to behavior script to execute (32-bit)
//          +0x1FC | Bottom collision (Float)
//          +0x200 | Top collision (Float)
//          +0x210 | Pointer to the initial Behavior Script (32-bit)
//          +0x218 | Pointer to the Object standing on (32-bit)
//          +0x21C | Pointer to collision data (32-bit)
OBJECT_TABLE = 0x246DB0
OBJECT_COUNT = 300
function object(i) => OBJECT_TABLE + 612 * i
function obj_script_ptr(i) => dword(object(i) + 0x210)

// $273CCD: [8-bit] Loading Sub-Map ID
function loading_submap_id() => byte(0x273CCD)

// $273CCE: [8-bit] Loading Map ID
function loading_map_id() => byte(0x273CCE)

// $273CCF: [8-bit] Map Loading Flag
function loading_flag() => byte(0x273CCF)

// $273CD8: Pause Info (8-bit)
//          bit1 - Game Paused
//          bit2 - Loading Level
function game_paused() => bit1(0x273CD8)
function loading_level() => bit2(0x273CD8)

// $273CF8: Current Animation (4 Bytes)
//          +0x00 | Animation ID (8-bit)
//          +0x01 | Action (8-bit)
//          bit1 - Standing Flag
//          bit2 - Walking Flag
//          bit3 - In Air Flag
//          bit4 - Star collected Flag
//          bit5 - In Water Flag
//          +0x02 | Action (8-bit)
//          bit4 - Grabbing Pole Flag
//          bit5 - Hanging on Ceiling Flag
//          bit6 - Idle Flag
//          bit7 - Attack Flag
function animation() => word(0x273CF8)
function anim_collect_star() => bit(12, 0x273CF8)
function anim_in_water() => bit(13, 0x273CF8)

// $273CFC: Previous Animation (4 Bytes)
//          +0x00 | Animation ID (8-bit)
//          +0x01 | Action (8-bit)
//          bit1 - Standing Flag
//          bit2 - Walking Flag
//          bit3 - In Air Flag
//          bit4 - Star collected Flag
//          bit5 - In Water Flag
//          +0x02 | Action (8-bit)
//          bit4 - Grabbing Pole Flag
//          bit5 - Hanging on Ceiling Flag
//          bit6 - Idle Flag
//          bit7 - Attack Flag

// $273D28: Mario X coords (Float)
// $273D2C: Mario Y coords (Float)
// $273D30: Mario Z coords (Float)
function mario_x() => float(0x273D28)
function mario_y() => float(0x273D2C)
function mario_z() => float(0x273D30)

// $273D60: Grounds Polygon Y coords (32-bit)
function ground_y() => dword(0x273D60)

// $273D78: Pointer to Mario Data (24-bit)
//          +0x7C | Pointer to the last object interacted
//          +0x80 | Pointer to the last object interacted
//          +0x84 | Pointer to the last object interacted
//          +0x88 | Pointer to the last object interacted

// $273D98: [16-bit] Stars Collected Amount
function stars() => word(0x273D98)

// $273D9A: [16-bit] Coins
function coins() => word(0x273D9A)

// $273D9D: [8-bit] Current HP
function health() => byte(0x273D9D)

// --- MAIN DATA -------------------------------------------------------------------

BTN_A = 15

KOOPATROL_BHV = 0x803fa96c
KOOPATROL_ALERTED = 0x02 // @ +0x17c

SOCCERBALL_BHV = 0x803fa200
SOCCERBALL_KICKED = 5 // @ +0xfc

MAP_C3_HIGHRISE = 0x09
MAP_B1_FORTRESS_A = 0x13
MAP_B1_FORTRESS_B = 0x21
MAP_B3_FINALE_A = 0x15
MAP_B3_FINALE_B = 0x1b
MAP_B3_FINALE_C = 0x22

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function collected_star(stage, star) => is_set(anim_collect_star()) && last_star_stage() == stage && last_star_num() == star

function guards_alerted() => any_of(range(0,OBJECT_COUNT-1), i => (
	// behavior script ptr for koopatrol
	obj_script_ptr(i) == KOOPATROL_BHV && 
	// previous state was not alerted
	prev(byte(object(i) + 0x17c)) != KOOPATROL_ALERTED &&
	// current state is alerted 
	byte(object(i) + 0x17c) == KOOPATROL_ALERTED
))

function soccerball_kicked(i) => (
	// behavior script ptr for soccer ball
	obj_script_ptr(i) == SOCCERBALL_BHV &&
	// cooldown on soccer ball was 0
	prev(dword(object(i) + 0xfc)) == 0 &&
	// cooldown is now 5
	dword(object(i) + 0xfc) == SOCCERBALL_KICKED
)

function dog_name_is(s) => (
	always_false() // may not be possible without ascii_string_equals() being able to handle BE
)

// --- RICH PRESENCE -------------------------------------------------------------------

ACTIONS = {
	0x01: "on the Title Screen",
	0x04: "in #2 Cumulus Correctional Center",
	0x05: "in #5 Peach Ruins",
	0x06: "watching the intro cutscene",
	0x07: "in #9 Forbidden Factory",
	0x08: "in #7 Awe-Inspiring Spires",
	0x09: "in #3 Hair-Raising High Rise",
	0x0a: "in #0 Upturned Deeps (somehow)",
	0x0b: "in #1 Maple Markindon",
	0x0c: "in #6 Swirling Circus",
	0x10: "selecting a level",
	0x11: "navigating Bowser's Rainbow Rings",
	0x13: "climbing Bowser's Flying Fortress",
	0x15: "challenging Bowser's Furious Finale",
	0x16: "in #8 Sakura Stronghold",
	0x17: "in #10 Desolate Reservoir",
	0x18: "in #4 Koopa Atoll",
	0x19: "watching the ending",
	0x1b: "fighting Bowser in Bowser's Furious Finale",
	0x1e: "fighting Bowser in Bowser's Rainbow Rings",
	0x21: "fighting Bowser in Bowser's Flying Fortress",
	0x22: "fighting Bowser in Bowser's Furious Finale",
}

rich_presence_conditional_display(map_id() >= 4,
	"Mario and {2} are {0} · ⭐ {1}/73",
	rich_presence_lookup("Action", map_id(), ACTIONS, fallback="playing with his dog"),
	rich_presence_number(stars()),
	// rich_presence_lookup("DogName", max_of(measured(1, when=dog_name_is("Goddard")), measured(0)), {1: "Goddard"}, "his dog")
	rich_presence_lookup("DogName", max_of(measured(1, when=(
		dword(dog_name() + 0) == 0x476f6464 && 
		dword(dog_name() + 4) == 0x61726400
	)), measured(0)), {1: "Goddard"}, "his dog")
)

rich_presence_display(
	"Title Screen"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// ######################################
// ##### C3 Hair-Raising High Rise ######
// ######################################

achievement(
	title="The Skyscraper Capers",
	description="Collect all 7 stars in Hair-Raising High Rise",
	points=5,
	trigger=(
		prev(sum_of(range(0,6), i => c3_stars(i))) == 6 &&
		measured(sum_of(range(0,6), i => c3_stars(i)) == 7, when=map_id() == MAP_C3_HIGHRISE)
	)
)

achievement(
	title="Goddard's Perfect Penalty Shootout",
	description="Complete Inside the Basement Sports Complex in Hair-Raising High Rise in five kicks or fewer",
	points=3,
	trigger=(
		// only show the challenge indicator in the sports complex
		map_id() == MAP_C3_HIGHRISE && submap_id() == 0x07 &&
		// trigger when earning the star in the sports complex
		trigger_when(prev(animation()) == 0x1904 && animation() == 0x1302 && last_star_stage() == 0x01 && last_star_num() == 5) &&
		// reset if the total number of kicks reaches 6
		disable_when(tally_of(range(0, OBJECT_COUNT-1), 6, i => soccerball_kicked(i)), until=map_id() != MAP_C3_HIGHRISE)
	)
)

achievement(
	title="Feet on the Ground, Head in the Clouds",
	description="Collect the 100-ish coin star in Hair-Raising High Rise without pressing A after going through the pipe",
	points=5,
	trigger=(
		// challenge begins when entering through the pipe (maybe make it when landing after pipe)
		once(map_id() == MAP_C3_HIGHRISE && prev(submap_id()) == 0x02 && submap_id() == 0x00) &&
		// trigger on collecting the 100-ish coin star
		trigger_when(collected_star(0x01, 7)) &&
		// reset if player leaves the map or submap
		never(map_id() != MAP_C3_HIGHRISE) && never(submap_id() != 0x00) &&
		// reset if the player is ever pressing A
		never(button(BTN_A) == 1)
	)
)

// ######################################
// #### B1 Bowser's Flying Fortress #####
// ######################################

achievement(
	title="Red Coins Around the Fortress",
	description="Collect the red coin star in Bowser's Flying Fortress",
	points=2,
	trigger=map_id() == MAP_B1_FORTRESS_A && is_set(b1_reds())
)

achievement(
	title="A Sneak to the Past",
	description="In Bowser's Flying Fortress, reach the statue garden without alerting any guards. Return to the area before the throne room to retry.",
	points=3,
	trigger=(
		once( // start of the tunnel
			map_id() == MAP_B1_FORTRESS_A &&
			mario_x() >=  4700.0 && mario_x() <=  5300.0 &&
			mario_y() >=  2950.0 && mario_y() <=  4000.0 &&
			mario_z() >= -6170.0 && mario_z() <= -4430.0
		) &&
		trigger_when( // end of tunnel (entering statue garden)
			mario_x() >= 4400.0 && mario_x() <= 4600.0 &&
			mario_y() >= 3230.0 && mario_y() <= 4100.0 &&
			mario_z() >= 5150.0 && mario_z() <= 6150.0
		) &&
		never(mario_z() < -6170.0) && // return to before the tunnel
		never(map_id() != MAP_B1_FORTRESS_A) &&
		never(guards_alerted())
	)
)

achievement(
	title="1080° SnowBowser",
	description="Defeat Bowser in Bowser's Flying Fortress to unlock World 2",
	type="progression",
	points=10,
	trigger=map_id() == MAP_B1_FORTRESS_B && is_set(bowser1_cleared())
)

// ######################################
// ##### B3 Bowser's Furious Finale #####
// ######################################

achievement(
	title="Twirling, Twirling, Twirling",
	description="In Bowser's Furious Finale, enter the warp box at the end of the Sakura Stronghold segment while Mario is spinning",
	points=3,
	trigger=map_id() == MAP_B3_FINALE_B && submap_id() == 0x04 && trigger_when(prev(animation()) == 0x08a4 && animation() == 0x130a)
)

achievement(
	title="Red Coins in the Doggiverse",
	description="Collect the red coin star in Bowser's Furious Finale",
	points=5,
	trigger=map_id() == MAP_B3_FINALE_B && is_set(b3_reds())
)

achievement(
	title="Bowser's Last Stand",
	description="Defeat Bowser in Bowser's Furious Finale and rescue Princess Peach",
	type="win_condition",
	points=25,
	trigger=map_id() == MAP_B3_FINALE_C && submap_id() == 0x01 && prev(animation()) == 0x1306 && animation() == 0x130a
)

// --- LEADERBOARDS -------------------------------------------------------------------
