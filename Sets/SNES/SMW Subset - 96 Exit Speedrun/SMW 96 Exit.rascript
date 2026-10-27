// Super Mario World [Subset - Sub 90-Minute 96 Exit Speedrun]
// #ID = 34233

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

// --- MEMORY -------------------------------------------------------------------

// $0019: Current Player - Powerup [8bit]
//        --- 0x00 | Small
//        --- 0x01 | Big
//        --- 0x02 | Cape
//        --- 0x03 | Fire
function powerup() => byte(0x000019)

// $009E: Sprite IDs [12 bytes]
//        0x7c = Peach (after Bowser fight)
SPRITE_IDS = 0x00009E

// $0100: Game State [8 bit]
//        --- 0x00 | Loading Nintendo Presents
//        --- 0x01 | Nintendo Presents
//        --- 0x02 | Fade to Title Screen
//        --- 0x03 | Load Title Screen
//        --- 0x04 | Prepare Title Screen
//        --- 0x05 | Fade in Title Screen
//        --- 0x06 | Circle Effect in Title Screen
//        --- 0x07 | Title Screen
//        --- 0x08 | File Select
//        --- 0x09 | File Deletion
//        --- 0x0A | Player Select
//        --- 0x0B | Fade to Overworld
//        --- 0x0C | Load Overworld
//        --- 0x0D | Fade in Overworld
//        --- 0x0E | Overworld
//        --- 0x0F | Fade to Level
//        --- 0x10 | Fade to Level 2
//        --- 0x11 | Load Level
//        --- 0x12 | Prepare Level
//        --- 0x13 | Fade in Level
//        --- 0x14 | In Level
//        --- 0x15 | Fade to Game Over / Time Up
//        --- 0x16 | Load Game Over / Time Up
//        --- 0x17 | Game Over / Time Up
//        --- 0x18 | Load Credits / Cutscene
//        --- 0x19 | Load Credits / Cutscene 2
//        --- 0x1A | Load Credits / Cutscene 3
//        --- 0x1B | Credits / Cutscene
//        --- 0x1C | Fade to Yoshi's House in Credits
//        --- 0x1D | Load Yoshi's House in Credits
//        --- 0x1E | Fade in Yoshi's House in Credits
//        --- 0x1F | Yoshi's House in Credits
//        --- 0x20 | Fade to Enemies in Credits
//        --- 0x21 | Fade to Enemies 2 in Credits
//        --- 0x22 | Fade to Enemies 3 in Credits
//        --- 0x23 | Fade to Enemies 4 in Credits
//        --- 0x24 | Fade in Enemies in Credits
//        --- 0x25 | Enemies in Credits
//        --- 0x26 | Fade to End Screen
//        --- 0x27 | Load End Screen
//        --- 0x28 | Fade in End Screen
//        --- 0x29 | End Screen
function game_state() => byte(0x000100)

// $0DB4: Mario Lives [8 bit]
function lives() => byte(0x000DB4)

// $0DC1: Yoshi "Carried" State [8 bit]
//        0 = not riding
//        non-0 = "carried" (might not be riding in castle/house)
function yoshi_carried() => byte(0x000DC1)

// $0DC2: Current Player Reserve Box Item [8 bit]
//        0x00 = Empty
//        0x01 = Mushroom
//        0x02 = Fire Flower
//        0x03 = Star
//        0x04 = Cape Feather
//        0xd7 = Orb
function item_box() => byte(0x000DC2)

// $0DC3: Backup Frame Counter [32 bit]
//        freezes in-level, but otherwise copied directly from $F3A
function backup_frame_counter() => dword(0x000DC3)

// $0DD5: Level Exit ID [8bit]
//        0x01 = Normal Exit
//        0x02 = Secret Exit 1
//        0x03 = Secret Exit 2
//        0x04 = Secret Exit 3
//        0x80 = Start+Select / Death
//        0xe0 = Show Save Prompt
function exit_id() => byte(0x000DD5)

// $0F3A: Frame Counter [32 bit]
function frame_counter() => dword(0x000F3A)

// $187A: Riding Yoshi State [8 bit] (0 on overworld)
//        0 = not riding
//        1 = riding
//        2 = turning around
function yoshi_ride_state() => byte(0x00187A)

// $13BF: Level ID [8 bit]
//        0x00 = Intro Level
function level_id() => byte(0x0013BF)

// $13C7: Current Player Yoshi [8 bit]
//        0x00 = None
//        0x04 = Yellow Yoshi
//        0x06 = Blue Yoshi
//        0x08 = Red Yoshi
//        0x0A = Green Yoshi
function current_player_yoshi() => byte(0x0013C7)

// $1F02: Overworld Event Flags [8 bit]
//        --- Bit0 | Donut Plains 1 - Normal Exit
//        --- Bit1 | #1 Iggy's Castle - Normal Exit
//        --- Bit2 | Yoshi's Island 4 - Normal Exit
//        --- Bit3 | Yoshi's Island 3 - Normal Exit
//        --- Bit4 | Yoshi's Island 2 - Normal Exit
//        --- Bit5 | Yellow Switch Palace - Normal Exit
//        --- Bit6 | Yoshi's Island 1 - Normal Exit

// $1F03: Overworld Event Flags [8 bit]
//        --- Bit0 | #2 Morton's Castle - Normal Exit
//        --- Bit1 | Donut Plains 4 - Normal Exit
//        --- Bit2 | Donut Plains 3 - Normal Exit
//        --- Bit3 | Donut Ghost House - Secret Exit
//        --- Bit4 | Donut Ghost House - Normal Exit
//        --- Bit5 | Donut Plains 2 - Secret Exit
//        --- Bit6 | Donut Plains 2 - Normal Exit
//        --- Bit7 | Donut Plains 1 - Secret Exit

// $1F04: Overworld Event Flags [8 bit]
//        --- Bit0 | Vanilla Dome 2 - Normal Exit
//        --- Bit1 | Vanilla Dome 1 - Secret Exit
//        --- Bit2 | Vanilla Dome 1 - Normal Exit
//        --- Bit3 | Donut Secret 2 - Normal Exit
//        --- Bit4 | Donut Secret House - Secret Exit
//        --- Bit5 | Donut Secret House - Normal Exit
//        --- Bit6 | Donut Secret 1 - Secret Exit
//        --- Bit7 | Donut Secret 1 - Normal Exit

// $1F05: Overworld Event Flags [8 bit]
//        --- Bit0 | Vanilla Secret 2 - Normal Exit
//        --- Bit1 | Vanilla Secret 1 - Secret Exit
//        --- Bit2 | Vanilla Secret 1 - Normal Exit
//        --- Bit3 | #3 Lemmy's Castle - Normal Exit
//        --- Bit4 | Vanilla Dome 4 - Normal Exit
//        --- Bit5 | Vanilla Dome 3 - Normal Exit
//        --- Bit6 | Vanilla Ghost House - Normal Exit
//        --- Bit7 | Vanilla Dome 2 - Secret Exit

// $1F06: Overworld Event Flags [8 bit]
//        --- Bit0 | Cookie Mountain - Normal Exit
//        --- Bit1 | Cheese Bridge Area - Secret Exit
//        --- Bit2 | Cheese Bridge Area - Normal Exit
//        --- Bit3 | #4 Ludwig's Castle - Normal Exit
//        --- Bit4 | Butter Bridge 2 - Normal Exit
//        --- Bit5 | Butter Bridge 1 - Normal Exit
//        --- Bit6 | Vanilla Fortress - Normal Exit
//        --- Bit7 | Vanilla Secret 3 - Normal Exit

// $1F07: Overworld Event Flags [8 bit]
//        --- Bit0 | Forest of Illusion 3 - Secret Exit
//        --- Bit1 | Forest of Illusion 3 - Normal Exit
//        --- Bit2 | Forest of Illusion 2 - Secret Exit
//        --- Bit3 | Forest of Illusion 2 - Normal Exit
//        --- Bit4 | Forest of Illusion 1 - Secret Exit
//        --- Bit5 | Forest of Illusion 1 - Normal Exit
//        --- Bit6 | Red Switch Palace - Normal Exit
//        --- Bit7 | Green Switch Palace - Normal Exit

// $1F08: Overworld Event Flags [8 bit]
//        --- Bit0 | Blue Switch Palace - Normal Exit
//        --- Bit2 | Forest Fortress - Normal Exit
//        --- Bit3 | Forest Secret Area - Normal Exit
//        --- Bit4 | Forest of Illusion 4 - Secret Exit
//        --- Bit5 | Forest of Illusion 4 - Normal Exit
//        --- Bit6 | Forest Ghost House - Secret Exit
//        --- Bit7 | Forest Ghost House - Normal Exit

// $1F09: Overworld Event Flags [8 bit]
//        --- Bit0 | Valley of Bowser 4 - Secret Exit
//        --- Bit1 | Valley of Bowser 4 - Normal Exit
//        --- Bit2 | Valley of Bowser 3 - Normal Exit
//        --- Bit3 | Valley Ghost House - Secret Exit
//        --- Bit4 | Valley Ghost House - Normal Exit
//        --- Bit5 | Valley of Bowser 2 - Secret Exit
//        --- Bit6 | Valley of Bowser 2 - Normal Exit
//        --- Bit7 | Valley of Bowser 1 - Normal Exit

// $1F0A: Overworld Event Flags [8 bit]
//        --- Bit0 | Chocolate Island 2 - Secret Exit
//        --- Bit1 | Chocolate Island 2 - Normal Exit
//        --- Bit6 | Valley Fortress - Normal Exit
//        --- Bit7 | #7 Larry's Castle - Normal Exit

// $1F0B: Overworld Event Flags [8 bit]
//        --- Bit0 | Chocolate Secret - Normal Exit
//        --- Bit1 | Sunken Ghost Ship - Normal Exit
//        --- Bit2 | #6 Wendy's Castle - Normal Exit
//        --- Bit3 | Chocolate Island 5 - Normal Exit
//        --- Bit4 | Chocolate Island 4 - Normal Exit
//        --- Bit5 | Chocolate Fortress - Normal Exit
//        --- Bit6 | Chocolate Island 3 - Secret Exit
//        --- Bit7 | Chocolate Island 3 - Normal Exit

// $1F0C: Overworld Event Flags [8 bit]
//        --- Bit0 | Star World 3 - Normal Exit
//        --- Bit2 | Star World 2 - Secret Exit
//        --- Bit3 | Star World 2 - Normal Exit
//        --- Bit5 | Star World 1 - Secret Exit
//        --- Bit6 | Star World 1 - Normal Exit

// $1F0D: Overworld Event Flags [8 bit]
//        --- Bit1 | Star World 5 - Secret Exit
//        --- Bit2 | Star World 5 - Normal Exit
//        --- Bit4 | Star World 4 - Secret Exit
//        --- Bit5 | Star World 4 - Normal Exit
//        --- Bit7 | Star World 3 - Secret Exit

// $1F0E: Overworld Event Flags [8 bit]
//        --- Bit0 | Way Cool - Normal Exit
//        --- Bit1 | Tubular - Normal Exit
//        --- Bit2 | Gnarly - Normal Exit
//        --- Bit4 | Choco-Ghost House - Normal Exit
//        --- Bit5 | Chocolate Island 1 - Normal Exit
//        --- Bit6 | #5 Roy's Castle - Normal Exit
//        --- Bit7 | Soda Lake - Normal Exit

// $1F0F: Overworld Event Flags [8 bit]
//        --- Bit3 | Funky - Normal Exit
//        --- Bit4 | Outrageous - Normal Exit
//        --- Bit5 | Mondo - Normal Exit
//        --- Bit6 | Groovy - Normal Exit
//        --- Bit7 | Awesome - Normal Exit

// $1F2E: Exit Count [8 bit]
function exit_count() => byte(0x001F2E)

// --- MAIN DATA -------------------------------------------------------------------

STAGE_NAMES = {
	0x00: "the intro",
	0x01: "Vanilla Secret 2",
	0x02: "Vanilla Secret 3",
	0x03: "Top Secret Area",
	0x04: "Donut Ghost House",
	0x05: "Donut Plains 3",
	0x06: "Donut Plains 4",
	0x07: "#2 Morton's Castle",
	0x08: "Green Switch Palace",
	0x09: "Donut Plains 2",
	0x0A: "Donut Secret 1",
	0x0B: "Vanilla Fortress",
	0x0C: "Butter Bridge 1",
	0x0D: "Butter Bridge 2",
	0x0E: "#4 Ludwig's Castle",
	0x0F: "Cheese Bridge Area",
	0x10: "Cookie Mountain",
	0x11: "Soda Lake",
	0x13: "Donut Secret House",
	0x14: "Yellow Switch Palace",
	0x15: "Donut Plains 1",
	0x18: "Sunken Ghost Ship",
	0x1A: "#6 Wendy's Castle",
	0x1B: "Chocolate Fortress",
	0x1C: "Chocolate Island 5",
	0x1D: "Chocolate Island 4",
	0x1F: "Forest Fortress",
	0x20: "#5 Roy's Castle",
	0x21: "Choco-Ghost House",
	0x22: "Chocolate Island 1",
	0x23: "Chocolate Island 3",
	0x24: "Chocolate Island 2",
	0x25: "#1 Iggy's Castle",
	0x26: "Yoshi's Island 4",
	0x27: "Yoshi's Island 3",
	0x28: "Yoshi's House",
	0x29: "Yoshi's Island 1",
	0x2A: "Yoshi's Island 2",
	0x2B: "Vanilla Ghost House",
	0x2D: "Vanilla Secret 1",
	0x2E: "Vanilla Dome 3",
	0x2F: "Donut Secret 2",
	0x31: "Bowser Front Door",
	0x32: "Bowser Back Door",
	0x33: "Valley of Bowser 4",
	0x34: "#7 Larry's Castle",
	0x35: "Valley Fortress",
	0x37: "Valley of Bowser 3",
	0x38: "Valley Ghost House",
	0x39: "Valley of Bowser 2",
	0x3A: "Valley of Bowser 1",
	0x3B: "Chocolate Secret",
	0x3C: "Vanilla Dome 2",
	0x3D: "Vanilla Dome 4",
	0x3E: "Vanilla Dome 1",
	0x3F: "Red Switch Palace",
	0x40: "#3 Lemmy's Castle",
	0x41: "Forest Ghost House",
	0x42: "Forest of Illusion 1",
	0x43: "Forest of Illusion 4",
	0x44: "Forest of Illusion 2",
	0x45: "Blue Switch Palace",
	0x46: "Forest Secret Area",
	0x47: "Forest of Illusion 3",
	0x49: "Funky",
	0x4A: "Outrageous",
	0x4B: "Mondo",
	0x4C: "Groovy",
	0x4E: "Gnarly",
	0x4F: "Tubular",
	0x50: "Way Cool",
	0x51: "Awesome",
	0x54: "Star World 2",
	0x56: "Star World 3",
	0x58: "Star World 1",
	0x59: "Star World 4",
	0x5A: "Star World 5",
}

NORMAL_EXIT = 0x01
SECRET_EXIT = 0x02

// references:
// - SNES Super Mario World "all 96 exits" by bahamete, kaizoman666 & Masterjun in 1:14:37.63
//   - https://tasvideos.org/2307M
// - Super Mario World 96 exit TAS HUMAN THEORY IN 1:18:11.667 (RTA TIME) by Noise de Gole
//   - https://www.youtube.com/watch?v=UMiif8Zs63o

// J is 16 frames faster for every save box
// J is 196 frames faster for every switch palace
EXITS = [
	{ "addr": bit0(0x001F02), "stage": "Donut Plains 1", "exit": NORMAL_EXIT, "frames": 2639, },
	// bahamete et al. | [frames=2723] enter 18544, end 21267, NON-OPTIMAL because grabs yoshi
	// Noise de Gole | [frames=2639] enter 121120, end 123759

	{ "addr": bit1(0x001F02), "stage": "#1 Iggy's Castle", "exit": NORMAL_EXIT, "frames": 5184, },
	// bahamete et al. | [frames=5184] enter 8583, end 13767, RTA viable
	// Noise de Gole | [frames=5209] enter 9006, end 14215

	{ "addr": bit2(0x001F02), "stage": "Yoshi's Island 4", "exit": NORMAL_EXIT, "frames": 2131, },
	// bahamete et al. | [frames=2131] enter 6452, end 8583, RTA viable
	// Noise de Gole | [frames=2165] enter 6841, end 9006

	{ "addr": bit3(0x001F02), "stage": "Yoshi's Island 3", "exit": NORMAL_EXIT, "frames": 2748, },
	// bahamete et al. | enter 4141, UNUSABLE because non-RTA viable yoshi wings setup
	// Noise de Gole | [frames=2748] enter 4093, end 6841

	{ "addr": bit4(0x001F02), "stage": "Yoshi's Island 2", "exit": NORMAL_EXIT, "frames": 2625, },
	// bahamete et al. | enter 1458, UNUSABLE because yoshi swap for goal tape + collecting yoshi
	// Noise de Gole | [frames=2625] enter 1468, end 4093

	{ "addr": bit5(0x001F02), "stage": "Yellow Switch Palace", "exit": NORMAL_EXIT, "frames": 1908, },
	// bahamete et al. | [frames=1908] enter 111634, end 113542 (114395), RTA viable
	// Noise de Gole | [frames=1694] enter 118635, end 120329 (121120)

	{ "addr": bit6(0x001F02), "stage": "Yoshi's Island 1", "exit": NORMAL_EXIT, "frames": 2926, },
	// bahamete et al. | [frames=2887] enter 108747, end 111634, UNUSABLE because yoshi swap to eat goal tape at end
	// Noise de Gole | [frames=2926] enter 115709, end 118635

	{ "addr": bit0(0x001F03), "stage": "#2 Morton's Castle", "exit": NORMAL_EXIT, "frames": 5186, },
	// bahamete et al. | [frames=5085] enter 35317, end 40402, possible lower bound. non-RTA viable vertical room, but mostly cycle-locked
	// Noise de Gole | [frames=5186] enter 38301, end 43487

	{ "addr": bit1(0x001F03), "stage": "Donut Plains 4", "exit": NORMAL_EXIT, "frames": 2724, },
	// bahamete et al. | [frames=1537] enter 33780, end 35317, UNUSABLE because yoshi wings setup
	// Noise de Gole | [frames=2724] enter 35577, end 38301

	{ "addr": bit2(0x001F03), "stage": "Donut Plains 3", "exit": NORMAL_EXIT, "frames": 2539, },
	// bahamete et al. | [frames=2539] enter 31241, end 33780, RTA viable (better than optimal because of yoshi fly + platform running)
	// Noise de Gole | [frames=2545] enter 33032, end 35577

	{ "addr": bit3(0x001F03), "stage": "Donut Ghost House", "exit": SECRET_EXIT, "frames": 1881, },
	// bahamete et al. | [frames=1881] enter 117465, end 119346 (119551), RTA viable (*technically*, though a human would never go for this strat in a run)
	// Noise de Gole | [frames=2014] enter 19676, end 21690 (21824)

	{ "addr": bit4(0x001F03), "stage": "Donut Ghost House", "exit": NORMAL_EXIT, "frames": 2056, },
	// bahamete et al. | [frames=2056] enter 29185, end 31241, questionable for cape tech in second room, but a possible lower bound
	// Noise de Gole | [frames=2120] enter 134984, end 137104 (137361)

	{ "addr": bit5(0x001F03), "stage": "Donut Plains 2", "exit": SECRET_EXIT, "frames": 4369, },
	// bahamete et al. | [frames=4325] enter 21267, end 25592, UNUSABLE because yoshi clip to enter keyhole early
	// Noise de Gole | [frames=4369] enter 123759, end 128128

	{ "addr": bit6(0x001F03), "stage": "Donut Plains 2", "exit": NORMAL_EXIT, "frames": 5122, },
	// bahamete et al. | [frames=1646] enter 27539, end 29185, UNUSABLE because non-RTA viable yoshi wings setup
	// Noise de Gole | [frames=5122] enter 129862, end 134984

	{ "addr": bit7(0x001F03), "stage": "Donut Plains 1", "exit": SECRET_EXIT, "frames": 2116, },
	// bahamete et al. | [frames=2094] enter 13767, end 15861, RTA viable
	// Noise de Gole | [frames=2116] enter 14215, end 16331

	{ "addr": bit0(0x001F04), "stage": "Vanilla Dome 2", "exit": NORMAL_EXIT, "frames": 3133, },
	// bahamete et al. | [frames=2668] enter 44896, end 47564, UNUSABLE because cape slope clip to fly under the whole stage lol
	// Noise de Gole | [frames=3133] enter 48349, end 51482

	{ "addr": bit1(0x001F04), "stage": "Vanilla Dome 1", "exit": SECRET_EXIT, "frames": 1410, },
	// bahamete et al. | [frames=1410] enter 128147, end 129557, RTA viable
	// Noise de Gole | [frames=1418] enter 137361, end 138779 <-- rbt

	{ "addr": bit2(0x001F04), "stage": "Vanilla Dome 1", "exit": NORMAL_EXIT, "frames": 1456, },
	// bahamete et al. | [frames=1290] enter 40402, end 41692, RTA viable (technically, but not human viable)
	// Noise de Gole | [frames=1456] enter 43487, end 44943

	{ "addr": bit3(0x001F04), "stage": "Donut Secret 2", "exit": NORMAL_EXIT, "frames": 2097, },
	// bahamete et al. | [frames=2043] enter 125635, end 127678 (128147), UNUSABLE because yoshi swap to eat goal tape
	// Noise de Gole | [frames=2097] enter 30723, end 32820 (33032)

	{ "addr": bit4(0x001F04), "stage": "Donut Secret House", "exit": SECRET_EXIT, "frames": 3972, },
	// bahamete et al. | [frames=3578] enter 119551, end 123129 (123171), possible lower bound, not RTA-viable
	// Noise de Gole | [frames=3972] enter 24438, end 28410

	{ "addr": bit5(0x001F04), "stage": "Donut Secret House", "exit": NORMAL_EXIT, "frames": 2406, },
	// bahamete et al. | [frames=2327] enter 123171, end 125498 (125635), RTA viable (technically)
	// Noise de Gole | [frames=2406] enter 28181, end 30587 (30723)

	{ "addr": bit6(0x001F04), "stage": "Donut Secret 1", "exit": SECRET_EXIT, "frames": 2555, },
	// bahamete et al. | [frames=2555] enter 15861, end 18416, RTA viable
	// Noise de Gole | [frames=2614] enter 21824, end 24438

	{ "addr": bit7(0x001F04), "stage": "Donut Secret 1", "exit": NORMAL_EXIT, "frames": 3345, },
	// bahamete et al. | [frames=3070] enter 114395, end 117465, UNUSABLE because spawns yoshi wings from key block
	// Noise de Gole | [frames=3345] enter 16331, end 19676

	{ "addr": bit0(0x001F05), "stage": "Vanilla Secret 2", "exit": NORMAL_EXIT, "frames": 2520, },
	// bahamete et al. | [frames=2573] enter 133321, end 135894, RTA viable (+32f for fire flower grab)
	// Noise de Gole | [frames=2520] enter 142703, end 145223

	{ "addr": bit1(0x001F05), "stage": "Vanilla Secret 1", "exit": SECRET_EXIT, "frames": 1739, },
	// bahamete et al. | [frames=1761] enter 129557, end 131318 (131379), RTA viable
	// Noise de Gole | [frames=1739] enter 138779, end 140518 (140579)

	{ "addr": bit2(0x001F05), "stage": "Vanilla Secret 1", "exit": NORMAL_EXIT, "frames": 1985, },
	// bahamete et al. | [frames=1804] enter 131379, end 133183 (133321), UNUSABLE because block dupe for yoshi wings
	// Noise de Gole | [frames=1985] enter 140579, end 142564 (142703)

	{ "addr": bit3(0x001F05), "stage": "#3 Lemmy's Castle", "exit": NORMAL_EXIT, "frames": 6125, },
	// bahamete et al. | [frames=6027] enter 56784, end 62811 (62982), possible lower bound, but cycle room gets 1 cycle faster than human viable (+665f)
	// Noise de Gole | [frames=6125] enter 61181, end 67306 (67478)

	{ "addr": bit4(0x001F05), "stage": "Vanilla Dome 4", "exit": NORMAL_EXIT, "frames": 2585, },
	// bahamete et al. | [frames=2508] enter 54276, end 56784, RTA viable (gets yoshi fly, but close enough)
	// Noise de Gole | [frames=2585] enter 58596, end 61181

	{ "addr": bit5(0x001F05), "stage": "Vanilla Dome 3", "exit": NORMAL_EXIT, "frames": 4025, },
	// bahamete et al. | [frames=3668] enter 50608, end 54276, possible lower bound, but this raft skip is beyond human-viable
	// Noise de Gole | [frames=4025] enter 54571, end 58596

	{ "addr": bit6(0x001F05), "stage": "Vanilla Ghost House", "exit": NORMAL_EXIT, "frames": 3044, },
	// bahamete et al. | [frames=3044] enter 47564, end 50608, RTA viable (at least, timing-wise)
	// Noise de Gole | [frames=3089] enter 51482, end 54571

	{ "addr": bit7(0x001F05), "stage": "Vanilla Dome 2", "exit": SECRET_EXIT, "frames": 1650, },
	// bahamete et al. | [frames=1267] enter 41692, end 42959, UNUSABLE because cape slope clip to fly under water to reach key 
	// Noise de Gole | [frames=1650] enter 44943, end 46593

	{ "addr": bit0(0x001F06), "stage": "Cookie Mountain", "exit": NORMAL_EXIT, "frames": 2146, },
	// bahamete et al. | [frames=2204] enter 64527, end 66731, boss kill
	// Noise de Gole | [frames=2146] enter 69074, end 71220 (71458)

	{ "addr": bit1(0x001F06), "stage": "Cheese Bridge Area", "exit": SECRET_EXIT, "frames": 2715, },
	// bahamete et al. | [frames=2715] enter 66969, end 69684, RTA viable
	// Noise de Gole | [frames=2715] enter 71458, end 74173

	{ "addr": bit2(0x001F06), "stage": "Cheese Bridge Area", "exit": NORMAL_EXIT, "frames": 1545, },
	// bahamete et al. | [frames=1545] enter 62982, end 64527, RTA viable (more efficient yoshi wings grab)
	// Noise de Gole | [frames=1596] enter 67478, end 69074

	{ "addr": bit3(0x001F06), "stage": "#4 Ludwig's Castle", "exit": NORMAL_EXIT, "frames": 5575, },
	// bahamete et al. | [frames=5575] enter 152542, end 158117, RTA viable
	// Noise de Gole | [frames=5654] enter 161979, end 167633

	{ "addr": bit4(0x001F06), "stage": "Butter Bridge 2", "exit": NORMAL_EXIT, "frames": 2507, },
	// bahamete et al. | [frames=2507] enter 150035, end 152542, RTA viable
	// Noise de Gole | [frames=2516] enter 159463, end 161979

	{ "addr": bit5(0x001F06), "stage": "Butter Bridge 1", "exit": NORMAL_EXIT, "frames": 7101, },
	// bahamete et al. | [frames=7101] enter 142934, end 150035, RTA viable
	// Noise de Gole | [frames=7113] enter 152350, end 159463

	{ "addr": bit6(0x001F06), "stage": "Vanilla Fortress", "exit": NORMAL_EXIT, "frames": 4602, },
	// bahamete et al. | [frames=4602] enter 138332, end 142934, RTA viable (extremely optimized reznor fight)
	// Noise de Gole | [frames=4679] enter 147671, end 152350

	{ "addr": bit7(0x001F06), "stage": "Vanilla Secret 3", "exit": NORMAL_EXIT, "frames": 2438, },
	// bahamete et al. | [frames=2438] enter 135894, end 138332, RTA viable
	// Noise de Gole | [frames=2448] enter 145223, end 147671

	{ "addr": bit0(0x001F07), "stage": "Forest of Illusion 3", "exit": SECRET_EXIT, "frames": 2506, },
	// bahamete et al. | [frames=2506] enter 189077, end 191583, RTA viable
	// Noise de Gole | [frames=2528] enter 199200, end 201728

	{ "addr": bit1(0x001F07), "stage": "Forest of Illusion 3", "exit": NORMAL_EXIT, "frames": 2926, },
	// bahamete et al. | [frames=2967] enter 180096, end 183063 (183150), UNUSABLE because yoshi swap to eat goal tape
	// Noise de Gole | [frames=2926] enter 181987, end 184913

	{ "addr": bit2(0x001F07), "stage": "Forest of Illusion 2", "exit": SECRET_EXIT, "frames": 2592, },
	// bahamete et al. | [frames=2408] enter 184693, end 187101, RTA viable (early yoshi clip, grabs first throw block, timer extension)
	// Noise de Gole | [frames=2592] enter 170062, end 172654 (uses timer extension)

	{ "addr": bit3(0x001F07), "stage": "Forest of Illusion 2", "exit": NORMAL_EXIT, "frames": 3614, },
	// bahamete et al. | [frames=3443] enter 176653, end 180096, RTA viable (early yoshi clip, grabs first throw block, timer extension)
	// Noise de Gole | [frames=3614] enter 178373, end 181987

	{ "addr": bit4(0x001F07), "stage": "Forest of Illusion 1", "exit": SECRET_EXIT, "frames": 1900, },
	// bahamete et al. | [frames=1900] enter 158117, end 160017, RTA viable but hyper-optimized
	// Noise de Gole | [frames=2029] enter 174462, end 176491

	{ "addr": bit5(0x001F07), "stage": "Forest of Illusion 1", "exit": NORMAL_EXIT, "frames": 2284, },
	// bahamete et al. | [frames=2284] enter 174369, end 176653, RTA viable (gets yoshi wings off the key block instead of the p-balloon block)
	// Noise de Gole | [frames=2429] enter 167633, end 170062 (+64f for yoshi) <-- wings off key block

	{ "addr": bit6(0x001F07), "stage": "Red Switch Palace", "exit": NORMAL_EXIT, "frames": 1900, },
	// bahamete et al. | [frames=1870] enter 42959, end 44829 (44896), RTA viable (mostly the same as "fast red")
	// Noise de Gole | [frames=1688] enter 46593, end 48281 (48349) <-- just "fast red"

	{ "addr": bit7(0x001F07), "stage": "Green Switch Palace", "exit": NORMAL_EXIT, "frames": 1903, },
	// bahamete et al. | [frames=1903] enter 25592, end 27495 (27539), RTA viable
	// Noise de Gole | [frames=1691] enter 128128, end 129819 (129862)

	{ "addr": bit0(0x001F08), "stage": "Blue Switch Palace", "exit": NORMAL_EXIT, "frames": 1891, },
	// bahamete et al. | [frames=1866] enter 187101, end 188967 (189077), RTA viable
	// Noise de Gole | [frames=1679] enter 172654, end 174333

	{ "addr": bit2(0x001F08), "stage": "Forest Fortress", "exit": NORMAL_EXIT, "frames": 4863, },
	// bahamete et al. | [frames=4863] enter 166577, end 171440 (171821), RTA viable
	// Noise de Gole | [frames=4930] enter 191043, end 195973

	{ "addr": bit3(0x001F08), "stage": "Forest Secret Area", "exit": NORMAL_EXIT, "frames": 2165, },
	// bahamete et al. | [frames=2165] enter 164412, end 166577, RTA viable
	// Noise de Gole | [frames=2176] enter 188867, end 191043

	{ "addr": bit4(0x001F08), "stage": "Forest of Illusion 4", "exit": SECRET_EXIT, "frames": 1815, },
	// bahamete et al. | [frames=1815] enter 162597, end 164412, RTA viable
	// Noise de Gole | [frames=1836] enter 187031, end 188867

	{ "addr": bit5(0x001F08), "stage": "Forest of Illusion 4", "exit": NORMAL_EXIT, "frames": 2865 - 32, },
	// TODO: look into drunken wings
	// bahamete et al. | [frames=1543] enter 183150, end 184693, UNUSABLE because dupe for yoshi wings
	// Noise de Gole | [frames=2865] enter 196267, end 199132 (+32f for powerup grab)

	{ "addr": bit6(0x001F08), "stage": "Forest Ghost House", "exit": SECRET_EXIT, "frames": 2118, }, // secret exit, right door, goes left
	// bahamete et al. | [frames=2580] enter 160017, end 162597, possible lower bound due to one corner clip at the turnaround
	// Noise de Gole | [frames=2118] enter 184913, end 187031 <-- RTA corner clip strat

	{ "addr": bit7(0x001F08), "stage": "Forest Ghost House", "exit": NORMAL_EXIT, "frames": 1796, }, // normal exit, left door, goes right
	// bahamete et al. | [frames=2548] enter 171821, end 174369, possible lower bound due to one corner clip at the turnaround
	// Noise de Gole | [frames=1796] enter 176491, end 178287 <-- RTA corner clip strat

	{ "addr": bit0(0x001F09), "stage": "Valley of Bowser 4", "exit": SECRET_EXIT, "frames": 2372, },
	// bahamete et al. | [frames=2153] enter 250886, end 253039 (253081), possible lower bound (flies under stage)
	// Noise de Gole | [frames=2372] enter 257183, end 259555

	{ "addr": bit1(0x001F09), "stage": "Valley of Bowser 4", "exit": NORMAL_EXIT, "frames": 2800, },
	// bahamete et al. | [frames=2517] enter 253081, end 255598 (255683), UNUSABLE because boss kill lmao
	// Noise de Gole | [frames=2800] enter 259597, end 262397

	{ "addr": bit2(0x001F09), "stage": "Valley of Bowser 3", "exit": NORMAL_EXIT, "frames": 2546, },
	// bahamete et al. | [frames=2533] enter 248353, end 250886, possible lower bound (screen scroll, yoshi swap to eat goal tape)
	// Noise de Gole | [frames=2546] enter 254637, end 257183

	{ "addr": bit3(0x001F09), "stage": "Valley Ghost House", "exit": SECRET_EXIT, "frames": 1630, },
	// bahamete et al. | [frames=1630] enter 239964, end 241594, RTA viable (more efficient key slide)
	// Noise de Gole | [frames=1637] enter 250735, end 252372

	{ "addr": bit4(0x001F09), "stage": "Valley Ghost House", "exit": NORMAL_EXIT, "frames": 2223, },
	// bahamete et al. | [frames=2206] enter 246147, end 248353, possible lower bound
	// Noise de Gole | [frames=2223] enter 252414, end 254637

	{ "addr": bit5(0x001F09), "stage": "Valley of Bowser 2", "exit": SECRET_EXIT, "frames": 4048, },
	// bahamete et al. | [frames=2821] enter 255683, end 258504, UNUSABLE because the whole sandbar is skipped out of bounds
	// Noise de Gole | [frames=4048] enter 267124, end 271172 <-- key in sandbar

	{ "addr": bit6(0x001F09), "stage": "Valley of Bowser 2", "exit": NORMAL_EXIT, "frames": 1542, },
	// bahamete et al. | [frames=1542] enter 238422, end 239964, RTA viable
	// Noise de Gole | [frames=1575] enter 249160, end 250735

	{ "addr": bit7(0x001F09), "stage": "Valley of Bowser 1", "exit": NORMAL_EXIT, "frames": 1815, },
	// bahamete et al. | [frames=1286] enter 237136, end 238422, possible lower bound, clips through ground, but vob1 wings on the first dragon coin
	// Noise de Gole | [frames=1815] enter 247345, end 249160

	{ "addr": bit0(0x001F0A), "stage": "Chocolate Island 2", "exit": SECRET_EXIT, "frames": 2301, },
	// bahamete et al. | [frames=2301] enter 201716, end 204017 (204214), RTA viable
	// Noise de Gole | [frames=2311] enter 211913, end 214224 (214421)

	{ "addr": bit1(0x001F0A), "stage": "Chocolate Island 2", "exit": NORMAL_EXIT, "frames": 2619, },
	// bahamete et al. | [frames=4267] enter 208900, end 213167, RTA viable (+8f for yoshi spawns)
	// Noise de Gole | [frames=2619] enter 219217, end 221836 <-- ci2 yellow switch strat

	{ "addr": bit6(0x001F0A), "stage": "Valley Fortress", "exit": NORMAL_EXIT, "frames": 3385, },
	// bahamete et al. | [frames=3077] enter 258504, end 261581, possible lower bound (skip a cycle in first half, keep flight in second half with huge cape gains)
	// Noise de Gole | [frames=3385] enter 271172, end 274557

	{ "addr": bit7(0x001F0A), "stage": "#7 Larry's Castle", "exit": NORMAL_EXIT, "frames": 4599, },
	// bahamete et al. | [frames=4468] enter 241594, end 246062 (246147), possible lower bound, flies under stage in room 2 to avoid turn blocks and pencils
	// Noise de Gole | [frames=4599] enter 262397, end 266996

	{ "addr": bit0(0x001F0B), "stage": "Chocolate Secret", "exit": NORMAL_EXIT, "frames": 4340, },
	// bahamete et al. | [frames=4231] enter 204214, end 208445 (208900), RTA viable
	// Noise de Gole | [frames=4340] enter 214421, end 218761 (219217)

	{ "addr": bit1(0x001F0B), "stage": "Sunken Ghost Ship", "exit": NORMAL_EXIT, "frames": 6027, },
	// bahamete et al. | [frames=6027] enter 231109, end 237136, RTA viable
	// Noise de Gole | [frames=6131] enter 241214, end 247345

	{ "addr": bit2(0x001F0B), "stage": "#6 Wendy's Castle", "exit": NORMAL_EXIT, "frames": 5988, },
	// bahamete et al. | [frames=5744] enter 225365, end 231109, possible lower bound, flies under crushers in first room
	// Noise de Gole | [frames=5988] enter 235226, end 241214

	{ "addr": bit3(0x001F0B), "stage": "Chocolate Island 5", "exit": NORMAL_EXIT, "frames": 2111, },
	// bahamete et al. | [frames=1613] enter 223752, end 225365, UNUSABLE because block dupe for yoshi wings
	// Noise de Gole | [frames=2111] enter 233115, end 235226

	{ "addr": bit4(0x001F0B), "stage": "Chocolate Island 4", "exit": NORMAL_EXIT, "frames": 1604, },
	// bahamete et al. | [frames=1604] enter 222148, end 223752, UNUSABLE (?) because block dupe for yoshi wings
	// Noise de Gole | [frames=2181] enter 230934, end 233115

	{ "addr": bit5(0x001F0B), "stage": "Chocolate Fortress", "exit": NORMAL_EXIT, "frames": 3477, },
	// bahamete et al. | [frames=3402] enter 218746, end 222148, RTA viable
	// Noise de Gole | [frames=3477] enter 227457, end 230934

	{ "addr": bit6(0x001F0B), "stage": "Chocolate Island 3", "exit": SECRET_EXIT, "frames": 2882, },
	// bahamete et al. | [frames=5579] enter 213167, end 218746, RTA viable
	// Noise de Gole | [frames=2882] enter 224575, end 227457

	{ "addr": bit7(0x001F0B), "stage": "Chocolate Island 3", "exit": NORMAL_EXIT, "frames": 2739, },
	// bahamete et al. | [frames=2707] enter 213167, end 215874, RTA viable
	// Noise de Gole | [frames=2739] enter 221836, end 224575

	{ "addr": bit0(0x001F0C), "stage": "Star World 3", "exit": NORMAL_EXIT, "frames": 1093, },
	// bahamete et al. | [frames=833] enter 74415, end 75248 (75296), UNUSABLE because lol, lmao
	// Noise de Gole | [frames=1093] enter 78941, end 80034 (80082)

	{ "addr": bit2(0x001F0C), "stage": "Star World 2", "exit": SECRET_EXIT, "frames": 2170, },
	// bahamete et al. | [frames=2149] enter 83232, end 85381 (85428), RTA viable
	// Noise de Gole | [frames=2170] enter 88817, end 90987 (91034)

	{ "addr": bit3(0x001F0C), "stage": "Star World 2", "exit": NORMAL_EXIT, "frames": 2545, },
	// bahamete et al. | [frames=2588] enter 85428, end 88016 (88064), RTA viable (+64f for growing yoshi)
	// Noise de Gole | [frames=2545] enter 91034, end 93579 (93627)

	{ "addr": bit5(0x001F0C), "stage": "Star World 1", "exit": SECRET_EXIT, "frames": 939, },
	// bahamete et al. | [frames=898] enter 82272, end 83170 (83232), RTA viable
	// Noise de Gole | [frames=939] enter 87815, end 88754 (88817)

	{ "addr": bit6(0x001F0C), "stage": "Star World 1", "exit": NORMAL_EXIT, "frames": 1505, },
	// bahamete et al. | [frames=1505] enter 88064, end 89569 (89670), UNUSABLE because yoshi wings
	// Noise de Gole | [frames=2395] enter 93627, end 96022 (96123)

	{ "addr": bit1(0x001F0D), "stage": "Star World 5", "exit": SECRET_EXIT, "frames": 1737, },
	// bahamete et al. | [frames=1737] enter 89670, end 91407 (91627), RTA viable (yoshi fly makes this a lower bound)
	// Noise de Gole | [frames=1910] enter 96123, end 98033 (98252)

	{ "addr": bit2(0x001F0D), "stage": "Star World 5", "exit": NORMAL_EXIT, "frames": 2351, },
	// bahamete et al. | [frames=2351] enter 79859, end 82210 (82272), RTA viable
	// Noise de Gole | [frames=2365] enter 85388, end 87753 (87815)

	{ "addr": bit4(0x001F0D), "stage": "Star World 4", "exit": SECRET_EXIT, "frames": 1720, },
	// bahamete et al. | [frames=1720] enter 78038, end 79758 (79859), RTA viable
	// Noise de Gole | [frames=1757] enter 83531, end 85288 (85388)

	{ "addr": bit5(0x001F0D), "stage": "Star World 4", "exit": NORMAL_EXIT, "frames": 2491, },
	// bahamete et al. | [frames=1834] enter 76156, end 77990 (78038), UNUSABLE because spawned yoshi wings from key block
	// Noise de Gole | [frames=2491] enter 80992, end 83483 (83531)

	{ "addr": bit7(0x001F0D), "stage": "Star World 3", "exit": SECRET_EXIT, "frames": 812, },
	// bahamete et al. | [frames=812] enter 75296, end 76108 (76156), RTA viable (silly yoshi nonsense)
	// Noise de Gole | [frames=862] enter 80082, end 80944 (80992)

	{ "addr": bit0(0x001F0E), "stage": "Way Cool", "exit": NORMAL_EXIT, "frames": 1563, },
	// bahamete et al. | [frames=1563] enter 93903, end 95466, RTA viable
	// Noise de Gole | [frames=1622] enter 100889, end 102511

	{ "addr": bit1(0x001F0E), "stage": "Tubular", "exit": NORMAL_EXIT, "frames": 1111, },
	// bahamete et al. | [frames=1111] enter 92792, end 93903, RTA viable (way too efficient at the wings dupe)
	// Noise de Gole | [frames=1188] enter 99701, end 100889

	{ "addr": bit2(0x001F0E), "stage": "Gnarly", "exit": NORMAL_EXIT, "frames": 1449, },
	// bahamete et al. | [frames=1165] enter 91627, end 92792, unsure about this one. uses block dupes higher up, not RTA viable but might be a lower bound
	// Noise de Gole | [frames=1449] enter 98252, end 99701

	{ "addr": bit4(0x001F0E), "stage": "Choco-Ghost House", "exit": NORMAL_EXIT, "frames": 2947, },
	// bahamete et al. | [frames=2947] enter 198769, end 201716, RTA viable
	// Noise de Gole | [frames=2952] enter 208961, end 211913

	{ "addr": bit5(0x001F0E), "stage": "Chocolate Island 1", "exit": NORMAL_EXIT, "frames": 2423, },
	// bahamete et al. | [frames=2423] enter 196346, end 198769, RTA viable (uses pipe speed)
	// Noise de Gole | [frames=2456] enter 206505, end 208961

	{ "addr": bit6(0x001F0E), "stage": "#5 Roy's Castle", "exit": NORMAL_EXIT, "frames": 4763, },
	// bahamete et al. | [frames=4763] enter 191583, end 196346, RTA viable
	// Noise de Gole | [frames=4777] enter 201728, end 206505

	{ "addr": bit7(0x001F0E), "stage": "Soda Lake", "exit": NORMAL_EXIT, "frames": 4498, },
	// bahamete et al. | [frames=4498] enter 69684, end 74182 (74415), RTA viable
	// Noise de Gole | [frames=4534] enter 74173, end 78707

	{ "addr": bit3(0x001F0F), "stage": "Funky", "exit": NORMAL_EXIT, "frames": 3528, },
	// bahamete et al. | [frames=3058] enter 105435, end 108493 (108747), UNUSABLE because of block dupe into yoshi wings
	// Noise de Gole | [frames=3528] enter 111931, end 115459 (115709)

	{ "addr": bit4(0x001F0F), "stage": "Outrageous", "exit": NORMAL_EXIT, "frames": 2553, },
	// bahamete et al. | [frames=2557] enter 102878, end 105435, RTA viable
	// Noise de Gole | [frames=2553] enter 109378, end 111931

	{ "addr": bit5(0x001F0F), "stage": "Mondo", "exit": NORMAL_EXIT, "frames": 2491, },
	// bahamete et al. | [frames=2744] enter 100134, end 102878, RTA viable timing but keeps yoshi
	// Noise de Gole | [frames=2491] enter 106887, end 109378 <-- reznor kill

	{ "addr": bit6(0x001F0F), "stage": "Groovy", "exit": NORMAL_EXIT, "frames": 1954, },
	// bahamete et al. | [frames=1954] enter 98180, end 100134, RTA viable - uses boss kill strat
	// Noise de Gole | [frames=1972] enter 104915, end 106887

	{ "addr": bit7(0x001F0F), "stage": "Awesome", "exit": NORMAL_EXIT, "frames": 2404, },
	// bahamete et al. | [frames=2714] enter 95466, end 98180, NON-OPTIMAL because no boss kill
	// Noise de Gole | [frames=2404] enter 102511, end 104915 <-- boss kill
]

RTA_OFFSET = 120

// frames from the start of the game to entering the first level
INTRO_TIME = 1458 - 459 - RTA_OFFSET // frame counts from bahamete et al.

// frames from entering back door to spawning peach
BOWSER_TIME = 269434 - 261581 // frame counts from bahamete et al.

OPTIMAL_TIME = sum_of(EXITS, x => x["frames"]) + INTRO_TIME + BOWSER_TIME
TARGET_TIME = 90 * 60 * 60

POWERUPS = {
	0x00: "Small",
	0x01: "🍄 Super",
	0x02: "🪶 Cape",
	0x03: "🔥 Fire",
}

YOSHI_ARE = {
	0x00: "is",
	0x04: "and 🟡 Yellow Yoshi are",
	0x06: "and 🔵 Blue Yoshi are",
	0x08: "and 🔴 Red Yoshi are",
	0x0a: "and 🟢 Green Yoshi are",
}

// --- AUX FUNCTIONS -------------------------------------------------------------------

function start_new_run() => (
	level_id() == 0x00 && exit_count() == 0 && 
	prev(game_state()) == 0x13 && game_state() == 0x14
)

function forbidden_actions() => (
	(item_box() > 0x04) ||
	(powerup() > 0x03)
)

RULES_TEXT = "No arbitrary code execution or Chuck eat item swap glitches allowed."

function valid_run() => once(start_new_run() && never(forbidden_actions()) && never(game_state() < 0x0B)) && frame_counter() >= RTA_OFFSET

// small adjustment to the frame counter
function current_time() => frame_counter() - RTA_OFFSET
function backup_current_time() => backup_frame_counter() - RTA_OFFSET

// the exit id is set back to 0 on the map screen whenever mario regains control on the map
// this means that it waits for mario to walk *and* for the save prompt
function level_completed() => game_state() == 0x0e && prev(exit_id()) > 0 && exit_id() == 0

// we are on pace if all remaining levels played perfectly could still come under the target time
function on_pace() => backup_current_time() + OPTIMAL_TIME - INTRO_TIME - sum_of(EXITS, x => x["addr"] * x["frames"]) < TARGET_TIME

// check to see if Peach is in the sprite table (though it seems like she is always at +8)
function win_the_game() => (
	game_state() == 0x14 && level_id() >= 0x31 && level_id() <= 0x32 &&
	all_of(range(0, 11), i => prev(byte(SPRITE_IDS + i)) != 0x7c) &&
	__ornext(any_of(range(0, 11), i => byte(SPRITE_IDS + i) == 0x7c))
)

// don't trust the exit count because we don't trust the player
function intended_exit_count() => sum_of(EXITS, x => x["addr"])

// the *work* i gotta do just to figure out what fricken color of yoshi we're riding, if we're riding one at all...
function yoshi_color_world() => current_player_yoshi() * (yoshi_carried() / yoshi_carried())
function yoshi_color_level() => yoshi_color_world() * (yoshi_ride_state() / yoshi_ride_state())

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() < 0x0B || frame_counter() < 120,
	"Getting ready to start a Super Mario World speedrun"
)

rich_presence_conditional_display(valid_run() && once(win_the_game()),
	"Run Complete! | 📌 {0}/96 exits",
	rich_presence_number(intended_exit_count())
)

rich_presence_conditional_display(valid_run() && game_state() < 0x0F,
	"{0} Mario {1}{2} on the overworld map 🗺️ | 📌 {3}/96 exits complete | ⏱️ {4}",
	rich_presence_lookup("Powerup", powerup(), POWERUPS, fallback="⚠️ Illegal"),
	rich_presence_lookup("Yoshi", yoshi_color_world(), YOSHI_ARE, fallback="is"),
	rich_presence_flag(" still on pace", when=on_pace(), lookupname="OnPace"),
	rich_presence_number(intended_exit_count()),
	rich_presence_value("Timer", current_time(), "FRAMES")
)

rich_presence_conditional_display(valid_run(),
	"{0} Mario {1}{2} in 🗺️ {3} | 📌 {4}/96 exits complete | ⏱️ {5}",
	rich_presence_lookup("Powerup", powerup(), POWERUPS, fallback="⚠️ Illegal"),
	rich_presence_lookup("Yoshi", yoshi_color_level(), YOSHI_ARE, fallback="is"),
	rich_presence_flag(" still on pace", when=on_pace(), lookupname="OnPace"),
	rich_presence_lookup("Stage", level_id(), STAGE_NAMES, fallback="Dinosaur Land"),
	rich_presence_number(intended_exit_count()),
	rich_presence_value("Timer", current_time(), "FRAMES")
)

rich_presence_conditional_display(game_state() < 0x0F,
	"{0} Mario {1} not currently on a run",
	rich_presence_lookup("Powerup", powerup(), POWERUPS, fallback="⚠️ Illegal"),
	rich_presence_lookup("Yoshi", yoshi_color_world(), YOSHI_ARE, fallback="is")
)

rich_presence_display(
	"{0} Mario {1} not currently on a run ({2})",
	rich_presence_lookup("Powerup", powerup(), POWERUPS, fallback="⚠️ Illegal"),
	rich_presence_lookup("Yoshi", yoshi_color_level(), YOSHI_ARE, fallback="is"),
	rich_presence_lookup("Stage", level_id(), STAGE_NAMES, fallback="Dinosaur Land")
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

MILESTONE_POINTS = [
	{"exits": 10, "points":  5, },
	{"exits": 20, "points":  5, },
	{"exits": 30, "points": 10, },
	{"exits": 40, "points": 10, },
	{"exits": 50, "points": 10, },
	{"exits": 60, "points": 10, },
	{"exits": 70, "points": 25, },
	{"exits": 80, "points": 25, },
	{"exits": 90, "points": 50, },
	{"exits": 96, "points": 50, },
]

for milestone in MILESTONE_POINTS
{
	achievement(
		title=format("On Pace After {0} Exits", milestone["exits"]),
		description=format("Complete {0} exits on pace for a sub 90-minute 96 exit run. ", milestone["exits"]) + RULES_TEXT,
		points=milestone["points"],
		trigger=(
			// this is a valid run that is still on pace to complete
			valid_run() && on_pace() && 
			// have now reached the target milestone
			intended_exit_count() == milestone["exits"] && 
			// the specific timing of this achievement is on the overworld having walked to the next tile
			level_completed()
		)
	)
}

/*
-- to rebuild this achievement --
Core: main checks and trigger
Alt 1: (copy the dummy measured tracker below here)
Alt 2: (add `Trigger Val 0 = Val 1` here)
*/
achievement(
	title="Sub 90-Minute 96 Exit Speedrun Complete!",
	description="Defeat Bowser and rescue Peach in less than 90 minutes after completing all 96 intended exits. " + RULES_TEXT,
	points=100,
	trigger=(
		valid_run() && never(!on_pace() && game_state() < 0x0F && exit_id() == 0) &&
		current_time() < TARGET_TIME && trigger_when(win_the_game())
	)
)

achievement(
	title="__DUMMY_MEASURED_TRACKER_DO_NOT_UPLOAD",
	description="[measured data for the win condition]",
	points=0,
	trigger=measured(intended_exit_count() == 96, when=valid_run())
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="96 Exit Speedrun",
	description="Defeat Bowser after clearing all 96 intended exits. " + RULES_TEXT,

	start=start_new_run(),
	cancel=forbidden_actions() || game_state() < 0x0B,
	submit=win_the_game() && intended_exit_count() == 96,

	value=max_of(
		measured(current_time(), when=frame_counter() >= RTA_OFFSET),
		measured(0)
	),
	format="FRAMES",
	lower_is_better=true
)