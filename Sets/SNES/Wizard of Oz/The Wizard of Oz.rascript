// The Wizard of Oz
// #ID = 1325

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0038: Game State Bitflags [16 bit]
//        0x0000=map screen
//        0x0211=credits
//        0x0200=main menu, earned password
//        0x0300=selecting something in main menu (loading password)
//        0x0800, 0x0C00 in levels
//        - 0x0B00 after collecting ticket
//        0xXX1F in minigame (0x051F during, 0x031F on win)
//        
//        byte 2, b3=Currently In-Level
function game_state() => word(0x0038)
function game_state_byte() => byte(0x0038)

// $0055: Controller Bitflags #1 [8 bit]
//        b4=R
//        b5=L
//        b6=X
//        b7=A

// $0056: Controller Bitflags #2 [8 bit]
//        b0=D-pad Right
//        b1=D-pad Left
//        b2=D-pad Down
//        b3=D-pad Up
//        b4=Start
//        b5=Select
//        b6=Y
//        b7=B

// $0061: Level ID [8 bit]
//        0x01=Shy Village
//        0x02=Gamboge Gorge
//        0x03=Maize Meadow
//        0x04=Saffron Fields
//        0x05=Xanthin Farms
//        0x06=Lemon Trees
//        0x07=Citron City
//        0x08=Yellow/Red Border
//        0x09=Rouge River, North Fork
//        0x0A=Poppy Fields
//        0x0B=Cinnabar City
//        0x0C=Carnelian Forest
//        0x0D=Scarlet Marsh
//        0x0E=Rouge River, West Fork
//        0x0F=Crimson Caves
//        0x10=Red/Blue Border
//        0x11=Zaffer Forest
//        0x12=Azure Hedges
//        0x13=Navy Village
//        0x14=Smalt Furnace
//        0x15=Indigo Palace
//        0x16=Cyan City
//        0x17=Blue/Purple Border
//        0x18=Mallow Marsh
//        0x19=Mauve Castle
//        0x1A=Amethyst Mountains
//        0x1B=Lilac Forest
//        0x1C=Lavender Gardens
//        0x1D=Yellow/Purple Border
//        0x1E=Emerald City
function level_id() => byte(0x0061)

// $0065: Room ID [8 bit]
//        0x00=Shy Village
//        0x02=Rouge River, North Fork
//        0x04=Smalt Furnace
//        0x06=Yellow-Red Border
//        0x08=Scarlet Marsh
//        0x0a=Red-Blue Border
//        0x0c=Blue-Purple Border
//        0x0e=Yellow-Purple Border
//        0x10=Cyan City
//        0x12=Cinnabar City
//        0x14=Lemon Trees
//        0x16=Carnelian Forest
//        0x18=Lilac Forest
//        0x1a=Amethyst Mountains
//        0x1c=Mauve Castle
//        0x1e=Maize Meadzow
//        0x20=Saffron Fields
//        0x22=Xanthin Farms
//        0x24=Gamboge Gorge
//        0x26=Emerald City
//        0x28=Indigo Palace
//        0x2a=Rouge River, West Fork
//        0x2c=Crimson Caves
//        0x2e=Azure Hedges
//        0x30=Poppy Fields
//        0x32=Citron City
//        0x34=Mallow Marsh
//        0x36=Zaffer Forest
//        0x38=Lavender Gardens
//        0x3a=Navy Village
//        0x3c=Maize Meadow Boss Room
//        0x40=Secret Cavern (Rouge River, West Fork)
//        0x44=Smalt Furnace Boss Room
//        0x46=Carnelian Forest Boss Room
//        0x48=The Barn (Saffron Fields)
//        0x4a=Maze House (Shy Village)
//        0x4c=Maze House (Zaffer Forest)
//        0x4e=Munchkin Home (Shy Village)
//        0x50=The Mill (Saffron Fields)
//        0x54=City Room (Citron City)
//        0x56=Storage Shed (Saffron Fields)
//        0x58=Frenzy Hideout (Cinnabar City)
//        0x5a=City Room (Cyan City)
function room_id() => byte(0x0065)

// $007B: Camera X Position [16 bit] (0 = left)
function cam_x() => word(0x007B)

// $007F: Camera Y Position [16 bit] (0 = top)
function cam_y() => word(0x007F)

// $018B: Number of accessible levels [16 bit]
//        Starts at 1, increments when last level beaten
//        Emerald City accessible = 0x001e (30)
function level_progress() => word(0x018B)

// $0199: Current Character [8 bit]
//        00=Dorothy
//        02=Scarecrow
//        04=Tinman
//        06=Lion
function current_character() => byte(0x0199)

// $01D1: Gold Gems (Ammo) [8 bit]
function gold_gems() => byte(0x01D1)

// $01D5: Flying Shoes Flight Timer (frames) [8 bit]
function flight_timer() => byte(0x01D5)

// $01D7: Shoe Charges Remaining [16 bit]
function shoe_charges() => word(0x01D7)

// $01D9: Secondary Ammo Type [8 bit]
//        01=blue bubbles
//        02=star wand
function secondary_ammo_type() => byte(0x01D9)

// $01DB: Secondary Ammo Count [8 bit]
function secondary_ammo_count() => byte(0x01DB)

// $01DD: Lives - Dorothy [8 bit]
function lives_dorothy() => byte(0x01DD)

// $01DF: Lives - Scarecrow [8 bit]
function lives_scarecrow() => byte(0x01DF)

// $01E1: Lives - Tinman [8 bit]
function lives_tinman() => byte(0x01E1)

// $01E3: Lives - Lion [8 bit]
function lives_lion() => byte(0x01E3)

// $01E5: Damage Taken - Dorothy [8 bit]
//        0=Full Health, 8=Death
function damage_taken_dorothy() => byte(0x01E5)

// $01E7: Damage Taken - Scarecrow [8 bit]
function damage_taken_scarecrow() => byte(0x01E7)

// $01E9: Damage Taken - Tinman [8 bit]
function damage_taken_tinman() => byte(0x01E9)

// $01EB: Damage Taken - Lion [8 bit]
function damage_taken_lion() => byte(0x01EB)

// $01ED: Bricks - Red (BCD) [8 bit]
function bricks_red() => bcd(byte(0x01ED))

// $01EE: Bricks - Blue (BCD) [8 bit]
function bricks_blue() => bcd(byte(0x01EE))

// $01EF: Bricks - Yellow (BCD) [8 bit]
function bricks_yellow() => bcd(byte(0x01EF))

// $01F0: Bricks - Purple (BCD) [8 bit]
function bricks_purple() => bcd(byte(0x01F0))

// $01F1: Bricks Placed - Red (BCD) [8 bit]
//        # bricks placed at Red/Blue border
//        complete bridge = 86 bricks
//        minimum 14 bricks needed
function bricks_placed_red() => bcd(byte(0x01F1))

// $01F2: Bricks Placed - Blue (BCD) [8 bit]
//        # bricks placed at Blue/Purple border
//        complete bridge = 92 bricks
//        minimum 15 bricks needed
function bricks_placed_blue() => bcd(byte(0x01F2))

// $01F3: Bricks Placed - Yellow (BCD) [8 bit]
//        # bricks placed at Yellow/Red border
//        complete bridge = 79 bricks
//        minimum 12 bricks needed
function bricks_placed_yellow() => bcd(byte(0x01F3))

// $01F4: Bricks Placed - Purple (BCD) [8 bit]
//        # bricks placed at Yellow/Purple border
//        complete bridge = 98 bricks
//        minimum 16 bricks needed
function bricks_placed_purple() => bcd(byte(0x01F4))

// $01F5: Tickets Collected Bitfield #1 [8 bit]
//        b0=??
//        b1=[Y] Shy Village Maze House ticket
//        b2=[Y] Saffron Fields barn ticket
//        b3=[Y] Saffron Fields mill ticket
//        b4=[Y] Lemon Trees minigame bone (Toto vs Mice)
//        b5=[Y] Maize Meadow minigame bone (Lemon Drop)
//        b6=[Y] Gamboge Gorge hole ticket
//        b7=[Y] Shy Village minigame bone (Hidden Message)
function ticket_y_shy_village_maze_house() => bit1(0x01F5)
function ticket_y_saffron_fields_barn() => bit2(0x01F5)
function ticket_y_saffron_fields_mill() => bit3(0x01F5)
function ticket_y_lemon_trees_minigame_bone_toto_vs_mice() => bit4(0x01F5)
function ticket_y_gamboge_gorge_hole() => bit6(0x01F5)
function ticket_y_shy_village_minigame_bone_hidden_message() => bit7(0x01F5)

// $01F6: Tickets Collected Bitfield #2 [8 bit]
//        b0=
//        b1=[R] Crimson Caves start ticket
//        b2=[R] Scarlet Marsh top end ticket
//        b3=[R] Carnelian Forest trees ticket
//        b4=[R] Cinnabar City roof ticket
//        b5=[R] Poppy Fields flower ticket
//        b6=
//        b7=??
function ticket_r_crimson_caves_start() => bit1(0x01F6)
function ticket_r_scarlet_marsh_top_end() => bit2(0x01F6)
function ticket_r_carnelian_forest_trees() => bit3(0x01F6)
function ticket_r_cinnabar_city_roof() => bit4(0x01F6)
function ticket_r_poppy_fields_flower() => bit5(0x01F6)

// $01F7: Tickets Collected Bitfield #3 [8 bit]
//        b0=[B] Zaffer Forest Maze House ticket #2
//        b1=[B] Zaffer Forest Maze House ticket #1
//        b2=[B] Azure Hedges minigame (Concentration)
//        b3=[B] Azure Hedges lower path ticket
//        b4=[R] Rouge River, North ticket
//        b5=
//        b6=[R] Rouge River, West minigame (Toto vs Lobsters)
//        b7=[R] Poppy Fields minigame bone (Follow the Path)
function ticket_b_zaffer_forest_maze_house_2() => bit0(0x01F7)
function ticket_b_zaffer_forest_maze_house_1() => bit1(0x01F7)
function ticket_b_azure_hedges_minigame_concentration() => bit2(0x01F7)
function ticket_b_azure_hedges_lower_path() => bit3(0x01F7)
function ticket_r_rouge_river_north() => bit4(0x01F7)
function ticket_r_rouge_river_west_minigame_toto_vs_lobsters() => bit6(0x01F7)
function ticket_r_poppy_fields_minigame_bone_follow_the_path() => bit7(0x01F7)

// $01F8: Tickets Collected Bitfield #4 [8 bit]
//        b0=[P] Lavender Gardens top ticket
//        b1=[P] Mauve Castle top left ticket
//        b2=
//        b3=
//        b4=[B] Navy Village treetops ticket
//        b5=[B] Indigo Palace top ticket
//        b6=[B] Smalt Furnace left side ticket
//        b7=
function ticket_p_lavender_gardens_top() => bit0(0x01F8)
function ticket_p_mauve_castle_top_left() => bit1(0x01F8)
function ticket_b_navy_village_treetops() => bit4(0x01F8)
function ticket_b_indigo_palace_top() => bit5(0x01F8)
function ticket_b_smalt_furnace_left_side() => bit6(0x01F8)

// $01F9: Tickets Collected Bitfield #5 [8 bit]
//        b0=??
//        b1=??
//        b2=??
//        b3=
//        b4=[P] Yellow/Purple Border bridge ticket
//        b5=[P] Lilac Forest low tree under clouds ticket
//        b6=[P] Mallow Marsh treetop ticket
//        b7=[P] Lavender Gardens minigame bone (Follow the Path)
function ticket_p_yellow_purple_border_bridge() => bit4(0x01F9)
function ticket_p_lilac_forest_low_tree_under_clouds() => bit5(0x01F9)
function ticket_p_mallow_marsh_treetop() => bit6(0x01F9)
function ticket_p_lavender_gardens_minigame_bone_follow_the_path() => bit7(0x01F9)

// $01FB: Tickets - Yellow [8 bit]
function tickets_yellow() => byte(0x01FB)

// $01FD: Tickets - Red [8 bit]
function tickets_red() => byte(0x01FD)

// $01FF: Tickets - Blue [8 bit]
function tickets_blue() => byte(0x01FF)

// $0201: Tickets - Purple [8 bit]
function tickets_purple() => byte(0x0201)

// $0207: Character X Position [16 bit]
//        camera-relative value
function player_cam_x() => word(0x0207)

// $0215: Character Y Position [16 bit]
//        stage-relative value
function stage_y() => word(0x0215)

// $0217: Character X Position [16 bit]
//        stage-relative value
function stage_x() => word(0x0217)

// $0239: Music: 0=Off, 2=On [8 bit]
function music() => byte(0x0239)

// $023B: Sound: 0=Off, 2=On [8 bit]
function sound() => byte(0x023B)

// $023D: Minigame ID [8 bit]
//        0x00=no minigame
//        0x01=Hidden Message @ Shy Village
//        0x02=Lemon Drop @ Maize Meadow
//        0x03=Toto vs Mice @ Lemon Trees
//        0x04=Follow the Path @ Poppy Fields
//        0x05=Toto vs Lobsters @ Rouge River, West Fork
//        0x06=Scrambled Concentration @ Azure Hedges
//        0x07=Follow the Path @ Lavender Gardens
function minigame_id() => byte(0x023D)

// $0263: [Several Minigames] Current Tile Index [8 bit]
//        [01] 8 per row, 40 in total
//        [02] 7 per row, 0x24 = dice roll button
//        1-6 start at 0x08, 7-12 start at 0x16
//        [03] 11 per row, strange numbering
//        start at 0x26, top left = 0x0c, target = 0x68
//        [04] 9 per row, 81 in total, target = 0x1a
//        [05] same as minigame 03 (toto vs mice)
//        [07] 15 per row (only 14 actually accessible)
//        start at 0x2d, bottom right = 0x85, target = 0x4b
function minigame_tile_index() => byte(0x0263)

// $0267: [All Minigames] Frames until bark [16 bit]
//        starts at 0x140 (320 = 4 seconds)
//        moving sets this to 0x140 again
//        after bark, randomly sets value (up to 0x200?)
//        
//        [Minigame = 06] This gets set from 0x140 in the instructions card to 0x010 during the minigame. Used to detect the game starting or being reset.
function minigame_timer_tracker() => word(0x0267)

// $026F: [Minigame = 06] Highlighted square [8 bit]
//        7 per row, 6 rows, 0x29 = last square
function concentration_highlighted_square() => byte(0x026F)

// $027D: [Minigame = 06] Frames until scramble [8 bit]
//        reset to 220 frames on scramble/match
function concentration_scramble() => byte(0x027D)

// $0285: [Minigame = 06] First selected type [8 bit]
//        mapping same as 0x001700
function concentration_first_selected_type() => byte(0x0285)

// $0289: [Minigame = 06] Concentration Progress [8 bit]
//        counts up from 0 to 14
function concentration_progress() => byte(0x0289)

// $028F: [Map] Level ID [8 bit]
//        0x00=Shy Village
//        0x01=Gamboge Gorge
//        0x02=Maize Meadow
//        0x03=Saffron Fields
//        0x04=Xanthin Farms
//        0x05=Lemon Trees
//        0x06=Citron City
//        0x07=Yellow/Red Border
//        0x08=Rouge River, North Fork
//        0x09=Poppy Fields
//        0x0A=Cinnabar City
//        0x0B=Carnelian Forest
//        0x0C=Scarlet Marsh
//        0x0D=Rouge River, West Fork
//        0x0E=Crimson Caves
//        0x0F=Red/Blue Border
//        0x10=Zaffer Forest
//        0x11=Azure Hedges
//        0x12=Navy Village
//        0x13=Smalt Furnace
//        0x14=Indigo Palace
//        0x15=Cyan City
//        0x16=Blue/Purple Border
//        0x17=Mallow Marsh
//        0x18=Mauve Castle
//        0x19=Amethyst Mountains
//        0x1A=Lilac Forest
//        0x1B=Lavender Gardens
//        0x1C=Yellow/Purple Border
//        0x1D=Emerald City
function map_level_id() => byte(0x028F)

// $029F: Overworld Map ID [8 bit]
//        00=Yellow Country
//        01=Red Country
//        02=Blue Country
//        03=Purple Country
//        04=Emerald City
function overworld_map_id() => byte(0x029F)

// $02A9: [Minigame = 01] Hidden Message Current Length [8 bit]
function hidden_message_currlen() => byte(0x02A9)

// $02DB: [All Minigames] Steps Taken [16 bit]
//        resets to 0 at start and when Toto barks
function all_minigames_steps_taken() => word(0x02DB)

// $02ED: [Minigame = 01] Incorrect Counter [8 bit]
//        if the input is correct, =0
//        otherwise, counts up starting from the first incorrect tile
function hidden_message_incorrect_counter() => byte(0x02ED)

// $05BC: Boss Health [16 bit]
//        counts down, death when value <0
function boss_health() => word(0x05BC)

// $09A1: Mallow Marsh - Scarecrow 1up Collected [8 bit]
//        00=Uncollected
//        80=Collected
//        
//        Part of an array of (8) byte objects:
//        +0 = Unknown
//        +1 = Object ID
//        +2 = (16) bit X position
//        +4 = (16) bit Y position
//        +6 = Unknown
//        +7 = Status Bitflags
//        b7=collected
function mallow_marsh_scarecrow_1up_collected() => bit7(0x09A1)

// $108C: [Minigame = 02] Used Numbers [24 bytes]
//        even bytes = 0/1 depending on if number is used
function lemon_drop_used_numbers(i) => byte(0x108C + 2*i)

// $10A2: [Minigame = 01] Hidden Message Tiles [40 bytes]
//        left to right, top to bottom
//        left column for buttons, unused
//        00=Used
//        01=Available
function tile_used(i) => byte(0x10A2 + i)

// $10F0: [Minigame = 02] Die #1 (val - 1) [8 bit]
function die_1() => byte(0x10F0)

// $10F2: [Several Minigames] Various [8 bit]
//        [02] Die #2 (val - 1)
//        [05] Number of Lobsters Jumped
function die_2() => byte(0x10F2)
function lobsters_jumped() => byte(0x10F2)

// $1700: [Minigame = 06] Board Contents [86 bytes]
//        two bytes for some boilerplate, seems to always be 0e 00
//        
//        84 bytes representing 42 squares of the board, mapping enumerated below, 00s inserted between. (note: empty cells are just skipped, not marked with a sentinel)
//        
//        0x00 = Toto
//        0x01 = Lobster
//        0x02 = Lemon Drop
//        0x03 = Blue Bird
//        0x04 = Oz Flag
//        0x05 = White Mushroom
//        0x06 = Apple
//        0x07 = Flower
//        0x08 = Faucet
//        0x09 = Rat
//        0x0a = Crow
//        0x0b = Spring Onion
//        0x0c = Vulture
//        0x0d = Orange Cat
function board_contents(i) => byte(0x1702 + i)

// $19BD: Lemon Drop Elimination In-Game Indicator [8 bit]
//        01=In-Game
//        *=Not in Game
function in_lemon_drop() => byte(0x19BD)

// --- MAIN DATA -------------------------------------------------------------------

LEVEL_SHY_VILLAGE = 0x01
LEVEL_GAMBOGE_GORGE = 0x02
LEVEL_MAIZE_MEADOW = 0x03
LEVEL_SAFFRON_FIELDS = 0x04
LEVEL_XANTHIN_FARMS = 0x05
LEVEL_LEMON_TREES = 0x06
LEVEL_CITRON_CITY = 0x07
LEVEL_YELLOW_BORDER = 0x08
LEVEL_ROUGE_RIVER_NORTH = 0x09
LEVEL_POPPY_FIELDS = 0x0A
LEVEL_CINNABAR_CITY = 0x0B
LEVEL_CARNELIAN_FOREST = 0x0C
LEVEL_SCARLET_MARSH = 0x0D
LEVEL_ROUGE_RIVER_WEST = 0x0E
LEVEL_CRIMSON_CAVES = 0x0F
LEVEL_RED_BORDER = 0x10
LEVEL_ZAFFER_FOREST = 0x11
LEVEL_AZURE_HEDGES = 0x12
LEVEL_NAVY_VILLAGE = 0x13
LEVEL_SMALT_FURNACE = 0x14
LEVEL_INDIGO_PALACE = 0x15
LEVEL_CYAN_CITY = 0x16
LEVEL_BLUE_BORDER = 0x17
LEVEL_MALLOW_MARSH = 0x18
LEVEL_MAUVE_CASTLE = 0x19
LEVEL_AMETHYST_MOUNTAINS = 0x1A
LEVEL_LILAC_FOREST = 0x1B
LEVEL_LAVENDER_GARDENS = 0x1C
LEVEL_PURPLE_BORDER = 0x1D
LEVEL_EMERALD_CITY = 0x1E

OVERWORLD_YELLOW = 0x00
OVERWORLD_RED = 0x01
OVERWORLD_BLUE = 0x02
OVERWORLD_PURPLE = 0x03
OVERWORLD_EMERALD = 0x04

CHAR_DOROTHY = 0x00
CHAR_SCARECROW = 0x02
CHAR_TINMAN = 0x04
CHAR_LION = 0x06

MINIGAME_NONE = 0
MINIGAME_TOTO_MESSAGE = 1
MINIGAME_LEMON_DROP = 2
MINIGAME_MICE = 3
MINIGAME_PATH_EASY = 4
MINIGAME_LOBSTERS = 5
MINIGAME_CONCENTRATION = 6
MINIGAME_PATH_HARD = 7

DENIAL_PATH = [
	0x09, 0x0A, 0x12, 0x13, 0x14, 0x1C, 0x1B, 0x23, 0x24,
	0x25, 0x1D, 0x1E, 0x16, 0x0E, 0x0D, 0x0C, 0x0B
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_level() => bit3(0x0039) == 1

function is_flying() => flight_timer() > 0

function complete_level(x) => game_state() == 0x200 && prev(level_progress()) == x && level_progress() == x+1

function win_the_game() => prev(game_state()) != 0x211 && game_state() == 0x211 && prior(level_id()) == LEVEL_EMERALD_CITY

function collect_ticket(level, ticket) => in_level() && level_id() == level && is_set(ticket)

function collect_all(level, tickets) => (
	in_level() && level_id() == level &&
	sum_of(tickets, x => prev(x)) < length(tickets) &&
	measured(sum_of(tickets, x => x) == length(tickets))
)

function build_path(path)
{
	trigger = (
		minigame_tile_index() == path[0] &&
		prev(hidden_message_currlen()) == 0 &&
		hidden_message_currlen() == 1
	)

	for i in range(1, length(path)-1)
		trigger = (
			once(trigger) &&
			prior(minigame_tile_index()) == path[i-1] &&
			minigame_tile_index() == path[i] &&
			prev(hidden_message_currlen()) == i &&
			hidden_message_currlen() == i+1
		)
	return trigger
}

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="If I Only Had a Brain",
	description="Rescue the Scarecrow and have him join your party",
	points=10,
	type="progression",
	trigger=(
		in_level() && level_id() == LEVEL_MAIZE_MEADOW && 
		prev(lives_scarecrow()) == 0x00 && lives_scarecrow() > 0x00
	)
)

achievement(
	title="Goldenrod Grandmaster",
	description="Complete Yellow Country on the way to the Emerald City",
	points=5,
	type="progression",
	trigger=complete_level(LEVEL_YELLOW_BORDER)
)

achievement(
	title="If I Only Had a Heart",
	description="Rescue the Tinman and have him join your party",
	points=10,
	type="progression",
	trigger=(
		in_level() && level_id() == LEVEL_CARNELIAN_FOREST && 
		prev(lives_tinman()) == 0x00 && lives_tinman() > 0x00
	)
)

achievement(
	title="Scarlet Superstar",
	description="Complete Red Country on the way to the Emerald City",
	points=5,
	type="progression",
	trigger=complete_level(LEVEL_RED_BORDER)
)

achievement(
	title="If I Only Had the Nerve",
	description="Rescue the Cowardly Lion and have him join your party",
	points=10,
	type="progression",
	trigger=(
		in_level() && level_id() == LEVEL_SMALT_FURNACE && 
		prev(lives_lion()) == 0x00 && lives_lion() > 0x00
	)
)

achievement(
	title="Periwinkle Prodigy",
	description="Complete Blue Country on the way to the Emerald City",
	points=5,
	type="progression",
	trigger=complete_level(LEVEL_BLUE_BORDER)
)

achievement(
	title="My Beautiful Wickedness!",
	description="\"I'm melting! I'm melting!\" etc, etc, and so on",
	points=10,
	type="progression",
	trigger=(
		level_id() == LEVEL_MAUVE_CASTLE && 
		prev(boss_health()) < 0x1000 && 
		boss_health() > 0xFF00
	)
)

achievement(
	title="Violet Virtuoso",
	description="Complete Purple Country on the way to the Emerald City",
	points=5,
	type="progression",
	trigger=complete_level(LEVEL_PURPLE_BORDER)
)

achievement(
	title="There's No Place Like Home",
	description="Deliver the ruby slippers to the Wizard of Oz in the Emerald City",
	points=25,
	type="win_condition",
	trigger=win_the_game()
)

achievement(
	title="And You Were There...",
	description="Reach the Wizard of Oz with the Scarecrow, the Tinman, and the Cowardly Lion",
	points=25,
	type="missable",
	trigger=(
		win_the_game() &&
		lives_dorothy() > 0x00 && 
		lives_scarecrow() > 0x00 && 
		lives_tinman() > 0x00 && 
		lives_lion() > 0x00
	)
)

achievement(
	title="Getting Lost in Shy Village",
	description="Collect the yellow ticket in the Shy Village Maze House",
	points=3,
	trigger=collect_ticket(LEVEL_SHY_VILLAGE, ticket_y_shy_village_maze_house())
)

achievement(
	title="Gale in the Gorge",
	description="Collect the yellow ticket in Gamboge Gorge",
	points=3,
	trigger=collect_ticket(LEVEL_GAMBOGE_GORGE, ticket_y_gamboge_gorge_hole())
)

achievement(
	title="Milling About in Saffron Fields",
	description="Collect the yellow ticket in the Saffron Fields mill",
	points=3,
	trigger=collect_ticket(LEVEL_SAFFRON_FIELDS, ticket_y_saffron_fields_mill())
)

achievement(
	title="Lofty Heights in Saffron Fields",
	description="Collect the yellow ticket in the Saffron Fields barn",
	points=3,
	trigger=collect_ticket(LEVEL_SAFFRON_FIELDS, ticket_y_saffron_fields_barn())
)

achievement(
	title="Swept Away in the Rouge River",
	description="Collect the red ticket in Rouge River, North Fork",
	points=3,
	trigger=collect_ticket(LEVEL_ROUGE_RIVER_NORTH, ticket_r_rouge_river_north())
)

achievement(
	title="Petal Pursuit in the Poppies",
	description="Collect the red ticket in the flowers of Poppy Fields",
	points=3,
	trigger=collect_ticket(LEVEL_POPPY_FIELDS, ticket_r_poppy_fields_flower())
)

achievement(
	title="Swinging in the Eaves",
	description="Collect the red ticket on the rooftops of Cinnabar City",
	points=3,
	trigger=collect_ticket(LEVEL_CINNABAR_CITY, ticket_r_cinnabar_city_roof())
)

achievement(
	title="In the Canopies of Carnelian Forest",
	description="Collect the red ticket in the treetops of Carnelian Forest",
	points=3,
	trigger=collect_ticket(LEVEL_CARNELIAN_FOREST, ticket_r_carnelian_forest_trees())
)

achievement(
	title="Scarlet Marsh's Best Kept Secret",
	description="Collect the red ticket hiding in Scarlet Marsh",
	points=3,
	trigger=collect_ticket(LEVEL_SCARLET_MARSH, ticket_r_scarlet_marsh_top_end())
)

achievement(
	title="Spelunking in Crimson Caves",
	description="Collect the red ticket just out of reach in Crimson Caves",
	points=3,
	trigger=collect_ticket(LEVEL_CRIMSON_CAVES, ticket_r_crimson_caves_start())
)

achievement(
	title="Trapped in the Zaffer Maze",
	description="Collect both blue tickets in the Zaffer Forest Maze House",
	points=5,
	trigger=collect_all(LEVEL_ZAFFER_FOREST, [
		ticket_b_zaffer_forest_maze_house_1(),
		ticket_b_zaffer_forest_maze_house_2()
	])
)

achievement(
	title="Air Force in Navy Village",
	description="Collect the blue ticket in the treetops of Navy Village",
	points=3,
	trigger=collect_ticket(LEVEL_NAVY_VILLAGE, ticket_b_navy_village_treetops())
)

achievement(
	title="Oz's Furnace Fun",
	description="Collect the blue ticket in the pipeworks of Smalt Furnace",
	points=3,
	trigger=collect_ticket(LEVEL_SMALT_FURNACE, ticket_b_smalt_furnace_left_side())
)

achievement(
	title="Out of Time in Indigo Palace",
	description="Collect the blue ticket at the top of Indigo Palace",
	points=3,
	trigger=collect_ticket(LEVEL_INDIGO_PALACE, ticket_b_indigo_palace_top())
)

achievement(
	title="Terrapin Ticket in Azure Hedges",
	description="Collect the blue ticket guarded by the topiaries of Azure Hedges",
	points=3,
	trigger=collect_ticket(LEVEL_AZURE_HEDGES, ticket_b_azure_hedges_lower_path())
)

achievement(
	title="A Sweet Treat in Mallow Marsh",
	description="Collect the purple ticket in the treetops of Mallow Marsh",
	points=3,
	trigger=collect_ticket(LEVEL_MALLOW_MARSH, ticket_p_mallow_marsh_treetop())
)

achievement(
	title="Storming the Mauve Castle",
	description="Collect the purple ticket in the battlements of Mauve Castle",
	points=3,
	trigger=collect_ticket(LEVEL_MAUVE_CASTLE, ticket_p_mauve_castle_top_left())
)

achievement(
	title="In the Shadow of the Lilac Clouds",
	description="Collect the purple ticket in the shade of the Lilac Forest",
	points=3,
	trigger=collect_ticket(LEVEL_LILAC_FOREST, ticket_p_lilac_forest_low_tree_under_clouds())
)

achievement(
	title="Stargazing in the Lavender Gardens",
	description="Collect the purple ticket in the hedgerow of the Lavender Gardens",
	points=3,
	trigger=collect_ticket(LEVEL_LAVENDER_GARDENS, ticket_p_lavender_gardens_top())
)

achievement(
	title="It's Just There for the Taking",
	description="Collect the purple ticket on the Yellow-Purple Border",
	points=3,
	trigger=collect_ticket(LEVEL_PURPLE_BORDER, ticket_p_yellow_purple_border_bridge())
)

achievement(
	title="Toto Finds the Hidden Message",
	description="Complete the Toto minigame in Shy Village to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_SHY_VILLAGE, ticket_y_shy_village_minigame_bone_hidden_message())
)

achievement(
	title="Toto Dodges the Mouse Gang",
	description="Complete the Toto minigame in Lemon Trees to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_LEMON_TREES, ticket_y_lemon_trees_minigame_bone_toto_vs_mice())
)

achievement(
	title="Toto Follows the Path",
	description="Complete the Toto minigame in Poppy Fields to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_POPPY_FIELDS, ticket_r_poppy_fields_minigame_bone_follow_the_path())
)

achievement(
	title="Toto Jumps the Lobsters",
	description="Complete the Toto minigame in Rouge River, West Fork to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_ROUGE_RIVER_WEST, ticket_r_rouge_river_west_minigame_toto_vs_lobsters())
)

achievement(
	title="Toto Matches Three-of-a-Kind",
	description="Complete the Toto minigame in Azure Hedges to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_AZURE_HEDGES, ticket_b_azure_hedges_minigame_concentration())
)

achievement(
	title="Toto Follows the Path Again",
	description="Complete the familiar Toto minigame in Lavender Gardens to earn a ticket",
	points=3,
	trigger=collect_ticket(LEVEL_LAVENDER_GARDENS, ticket_p_lavender_gardens_minigame_bone_follow_the_path())
)

achievement(
	title="Orange You Glad We Fixed It?",
	description="Place all 79 yellow bricks to make safe the Yellow-Red Border",
	points=10,
	trigger=(
		measured(
			bcd(bricks_placed_yellow()) >= 79, 
			when=in_level() && level_id() == LEVEL_YELLOW_BORDER
		) &&
		prev(bricks_yellow()) > 0 && bricks_yellow() == 0
	)
)

achievement(
	title="The Purplexing Road",
	description="Place all 86 red bricks to make safe the Red-Blue Border",
	points=10,
	trigger=(
		measured(
			bcd(bricks_placed_red()) >= 86, 
			when=in_level() && level_id() == LEVEL_RED_BORDER
		) &&
		prev(bricks_red()) > 0 && bricks_red() == 0
	)
)

achievement(
	title="This Bridge Indigoing to Build Itself",
	description="Place all 92 blue bricks to make safe the Blue-Purple Border",
	points=10,
	trigger=(
		measured(
			bcd(bricks_placed_blue()) >= 92, 
			when=in_level() && level_id() == LEVEL_BLUE_BORDER
		) &&
		prev(bricks_blue()) > 0 && bricks_blue() == 0
	)
)

achievement(
	title="The Technicolor Trail of Oz",
	description="Place all 98 purple bricks to make safe the Yellow-Purple Border",
	points=10,
	trigger=(
		measured(
			bcd(bricks_placed_purple()) >= 98, 
			when=in_level() && level_id() == LEVEL_PURPLE_BORDER
		) &&
		prev(bricks_purple()) > 0 && bricks_purple() == 0
	)
)

achievement(
	title="Broken Bridges in Winkie Country",
	description="Without flying, cross the Yellow-Red Border with no more than 20 yellow bricks placed",
	points=10,
	type="missable",
	trigger=(
		once(
			in_level() && level_id() == LEVEL_YELLOW_BORDER && 
			bricks_placed_yellow() <= 20 && stage_x() <= 0x96
		) &&
		trigger_when(stage_x() >= 0x79E) &&
		never(is_flying()) &&
		never(!in_level()) &&
		never(bricks_placed_yellow() > 20) &&
		never(level_id() != LEVEL_YELLOW_BORDER)
	)
)

achievement(
	title="Broken Bridges in Quadling Country",
	description="Without flying, cross the Red-Blue Border with no more than 20 red bricks placed",
	points=10,
	type="missable",
	trigger=(
		once(
			in_level() && level_id() == LEVEL_RED_BORDER && 
			bricks_placed_red() <= 20 && stage_x() <= 0x96
		) &&
		trigger_when(stage_x() >= 0x79E) &&
		never(is_flying()) &&
		never(!in_level()) &&
		never(bricks_placed_red() > 20) &&
		never(level_id() != LEVEL_RED_BORDER)
	)
)

achievement(
	title="Broken Bridges in Munchkin Country",
	description="Without flying, cross the Blue-Purple Border with no more than 20 blue bricks placed",
	points=10,
	type="missable",
	trigger=(
		once(
			in_level() && level_id() == LEVEL_BLUE_BORDER && 
			bricks_placed_blue() <= 20 && stage_x() <= 0x96
		) &&
		trigger_when(stage_x() >= 0x79E) &&
		never(is_flying()) &&
		never(!in_level()) &&
		never(bricks_placed_blue() > 20) &&
		never(level_id() != LEVEL_BLUE_BORDER)
	)
)

achievement(
	title="Broken Bridges in Gillikin Country",
	description="Without flying, cross the Purple-Yellow Border with no more than 20 purple bricks placed",
	points=10,
	type="missable",
	trigger=(
		once(
			in_level() && level_id() == LEVEL_PURPLE_BORDER && 
			bricks_placed_purple() <= 20 && stage_x() <= 0x96
		) &&
		trigger_when(stage_x() >= 0x79E) &&
		never(is_flying()) &&
		never(!in_level()) &&
		never(bricks_placed_purple() > 20) &&
		never(level_id() != LEVEL_PURPLE_BORDER)
	)
)

achievement(
	title="Toto in Denial",
	description="Refuse to accept reality in the Find the Hidden Message minigame",
	points=5,
	type="missable",
	trigger=(
		build_path(DENIAL_PATH) &&
		never(minigame_id() != MINIGAME_TOTO_MESSAGE) &&
		never(minigame_tile_index() == 0x10)
	)
)

achievement(
	title="Toto vs the Wizard of Odds",
	description="Clear 10 numbers in the Lemon Drop Elimination minigame",
	points=10,
	trigger=(
		level_id() == LEVEL_MAIZE_MEADOW &&
		measured(12 - sum_of(range(0,11), i => lemon_drop_used_numbers(i) / lemon_drop_used_numbers(i)) == 0x0A,
			when=minigame_id() == MINIGAME_LEMON_DROP && in_lemon_drop() == 0x01
		)
	)
)

achievement(
	title="Toto Chases His Tail",
	description="Get trapped in an infinite loop in Toto's Follow the Path minigame in Poppy Fields",
	points=1,
	type="missable",
	trigger=(
		level_id() == LEVEL_POPPY_FIELDS &&
		measured(repeated(3,
			prev(minigame_tile_index()) != 0x48 && minigame_tile_index() == 0x48),
			when=minigame_id() == MINIGAME_PATH_EASY
		) && never(minigame_tile_index() == 0x12)
	)
)

achievement(
	title="A Pincer Maneuver",
	description="Clear 8+ lobsters in the Toto vs Lobsters minigame",
	points=5,
	type="missable",
	trigger=(
		game_state_byte() == 0x1F && 
		level_id() == LEVEL_ROUGE_RIVER_WEST &&
		measured(
			lobsters_jumped() >= 8,
			when=minigame_id() == MINIGAME_LOBSTERS
		)
	)
)

achievement(
	title="Toto Cracks the Scramble",
	description="Complete the Scrambled Concentration minigame without failing to make a match 3 or more times",
	points=10,
	type="missable",
	trigger=(
		level_id() == LEVEL_AZURE_HEDGES &&
		once(prev(minigame_timer_tracker()) == 0x140 && minigame_timer_tracker() == 0x10) &&
		trigger_when(concentration_progress() == 0x0E) &&
		never(minigame_timer_tracker() == 0x140) &&
		never(minigame_id() != MINIGAME_CONCENTRATION) &&
		never(repeated(3,
			prev(concentration_scramble()) != 0xDC && 
			concentration_scramble() == 0xDC &&
			prev(concentration_progress()) == concentration_progress()
		))
	)
)

achievement(
	title="Staying Dry in Scarlet Marsh",
	description="Cross Scarlet Marsh without ever falling into the water",
	points=5,
	trigger=(
		once(stage_x() < 0xBE) &&
		trigger_when(stage_x() > 0x5DC && prev(in_level()) && game_state() == 0x00) &&
		never(level_id() != LEVEL_SCARLET_MARSH) && 
		never(prev(!in_level())) &&
		never(stage_y() < 0x8000 && stage_y() > 0x1B3)
	)
)

achievement(
	title="Tugging On My Heartstrings",
	description="Help out a friend by collecting the Scarecrow's extra life in Mallow Marsh as the Tinman",
	points=2,
	type="missable",
	trigger=(
		in_level() && level_id() == LEVEL_MALLOW_MARSH && 
		current_character() == CHAR_TINMAN &&
		is_set(mallow_marsh_scarecrow_1up_collected())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Scramble Sprint",
	description="Unscramble Toto's Concentration minigame as quickly as possible",

	start=(
		minigame_id() == MINIGAME_CONCENTRATION && 
		prev(minigame_timer_tracker()) == 0x140 &&
		minigame_timer_tracker() == 0x10
	),
	cancel=minigame_id() != MINIGAME_CONCENTRATION,
	submit=concentration_progress() == 0x0E,

	value=measured(tally(0, always_true())) && never(minigame_timer_tracker() == 0x140),
	format="FRAMES",
	lower_is_better=true
)
