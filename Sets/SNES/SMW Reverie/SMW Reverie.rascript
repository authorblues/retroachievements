// ~Hack~ Reverie
// #ID = 30906

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")

// --- MEMORY -------------------------------------------------------------------

// $0000D1: Player X Position [16 bit]
function player_x() => word(0x0000D1)

// $0000D3: Player Y Position [16 bit]
function player_y() => word(0x0000D3)

// $000100: Game State [8-bit]
//          --- 00 | Loading Nintendo Presents
//          --- 01 | Nintendo Presents
//          --- 02 | Fade to Title Screen
//          --- 03 | Load Title Screen
//          --- 04 | Prepare Title Screen
//          --- 05 | Fade in Title Screen
//          --- 06 | Circle Effect in Title Screen
//          --- 07 | Title Screen
//          --- 08 | File Select
//          --- 09 | File Deletion
//          --- 0A | Player Select
//          --- 0B | Fade to Overworld
//          --- 0C | Load Overworld
//          --- 0D | Fade in Overworld
//          --- 0E | Overworld
//          --- 0F | Fade to Level
//          --- 10 | Fade to Level 2
//          --- 11 | Load Level
//          --- 12 | Prepare Level
//          --- 13 | Fade in Level
//          --- 14 | In Level
//          --- 15 | Fade to Game Over / Time Up
//          --- 16 | Load Game Over / Time Up
//          --- 17 | Game Over / Time Up
//          --- 18 | Load Credits / Cutscene
//          --- 19 | Load Credits / Cutscene 2
//          --- 1A | Load Credits / Cutscene 3
//          --- 1B | Credits / Cutscene
//          --- 1C | Fade to Yoshi's House in Credits
//          --- 1D | Load Yoshi's House in Credits
//          --- 1E | Fade in Yoshi's House in Credits
//          --- 1F | Yoshi's House in Credits
//          --- 20 | Fade to Enemies in Credits
//          --- 21 | Fade to Enemies 2 in Credits
//          --- 22 | Fade to Enemies 3 in Credits
//          --- 23 | Fade to Enemies 4 in Credits
//          --- 24 | Fade in Enemies in Credits
//          --- 25 | Enemies in Credits
//          --- 26 | Fade to End Screen
//          --- 27 | Load End Screen
//          --- 28 | Fade in End Screen
//          --- 29 | End Screen
function game_state() => byte(0x000100)

// $00010A: Current File [8 bit]
//          00 = A
//          01 = B
//          02 = C
function current_file() => byte(0x00010A)

// $00010B: Current Map [16 bit]
//          Current Map [16 bit]
//          0x0001 = Origin D1
//          0x0002 = Treetops D1
//          0x0003 = Subterrane D1
//          0x0004 = Tower inside D1
//          0x0005 = Caldera D1
//          0x0006 = Lake D1
//          0x0007 = Precipice D1
//          0x0008 = Treetops treehouses D1
//          0x0009 = Treetops glade D1
//          0x000a = Tower outside D1
//          0x000b = Tower clock rooms D1
//          0x000c = Tower left tower D1
//          0x000d = Tower right tower D1
//          0x000e = dance hall D1
//          0x000f = above Precipice D1
//          0x0010 = "This realm will soon crumble"
//          0x0011 = Origin D2
//          0x0013 = Treetops D2
//          0x0014 = Subterrane D2
//          0x0015 = Tower inside D2
//          0x0016 = Caldera D2
//          0x0017 = Lake D2
//          0x0018 = Precipice D2
//          0x0019 = above Precipice D2
//          0x001a = Treetops treehouses D2
//          0x001b = Treetops inner grove D2
//          0x001c = Tower D2
//          0x001d = Tower clock rooms D2
//          0x001e = Tower left tower D2
//          0x001f = Tower right tower D2
//          0x0020 = dance hall D2
//          0x0021 = Moon below Subterrane D1
//          0x0022 = music box room Treetops D2
//          0x0023 = chest room Subterrane D2
//          0x0025 = clock room Tower D2
//          0x0026 = key room Caldera D2 (chest @ X < 0x200, scale @ X > 0x300)
//          0x0027 = creature statues Lake D2
//          0x0028 = atlas room Precipice D2
//          0x0029 = music box room Treetops D1
//          0x002a = chest room Subterrane D1
//          0x002b = clock room Tower D1
//          0x002c = key room Caldera D1
//          0x002d = creature statues Lake D1
//          0x002e = atlas room Precipice D1
//          0x002f = Genesis center room D3
//          0x0030 = Origin D4
//          0x0031 = Treetops D4
//          0x0032 = Subterrane D4
//          0x0033 = Tower D4
//          0x0034 = Caldera D4
//          0x0035 = Lake D4
//          0x0036 = Precipice D4
//          0x0037 = Tower outside D4
//          0x0038 = Tower side room D4
//          0x0041 = Credits 1
//          0x0042 = Credits 2
//          0x0043 = Credits 3
//          0x0044 = Credits 4
//          0x0045 = Credits 5
//          0x0046 = Credits 6
//          0x0047 = Credits 7
//          0x0050 = Genesis D3
//          0x0051 = Swamp D3
//          0x0052 = Grotto D3
//          0x0053 = Ruins D3
//          0x0054 = Fissure D3
//          0x0055 = Cenote D3
//          0x0056 = Welkin D3
//          0x0057 = dance hall Cenote D3
//          0x0058 = grid treehouse Swamp D3
//          0x0059 = clouds below Welkin D3
//          0x0060 = Credits 1
//          0x0061 = Credits 2
//          0x0062 = Credits 3
//          0x0063 = Credits 4
//          0x0064 = Credits 5
//          0x0065 = Credits 6
//          0x0066 = Credits 7
//          0x0105 = vestibule
function current_map() => word(0x00010B)

// $000F3A: Loop 1 Frames Remaining [8 bit]
// $000F3B: Loop 1 Seconds Remaining [8 bit]
// $000F3C: Loop 1 Minutes Remaining [8 bit]
function time_00_00_XX_L1() => byte(0x000F3A)
function time_00_XX_00_L1() => byte(0x000F3B)
function time_XX_00_00_L1() => byte(0x000F3C)
function current_time() => time_00_00_XX_L1() + 60 * (time_00_XX_00_L1() + 60 * time_XX_00_00_L1())

// $0013BF: Level Number [8 bit]
//          for message purposes
//          
//          0x01,1 = Galoomba mathematician Treetops D1
//          0x01,2 = Galoomba number the gaps as you fall Treetops D2
//          0x02,1 = Swooper a dormant being Subterrane D1
//          0x02,2 = Swooper hanging four Subterrane D2
//          0x03,1 = Boo treetops vine puzzle Tower D1
//          0x03,2 = Boo overhead dancers Tower D2
//          0x04,1 = Blarggh shoulder work Caldera D1
//          0x04,2 = Blarggh open the closed door Caldera D2
//          0x05,1 = Rip van Fish six doors Lake D1
//          0x05,2 = Rip van Fish left thrice, right twice Lake D2
//          0x06,1 = Monty Mole performed a certain way Precipice D1
//          0x06,2 = Monty Mole gather the hues
//          0x07,1 = Starman show me their meaning
//          0x12,1 = Boo!
//          0x26,2 = essence of a land is its center Treetops D2
//          0x28,1 = (scroll) scan the land as a clock would
//          0x30,1 through 0x32,2 = essence location scrolls
function message_level() => byte(0x0013BF)

// $001426: Message Box Trigger [8 bit]
//          00 = none
//          01 = message 1
//          02 = message 2
function message_box_trigger() => byte(0x001426)

// $001602: Sprite Metadata [12 bytes]
function sprite_metadata(i) => byte(0x001602 + i)

// $001696: Cutscene Flag [8 bit]
function cutscene_flag() => byte(0x001696)

// $01AB10: Custom Sprite Check [12 bytes]
//          bit3 = is custom
function is_custom_sprite(i) => bit3(0x01AB10 + i)

// $01AB9E: Sprite ID for custom sprites [12 bytes]
function sprite_id(i) => byte(0x01AB9E + i)

// $01B900: Reverie File Seed [16 bit]
function reverie_file_seed() => word(0x01B900)

// $01B902: Glyphs of Origin [6 bytes]
//          earth, void, time, fire, sea, sky
function glyphs_of_origin(elt) => byte(0x01B902+elt)

// $01B908: Star Status [8 bit]
//          00 = asleep
//          01 = awake
function star_status() => byte(0x01B908)

// $01B909: Moon Status [8 bit]
//          00 = asleep
//          01 = awake
//          02 = post-game
function moon_status() => byte(0x01B909)

// $01B90A: Moon Essences Solved [8 bit]
//          bit0 | Earth essence
//          bit1 | Void essence
//          bit2 | Time essence
//          bit3 | Fire essence
//          bit4 | Sea essence
//          bit5 | Sky essence
function moon_essence_solved(elt) => bit(elt, 0x01B90A)
function moon_essence_count() => bitcount(0x01B90A)

// $01B90B: Moon Orbs Collected [8 bit]
//          bit0 | Earth orb
//          bit1 | Void orb
//          bit2 | Time orb
//          bit3 | Fire orb
//          bit4 | Sea orb
//          bit5 | Sky orb
function moon_orb_collected(elt) => bit(elt, 0x01B90B)

// $01B90C: Item Box Contents [8 bit]
//          0x00 = empty
//          0x2f = springboard
//          0x80 = key
function item_box_contents() => byte(0x01B90C)

// $01B90D: Item Box Occupied [8 bit]
//          0 = Empty
//          1 = Has Item
function item_box_occupied() => byte(0x01B90D)

// $01B910: Chest Opened [8 bit]
//          bit0 | Earth chest
//          bit1 | Void chest
//          bit2 | Time chest
//          bit3 | Fire chest
//          bit4 | Sea chest
//          bit5 | Sky chest
function chest_opened(elt) => bit(elt, 0x01B910)

// $01B911: Remains [8 bit]
//          bit0 | Bow Before Darkness
//          bit1 | Reveal Swamp
//          bit2 | Talk Lake
//          bit3 | Anew in Caldera
//          bit4 | Do nothing in Precipice
//          bit5 | Read action scriptures
//          bit7 | Essence of Death (room 0x21)
function remains_bow_darkness() => bit0(0x01B911)
function remains_meaning_of_birth() => bit4(0x01B911)
function remains_essence_of_death() => bit7(0x01B911)

// $01B912: Chest Unlocked [8 bit]
//          bit0 | Earth chest
//          bit1 | Void chest
//          bit2 | Time chest
//          bit3 | Fire chest
//          bit4 | Sea chest
//          bit5 | Sky chest
function chest_unlocked(elt) => bit(elt, 0x01B912)

// $01B914: Subterrane Pipe Switch States [4 bytes]
//          +0 | room=0x10, correct=3
//          +1 | room=0x01, correct=3
//          +2 | room=0x06, correct=2
//          +3 | room=0x04, correct=1
//          
//          0 = ╩
//          1 = ╣
//          2 = ╦
//          3 = ╠
function subterrane_pipe_switch_states(i) => byte(0x01B914+i)

// $01B918: Current Screen [8 bit]
//          counts from 0 in row-major order
//          intro room = 0xFF
function current_screen() => byte(0x01B918)

// $01B919: Music Box Seed [8 bit]
function music_box_seed() => byte(0x01B919)

// $01B91A: Music Box Sequence [8 bit]
function music_box_sequence() => byte(0x01B91A)

// $01B91B: Music Box Index [8 bit]
function music_box_index() => byte(0x01B91B)

// $01B91C: Music Box Buffer [4 bytes]
function music_box_buffer() => dword(0x01B91C)

// $01B921: Puzzle Status [8 bit]
//          bit0 | Music Box Puzzle in Treetops (for key)
//          bit1 | Pipe Puzzle in Subterrane (flood Caldera)
//          bit2 | Clock Puzzle in Tower (for p-switch)
//          bit3 | Animal Blocks in Lake (unlock dance hall)
//          bit4 | Vine dance in Treetops
//          bit5 | Glyphs of Origin dance puzzle to wake star
function music_box() => bit0(0x01B921)
function pipe_puzzle() => bit1(0x01B921)
function tower_clock() => bit2(0x01B921)
function lake_animals() => bit3(0x01B921)
function treetops_vine() => bit4(0x01B921)
function origin_dance() => bit5(0x01B921)

// $01B922: Clock Switches [4 bytes]
//          from left to right
CLOCK_SWITCHES = 0x01B922

// $01B926: Animal Blocks [4 bytes]
//          +0 | Sea block
//          +1 | Void block
//          +2 | Fire block
//          +3 | Sky block
ANIMAL_BLOCKS = 0x01B926

// $01B92A: Tower Door Status [8 bit]
//          0 = Locked
//          1 = Unlocked
function tower_door_status() => byte(0x01B92A)

// $01B92B: Riddle Status - Second Dream [8 bit]
//          bit0 | Earth riddle
//          bit1 | Void riddle
//          bit2 | Time riddle
//          bit3 | Fire riddle
//          bit4 | Sea riddle
//          bit5 | Sky riddle - hanging four
function riddle_status(elt) => bit(elt, 0x01B92B)

// $01B92E: World Status [8 bit]
//          00 = First Dream
//          01 = Second Dream
//          02 = Third Dream
//          03 = Collapsed Dream
function world_status() => byte(0x01B92E)

// $01B92F: Dark Star Status [8 bit]
//          0 = asleep
//          1 = awake
function dark_star_status() => byte(0x01B92F)

// $01B930: Truth Status [8 bit]
//          bit0 | Genesis climb
//          bit1 | Swamp song
//          bit2 | Swamp door
//          bit3 | Grotto rope
//          bit4 | Ruins block
//          bit5 | Cenote fish puzzle
//          bit6 | Welkin ancient names
//          bit7 | Dark Star's name
function genesis_climb() => bit0(0x01B930)
function swamp_song() => bit1(0x01B930)
function swamp_door() => bit2(0x01B930)
function grotto_rope() => bit3(0x01B930)
function ruins_block() => bit4(0x01B930)
function cenote_fish() => bit5(0x01B930)
function welkin_ancient_names() => bit6(0x01B930)
function dark_star_name() => bit7(0x01B930)

// $01B931: Fissure Door Sequence [8 bit]
function fissure_door_sequence() => byte(0x01B931)

// $01B932: Ancestor Times [6 bytes]
//          +0 | Earth ancestor
//          +1 | Void ancestor
//          +2 | Time ancestor
//          +3 | Fire ancestor
//          +4 | Sea ancestor
//          +5 | Sky ancestor
function ancestor_times(elt) => byte(0x01B932 + elt)

// $01B938: Ruins Clock State [8 bit]
function ruins_clock_state() => byte(0x01B938)

// --- MAIN DATA -------------------------------------------------------------------
ELT_EARTH = 0
ELT_VOID = 1
ELT_TIME = 2
ELT_FIRE = 3
ELT_SEA = 4
ELT_SKY = 5
ALL_ELEMENTS = range(0, 5)

MAP_D1_ORIGIN = 0x0001
MAP_D1_TREETOPS = 0x0002
MAP_D1_SUBTERRANE = 0x0003
MAP_D1_TOWER = 0x0004
MAP_D1_CALDERA = 0x0005
MAP_D1_LAKE = 0x00006
MAP_D1_PRECIPICE = 0x0007

MAP_D1_TREETOPS_TREEHOUSE = 0x0008
MAP_D1_TREETOPS_GROVE = 0x0009
MAP_D1_TOWER_OUTSIDE = 0x000a
MAP_D1_TOWER_CLOCK_ROOM = 0x000b
MAP_D1_TOWER_LEFT = 0x000c
MAP_D1_TOWER_RIGHT = 0x000d
MAP_D1_LAKE_DANCEHALL = 0x000e
MAP_D1_PRECIPICE_TOP = 0x000f

MAP_D1_REALM_CRUMBLE = 0x0010

MAP_D1_TREETOPS_MUSIC = 0x0029
MAP_D1_SUBTERRANE_CHEST = 0x002a
MAP_D1_TOWER_CLOCK = 0x002b
MAP_D1_CALDERA_KEYSCALES = 0x002c
MAP_D1_LAKE_CREATURES = 0x002d
MAP_D1_PRECIPICE_ATLAS = 0x002e

MAP_D2_ORIGIN = 0x0011
MAP_D2_TREETOPS = 0x0013
MAP_D2_SUBTERRANE = 0x0014
MAP_D2_TOWER = 0x0015
MAP_D2_CALDERA = 0x0016
MAP_D2_LAKE = 0x0017
MAP_D2_PRECIPICE = 0x0018

MAP_D2_PRECIPICE_TOP = 0x0019
MAP_D2_TREETOPS_TREEHOUSE = 0x001a
MAP_D2_TREETOPS_GROVE = 0x001b
MAP_D2_TOWER_OUTSIDE = 0x001c
MAP_D2_TOWER_CLOCK_ROOM = 0x001d
MAP_D2_TOWER_LEFT = 0x001e
MAP_D2_TOWER_RIGHT = 0x001f
MAP_D2_LAKE_DANCEHALL = 0x0020

MAP_D2_SUBTERRANE_LOWER = 0x0021

MAP_D2_TREETOPS_MUSIC = 0x0022
MAP_D2_SUBTERRANE_CHEST = 0x0023
MAP_D2_TOWER_CLOCK = 0x0025
MAP_D2_CALDERA_KEYSCALES = 0x0026
MAP_D2_LAKE_CREATURES = 0x0027
MAP_D2_PRECIPICE_ATLAS = 0x0028

MAP_D3_GENESIS = 0x0050
MAP_D3_SWAMP = 0x0051
MAP_D3_GROTTO = 0x0052
MAP_D3_RUINS = 0x0053
MAP_D3_FISSURE = 0x0054
MAP_D3_CENOTE = 0x0055
MAP_D3_WELKIN = 0x0056

MAP_D3_GENESIS_CENTER = 0x002f
MAP_D3_CENOTE_DANCEHALL = 0x0057
MAP_D3_SWAMP_TREEHOUSE = 0x0058
MAP_D3_WELKIN_CLOUDS = 0x0059
MAP_D3_TOMB = 0x0070

MAP_D4_ORIGIN = 0x0030
MAP_D4_TREETOPS = 0x0031
MAP_D4_SUBTERRANE = 0x0032
MAP_D4_TOWER = 0x0033
MAP_D4_CALDERA = 0x0034
MAP_D4_LAKE = 0x0035
MAP_D4_PRECIPICE = 0x0036

MAP_D4_TOWER_OUTSIDE = 0x0037
MAP_D4_TOWER_SIDE_ROOM = 0x0038

MAP_VESTIBULE = 0x0105

MAP_CREDITS_1A = 0x0041
MAP_CREDITS_1B = 0x0060

DREAM_1 = 0
DREAM_2 = 1
DREAM_3 = 2
DREAM_COLLAPSED = 3

DREAMERS = [
	{ "level": 0x01, "msg": 2 },
	{ "level": 0x02, "msg": 2 },
	{ "level": 0x03, "msg": 2 },
	{ "level": 0x04, "msg": 2 },
	{ "level": 0x05, "msg": 2 },
	{ "level": 0x06, "msg": 2 },
]

FAREWELL = [
	{ "level": 0x42, "msg": 1 },
	{ "level": 0x42, "msg": 2 },
	{ "level": 0x44, "msg": 2 },
]

WARPS_3to2 = [
	[MAP_D3_SWAMP, MAP_D2_TREETOPS],
	[MAP_D3_CENOTE, MAP_D2_LAKE],
	[MAP_D3_FISSURE, MAP_D2_CALDERA],
	[MAP_D3_RUINS, MAP_D2_TOWER],
	[MAP_D3_GROTTO, MAP_D2_SUBTERRANE],
	[MAP_D3_WELKIN, MAP_D2_PRECIPICE],
]

RETROACHIEVEMENTS = [17, 5, 19, 17, 15, 0, 2, 7, 10, 5, 21, 5, 12, 5, 13, 19, 18]
SPELLING_COOLDOWN = 6 * 60

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => game_state() > 0x0B

function check_location(dream, map, screen) => (
	in_game() && 
	world_status() == dream && 
	current_map() == map && 
	current_screen() == screen
)

function collect_moon_orb(elt) => chest_unlocked(elt) == 1 && chest_opened(elt) == 1 && is_set(moon_orb_collected(elt))

function is_message(a, b) => prev(message_box_trigger()) == 0 && message_level() == a && message_box_trigger() == b

function in_credits() => (
	(current_map() >= MAP_CREDITS_1A && current_map() < MAP_CREDITS_1A + 7) ||
	(current_map() >= MAP_CREDITS_1B && current_map() < MAP_CREDITS_1B + 7) ||
	current_map() == MAP_D1_REALM_CRUMBLE
)

function spell_sequence(ndx, letters)
{
	trigger = always_true()
	for i in range(0, length(letters)-1)
		trigger = once(trigger && sprite_metadata(ndx) == letters[i])
	return trigger_when(trigger)
}

function dream_collapse() => check_location(DREAM_COLLAPSED, MAP_D2_SUBTERRANE_LOWER, 0xff) && prev(world_status()) == DREAM_1

// --- RICH PRESENCE -------------------------------------------------------------------

Locations = {
	MAP_D1_ORIGIN: "Origin",
	MAP_D1_TREETOPS: "Treetops",
	MAP_D1_SUBTERRANE: "Subterrane",
	MAP_D1_TOWER: "Tower",
	MAP_D1_CALDERA: "Caldera",
	MAP_D1_LAKE: "Lake",
	MAP_D1_PRECIPICE: "Precipice",

	MAP_D1_TREETOPS_TREEHOUSE: "Treetops",
	MAP_D1_TREETOPS_GROVE: "Treetops",
	MAP_D1_TOWER_OUTSIDE: "Tower",
	MAP_D1_TOWER_CLOCK_ROOM: "Tower",
	MAP_D1_TOWER_LEFT: "Tower",
	MAP_D1_TOWER_RIGHT: "Tower",
	MAP_D1_LAKE_DANCEHALL: "Lake",
	MAP_D1_PRECIPICE_TOP: "Precipice",

	MAP_D1_TREETOPS_MUSIC: "Treetops",
	MAP_D1_SUBTERRANE_CHEST: "Subterrane",
	MAP_D1_TOWER_CLOCK: "Tower",
	MAP_D1_CALDERA_KEYSCALES: "Caldera",
	MAP_D1_LAKE_CREATURES: "Lake",
	MAP_D1_PRECIPICE_ATLAS: "Precipice",

	MAP_D2_ORIGIN: "Origin",
	MAP_D2_TREETOPS: "Treetops",
	MAP_D2_SUBTERRANE: "Subterrane",
	MAP_D2_TOWER: "Tower",
	MAP_D2_CALDERA: "Caldera",
	MAP_D2_LAKE: "Lake",
	MAP_D2_PRECIPICE: "Precipice",

	MAP_D2_PRECIPICE_TOP: "Precipice",
	MAP_D2_TREETOPS_TREEHOUSE: "Treetops",
	MAP_D2_TREETOPS_GROVE: "Treetops",
	MAP_D2_TOWER_OUTSIDE: "Tower",
	MAP_D2_TOWER_CLOCK_ROOM: "Tower",
	MAP_D2_TOWER_LEFT: "Tower",
	MAP_D2_TOWER_RIGHT: "Tower",
	MAP_D2_LAKE_DANCEHALL: "Lake",

	MAP_D2_SUBTERRANE_LOWER: "Subterrane",
	
	MAP_D2_TREETOPS_MUSIC: "Treetops",
	MAP_D2_SUBTERRANE_CHEST: "Subterrane",
	MAP_D2_TOWER_CLOCK: "Tower",
	MAP_D2_CALDERA_KEYSCALES: "Caldera",
	MAP_D2_LAKE_CREATURES: "Lake",
	MAP_D2_PRECIPICE_ATLAS: "Precipice",

	MAP_D3_GENESIS: "Genesis",
	MAP_D3_SWAMP: "Swamp",
	MAP_D3_GROTTO: "Grotto",
	MAP_D3_RUINS: "Ruins",
	MAP_D3_FISSURE: "Fissure",
	MAP_D3_CENOTE: "Cenote",
	MAP_D3_WELKIN: "Welkin",

	MAP_D3_GENESIS_CENTER: "Genesis",
	MAP_D3_CENOTE_DANCEHALL: "Cenote",
	MAP_D3_SWAMP_TREEHOUSE: "Swamp",
	MAP_D3_WELKIN_CLOUDS: "Welkin",
	MAP_D3_TOMB: "Tomb",

	MAP_D4_ORIGIN: "Origin",
	MAP_D4_TREETOPS: "Treetops",
	MAP_D4_SUBTERRANE: "Subterrane",
	MAP_D4_TOWER: "Tower",
	MAP_D4_CALDERA: "Caldera",
	MAP_D4_LAKE: "Lake",
	MAP_D4_PRECIPICE: "Precipice",

	MAP_D4_TOWER_OUTSIDE: "Tower",
	MAP_D4_TOWER_SIDE_ROOM: "Tower",

	MAP_VESTIBULE: "Vestibule",
}

PIPE_SWITCHES = {0: "╩", 1: "╣", 2: "╦", 3: "╠"}

function rp_wake(x) => rich_presence_lookup("Dream", x, {0: "💤"}, fallback="")
function rp_number(x) => rich_presence_value("_Number", x, "VALUE")
rp_location = rich_presence_lookup("Location", current_map(), Locations, fallback="Lost in a Dream")
rp_time = rich_presence_value("_Frames", current_time(), "FRAMES")

BASE_DISPLAY = "Playing Reverie 🌛💤"
rich_presence_conditional_display(!in_game(), BASE_DISPLAY)
rich_presence_conditional_display(in_credits(), BASE_DISPLAY)

rich_presence_conditional_display(world_status() == DREAM_1,
	"⭐{0} | ⏱️{2} | {1}",
	rp_wake(star_status()),
	rp_location,
	rp_time
)

rich_presence_conditional_display(world_status() == DREAM_2,
	"🌛{0} | {1}",
	rp_wake(moon_status()),
	rp_location
)

rich_presence_conditional_display(world_status() == DREAM_3,
	"🌠{0} | {1}",
	rp_wake(dark_star_status()),
	rp_location
)

rich_presence_conditional_display(world_status() == DREAM_COLLAPSED,
	"🌃 | {0}",
	rp_location
)

rich_presence_display(BASE_DISPLAY)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- [ DREAM_1 ]
achievement(
	title="Reading is Fundamental!",
	description="Press X to interact with the world around you",
	points=1,
	trigger=in_game() && prev(message_box_trigger()) == 0 && message_box_trigger() > 0
)

achievement(
	title="Aid Conveyed in the Glade",
	description="Earn a tool in Treetops by solving the mystery of the noteblocks",
	points=5,
	trigger=check_location(DREAM_1, MAP_D1_TREETOPS_GROVE, 0xff) && is_set(music_box())
)

achievement(
	title="Rites of Spring",
	description="Usher in fresh growth in Treetops to reach new heights",
	type="progression",
	points=3,
	trigger=check_location(DREAM_1, MAP_D1_TREETOPS, 0x02) && is_set(treetops_vine())
)

achievement(
	title="Better Hire a Plumber",
	description="Fix the pipes in Subterrane",
	type="progression",
	points=5,
	trigger=check_location(DREAM_1, MAP_D1_SUBTERRANE, 0x0c) && is_set(pipe_puzzle())
)

achievement(
	title="A Bit of Shoulder Work",
	description="With a little effort, it shouldn't be too difficult to move things around",
	points=3,
	trigger=in_game() && prev(item_box_occupied()) == 0 && item_box_occupied() == 1 && item_box_contents() != 0
)

achievement(
	title="It's Probably Some Kind of Hunting Lodge for Rich Weirdos",
	description="Before waking the star, open the Tower's front door",
	type="missable",
	points=5,
	trigger=check_location(DREAM_1, MAP_D1_TOWER_OUTSIDE, 0x09) && is_set(tower_door_status())
)

achievement(
	title="Unlock the Mental Block in the Tick-Tock Tower",
	description="Solve the mystery of the Tower clocks for a helpful tool",
	type="progression",
	points=5,
	trigger=check_location(DREAM_1, MAP_D1_TOWER_RIGHT, 0xff) && is_set(tower_clock())
)

achievement(
	title="Dance of the Animals",
	description="Reveal the secret room in Lake by solving the mystery of the animals",
	points=5,
	trigger=check_location(DREAM_1, MAP_D1_LAKE, 0x07) && is_set(lake_animals())
)

achievement(
	title="Born to Sleep, Forced to Wake Up",
	description="Wake the star before time runs out, Luigi",
	type="progression",
	points=25,
	trigger=check_location(DREAM_1, MAP_D1_PRECIPICE_TOP, 0xff) && is_set(star_status())
)

achievement(
	title="Ma'at's Judgement",
	description="Closed for maintenance: Somebody broke the digital display again. Signed, Management",
	points=3,
	trigger=(
		in_game() &&
		
		any_of(range(0, 11), (i) =>
		(
			// on the previous frame, it was a custom scale readout with a value of 24 or less
			prev(is_custom_sprite(i)) == 1 && prev(sprite_id(i)) == 0x1c && prev(sprite_metadata(i)) <= 24 && 

			// on the current frame, it is a custom scale readout with a value greater than 24
			is_custom_sprite(i) == 1 && sprite_id(i) == 0x1c && sprite_metadata(i) > 24
		))
	)
)

// --- [ DREAM_2 ]
achievement(
	title="Somniloquism",
	description="In the second dream, listen to the words of all six dreamers in one session",
	points=5,
	trigger=(
		// measure the number of dreamers spoken to in the second dream
		measured(tally_of(DREAMERS, length(DREAMERS), (x) => once(is_message(x["level"], x["msg"])))) &&
		
		// reset on the title screen
		never(!in_game())
	)
)

achievement(
	title="And Stillness to Follow",
	description="Solve the riddle of the fire dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_TREETOPS, 0x13) ||
			check_location(DREAM_2, MAP_D2_TREETOPS, 0x13)
		) && 
		is_set(riddle_status(ELT_EARTH))
	)
)

achievement(
	title="Gather the Hues",
	description="Solve the riddle of the sky dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_SUBTERRANE, 0x03) ||
			check_location(DREAM_2, MAP_D2_SUBTERRANE, 0x03)
		) &&
		is_set(riddle_status(ELT_VOID))
	)
)

achievement(
	title="The Small and Ignored",
	description="Solve the riddle of the sea dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_TOWER_LEFT, 0xff) ||
			check_location(DREAM_2, MAP_D2_TOWER_LEFT, 0xff)
		) &&
		is_set(riddle_status(ELT_TIME))
	)
)

achievement(
	title="Number the Gaps",
	description="Solve the riddle of the earth dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_CALDERA, 0x02) ||
			check_location(DREAM_2, MAP_D2_CALDERA, 0x02)
		) &&
		is_set(riddle_status(ELT_FIRE))
	)
)

achievement(
	title="The Overhead Dancers",
	description="Solve the riddle of the time dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_LAKE, 0x03) ||
			check_location(DREAM_2, MAP_D2_LAKE, 0x03)
		) &&
		is_set(riddle_status(ELT_SEA))
	)
)

achievement(
	title="The Hanging Four",
	description="Solve the riddle of the void dreamer",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_PRECIPICE, 0x06) ||
			check_location(DREAM_2, MAP_D2_PRECIPICE, 0x06)
		) &&
		is_set(riddle_status(ELT_SKY))
	)
)

achievement(
	title="Verdant Emerald",
	description="Unlock and collect the Terrene Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_TREETOPS_MUSIC, 0xff) ||
			check_location(DREAM_2, MAP_D2_TREETOPS_MUSIC, 0xff)
		) && collect_moon_orb(ELT_EARTH)
	)
)

achievement(
	title="Royal Amethyst",
	description="Unlock and collect the Abyssal Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_SUBTERRANE_CHEST, 0xff) ||
			check_location(DREAM_2, MAP_D2_SUBTERRANE_CHEST, 0xff)
		) && collect_moon_orb(ELT_VOID)
	)
)

achievement(
	title="Timeless Citrine",
	description="Unlock and collect the Temporal Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_TOWER_CLOCK, 0xff) ||
			check_location(DREAM_2, MAP_D2_TOWER_CLOCK, 0xff)
		) && collect_moon_orb(ELT_TIME)
	)
)

achievement(
	title="Warm Garnet",
	description="Unlock and collect the Scorched Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_CALDERA_KEYSCALES, 0xff) ||
			check_location(DREAM_2, MAP_D2_CALDERA_KEYSCALES, 0xff)
		) && collect_moon_orb(ELT_FIRE)
	)
)

achievement(
	title="Deep Sapphire",
	description="Unlock and collect the Oceanic Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_LAKE_CREATURES, 0xff) ||
			check_location(DREAM_2, MAP_D2_LAKE_CREATURES, 0xff)
		) && collect_moon_orb(ELT_SEA)
	)
)

achievement(
	title="Bright Topaz",
	description="Unlock and collect the Celestial Orb",
	type="progression",
	points=5,
	trigger=(
		(
			check_location(DREAM_1, MAP_D1_PRECIPICE_ATLAS, 0xff) ||
			check_location(DREAM_2, MAP_D2_PRECIPICE_ATLAS, 0xff)
		) && collect_moon_orb(ELT_SKY)
	)
)

achievement(
	title="The Essence of Sleep",
	description="Release all of the moon essences",
	type="progression",
	points=5,
	trigger=in_game() && measured(moon_essence_count() == 6) && prev(moon_essence_count()) == 5
)

achievement(
	title="And a New Day Will Dawn",
	description="Wake the moon to complete the cycle",
	type="win_condition",
	points=50,
	trigger=check_location(DREAM_2, MAP_D2_SUBTERRANE_LOWER, 0xff) && prev(moon_status()) == 0 && moon_status() == 1
)

// --- [ DREAM_3 ]
achievement(
	title="Back to the Beginning",
	description="Discover a dream in disarray",
	points=5,
	trigger=world_status() == DREAM_3 && prev(current_map()) == MAP_D2_ORIGIN && current_map() == MAP_D3_GENESIS
)

achievement(
	title="A Link to the Past",
	description="Return to the second dream from an inverted world",
	points=5,
	trigger=in_game() && world_status() == DREAM_3 && any_of(WARPS_3to2, (x) => prev(current_map()) == x[0] && current_map() == x[1])
)

achievement(
	title="Land of Confusion",
	description="Reveal a path to the heart of Genesis",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_GENESIS, 0x0e) && is_set(genesis_climb())
)

achievement(
	title="A Familiar Tune",
	description="Discover the ancient name of the earth in Swamp",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_SWAMP, 0x05) && is_set(swamp_song())
)

achievement(
	title="Stay Out! No Plumbers Allowed",
	description="Open the door to the lone treehouse in Swamp",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_SWAMP, 0x0c) && is_set(swamp_door())
)

achievement(
	title="Much Ado About His Darkness",
	description="Interpret the writings of the void in Grotto to find a new path",
	points=10,
	trigger=check_location(DREAM_3, MAP_D3_GROTTO, 0x07) && is_set(grotto_rope())
)

achievement(
	title="Rock Around the Clock",
	description="Take the time to remove the obstruction in Ruins to find a new path",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_RUINS, 0x0d) && is_set(ruins_block())
)

achievement(
	title="Hotel Luigi",
	description="Discover the ancient name of the sky in Fissure",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_FISSURE, 0x05) && is_message(0x4e, 0x01)
)

achievement(
	title="Fly Me To the Moon",
	description="Descend into the skies below Welkin",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_WELKIN, 0x0a) && is_set(welkin_ancient_names())
)

achievement(
	title="Swimming Upstream",
	description="Reveal a secret room in Cenote by solving the mystery of the fish",
	points=5,
	trigger=check_location(DREAM_3, MAP_D3_CENOTE, 0x07) && is_set(cenote_fish())
)

achievement(
	title="Getting an A+ in Reverie 301",
	description="Prove thou art literate by spelling RETROACHIEVEMENTS in the Cenote secret room. You have 60 seconds from when you enter the room. Leave the room to retry",
	points=5,
	trigger=(
		in_game() && 
		once(prev(current_map()) == MAP_D3_CENOTE && current_map() == MAP_D3_CENOTE_DANCEHALL) && 
		never(current_map() != MAP_D3_CENOTE_DANCEHALL) &&
		never(repeated(60 * 60, current_map() == MAP_D3_CENOTE_DANCEHALL)) &&
		
		// check all the sprite slots for the custom dance readout sprite from the dance hall
		any_of(range(0, 11), (i) => is_custom_sprite(i) == 1 && sprite_id(i) == 0x22 && spell_sequence(i, RETROACHIEVEMENTS))
	)
)

achievement(
	title="Curious Dreamwalker",
	description="Wake the dormant being in the skies below",
	points=50,
	trigger=(
		check_location(DREAM_3, MAP_D3_WELKIN_CLOUDS, 0xff) && 
		dark_star_name() == 1 && 
		prev(dark_star_status()) == 0 && dark_star_status() == 1
	)
)

achievement(
	title="Farewell, Traveller",
	description="Seek out the three celestial beings and read their words of farewell after waking them all",
	points=5,
	trigger=(
		// measure the number of dreamers spoken to in the second dream
		measured(tally_of(FAREWELL, length(FAREWELL), (x) => once(is_message(x["level"], x["msg"])))) &&
		
		// reset on the title screen
		never(!in_game())
	)
)

// --- [ POSTGAME DLC ]
achievement(
	title="The Search for the Ancestral Remnants",
	description="Begin following the clues of the ancestral remnants",
	points=2,
	trigger=check_location(DREAM_3, MAP_D3_RUINS, 0x10) && is_set(remains_bow_darkness())
)

achievement(
	title="What It Means to Be Birthed",
	description="Discover the ancestral remnants of Her Sacredness",
	points=5,
	trigger=check_location(DREAM_3, MAP_D2_PRECIPICE, 0x00) && is_set(remains_meaning_of_birth())
)

achievement(
	title="Does That Make This a La-Mulana?",
	description="Enter the Tomb",
	points=10,
	trigger=in_game() && world_status() == DREAM_3 && prev(current_map()) == MAP_D3_CENOTE_DANCEHALL && current_map() == MAP_D3_TOMB
)

achievement(
	title="Mine Own Essence",
	description="Awaken the true essence of death",
	points=25,
	trigger=check_location(DREAM_3, MAP_D3_TOMB, 0x21) && is_set(remains_essence_of_death())
)

// --- [ DREAM_COLLAPSED ]
achievement(
	title="A Dream Destined to Collapse",
	description="Disrupt the natural order and collapse the dream",
	points=25,
	trigger=dream_collapse()
)

achievement(
	title="A Dream Restored",
	description="Perform a sacred dance to restore the collapsed dream",
	points=10,
	trigger=in_game() && current_map() == MAP_D4_ORIGIN && prev(world_status()) == DREAM_COLLAPSED && world_status() == DREAM_1
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Collapsed Dream Speedrun",
	description="Reach the collapsed dream as fast as possible",

	start=dream_collapse(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(current_time()),
	format="FRAMES",
	lower_is_better=true
)