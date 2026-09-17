// Dizzy IV: Magicland Dizzy
// #ID = 19499
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

// --- MEMORY -------------------------------------------------------------------

// $3F04: Object Table [? bytes]
//        each object is 15 bytes, item indices listed at 0x5721
//        other indices listed at the bottom of this note
//        
//        +0 | Screen [8 bit]
//        +2 | X position [8 bit]
//        +3 | Y position [8 bit]
//        
//        indices: (multiply by 15)
//        2 = Zaks
//        3 = castle backdoor
//        4 = ice palace dungeon wall
//        15 = left pacman ghost
//        16 = right pacman ghost
//        18 = goat
//        19 = goat rope
//        20 = bridge troll
//        40 = red chess queen
//        42 = Dora (next to Prince)
//        54 = Dozy
//        54 = Denzil on ice
//        55 = Dylan
//        56 = Daisy
//        57 = Grand-Dizzy
//        58 = Prince Charming
//        61 = Satan
OBJECT_TABLE = 0x3F04

// $401B: Goat State [8 bit]
//        0 = tied up
//        1 = rope cut
//        2 = running
function goat_state() => byte(0x401B)

// $42A0: Talked to Hades [8 bit] (room=0x70)
//        0 = not talked
//        1 = talked
function talked_to_hades() => byte(0x42A0)

// $42CD: Dylan State [8 bit]
//        0 = initial state
//        1 = cut a leaf off the bush
function dylan_state() => byte(0x42CD)

// $4408: Devil State [8 bit]
//        0 = Zaks' ring not destroyed
//        1 = Zaks' ring destroyed
function devil_state() => byte(0x4408)

// $44F4: Talked to Prince Charming [8 bit] (room=0x4d)
//        0 = not talked
//        1 = talked
function talked_to_prince_charming() => byte(0x44F4)

// $44F5: Talked to Glenda [8 bit] (room=0x55)
//        0 = not talked
//        1 = talked
function talked_to_glenda() => byte(0x44F5)

// $44F6: Talked to Bard [8 bit] (room=0x33)
//        0 = not talked
//        1 = talked
function talked_to_bard() => byte(0x44F6)

// $44F7: Talked to Daisy [8 bit] (room=0x4a)
//        0 = not talked
//        1 = talked
function talked_to_daisy_room_0x4a() => byte(0x44F7)

// $44F9: Talked to Dylan [8 bit] (room=0x51)
//        0 = not talked
//        1 = talked
function talked_to_dylan() => byte(0x44F9)

// $44FA: Talked to Daisy [8 bit] (room=0x74)
//        0 = not talked
//        1 = talked
function talked_to_daisy_room_0x74() => byte(0x44FA)

// $4EF8: Talked to Denzil [8 bit] (room=0x47)
//        0xFF = not talked
//        0x00 = talked
function talked_to_denzil() => byte(0x4EF8)

// $5721: Inventory #1 [8 bit]
//        0x3e = Some Magic Pipes
//        0x3f = A Personal Stereo
//        0x40 = A Dagger
//        0x41 = An Ancient Lamp
//        0x42 = A Cloth Duster
//        0x43 = A Lightning Rod
//        0x44 = A Black Cat
//        0x45 = A Leaf
//        0x46 = A Burning Torch
//        0x47 = A Poisoned Apple
//        0x48 = Weedkiller Potion
//        0x49 = The 'Drinkme' Potion
//        0x4a = The 'Eatme' Cake
//        0x4b = A Big Stick
//        0x4c = The Gold Cross
//        0x4d = Something Sticky
//        0x4e = Excalibur
//        0x4f = The Power Pill
//        0x50 = The Handle
//        0x51 = A Bucket
//        0x52 = A Bucket of Hot Water
//        0x53 = Dora Frog
//        0x54 = Wizardslayer Trident
//        0x55 = Zaks' Ring
//        0x56 = Backdoor Key
//        0x57 = A Bag of Rubbish
//        0x58 = Empty Milk Bottle
//        0x59 = A Railing
//        0x5a = A Railing
//        0x5b = A Railing
function inventory(i) => byte(0x5721 + i)

// $E679: Daisy Scale [8 bit]
//        3 = big
//        5 = giant (crush)
function daisy_scale() => byte(0xE679)

// $EF7E: Dizzy X [8 bit]
//        left is 0x02
//        right is 0x38
function dizzy_x() => byte(0xEF7E)

// $EF7F: Dizzy Y [8 bit]
//        top is 0x43
//        bottom is 0xb5
function dizzy_y() => byte(0xEF7F)

// $EF82: Dizzy Y Speed [8 bit]
//        0xf9 (-7) when jumping, terminal velocity is 0x07
function dizzy_y_velocity() => byte(0xEF82)

// $EF85: On Ground [8 bit]
//        0 = not grounded
//        1 = grounded
function grounded() => byte(0xEF85)

// $EF94: Room [8 bit]
//        0x00 = title screen
//        0x01 = Zaks' room ("Zaks' Tower")
//        0x02 = ending screen ("Congratulations!")
//        0x09 = top of the tallest castle tower ("The Tallest Tower")
//        0x17 = top of Zaks' west tower ("West Tower")
//        0x18 = climbing Zaks' east tower ("Zaks' Tower")
//        0x20 = climbing the tall castle tower ("The Tallest Tower")
//        0x21 = right of tall castle tower ("Sky")
//        0x22 = off the left of east treehouse ("Sky")
//        0x23 = top of east treehouse ("The Tree Top")
//        0x24 = top of the monolith ("Top of the Monolith")
//        0x2a = above the volcano ("The Harpy's Eyrie")
//        0x2c = left chess room ("Curiouser and Curiouser")
//        0x2d = right chess room ("The Chessboard")
//        0x2e = Zaks' west tower ("Mirror, Mirror?")
//        0x2f = Zaks' east tower ("Zaks' Tower")
//        0x33 = bard's house ("The Bard's Treehouse")
//        0x34 = east of bard's house ("Out on a Limb")
//        0x35 = castle 2nd floor west ("The Watch-Tower")
//        0x36 = castle 2nd floor chapel ("The Chapel")
//        0x37 = top of castle stairs ("The Upper Gallery")
//        0x38 = castle 2nd floor bedroom ("A Tower With a View")
//        0x39 = clouds above the well ("In the Clouds")
//        0x3a = middle of east treehouse ("Up a Tree")
//        0x3b = halfway up strange monolith ("Up the Monolith")
//        0x40 = west of volcano ("Climbing a Volcano")
//        0x41 = volcano caldera ("The Dormant Volcano")
//        0x42 = east of volcano ("Hellgate")
//        0x45 = Zaks' main hall ("Main Hall")
//        0x46 = Zaks' entrance hall ("Entrance Hall")
//        0x47 = outside Zaks' castle ("Ice Palace Entrance")
//        0x48 = left bridge ("Across the Bridge")
//        0x49 = right bridge ("The Trollbridge")
//        0x4a = bottom of west treehouse, Dozy sleeping ("Sleepy Hollow")
//        0x4b = west of castle ("The Sword in the Stone")
//        0x4c = drawbridge ("The Drawbridge")
//        0x4d = throne room ("The Throne Room")
//        0x4e = castle stairs ("The Grand Hall")
//        0x4f = shark moat ("Castle Back Door")
//        0x50 = top of the well ("Ye Olde Well")
//        0x51 = at the bottom of east treehouse ("Bushy Grove")
//        0x52 = bottom of tower ("The Mysterious Monolith")
//        0x53 = weirdhenge ("Weirdhenge")
//        0x54 = ghost swamp ("The Haunted Swamp")
//        0x55 = witch's island ("Good Witch Glenda's Isle")
//        0x56 = east swamp ("The Haunted Swamp")
//        0x57 = bottom of volcano ("The Hot Water Geyser")
//        0x59 = down into hell ("Descent Into the Depths")
//        0x5c = Zak's mother's room ("The Crypt")
//        0x65 = dungeon under castle ("The Forgotten Dungeon")
//        0x66 = passage in the well ("The Secret Passage")
//        0x67 = middle of the well ("Down a Well")
//        0x6f = left of devil's room ("The Cracks of Gehenna")
//        0x70 = devil's room ("Hades")
//        0x73 = basement of Zaks' castle ("The Deepest Dungeon")
//        0x74 = Daisy room in Zaks' castle basement ("The Oubliette")
//        0x7e = bottom of the well ("Sticky End")
function room() => byte(0xEF94)

// $EF95: Loading Room [8 bit]
//        change this value to warp
function loading_room() => byte(0xEF95)

// $EF9B: Diamond Count [8 bit]
function diamond_count() => byte(0xEF9B)

// $EF9C: Health [8 bit]
//        0x1F = full health
//        0x00 = dead
function health() => byte(0xEF9C)

// $EF9D: Displayed Health [8 bit]
//        follows 0xef9c
function displayed_health() => byte(0xEF9D)

// $EF9E: Lives [8 bit]
//        starts at 3, game over at 0
//        should serve as an in-game check
function lives() => byte(0xEF9E)

// $EFB7: Number of Torches [8 bit]
//        seems to match the number of torches on screen
function number_of_torches() => byte(0xEFB7)

// $EFCC: Jumping [8 bit]
//        0 = not jumping
//        1 = jumping
function jump_input() => byte(0xEFCC)

// --- MAIN DATA -------------------------------------------------------------------

OBJ_ZAKS = 2
OBJ_CASTLE_BACKDOOR = 3
OBJ_ICE_DUNGEON_WALL = 4
OBJ_GHOST_LEFT = 15
OBJ_GHOST_RIGHT = 16
OBJ_GOAT = 18
OBJ_GOAT_ROPE = 19
OBJ_BRIDGE_TROLL = 20
OBJ_CHESS_QUEEN = 40
OBJ_DORA_CASTLE = 42
OBJ_DOZY = 54
OBJ_DENZIL = 54
OBJ_DYLAN = 55
OBJ_DAISY = 56
OBJ_GRAND_DIZZY = 57
OBJ_PRINCE = 58
OBJ_SATAN = 61

ROOM_NAME = {
	// default: "Sky"
	0x00: "Title Screen",
	0x01: "Zaks' Tower",
	0x02: "Congratulations!",
	0x09: "The Tallest Tower",
	0x17: "West Tower",
	0x18: "Zaks' Tower",
	0x20: "The Tallest Tower",
	0x23: "The Tree Top",
	0x24: "Top of the Monolith",
	0x2a: "The Harpy's Eyrie",
	0x2c: "Curiouser and Curiouser",
	0x2d: "The Chessboard",
	0x2e: "Mirror, Mirror?",
	0x2f: "Zaks' Tower",
	0x33: "The Bard's Treehouse",
	0x34: "Out on a Limb",
	0x35: "The Watch-Tower",
	0x36: "The Chapel",
	0x37: "The Upper Gallery",
	0x38: "A Tower With a View",
	0x39: "In the Clouds",
	0x3a: "Up a Tree",
	0x3b: "Up the Monolith",
	0x40: "Climbing a Volcano",
	0x41: "The Volcano",
	0x42: "Hellgate",
	0x45: "Main Hall",
	0x46: "Entrance Hall",
	0x47: "Ice Palace Entrance",
	0x48: "Across the Bridge",
	0x49: "The Trollbridge",
	0x4a: "Sleepy Hollow",
	0x4b: "The Sword in the Stone",
	0x4c: "The Drawbridge",
	0x4d: "The Throne Room",
	0x4e: "The Grand Hall",
	0x4f: "Castle Back Door",
	0x50: "Ye Olde Well",
	0x51: "Bushy Grove",
	0x52: "The Mysterious Monolith",
	0x53: "Weirdhenge",
	0x54: "The Haunted Swamp",
	0x55: "Good Witch Glenda's Isle",
	0x56: "The Haunted Swamp",
	0x57: "The Hot Water Geyser",
	0x59: "Descent Into the Depths",
	0x5c: "The Crypt",
	0x65: "The Forgotten Dungeon",
	0x66: "The Secret Passage",
	0x67: "Down a Well",
	0x6f: "The Cracks of Gehenna",
	0x70: "Hades",
	0x73: "The Deepest Dungeon",
	0x74: "The Oubliette",
	0x7e: "Sticky End",
}

// follows "Dizzy is..."
ROOM_DESC = {
	// default: "in the sky"
	0x00: "on the title screen",
	0x01: "in the evil wizard Zaks' tower",
	0x02: "victorious, at the end of the game",
	0x09: "at the top of the tallest castle tower",
	0x17: "at the top of Zaks' west tower",
	0x18: "climbing Zaks' east tower",
	0x20: "climbing the tall castle tower",
	0x23: "atop the east treehouse",
	0x24: "atop the mysterious monolith",
	0x2a: "above the volcano",
	0x2c: "inside the looking glass",
	0x2d: "inside the looking glass",
	0x2e: "climbing Zaks' west tower",
	0x2f: "climbing Zaks' east tower",
	0x33: "outside the bard's house",
	0x34: "east of the bard's house",
	0x35: "inside the castle",
	0x36: "inside the castle",
	0x37: "inside the castle",
	0x38: "inside the castle",
	0x39: "above the well",
	0x3a: "climbing the east treehouse",
	0x3b: "halfway up the mysterious monolith",
	0x40: "climbing the volcano",
	0x41: "standing on the volcano caldera",
	0x42: "entering the volcano tunnels",
	0x45: "inside Zaks' main hall",
	0x46: "in Zaks' entrance hall",
	0x47: "outside Zaks' castle",
	0x48: "crossing the troll bridge",
	0x49: "at the troll bridge",
	0x4a: "beneath the west treehouse",
	0x4b: "beneath the west treehouse",
	0x4c: "inside the castle",
	0x4d: "inside the castle",
	0x4e: "inside the castle",
	0x4f: "at the castle backdoor",
	0x50: "near the well",
	0x51: "at the bottom of east treehouse",
	0x52: "at the base of the mysterious monolith",
	0x53: "visiting Weirdhenge",
	0x54: "crossing the ghostly swamp",
	0x55: "visiting the witch's island",
	0x56: "crossing the east swamp",
	0x57: "at the base of the volcano",
	0x59: "descending into hell",
	0x5c: "in the dungeons of Zak's castle",
	0x65: "underneath the castle",
	0x66: "underneath the castle",
	0x67: "falling down the well",
	0x6f: "sweating in Gehenna",
	0x70: "making a deal with the devil",
	0x73: "in the dungeons of Zak's castle",
	0x74: "in the dungeons of Zak's castle",
	0x7e: "falling down the well",
}

ITEM_DESC = {
	0x3e: "some magic pipes",
	0x3f: "a personal stereo",
	0x40: "a dagger",
	0x41: "an ancient lamp",
	0x42: "a cloth duster",
	0x43: "a lightning rod",
	0x44: "a black cat",
	0x45: "a leaf",
	0x46: "a burning torch",
	0x47: "a poisoned apple",
	0x48: "weedkiller potion",
	0x49: "the 'drink-me' potion",
	0x4a: "the 'eat-me' cake",
	0x4b: "a big stick",
	0x4c: "the gold cross",
	0x4d: "something sticky",
	0x4e: "Excalibur",
	0x4f: "the power pill",
	0x50: "the handle",
	0x51: "a bucket",
	0x52: "a bucket of hot water",
	0x53: "Dora (who is currently a frog)",
	0x54: "the Wizardslayer trident",
	0x55: "Zaks' ring",
	0x56: "the backdoor key",
	0x57: "a bag of rubbish",
	0x58: "an empty milk bottle",
	0x59: "a railing",
	0x5a: "a railing",
	0x5b: "a railing",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function _obj_base(i) => OBJECT_TABLE + 15*i
function obj_screen(i) => byte(_obj_base(i) + 0)

function obj_exit(i) => prev(obj_screen(i)) != 0xFF && obj_screen(i) == 0xFF

function new_game() => lives() > prev(lives()) && prev(room()) == 0x00 && room() == 0x53
function win_the_game() => diamond_count() == 30 && devil_state() == 1 && prev(room()) == 0x70 && room() == 0x02

function one_diamond() => diamond_count() > prev(diamond_count())
function jump() => prev(grounded()) == 1 && grounded() == 0 && jump_input() == 1 && dizzy_y_velocity() >= 0x80

// --- RICH PRESENCE -------------------------------------------------------------------

function rp_item(i) => rich_presence_lookup("ITEM", inventory(i), ITEM_DESC, fallback="")
function rp_comma(i) => rich_presence_flag(", ", when=inventory(i) != 0 && inventory(i+1) != 0, lookupname="COMMA")

rp_room_name = rich_presence_lookup("ROOMNAME", room(), ROOM_NAME, fallback="Sky")
rp_room_desc = rich_presence_lookup("ROOMDESC", room(), ROOM_DESC, fallback="in the sky")

rp_lives = rich_presence_number(lives())
rp_lifeword = rich_presence_lookup("LIFEWORD", lives(), {1: "life"}, fallback="lives")
rp_diamonds = rich_presence_number(diamond_count())

rich_presence_conditional_display(room() == 0,
	"[Dizzy IV: Magicland Dizzy] on the title screen"
)

rich_presence_conditional_display(room() == 2,
	"Dizzy has once again saved the day and rescued the Yolkfolk. Our hero!"
)

rich_presence_conditional_display(inventory(0) == 0,
	"Dizzy is {0} carrying nothing · {1} · {2} {3}, 💎 {4}",
	rp_room_desc, rp_room_name,
	rp_lives, rp_lifeword, rp_diamonds
)

rich_presence_display(
	"Dizzy is {0} carrying {5}{6}{7}{8}{9} · {1} · {2} {3}, 💎 {4}",
	rp_room_desc, rp_room_name,
	rp_lives, rp_lifeword, rp_diamonds,
	rp_item(0), rp_comma(0), rp_item(1), rp_comma(1), rp_item(2)
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Eggsponential Growth",
	description="Save Daisy from her big predicament",
	type="progression",
	points=5,
	trigger=room() == 0x74 && obj_exit(OBJ_DAISY)
)

achievement(
	title="A Root Awakening",
	description="Get to the root of Dylan's problem",
	type="progression",
	points=5,
	trigger=room() == 0x51 && obj_exit(OBJ_DYLAN)
)

achievement(
	title="Fool's Mate",
	description="Save Grand-Dizzy from checkmate",
	type="progression",
	points=5,
	trigger=room() == 0x2c && obj_exit(OBJ_GRAND_DIZZY)
)

achievement(
	title="Chill Out, Denzil",
	description="Break the ice with Denzil",
	type="progression",
	points=5,
	trigger=room() == 0x47 && obj_exit(OBJ_DENZIL)
)

achievement(
	title="Egglectric Boogaloo",
	description="Give Dozy a shocking wake-up call",
	type="progression",
	points=5,
	trigger=room() == 0x4a && obj_exit(OBJ_DOZY)
)

achievement(
	title="Happily Eggver After",
	description="Help Dora kiss her trouble goodbye",
	type="progression",
	points=3,
	trigger=room() == 0x4d && obj_exit(OBJ_PRINCE)
)

achievement(
	title="Dizzy the Wizard Slayer",
	description="Defeat Zaks in his tallest tower",
	type="progression",
	points=5,
	trigger=room() == 0x01 && obj_exit(OBJ_ZAKS)
)

achievement(
	title="Deviled Egg",
	description="Make a deal with the devil by bringing him 30 diamonds",
	type="win_condition",
	points=25,
	trigger=win_the_game()
)

achievement(
	title="Wakka Wakka",
	description="Exorcise the ghosts in the swamp",
	points=3,
	trigger=(
		room() == 0x54 && 
		__ornext(
			prev(obj_screen(OBJ_GHOST_LEFT)) == 0x54 ||
			prev(obj_screen(OBJ_GHOST_RIGHT)) == 0x54
		) &&
		obj_screen(OBJ_GHOST_LEFT) == 0xFF &&
		obj_screen(OBJ_GHOST_RIGHT) == 0xFF
	)
)

achievement(
	title="Getting Trolled IRL",
	description="Cross the Trollbridge",
	points=3,
	trigger=(
		obj_screen(OBJ_BRIDGE_TROLL) == 0xFF &&
		prev(room()) == 0x49 && room() == 0x48
	)
)

achievement(
	title="Feeding Her is Eggsactly How We Got in This Situation",
	description="Feed the wrong thing to Daisy to have a bad time",
	type="missable",
	points=2,
	trigger=(
		room() == 0x74 && daisy_scale() == 5 && 
		health() == 0 &&
		prev(displayed_health()) > 0 && displayed_health() == 0
	)
)

achievement(
	title="UWC: An Utterly Wearisome Climb",
	description="Meet an untimely end in the Harpy's Eyrie",
	points=10,
	trigger=(
		room() == 0x2a &&
		prev(health()) > 0 && health() == 0
	)
)

achievement(
	title="A Little Bit of Bizzy Work",
	description="Place all three railings in the Prince's throne room. It's time to redecorate!",
	points=2,
	trigger=(
		room() == 0x4d &&
		__ornext(any_of(range(0x59, 0x5b), i => prev(obj_screen(i)) != 0x4d)) &&
		all_of(range(0x59, 0x5b), i => obj_screen(i) == 0x4d)
	)
)

achievement(
	title="Zaks Attacks",
	description="Defeat Zaks without collecting any diamonds and without dying",
	type="missable",
	points=50,
	trigger=(
		lives() == 3 && diamond_count() == 0 &&
		trigger_when(room() == 0x01 && obj_exit(OBJ_ZAKS))
	)
)

achievement(
	title="All the King's Horses",
	description=(
		"Pull Excalibur from the stone without running out of points. " +
		"Each diamond collected earns five points, and each jump costs one point. " +
		"(Refer to the leaderboard for your current available points)"
	),
	type="missable",
	points=25,
	trigger=(
		once(new_game()) &&
		trigger_when(prev(obj_screen(0x4e)) == room() && obj_screen(0x4e) == 0xff) &&
		never(tally(1,
			deduct(one_diamond()),
			deduct(one_diamond()),
			deduct(one_diamond()),
			deduct(one_diamond()),
			deduct(one_diamond()),
			jump()
		))
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Excalibur Points Leader",
	description="Most points remaining when pulling Excalibur from the stone",

	start=new_game(),
	cancel=(
		// if you die or go back to the title screen, cancel leaderboard
		room() == 0x00 || lives() == 0 ||
		(
			// if you run out of points, cancel leaderboard
			tally(1,
				deduct(one_diamond()),
				deduct(one_diamond()),
				deduct(one_diamond()),
				deduct(one_diamond()),
				deduct(one_diamond()),
				jump()
			) &&
			// this is janky! resetting the hitcounts on a Delta so that the cancel
			// on game over has a chance to fire. this works, but it's silly. unfortunately
			// it is necessary, since hits on cancel don't clear automatically
			never(prev(room()) == 0x00) &&
			never(prev(lives()) == 0)
		)
	),
	submit=prev(obj_screen(0x4e)) == room() && obj_screen(0x4e) == 0xff,

	value=measured(tally(0,
			one_diamond(),
			one_diamond(),
			one_diamond(),
			one_diamond(),
			one_diamond(),
			deduct(jump())
		)),
	format="VALUE",
	lower_is_better=false
)