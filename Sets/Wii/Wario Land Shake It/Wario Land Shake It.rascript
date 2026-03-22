// Wario Land: Shake It!
// #ID = 34690

// Manual can be found here:
// https://csassets.nintendo.com/noaext/image/private/t_KA_PDF/Wii_Wario_Shake?_a=DATAg1AAZAA0

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function ptr(x) => dword_be(x) & 0x1fffffff
function ptr_chain(addr, offsets)
{
	for offset in offsets
		addr = ptr(addr) + offset
	return addr
}

// --- MEMORY -------------------------------------------------------------------

class Region
{
	regionname = ""
	gamename = ""
	flag = ""
	diskname = ""
	addr_file_loaded = -1
	addr_player_root = -1
	addr_stage_id = -1
	addr_save_data = -1
	addr_temp_progress = -1
	
	function save_ptr() => ptr(this.addr_save_data)
	function is_region() => ascii_string_equals(0x3180, this.diskname)

	function in_level() => ascii_string_equals(ptr(ptr(this.save_ptr() + 0x34) + 0x04) + 0x08, "Game")
	// function in_level() => ascii_string_equals(this.addr_player_root, "Player") || ascii_string_equals(this.addr_player_root, "Submarine")
	function in_shop() => ascii_string_equals(ptr(ptr(this.save_ptr() + 0x34) + 0x04) + 0x08, "Shop")
	// function in_shop() => ascii_string_equals(this.addr_player_root, "EnvPartsShop") // this seems to always be stored in the same spot
	function in_stage_results() => ascii_string_equals(ptr(ptr(this.save_ptr() + 0x34) + 0x04) + 0x08, "StageRes")
	// function in_stage_results() => __ornext(any_of(range(-10, 10) , (i) => ascii_string_equals(this.addr_player_root + i*0x30 + 0x0c, "eRes")))
	function in_music_room() => ascii_string_equals(ptr(ptr(this.save_ptr() + 0x34) + 0x04) + 0x08, "MusicRoo")

	function is_file_loaded() => word_be(this.addr_file_loaded) == 0
	function health() => float_be(ptr(this.addr_player_root + 0x28) + 0x1F4)
	function stage_id() => dword_be(this.addr_stage_id)

	function loaded_file() => dword_be(this.save_ptr() + 0x44)
	function _file_offset(file) => this.save_ptr() + 712 * file
	function total_gold(file) => dword_be(this._file_offset(file) + 0x90)
	function max_hearts(file) => float_be(this._file_offset(file) + 0x94)
	function recovery_potions(file) => dword_be(this._file_offset(file) + 0x98)

	function treasure(file, offset, b) => bit(b, this._file_offset(file) + offset)
	function movie_owned(file, i) => byte(this._file_offset(file) + 0xCE + 2*i)
	function movie_new(file, i) => byte(this._file_offset(file) + 0xCF + 2*i)

	function _stage_offset(file, stage) => this._file_offset(file) + 0xD4 + 12*stage
	function mission_flag(file, stage, mission) => bit(mission, this._stage_offset(file, stage) + 2)
	function stage_unlocked(file, stage) => bit0(this._stage_offset(file, stage) + 3)
	function stage_completed(file, stage) => bit1(this._stage_offset(file, stage) + 3)
	function secret_map_collected(file, stage) => bit3(this._stage_offset(file, stage) + 3)
	function treasure_flags(file, stage, treasure) => bit(treasure+3, this._stage_offset(file, stage) + 3)
	function best_coin(file, stage) => dword_be(this._stage_offset(file, stage) + 4)
	function best_time(file, stage) => dword_be(this._stage_offset(file, stage) + 8)

	function level_mission(i) => bit(i, ptr_chain(this.addr_temp_progress, [0x50, 0x08, 0x3E]))
	function level_treasure(i) => bit(i+3, ptr_chain(this.addr_temp_progress, [0x50, 0x08, 0x3F]))
	function level_coins() => dword_be(ptr_chain(this.addr_temp_progress, [0x50, 0x08, 0x40]))
}

REGIONS = [
	Region(
		regionname="US",
		gamename="Wario Land: Shake It!",
		flag="🇺🇸",
		diskname="RWLE",
		addr_file_loaded=0x50F36A,
		addr_player_root=0x535C50,
		addr_stage_id=0x61B338,
		addr_save_data=0x61DA90,
		addr_temp_progress=0x61DB00
	),
	Region(
		regionname="EU",
		gamename="Wario Land: The Shake Dimension",
		flag="🇪🇺",
		diskname="RWLP",
		addr_file_loaded=0x50FE4A,
		addr_player_root=0x536F50,
		addr_stage_id=0x61C6B8,
		addr_save_data=0x61EE10,
		addr_temp_progress=0x61EE80
	),
]

// --- MAIN DATA -------------------------------------------------------------------

ALLFILES = range(0,3)
WORLDS = [
	"The Sweet Stuff",
	"Ratl Ruins",
	"Wiggly Wilds",
	"Rocking Range",
	"Jiggle Jungle",
	"Quiver Cliffs",
	"Shakedown Schooner",
]

class Treasure
{
	name = ""
	offset = -1
	bit = -1

	function collected(region, file) => region.treasure(file, this.offset, this.bit)
}

class Stage
{
	id = -1
	world = -1
	name = ""
	map_in = -1
	treasures = []
	missions = 0

	function mission_count(region, file) => bitcount(region._stage_offset(file, this.id) + 2) // sum_of(range(0, this.missions-1), (i) => region.mission_flag(file, this.id, i))
	function treasure_count(region, file) => sum_of(this.treasures, (t) => t.collected(region, file))
	function is_secret() => this.map_in != -1

	function get_treasure_list()
	{
		/*
		tlist = ""
		for t in this.treasures { tlist = tlist + ", " + t.name }
		return substring(tlist, 2)
		*/
		return format("the {0}, {1}, and {2}", this.treasures[0].name, this.treasures[1].name, this.treasures[2].name)
	}

	function completed() => any_of(REGIONS, (region) => any_of(ALLFILES, (file) => (
		region.is_file_loaded() && region.loaded_file() == file && region.in_stage_results() &&
		// prev(region.best_time(file, this.id)) == 0xFFFFFFFF && region.best_time(file, this.id) != 0xFFFFFFFF
		is_set(region.stage_completed(file, this.id))
	)))

	function all_missions_done() => any_of(REGIONS, (region) => any_of(ALLFILES, (file) => (
		region.is_file_loaded() && region.loaded_file() == file && region.in_stage_results() &&
		prev(this.mission_count(region, file)) < this.missions && 
		this.mission_count(region, file) == this.missions
	)))

	function all_treasure_found() => any_of(REGIONS, (region) => any_of(ALLFILES, (file) => (
		region.is_file_loaded() && region.loaded_file() == file && region.in_stage_results() &&
		prev(this.treasure_count(region, file)) < 3 && 
		this.treasure_count(region, file) == 3
	)))

	function collected_map() => any_of(REGIONS, (region) => any_of(ALLFILES, (file) => (
		region.is_file_loaded() && region.loaded_file() == file && region.in_stage_results() &&
		is_set(region.secret_map_collected(file, this.id))
	)))
}

STAGES = [
	// --- Area 0: The Sweet Stuff ---
	Stage(id=0, world=0, name="Aboard the Sweet Stuff", missions=3, 
		treasures=[
			Treasure(offset=0x9F, bit=0, name="Merfle Syrup"),
			Treasure(offset=0x9F, bit=1, name="Six-Week-Old Curry"),
			Treasure(offset=0x9F, bit=2, name="Fickle Compass"),
		]
	),

	// --- Area 1: Ratl Ruins ---
	Stage(id=2, world=1, name="Stonecarving City", missions=3, treasures=[
		Treasure(offset=0x9F, bit=3, name="Stone Coin"),
		Treasure(offset=0x9F, bit=4, name="Full-Body Goggles"),
		Treasure(offset=0x9F, bit=5, name="Crystal Skull"),
	]),
	Stage(id=3, world=1, name="Whoopsy Desert", missions=3, treasures=[
		Treasure(offset=0x9F, bit=6, name="Cheese Pyramid"),
		Treasure(offset=0x9F, bit=7, name="Liquid Giggles"),
		Treasure(offset=0x9E, bit=0, name="Ancient Digital Watch"),
	]),
	Stage(id=4, world=1, name="Foulwater Falls", missions=4, treasures=[
		Treasure(offset=0x9E, bit=1, name="Recyclable Bottle"),
		Treasure(offset=0x9E, bit=2, name="Silver Armor"),
		Treasure(offset=0x9E, bit=3, name="The Key to My Heart"),
	]),
	Stage(id=5, world=1, name="Run-Down Pyramid", missions=4, treasures=[
		Treasure(offset=0x9E, bit=4, name="One Heavy Spear"),
		Treasure(offset=0x9E, bit=5, name="Moonstone"),
		Treasure(offset=0x9E, bit=6, name="Manly Moai"),
	]),
	Stage(id=1, world=1, name="Rollanratl Battle", missions=3, treasures=[
		Treasure(offset=0x9D, bit=4, name="Rollanratl Emblem"),
	]),
	Stage(id=7, world=1, name="Disturbing Tomb", map_in=3, missions=6, treasures=[
		Treasure(offset=0x9D, bit=2, name="Instant Tutanramen"),
		Treasure(offset=0x9D, bit=3, name="Golden Tissues"),
		Treasure(offset=0xAB, bit=4, name="Oasis in a Teapot"),
	]),
	Stage(id=8, world=1, name="Gurgle Gulch", map_in=4, missions=7, treasures=[
		Treasure(offset=0x9D, bit=5, name="Imperial Boxers"),
		Treasure(offset=0x9D, bit=6, name="Wario's Dustcloth"),
		Treasure(offset=0x9D, bit=7, name="Something Important"),
	]),

	// --- Area 2: Wiggly Woods ---
	Stage(id=10, world=2, name="Just Plains", missions=3, treasures=[
		Treasure(offset=0x9C, bit=0, name="Baobab Wood Pacifier"),
		Treasure(offset=0x9C, bit=1, name="Empty Piggy Bank"),
		Treasure(offset=0x9C, bit=2, name="Stuffed Wildebeest"),
	]),
	Stage(id=11, world=2, name="Wavy Waters", missions=3, treasures=[
		Treasure(offset=0x9C, bit=3, name="Peach Sandals"),
		Treasure(offset=0x9C, bit=4, name="Turtleskin Hat"),
		Treasure(offset=0x9C, bit=5, name="Mermaid Scale"),
	]),
	Stage(id=12, world=2, name="Mt. Lava Lava", missions=4, treasures=[
		Treasure(offset=0x9C, bit=6, name="Bangin'-Together Rocks"),
		Treasure(offset=0x9C, bit=7, name="Combustible Top"),
		Treasure(offset=0xA3, bit=0, name="Fantabulous Fan"),
	]),
	Stage(id=13, world=2, name="Savannah Valley", missions=5, treasures=[
		Treasure(offset=0xA3, bit=1, name="Hypno-Specs"),
		Treasure(offset=0xA3, bit=2, name="Diamond Ski Mask"),
		Treasure(offset=0xA3, bit=3, name="Solid-Gold Shuttlecock"),
	]),
	Stage(id=9, world=2, name="Hot Roderick Race", missions=3, treasures=[
		Treasure(offset=0xA3, bit=6, name="Hot Roderick Emblem"),
	]),
	Stage(id=15, world=2, name="Sneak Peak", map_in=12, missions=7, treasures=[
		Treasure(offset=0xA3, bit=7, name="Extra-Nutty Chestnut"),
		Treasure(offset=0xA2, bit=0, name="Stone Hockey Mask"),
		Treasure(offset=0xA2, bit=1, name="Saphfire"),
	]),
	Stage(id=14, world=2, name="Lowdown Depths", map_in=15, missions=6, treasures=[
		Treasure(offset=0xAB, bit=5, name="Lion-Mane Wig"),
		Treasure(offset=0xA3, bit=5, name="Moon Light"),
		Treasure(offset=0x9D, bit=1, name="B.C. Bongo"),
	]),

	// --- Area 3: Rocking Range ---
	Stage(id=17, world=3, name="Wreck Train", missions=3, treasures=[
		Treasure(offset=0xA2, bit=2, name="Perfect Disguise"),
		Treasure(offset=0xA2, bit=3, name="Hotter Sauce"),
		Treasure(offset=0xA2, bit=4, name="Diamond Lightbulb"),
	]),
	Stage(id=18, world=3, name="Stonetooth Cave", missions=4, treasures=[
		Treasure(offset=0xA2, bit=5, name="Fossilized Drumstick"),
		Treasure(offset=0xA2, bit=6, name="Kissing Stapler"),
		Treasure(offset=0xA2, bit=7, name="Gold-Handled Bucket"),
	]),
	Stage(id=19, world=3, name="Its-all Mine", missions=4, treasures=[
		Treasure(offset=0xA1, bit=0, name="Pterodactyl Stew"),
		Treasure(offset=0xA1, bit=1, name="Gold Press-on Nails"),
		Treasure(offset=0xA1, bit=2, name="Really Tempting Apple"),
	]),
	Stage(id=20, world=3, name="Glittertown", missions=5, treasures=[
		Treasure(offset=0xA1, bit=3, name="Ancient Duck Soup Mix"),
		Treasure(offset=0xA1, bit=4, name="Energy Drink"),
		Treasure(offset=0xA1, bit=5, name="Pink Diamond"),
	]),
	Stage(id=16, world=3, name="Chortlebot Challenge", missions=3, treasures=[
		Treasure(offset=0xA0, bit=0, name="Chortlebot Emblem"),
	]),
	Stage(id=22, world=3, name="Neon City", map_in=20, missions=6, treasures=[
		Treasure(offset=0xA0, bit=1, name="Play Money"),
		Treasure(offset=0xA0, bit=2, name="Mirror Crystal Ball"),
		Treasure(offset=0xA0, bit=3, name="Spyfruit"),
	]),
	Stage(id=21, world=3, name="Derailed Express", map_in=22, missions=7, treasures=[
		Treasure(offset=0xA1, bit=6, name="Train Time"),
		Treasure(offset=0xA1, bit=7, name="24K Baseball Bat"),
		Treasure(offset=0xA3, bit=4, name="Overachieving Star"),
	]),

	// --- Area 4: Jiggle Jungle ---
	Stage(id=24, world=4, name="Ropey Jungle", missions=3, treasures=[
		Treasure(offset=0xA0, bit=4, name="Piranha Dentures"),
		Treasure(offset=0xA0, bit=5, name="Pied Piper's Pupil"),
		Treasure(offset=0xA0, bit=6, name="Eye of the Storm"),
	]),
	Stage(id=25, world=4, name="Windbreak Bay", missions=3, treasures=[
		Treasure(offset=0xA0, bit=7, name="Lanternfish"),
		Treasure(offset=0xA7, bit=0, name="Ammoniteless Shell"),
		Treasure(offset=0xA7, bit=1, name="Swine Pearls"),
	]),
	Stage(id=26, world=4, name="Airytale Castle", missions=5, treasures=[
		Treasure(offset=0xA7, bit=2, name="Cupid's Bow"),
		Treasure(offset=0xA7, bit=3, name="Rainbow Toucan"),
		Treasure(offset=0xA7, bit=4, name="Flying Slipper"),
	]),
	Stage(id=27, world=4, name="Soggybog River", missions=5, treasures=[
		Treasure(offset=0xA7, bit=5, name="Bottle of Toad Oil"),
		Treasure(offset=0xA7, bit=6, name="Flowerworks"),
		Treasure(offset=0xA7, bit=7, name="Amber Ring"),
	]),
	Stage(id=23, world=4, name="Bloomsday Blowout", missions=3, treasures=[
		Treasure(offset=0xA6, bit=2, name="Bloomsday Emblem"),
	]),
	Stage(id=6, world=4, name="Launchpad Labyrinth", map_in=26, missions=7, treasures=[
		Treasure(offset=0x9E, bit=7, name="Pot Full o' Mystery"),
		Treasure(offset=0x9D, bit=0, name="Dung Beetle Pendant"),
		Treasure(offset=0xAB, bit=3, name="Solid-Gold Flyer"),
	]),
	Stage(id=29, world=4, name="Riverbloat Rapids", map_in=27, missions=7, treasures=[
		Treasure(offset=0xA6, bit=3, name="Venus Guytrap Seed"),
		Treasure(offset=0xA6, bit=4, name="Muscleman Suit"),
		Treasure(offset=0xA6, bit=5, name="Emerald Melon"),
	]),
	Stage(id=28, world=4, name="Prism Prison", map_in=29, missions=6, treasures=[
		Treasure(offset=0xA6, bit=0, name="Air Guitar"),
		Treasure(offset=0xA6, bit=1, name="Flying Floor Pillow"),
		Treasure(offset=0xAB, bit=6, name="Electric Ukulele"),
	]),

	// --- Area 5: Quiver Cliffs ---
	Stage(id=31, world=5, name="Mount Bighill", missions=3, treasures=[
		Treasure(offset=0xA6, bit=6, name="Last Mahjong Tile"),
		Treasure(offset=0xA6, bit=7, name="Nine Winks"),
		Treasure(offset=0xA5, bit=0, name="Dragon Whisker"),
	]),
	Stage(id=32, world=5, name="Creep Blue Sea", missions=3, treasures=[
		Treasure(offset=0xA5, bit=1, name="Pirate's Eye Patch"),
		Treasure(offset=0xA5, bit=2, name="Message in a Bottle"),
		Treasure(offset=0xA5, bit=3, name="Blue Coral"),
	]),
	Stage(id=33, world=5, name="Slipshod Slopes", missions=5, treasures=[
		Treasure(offset=0xA5, bit=4, name="Hot Dog"),
		Treasure(offset=0xA5, bit=5, name="Crown of Ice"),
		Treasure(offset=0xA5, bit=6, name="Aurora Robealis"),
	]),
	Stage(id=34, world=5, name="Bad Manor", missions=5, treasures=[
		Treasure(offset=0xA5, bit=7, name="Vampire's Mirror"),
		Treasure(offset=0xA4, bit=0, name="Star Hammer"),
		Treasure(offset=0xA4, bit=1, name="Pandora's Box"),
	]),
	Stage(id=30, world=5, name="Large Fry Cook-Off", missions=3, treasures=[
		Treasure(offset=0xA4, bit=7, name="Large Fry Emblem"),
	]),
	Stage(id=35, world=5, name="Bamboozle Village", map_in=33, missions=7, treasures=[
		Treasure(offset=0xA4, bit=2, name="Collapsible Telescope"),
		Treasure(offset=0xA4, bit=3, name="Nice Cup of Green Tea"),
		Treasure(offset=0xA4, bit=4, name="Tiger-Eye"),
	]),
	Stage(id=36, world=5, name="Freezing Fields", map_in=35, missions=6, treasures=[
		Treasure(offset=0xA4, bit=5, name="Santa's Sled"),
		Treasure(offset=0xA4, bit=6, name="Frozen Mammoth"),
		Treasure(offset=0xAB, bit=7, name="Ever-Ice"),
	]),
	Stage(id=37, world=5, name="Boogie Mansion", map_in=34, missions=7, treasures=[
		Treasure(offset=0xAB, bit=0, name="Ghost Potion"),
		Treasure(offset=0xAB, bit=1, name="Magic Lamp"),
		Treasure(offset=0xAB, bit=2, name="Therapeutic Music Box"),
	]),

	// --- Area 6: Shakedown Schooner ---
	Stage(id=38, world=6, name="VS the Shake King", missions=3, treasures=[
		Treasure(offset=0xAA, bit=0, name="Shake King Emblem"),
	]),
]

STAGE_BY_NAME = {}
STAGE_BY_ID = {}

ALL_TREASURES = []
STAGE_NAMES = {}
for stage in STAGES
{
	for t in stage.treasures
		array_push(ALL_TREASURES, t)
	STAGE_NAMES[stage.id] = stage.name

	STAGE_BY_NAME[stage.name] = stage
	STAGE_BY_ID[stage.id] = stage
}

ALL_MOVIES = [0, 1]

// --- RICH PRESENCE -------------------------------------------------------------------

function rp_treasure(x) => rich_presence_lookup("TreasureCollected", x, {0: "📦"}, fallback="💎")
function rp_secretmap(x) => rich_presence_lookup("MapCollected", x, {0: ""}, fallback=" 🗺️")
function rp_shopmap(x) => rich_presence_lookup("ShopMap", x, {0: "❌"}, fallback="🗺️")

for region in REGIONS
{
	rich_presence_conditional_display(region.is_region() && region.in_level(),
		region.flag + " In Level · {0} [{1}{2}{3}]{4} · 🪙 {5} · ❤️ {6}{7}",
		rich_presence_lookup("StageName", region.stage_id(), STAGE_NAMES, fallback=STAGE_NAMES[0]),
		rp_treasure(region.treasure_flags(region.loaded_file(), region.stage_id(), 1) + region.level_treasure(1)),
		rp_treasure(region.treasure_flags(region.loaded_file(), region.stage_id(), 2) + region.level_treasure(2)),
		rp_treasure(region.treasure_flags(region.loaded_file(), region.stage_id(), 3) + region.level_treasure(3)),
		rp_secretmap(region.treasure_flags(region.loaded_file(), region.stage_id(), 0) + region.level_treasure(0)),
		rich_presence_number(region.level_coins()),
		rich_presence_value("_F", region.health(), "FLOAT1"),
		rich_presence_lookup("Potions", region.recovery_potions(region.loaded_file()), {1: " 🍾", 2: " 🍾🍾"}, fallback="")
	)

	rich_presence_conditional_display(region.is_region() && region.in_shop(),
		region.flag + " Shopping · 💰 {0} · [{1}{2}{3}{4}{5}]",
		rich_presence_number(region.total_gold(region.loaded_file())),
		rp_shopmap(region.stage_unlocked(region.loaded_file(), 2)),
		rp_shopmap(region.stage_unlocked(region.loaded_file(), 10)),
		rp_shopmap(region.stage_unlocked(region.loaded_file(), 17)),
		rp_shopmap(region.stage_unlocked(region.loaded_file(), 24)),
		rp_shopmap(region.stage_unlocked(region.loaded_file(), 31))
	)

	rich_presence_conditional_display(region.is_region() && region.in_music_room(),
		region.flag + " Enjoying the Media Room 🎵"
	)

	rich_presence_conditional_display(region.is_region() && region.is_file_loaded(),
		region.flag + " In Menus"
	)

	rich_presence_conditional_display(region.is_region(),
		region.flag + " " + region.gamename
	)
}

rich_presence_display(
	"Waaaaah!"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

function stage_complete_achievement(stage, title, points)
{
	achievement(
		title=title,
		description=format("Complete \"{0}\"", stage.name), 
		type=if_else(stage.is_secret(), "", if_else(stage.id == 38, "win_condition", "progression")),
		points=points,
		trigger=stage.completed()
	)
}

function stage_missions_achievement(stage, title, points)
{
	achievement(
		title=title,
		description=format("Complete every extra mission in \"{0}\"", stage.name),
		points=points,
		trigger=stage.all_missions_done()
	)
}

function stage_treasure_achievement(stage, title, points)
{
	achievement(
		title=title,
		description=format("Collect every treasure in \"{0}\": {1}", stage.name, stage.get_treasure_list()),
		points=points,
		trigger=stage.all_treasure_found()
	)
}

function stage_map_achievement(stage, title)
{
	achievement(
		title=title,
		description=format("Find the secret treasure map in \"{0}\"", stage.name),
		points=2,
		trigger=stage.collected_map()
	)
}

// completion, missions, and treasure for all stages (required stages completion = progression)
// https://www.mariowiki.com/List_of_Wario_Land:_Shake_It!_missions

// --- Area 0: The Sweet Stuff ---
stage_complete_achievement(STAGE_BY_ID[0], "Not My First Rodeo", 1)
stage_missions_achievement(STAGE_BY_ID[0], "Top of the Class", 2)
stage_treasure_achievement(STAGE_BY_ID[0], "Sugar and Spice", 3) // "Scurvy-Curing Curry"

// --- Area 1: Ratl Ruins ---
stage_complete_achievement(STAGE_BY_ID[2], "My Masterpiece", 2)
stage_missions_achievement(STAGE_BY_ID[2], "Speedcarving", 2)
stage_treasure_achievement(STAGE_BY_ID[2], "Indiana Jones, Eat Your Heart Out", 3)

stage_complete_achievement(STAGE_BY_ID[3], "Didn't Break a Sweat", 2)
stage_missions_achievement(STAGE_BY_ID[3], "Roadrunner", 3)
stage_treasure_achievement(STAGE_BY_ID[3], "Taking My Time", 3)
stage_map_achievement(     STAGE_BY_ID[3], "Out on a Limb")

stage_complete_achievement(STAGE_BY_ID[4], "Into the Awazon River Basin", 2)
stage_missions_achievement(STAGE_BY_ID[4], "Fortune Falls", 3)
stage_treasure_achievement(STAGE_BY_ID[4], "Getting the Bottle Deposit", 3)
stage_map_achievement(     STAGE_BY_ID[4], "In the Blue Grotto")

stage_complete_achievement(STAGE_BY_ID[5], "Run-Down, Sundown", 2)
stage_missions_achievement(STAGE_BY_ID[5], "Voiding the Unibucket Warranty", 3)
stage_treasure_achievement(STAGE_BY_ID[5], "Adding Clefable to the Pokedex", 3)

stage_complete_achievement(STAGE_BY_ID[1], "A Good Roll Model", 5)
stage_missions_achievement(STAGE_BY_ID[1], "Unstoppable Force vs Unshakable Object", 5)

stage_complete_achievement(STAGE_BY_ID[7], "Dying to Escape!", 2)
stage_missions_achievement(STAGE_BY_ID[7], "Garlic Glutton", 3)
stage_treasure_achievement(STAGE_BY_ID[7], "Just Add Water", 3)

stage_complete_achievement(STAGE_BY_ID[8], "What Is This? The Water Temple?", 2)
stage_missions_achievement(STAGE_BY_ID[8], "Scarracuda, Will You Do the Fandango?", 3)
stage_treasure_achievement(STAGE_BY_ID[8], "The Emperor's New Boxers", 3)

// --- Area 2: Wiggly Woods ---
stage_complete_achievement(STAGE_BY_ID[10], "Just Like I Like My Pizza", 2)
stage_missions_achievement(STAGE_BY_ID[10], "You Got a Problem With That?", 2)
stage_treasure_achievement(STAGE_BY_ID[10], "Bring Your Own Treasure", 3)

stage_complete_achievement(STAGE_BY_ID[11], "Bubble Lagoon", 2)
stage_missions_achievement(STAGE_BY_ID[11], "That Subwarine Is a Rental", 3)
stage_treasure_achievement(STAGE_BY_ID[11], "Wario's Well-Documented Interest in Feet", 3)

stage_complete_achievement(STAGE_BY_ID[12], "Seismic Panic", 2)
stage_missions_achievement(STAGE_BY_ID[12], "Taking the Lump Sum Payout", 3)
stage_treasure_achievement(STAGE_BY_ID[12], "Dragon Emperor Supreme Flight", 3)
stage_map_achievement(     STAGE_BY_ID[12], "Caldera Cartography")

stage_complete_achievement(STAGE_BY_ID[13], "Open Canopy Concept", 2)
stage_missions_achievement(STAGE_BY_ID[13], "Block Busters Inc.", 3)
stage_treasure_achievement(STAGE_BY_ID[13], "Rich People Sure Are Different", 3) // Katamari reference

stage_complete_achievement(STAGE_BY_ID[9], "Blazing to the Finish", 5)
stage_missions_achievement(STAGE_BY_ID[9], "This Race Was a Drag", 5)

stage_complete_achievement(STAGE_BY_ID[15], "A Preview of Bandinero Evolution", 2)
stage_missions_achievement(STAGE_BY_ID[15], "Pogo-a-gogo", 3)
stage_treasure_achievement(STAGE_BY_ID[15], "We're All Nuts Here", 3)
stage_map_achievement(     STAGE_BY_ID[15], "Atlas & His Boulder")

stage_complete_achievement(STAGE_BY_ID[14], "The Lowdown Escape", 2)
stage_missions_achievement(STAGE_BY_ID[14], "Slow and Steady", 3)
stage_treasure_achievement(STAGE_BY_ID[14], "Lunar Luminosity", 3)

// --- Area 3: Rocking Range ---
stage_complete_achievement(STAGE_BY_ID[17], "Mayhem on the Rocking Range Express", 2)
stage_missions_achievement(STAGE_BY_ID[17], "The Same Six Minutes You Gave Me", 2)
stage_treasure_achievement(STAGE_BY_ID[17], "First We Feast", 3)

stage_complete_achievement(STAGE_BY_ID[18], "What If Dinosaurs Were Real?", 2)
stage_missions_achievement(STAGE_BY_ID[18], "Where They Manufacture Evidence", 3)
stage_treasure_achievement(STAGE_BY_ID[18], "Elevating the Humble Bucket", 3)

stage_complete_achievement(STAGE_BY_ID[19], "It's All Mine!... Wait, That's the Name?", 2)
stage_missions_achievement(STAGE_BY_ID[19], "Wario Hoops 1-vs-3", 3)
stage_treasure_achievement(STAGE_BY_ID[19], "Eve's Stolen Lunch", 3)

stage_complete_achievement(STAGE_BY_ID[20], "Viva Wah-s Vegas", 2)
stage_missions_achievement(STAGE_BY_ID[20], "Wah-n Armed Bandit", 3)
stage_treasure_achievement(STAGE_BY_ID[20], "Just Add Water (Again)", 3)
stage_map_achievement(     STAGE_BY_ID[20], "Crossing the Bellagio Fountains")

stage_complete_achievement(STAGE_BY_ID[16], "Just Clownin' Around", 5)
stage_missions_achievement(STAGE_BY_ID[16], "Honk Honk", 5)

stage_complete_achievement(STAGE_BY_ID[22], "Altantis City", 2)
stage_missions_achievement(STAGE_BY_ID[22], "Garlic Breath", 3)
stage_treasure_achievement(STAGE_BY_ID[22], "Mr. Orange and Mr. Berry", 3)
stage_map_achievement(     STAGE_BY_ID[22], "A Practical Reward")

stage_complete_achievement(STAGE_BY_ID[21], "Chasing the Sunset", 2)
stage_missions_achievement(STAGE_BY_ID[21], "Catch-22", 3)
stage_treasure_achievement(STAGE_BY_ID[21], "Straight Baseball Life", 3)

// --- Area 4: Jiggle Jungle ---
stage_complete_achievement(STAGE_BY_ID[24], "Guytrap Threepwood", 2)
stage_missions_achievement(STAGE_BY_ID[24], "Pacifism in Paradise", 2)
stage_treasure_achievement(STAGE_BY_ID[24], "The Spooniest Bard", 3)

stage_complete_achievement(STAGE_BY_ID[25], "Breaking Wind Is My Specialty", 2)
stage_missions_achievement(STAGE_BY_ID[25], "Paid for Subwarine Insurance", 3)
stage_treasure_achievement(STAGE_BY_ID[25], "Which Came First?", 3)

stage_complete_achievement(STAGE_BY_ID[26], "Jack Said There'd Be a Golden Goose", 2)
stage_missions_achievement(STAGE_BY_ID[26], "No Fines in Fae Court", 3)
stage_treasure_achievement(STAGE_BY_ID[26], "Who Can? Toucan", 3)
stage_map_achievement(     STAGE_BY_ID[26], "The Map to... the Golden Harp?")

stage_complete_achievement(STAGE_BY_ID[27], "A River Runs Through It", 2)
stage_missions_achievement(STAGE_BY_ID[27], "Getting By and Staying Dry", 3)
stage_treasure_achievement(STAGE_BY_ID[27], "Oil and Water", 3)
stage_map_achievement(     STAGE_BY_ID[27], "Waterlogged Logistics")

stage_complete_achievement(STAGE_BY_ID[23], "Scumflower Skirmish", 5)
stage_missions_achievement(STAGE_BY_ID[23], "Bumbleprod Beatdown", 5)

stage_complete_achievement(STAGE_BY_ID[6], "Maze-Solving by Sunset", 2)
stage_missions_achievement(STAGE_BY_ID[6], "Keep It Inside the Lines", 3)
stage_treasure_achievement(STAGE_BY_ID[6], "Ea-Nasir's More Reputable Brother", 3)

stage_complete_achievement(STAGE_BY_ID[29], "Raining in the Rapids", 2)
stage_missions_achievement(STAGE_BY_ID[29], "Wario's Green Thumb", 3)
stage_treasure_achievement(STAGE_BY_ID[29], "I'm Ready for My \"Muscle March\" Cameo", 3)
stage_map_achievement(     STAGE_BY_ID[29], "In the Warmth of a Riverside Cave")

stage_complete_achievement(STAGE_BY_ID[28], "Wario's Great Escape", 2)
stage_missions_achievement(STAGE_BY_ID[28], "Time Off for Good Behavior", 3)
stage_treasure_achievement(STAGE_BY_ID[28], "Jam Band Jamboree", 3)

// --- Area 5: Quiver Cliffs ---
stage_complete_achievement(STAGE_BY_ID[31], "Mountain Mechanisms", 2)
stage_missions_achievement(STAGE_BY_ID[31], "Rapid Riches", 2)
stage_treasure_achievement(STAGE_BY_ID[31], "Treasure in Tenpai", 3)

stage_complete_achievement(STAGE_BY_ID[32], "All the Coral I Can Steal", 2)
stage_missions_achievement(STAGE_BY_ID[32], "Only the Good Stuff", 3)
stage_treasure_achievement(STAGE_BY_ID[32], "\"I'm Trapped in a Bottle Factory!\"", 3)

stage_complete_achievement(STAGE_BY_ID[33], "An Icy Reception", 2)
stage_missions_achievement(STAGE_BY_ID[33], "Leaving No Evidence Behind", 3)
stage_treasure_achievement(STAGE_BY_ID[33], "The Emperor's New Clothes", 3)
stage_map_achievement(     STAGE_BY_ID[33], "Take the Polar Plunge")

stage_complete_achievement(STAGE_BY_ID[34], "Get It? Like \"Bad Manners\"", 2)
stage_missions_achievement(STAGE_BY_ID[34], "Recap Attack", 3)
stage_treasure_achievement(STAGE_BY_ID[34], "Worth Taking a Look", 3)
stage_map_achievement(     STAGE_BY_ID[34], "Deed to the Bad Manor")

stage_complete_achievement(STAGE_BY_ID[30], "An Appetite for Violence", 5)
stage_missions_achievement(STAGE_BY_ID[30], "Meal Prep Master", 5)

stage_complete_achievement(STAGE_BY_ID[35], "The Booby Trapped Village", 2)
stage_missions_achievement(STAGE_BY_ID[35], "Peek-a-Boom", 3)
stage_treasure_achievement(STAGE_BY_ID[35], "All-Seeing and All-Creepy", 3)
stage_map_achievement(     STAGE_BY_ID[35], "A Better Reward")

stage_complete_achievement(STAGE_BY_ID[36], "Slippery Slope", 2)
stage_missions_achievement(STAGE_BY_ID[36], "A Hat Trick on the Ice", 3)
stage_treasure_achievement(STAGE_BY_ID[36], "Have You Heard of Ice-9?", 3)

stage_complete_achievement(STAGE_BY_ID[37], "Boogie Down", 2)
stage_missions_achievement(STAGE_BY_ID[37], "Just a Little Birthday Boy", 3)
stage_treasure_achievement(STAGE_BY_ID[37], "Mixing the Stuff Under the Sink", 3)

// --- Area 6: Shakedown Schooner ---
stage_complete_achievement(STAGE_BY_ID[38], "The Shake King Shakedown", 25)
stage_missions_achievement(STAGE_BY_ID[38], "Mercenary Mania", 10)

// purchase and watch all movies
achievement(
	title="A Real Film Buff",
	description="Purchase and watch every movie",
	points=5,
	trigger=any_of(REGIONS, (r) => any_of(ALLFILES, (file) => (
		// check correct file
		r.is_file_loaded() && r.loaded_file() == file && r.in_music_room() &&
		// all of the movies are owned
		all_of(ALL_MOVIES, (m) => r.movie_owned(file, m) == 1) &&
		// any of the movies are new (previous frame)
		__ornext(any_of(ALL_MOVIES, (m) => prev(r.movie_new(file, m)) == 1)) &&
		// all of the movies are not new
		all_of(ALL_MOVIES, (m) => r.movie_new(file, m) == 0)
	)))
)

// treasure completion (25%, 50%, 75%, 100%)
TREASURE_THRESHOLDS = [
	{"threshold":  25, "points":  3, "title": "A Tiny Pile of Junk"},
	{"threshold":  50, "points":  5, "title": "You Call This a Treasure Hoard?"},
	{"threshold":  75, "points": 10, "title": "Wario Didn't Even Break a Sweat"},
//	{"threshold": 100, "points": 25, "title": "Wario Is the Treasure Master"},
]

for data in TREASURE_THRESHOLDS
{
	n = (data["threshold"] * length(ALL_TREASURES)) / 100
	achievement(
		title=data["title"],
		description=format("Collect {0}% of the treasure in the Shake Dimension", data["threshold"]),
		points=data["points"],
		trigger=any_of(REGIONS, (r) => any_of(ALLFILES, (file) => (
			r.is_file_loaded() && r.loaded_file() == file && r.in_stage_results() &&
			sum_of(ALL_TREASURES, (t) => prev(t.collected(r, file))) < n &&
			sum_of(ALL_TREASURES, (t) => t.collected(r, file)) >= n
		)))
	)
}

achievement(
	title="Wario Is the Treasure Master",
	description="Collect all of the treasure in the Shake Dimension",
	points=25,
	trigger=any_of(REGIONS, (r) => any_of(ALLFILES, (file) => (
		sum_of(ALL_TREASURES, (t) => prev(t.collected(r, file))) < length(ALL_TREASURES) &&
		measured(sum_of(ALL_TREASURES, (t) => t.collected(r, file)) == length(ALL_TREASURES),
			when=r.is_file_loaded() && r.loaded_file() == file,
			format="percent") &&
		unless(!r.in_stage_results())
	)))
)

// mission completion (25%, 50%, 75%, 100%)
MISSION_THRESHOLDS = [
	{"threshold":  25, "points":  3, "title": "Working Hard"},
	{"threshold":  50, "points":  5, "title": "Exceeds Expectations"},
	{"threshold":  75, "points": 10, "title": "Hardest Working Man in the Shake Dimension"},
//	{"threshold": 100, "points": 25, "title": "Mission Accomplished!"},
]

TOTAL_MISSION_COUNT = sum_of(STAGES, (stage) => stage.missions)
for data in MISSION_THRESHOLDS
{
	n = (data["threshold"] * TOTAL_MISSION_COUNT) / 100
	achievement(
		title=data["title"],
		description=format("Complete {0}% of the extra missions in the Shake Dimension", data["threshold"]),
		points=data["points"],
		trigger=any_of(REGIONS, (r) => any_of(ALLFILES, (file) => (
			r.is_file_loaded() && r.loaded_file() == file && r.in_stage_results() &&
			sum_of(STAGES, (stage) => prev(stage.mission_count(r, file))) < n &&
			sum_of(STAGES, (stage) => stage.mission_count(r, file)) >= n
		)))
	)
}

achievement(
	title="Mission Accomplished!",
	description="Complete all of the extra missions in the Shake Dimension",
	points=25,
	trigger=any_of(REGIONS, (r) => any_of(ALLFILES, (file) => (
		sum_of(STAGES, (stage) => prev(stage.mission_count(r, file))) < TOTAL_MISSION_COUNT &&
		measured(sum_of(STAGES, (stage) => stage.mission_count(r, file)) >= TOTAL_MISSION_COUNT,
			when=r.is_file_loaded() && r.loaded_file() == file,
			format="percent") &&
		unless(!r.in_stage_results())
	)))
)

// purchase all heart vessels
achievement(
	title="Wario, Dashing Heartthrob",
	description="Purchase every Heart Vessel from The Pirate Shop",
	points=10,
	trigger=any_of(REGIONS, (region) => any_of(ALLFILES, (file) => (
		region.in_shop() && prev(region.max_hearts(file)) == 9.0 &&
		measured(region.max_hearts(file) - 5 == 5, 
			when=region.is_file_loaded() && region.loaded_file() == file)
	)))
)


/*

stage_complete_achievement(STAGE_BY_ID[], "", )
stage_missions_achievement(STAGE_BY_ID[], "", )
stage_treasure_achievement(STAGE_BY_ID[], "", )
stage_map_achievement(     STAGE_BY_ID[], "")
*/

// --- LEADERBOARDS -------------------------------------------------------------------
