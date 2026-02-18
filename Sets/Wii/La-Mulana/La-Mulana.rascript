// La-Mulana
// #ID = 144

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

HOURS_ = 60 * 60 * 1000

// --- MEMORY -------------------------------------------------------------------
// https://retroachievements.org/codenotes.php?g=144

class Region
{
	regionname = ""
	regionflag = ""
	diskname = ""
	addr_flag_table = -1
	addr_inventory_ptr = -1
	addr_weapon_used = -1
	addr_subweapon_used = -1

	addr_field_id = -1
	addr_roomscreen_id = -1

	addr_player_data = -1
	addr_bossshop_state = -1
	addr_pause_state = -1
	addr_msx_state = -1
	addr_ingame_time = -1
	addr_music_id = -1
	addr_lamp_status = -1
	addr_software_enabled = -1

	function inventory(x) => word_be((dword_be(this.addr_inventory_ptr) & 0x1fffffff) + x*2)
	function weapon_used() => byte(this.addr_weapon_used) // values match enumerated ITEM_* (+1) values below
	function subweapon_used() => byte(this.addr_subweapon_used) // values match enumerated ITEM_* values below
	
	function flag(x) => byte(this.addr_flag_table + x)
	function field_id() => byte(this.addr_field_id)
	function screen_id() => word_be(this.addr_roomscreen_id)
	function room_id() => byte(this.addr_roomscreen_id)
	function music_id() => dword_be(this.addr_music_id)

	function boss_shop_gamestate() => byte(this.addr_bossshop_state)
	function unpaused() => bit2(this.addr_pause_state) == 0 && bit5(this.addr_msx_state) == 0
	function ingame_time_ms() => dword_be(this.addr_ingame_time)

	function _lemeza() => dword_be(this.addr_player_data) & 0x1fffffff
	function health() => dword_be(this._lemeza() + 0x204)
	function xpos() => float_be(this._lemeza() + 0x01e0)
	function ypos() => float_be(this._lemeza() + 0x01e4)

	function double_jump_used() => dword_be(this._lemeza() + 0x034) == 0x01
	function lamp_active() => bit0(this.addr_lamp_status) == 1

	function sacred_orb_count() => this.flag(852) // 10 total
	function game_software_count() => this.flag(744) // 9 total
	function software_count() => this.flag(745) // 20 total
	function coin_chest_count() => this.flag(119) // 28 total

	function ankh_jewel_chest(x) => this.flag(142+x) // 8 bytes, ==2 if ankh collected
	function is_hard_mode() => this.flag(362) == 0x02
	function boss_state(x) => this.flag(246 + x)
	function software_enabled(x) => byte(this.addr_software_enabled + x - 85)

	function is_region() => ascii_string_equals(0x3180, this.diskname)
	function in_game() => this.is_region() && prev(this.field_id()) != F_TITLE_SCREEN

	function in_room(field, screen) => this.field_id() == field && this.screen_id() == screen
	function start_boss_fight(x) => prev(this.boss_state(x)) < 2 && this.boss_state(x) == 2
	function end_boss_fight(x) => prev(this.boss_state(x)) == 2 && this.boss_state(x) == 3
}

REGIONS = [
	Region(
		regionname="US",
		regionflag="🇺🇸",
		diskname="WLME",
		addr_flag_table=0x374B88,
		addr_inventory_ptr=0x363BF0,
		addr_weapon_used=0x363FB9,
		addr_subweapon_used=0x363FBB,
		addr_field_id=0x363FD0,
		addr_roomscreen_id=0x363FD1,
		addr_player_data=0x363F60,
		addr_bossshop_state=0x37616E,
		addr_pause_state=0x376169,
		addr_msx_state=0x37616A,
		addr_ingame_time=0x363B8C,
		addr_music_id=0x363ABC,
		addr_lamp_status=0x37617A,
		addr_software_enabled=0x376600
	),
	Region(
		regionname="EU",
		regionflag="🇪🇺",
		diskname="WLMP",
		addr_flag_table=0x374B88,
		addr_inventory_ptr=0x363BF0,
		addr_weapon_used=0x363FB9,
		addr_subweapon_used=0x363FBB,
		addr_field_id=0x363FD0,
		addr_roomscreen_id=0x363FD1,
		addr_player_data=0x363F60,
		addr_bossshop_state=0x37616E,
		addr_pause_state=0x376169,
		addr_msx_state=0x37616A,
		addr_ingame_time=0x363B8C,
		addr_music_id=0x363ABC,
		addr_lamp_status=0x37617A,
		addr_software_enabled=0x376600
	),
	Region(
		regionname="JP",
		regionflag="🇯🇵",
		diskname="WLMJ",
		addr_flag_table=0x3C0D88,
		addr_inventory_ptr=0x3AFC30,
		addr_weapon_used=0x3B0021,
		addr_subweapon_used=0x3B0023,
		addr_field_id=0x3B0038,
		addr_roomscreen_id=0x3B0039,
		addr_player_data=0x3AFFC8,
		addr_bossshop_state=0x3C236E,
		addr_pause_state=0x3C2369,
		addr_msx_state=0x3C236A,
		addr_ingame_time=0x3AFBCC,
		addr_music_id=0x3AFAFC,
		addr_lamp_status=0x3C237A,
		addr_software_enabled=0x3C2800
	),
]

// --- MAIN DATA -------------------------------------------------------------------

F_GUIDANCE = 0x00
F_SURFACE = 0x01
F_MAUSOLEUM = 0x02
F_SUN_TEMPLE = 0x03
F_SPRING = 0x04
F_INFERNO = 0x05
F_EXTINCTION = 0x06
F_TWIN_LABS = 0x07
F_ENDLESS = 0x08
F_SHRINE_MOTHER = 0x09
F_ILLUSION = 0x0A
F_GRAVEYARD = 0x0B
F_MOONLIGHT = 0x0C
F_TOWER_GODDESS = 0x0D
F_RUIN = 0x0E
F_BIRTH_ALT = 0x0F
F_BIRTH_GRAIL = 0x10
F_DIMENSIONAL = 0x11
F_TRUE_SHRINE = 0x12
F_TIME_MAUS = 0x13
F_TIME_GUIDANCE = 0x14
F_TIME_SURFACE = 0x15
F_TITLE_SCREEN = 0xFF

ITEM_WHIP_LEATHER = 0
ITEM_WHIP_CHAIN = 1
ITEM_WHIP_FLAIL = 2
ITEM_KNIFE = 3
ITEM_KEY_SWORD = 4
ITEM_AXE = 5
ITEM_KATANA = 6
ITEM_KEY_SWORD_EMPOWERED = 7

ITEM_SHURIKEN = 8
ITEM_ROLLING_SHURIKEN = 9
ITEM_EARTH_SPEAR = 10
ITEM_FLARE_GUN = 11
ITEM_BOMB = 12
ITEM_CHAKRAM = 13
ITEM_CALTROPS = 14
ITEM_PISTOL = 15
ITEM_SHIELD_BUCKLER = 16
ITEM_SHIELD_SILVER = 17
ITEM_SHIELD_ANGEL = 18
ITEM_ANKH_JEWELS = 19

ITEM_SCANNER = 20
ITEM_DJED_PILLAR = 21
ITEM_MINI_DOLL = 22
ITEM_MAGATAMA = 23
ITEM_COG = 24
ITEM_LAMP_CHARGED = 25
ITEM_POCHETTE_KEY = 26
ITEM_DRAGON_BONE = 27
ITEM_CRYSTAL_SKULL = 28
ITEM_VESSEL = 29
ITEM_PEPPER = 30
ITEM_STATUE_WOMAN = 31
ITEM_KEY_OF_ETERNITY = 32
ITEM_SERPENT_STAFF = 33
ITEM_TALISMAN = 34
ITEM_MSX = 35
ITEM_CASE_WATERPROOF = 36
ITEM_CASE_HEATPROOF = 37
ITEM_SHELL_HORN = 38
ITEM_GLOVE = 39
ITEM_HOLY_GRAIL = 40
ITEM_ISIS_PENDANT = 41
ITEM_CRUCIFIX = 42
ITEM_HELMET = 43
ITEM_GRAPPLE_CLAW = 44
ITEM_BRONZE_MIRROR = 45
ITEM_EYE_OF_TRUTH = 46
ITEM_RING = 47
ITEM_SCALESPHERE = 48
ITEM_GAUNTLET = 49
ITEM_ANCHOR = 50
ITEM_PLANE_MODEL = 51
ITEM_OCARINA = 52
ITEM_FEATHER = 53
ITEM_BOOK_OF_THE_DEAD = 54
ITEM_FAIRY_CLOTHES = 55
ITEM_SCRIPTURES = 56
ITEM_HERMES_BOOTS = 57
ITEM_FRUIT_OF_EDEN = 58
ITEM_TWIN_STATUE = 59
ITEM_BRACELET = 60
ITEM_PERFUME = 61
ITEM_SPAULDER = 62
ITEM_DIMENSIONAL_KEY = 63
ITEM_ICE_CAPE = 64
ITEM_SEAL_1_ORIGIN = 65
ITEM_SEAL_2_BIRTH = 66
ITEM_SEAL_3_LIFE = 67
ITEM_SEAL_4_DEATH = 68
ITEM_SACRED_ORB = 69
ITEM_MAPS = 70
ITEM_TREASURES = 71
ITEM_DIARY = 72
ITEM_MULANA_TALISMAN = 73
ITEM_BATHING_SUIT = 74
ITEM_SHIELD_SILVER_FAKE = 75
ITEM_MSX2 = 76
ITEM_MEDICINE_YELLOW = 77
ITEM_MEDICINE_GREEN = 78
ITEM_MEDICINE_RED = 79
ITEM_LAMP_UNCHARGED = 80
ITEM_STATUE_MATERNITY = 81
ITEM_HOLY_GRAIL_BROKEN = 82
ITEM_HOLY_GRAIL_EMPOWERED = 83
ITEM_SECRET_TREASURE_OF_LIFE = 84

SOFTWARE_GLYPH_READER = 85
SOFTWARE_XELPUD_MAILER = 86
SOFTWARE_YAGOO_MAP_READER = 87
SOFTWARE_YAGOO_MAP_STREET = 88
SOFTWARE_TEXTTRAX = 89
SOFTWARE_TEXTTRAX_MEMORY = 90
SOFTWARE_SNAPSHOTS = 91
SOFTWARE_GUILD = 92
SOFTWARE_MANTRA = 93
SOFTWARE_EMUSIC = 94
SOFTWARE_BEOLAMU = 95
SOFTWARE_DEATHV = 96
SOFTWARE_RANDC = 97
SOFTWARE_CAPSTAR = 98
SOFTWARE_MOVE = 99
SOFTWARE_MEKURI = 100
SOFTWARE_BOUNCE = 101
SOFTWARE_MIRACLE = 102
SOFTWARE_MIRAI = 103
SOFTWARE_LAMULANA = 104

QUANTITY_WEIGHTS = 105
QUANTITY_COINS = 106
QUANTITY_SHURIKEN = 107
QUANTITY_ROLLING_SHURIKEN = 108
QUANTITY_EARTH_SPEAR = 109
QUANTITY_FLARE_GUN = 110
QUANTITY_BOMB = 111
QUANTITY_CHAKRAM = 112
QUANTITY_CALTROPS = 113
QUANTITY_PISTOL_CLIPS = 114
QUANTITY_PISTOL_ROUNDS = 116 // ???

BOSS_AMPHISBAENA = 0
BOSS_SAKIT = 1
BOSS_ELLMAC = 2
BOSS_BAHAMUT = 3
BOSS_VIY = 4
BOSS_PALENQUE = 5
BOSS_BAPHOMET = 6
BOSS_TIAMAT = 7
BOSS_MOTHER = 8

BOSS_NAMES = [
	"Amphisbaena",
	"Sakit",
	"Ellmac",
	"Bahamut",
	"Viy",
	"Palenque",
	"Baphomet",
	"Tiamat",
	"the Mother",
]

PHILOSOPHERS = [
	120, // Giltoriyo
	122, // Alsedana
	139, // Samaranta
	269, // Fobos
]

COUNTED_ITEMS = [
	// ITEM_WHIP_LEATHER,
	ITEM_WHIP_CHAIN,
	ITEM_WHIP_FLAIL,
	ITEM_KNIFE,
	ITEM_KEY_SWORD, // stays 1 even when empowered (state change, not tracking empowered)
	// ITEM_KEY_SWORD_EMPOWERED,
	ITEM_AXE,
	ITEM_KATANA,
	ITEM_SHURIKEN,
	ITEM_ROLLING_SHURIKEN,
	ITEM_EARTH_SPEAR,
	ITEM_FLARE_GUN,
	ITEM_BOMB,
	ITEM_CHAKRAM,
	ITEM_CALTROPS,
	ITEM_PISTOL,
	ITEM_SHIELD_BUCKLER,
	ITEM_SHIELD_SILVER,
	// ITEM_SHIELD_SILVER_FAKE,
	ITEM_SHIELD_ANGEL,
	ITEM_SCANNER,
	ITEM_DJED_PILLAR,
	ITEM_MINI_DOLL,
	ITEM_MAGATAMA,
	ITEM_COG,
	ITEM_LAMP_CHARGED, // 1 moves between charged/uncharged when used
	ITEM_LAMP_UNCHARGED,
	ITEM_POCHETTE_KEY,
	ITEM_DRAGON_BONE,
	ITEM_CRYSTAL_SKULL,
	ITEM_VESSEL, // is 1 when filled with medicine, but when medicine is used/emptied, set to 2
	// ITEM_MEDICINE_YELLOW,
	// ITEM_MEDICINE_GREEN,
	// ITEM_MEDICINE_RED,
	ITEM_PEPPER,
	ITEM_STATUE_WOMAN, // stays 1 when maternity (state change, not tracking maternity)
	// ITEM_STATUE_MATERNITY,
	ITEM_KEY_OF_ETERNITY,
	ITEM_SERPENT_STAFF,
	ITEM_TALISMAN,
	// ITEM_MSX,
	ITEM_MSX2,
	ITEM_CASE_WATERPROOF,
	ITEM_CASE_HEATPROOF,
	ITEM_SHELL_HORN,
	ITEM_GLOVE,
	ITEM_HOLY_GRAIL, // = 0 when the grail is broken/empowered
	ITEM_HOLY_GRAIL_BROKEN,
	ITEM_HOLY_GRAIL_EMPOWERED, // three grail values should sum to 1 when owned
	ITEM_ISIS_PENDANT,
	ITEM_CRUCIFIX,
	ITEM_HELMET,
	ITEM_GRAPPLE_CLAW,
	ITEM_BRONZE_MIRROR,
	ITEM_EYE_OF_TRUTH,
	ITEM_RING,
	ITEM_SCALESPHERE,
	ITEM_GAUNTLET,
	ITEM_ANCHOR,
	ITEM_PLANE_MODEL,
	ITEM_OCARINA,
	ITEM_FEATHER,
	ITEM_BOOK_OF_THE_DEAD,
	ITEM_FAIRY_CLOTHES,
	ITEM_SCRIPTURES,
	ITEM_HERMES_BOOTS,
	ITEM_FRUIT_OF_EDEN,
	ITEM_TWIN_STATUE,
	ITEM_BRACELET,
	ITEM_PERFUME,
	ITEM_SPAULDER,
	ITEM_DIMENSIONAL_KEY,
	ITEM_ICE_CAPE,
	ITEM_SEAL_1_ORIGIN,
	ITEM_SEAL_2_BIRTH,
	ITEM_SEAL_3_LIFE,
	ITEM_SEAL_4_DEATH,
	ITEM_TREASURES,
	ITEM_DIARY,
	ITEM_MULANA_TALISMAN,
	// ITEM_SECRET_TREASURE_OF_LIFE,
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function item_count(r) => (
	// 3 (-2) rotating grail states, 2 (-1) rotating lamp states
	sum_of(COUNTED_ITEMS, x => r.inventory(x) / r.inventory(x)) +
	// 8 ankh jewels
	sum_of(range(0,7), x => r.ankh_jewel_chest(x) / 2)
)

MAX_COUNTED_ITEMS = length(COUNTED_ITEMS) - 3 + 8

function win_the_game(r) => (
	// mother has been defeated, we are escaping!
	r.boss_state(BOSS_MOTHER) == 0x04 &&
	// we're in Mulbruk's room
	r.in_room(F_SUN_TEMPLE, 0x0300) &&
	// game is not paused (blocks Enga Musica)...
	r.unpaused() &&
	// ...since we're checking music id for the escape
	prev(r.music_id()) != 0x2B && r.music_id() == 0x2B
) 

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

function one_finger_achievement(boss, field, screen, title, points)
{
	achievement(
		title=title,
		description=format("Defeat {0} without using any sub-weapons in hard mode", BOSS_NAMES[boss]),
		points=points,
		trigger=any_of(REGIONS, r => (
			once(r.is_region() && r.is_hard_mode() && r.in_room(field, screen) && r.start_boss_fight(boss)) &&
			trigger_when(r.end_boss_fight(boss)) &&
			never(r.is_region() && !r.in_room(field, screen)) &&
			never(r.is_region() && r.subweapon_used() >= 0x08 && r.subweapon_used() <= 0x0F)
		))
	)
}

function boss_progression_achievement(boss, field, screen, title, points)
{
	achievement(
		title=title,
		description=format("Defeat {0}", BOSS_NAMES[boss]),
		type="progression",
		points=points,
		trigger=any_of(REGIONS, r => (
			r.is_region() && r.in_room(field, screen) &&
			r.end_boss_fight(boss)
		))
	)
}

function item_achievement(item, field, screen, title, desc, points)
{
	achievement(
		title=title,
		description=desc,
		points=points,
		trigger=any_of(REGIONS, r => (
			r.is_region() && r.in_room(field, screen) &&
			// r.boss_shop_gamestate() == 0x41 && // <-- add this for shops
			prev(r.inventory(item)) == 0 && r.inventory(item) > 0
		))
	)
}

achievement(
	title="Rise and Shine, Seventh Children",
	description="Wake all four philosophers",
	type="progression",
	points=5,
	trigger=any_of(REGIONS, r => (
		sum_of(PHILOSOPHERS, x => prev(r.flag(x) / r.flag(x))) == 3 &&
		measured(
			sum_of(PHILOSOPHERS, x => r.flag(x) / r.flag(x)) == 4,
			when=r.in_game()
		)
	))
)

achievement(
	title="Arise, My Creation",
	description="Ugallu's body, Urmahlullu's voice, Umu Dabrutu's wings, Ushum's tail",
	type="progression",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_DIMENSIONAL, 0x0901) &&
		prev(r.flag(704)) == 4 && r.flag(704) == 5
	))
)

achievement(
	title="Kingdom Hearts... Is Light!",
	description="Empower the Key Sword",
	type="progression",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_ILLUSION, 0x0000) &&
		prev(r.flag(292)) < 0x04 && r.flag(292) == 0x04
	))
)

boss_progression_achievement(BOSS_AMPHISBAENA, F_GUIDANCE, 0x0801, "King Konda", 2)
// boss_progression_achievement(BOSS_SAKIT, F_MAUSOLEUM, 0x0801, "Giant's Rage", 5)
boss_progression_achievement(BOSS_ELLMAC, F_SUN_TEMPLE, 0x0800, "High Speed Beast", 10)
// boss_progression_achievement(BOSS_BAHAMUT, F_SPRING, 0x0400, "Dangerous Raid", 10)
boss_progression_achievement(BOSS_VIY, F_INFERNO, 0x0801, "In the Bottom", 10)
// boss_progression_achievement(BOSS_BAPHOMET, F_TWIN_LABS, 0x0401, "Sabbat", 10)
boss_progression_achievement(BOSS_PALENQUE, F_EXTINCTION, 0x0901, "Ancient Machine", 25)
// boss_progression_achievement(BOSS_TIAMAT, F_DIMENSIONAL, 0x0900, "Interstice of the Dimension", 25)
boss_progression_achievement(BOSS_MOTHER, F_TRUE_SHRINE, 0x0300, "Good Night Mom", 25)

one_finger_achievement(BOSS_AMPHISBAENA, F_GUIDANCE, 0x0801, "All I Need Is One Finger versus Amphibaena", 5)
one_finger_achievement(BOSS_SAKIT, F_MAUSOLEUM, 0x0801, "All I Need Is One Finger versus Sakit", 5)
one_finger_achievement(BOSS_ELLMAC, F_SUN_TEMPLE, 0x0800, "All I Need Is One Finger versus Ellmac", 10)
one_finger_achievement(BOSS_BAHAMUT, F_SPRING, 0x0400, "All I Need Is One Finger versus Bahamut", 10)
one_finger_achievement(BOSS_VIY, F_INFERNO, 0x0801, "All I Need Is One Finger versus Viy", 10)
one_finger_achievement(BOSS_BAPHOMET, F_TWIN_LABS, 0x0401, "All I Need Is One Finger versus Baphomet", 10)
one_finger_achievement(BOSS_PALENQUE, F_EXTINCTION, 0x0901, "All I Need Is One Finger versus Palenque", 25)
one_finger_achievement(BOSS_TIAMAT, F_DIMENSIONAL, 0x0900, "All I Need Is One Finger versus Tiamat", 25)
one_finger_achievement(BOSS_MOTHER, F_TRUE_SHRINE, 0x0300, "All I Need Is One Finger versus the Mother", 25)

achievement(
	title="The Myth of \"Consensual\" Boss Fights",
	description="Defeat Baphomet without killing Zu or Peryton",
	type="missable",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_TWIN_LABS, 0x0401) &&
		r.flag(482) == 0 && r.flag(472) == 0 &&
		r.end_boss_fight(BOSS_BAPHOMET)
	))
)

achievement(
	title="We Love a Healthy Boy",
	description="Collect all sacred orbs",
	points=10,
	trigger=any_of(REGIONS, r => (
		prev(r.sacred_orb_count()) == 9 && 
		measured(r.sacred_orb_count() == 10, when=r.in_game())
	))
)

achievement(
	title="Ransacking the Ruins",
	description="Collect all items",
	points=25,
	trigger=any_of(REGIONS, r => (
		prev(item_count(r)) == MAX_COUNTED_ITEMS - 1 &&
		measured(item_count(r) == MAX_COUNTED_ITEMS, when=r.in_game(), format="percent")
	))
)

achievement(
	title="Let's Play NIGORO Game!",
	description="Collect all game software",
	points=10,
	trigger=any_of(REGIONS, r => (
		prev(r.game_software_count()) == 8 && 
		measured(r.game_software_count() == 9, when=r.in_game())
	))
)

achievement(
	title="__AllCoinChests",
	description="Open all coin chests",
	points=5,
	trigger=any_of(REGIONS, r => (
		prev(r.coin_chest_count()) == 27 && 
		measured(r.coin_chest_count() == 28, when=r.in_game())
	))
)

achievement(
	title="Open Sesame",
	description="Unlock all key fairy checks",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.in_game() && prev(r.flag(902)) == 3 && r.flag(902) == 4
	))
)

achievement(
	title="Samaranta Is Impressed by Your Dedication",
	description="Complete the game in under 40 hours in-game time",
	type="missable",
	points=10,
	trigger=any_of(REGIONS, r => (
		r.is_region() && win_the_game(r) && r.ingame_time_ms() < 40 * HOURS_
	))
)

achievement(
	title="Rusalii Is Amazed by Your Speed",
	description="Complete the game in under 10 hours in-game time",
	type="missable",
	points=25,
	trigger=any_of(REGIONS, r => (
		r.is_region() && win_the_game(r) && r.ingame_time_ms() < 10 * HOURS_
	))
)

achievement(
	title="To the One Who Toils for Naught: Thou Art Foolish",
	description="Unlock the third floor of the Endless Corridor while treading the fool's path",
	type="missable",
	points=5,
	trigger=any_of(REGIONS, r => (
		once(r.is_region() && r.in_room(F_ENDLESS, 0x0303) && prev(r.flag(506)) == 0 && r.flag(506) == 1) &&
		trigger_when(r.in_room(F_ENDLESS, 0x0303) && prev(r.flag(506)) == 1 && r.flag(506) == 2) &&
		never(r.is_region() && r.field_id() != F_ENDLESS) && 
		never(r.is_region() && r.room_id() != 0x03) &&
		never(r.is_region() && r.flag(506) == 0) &&
		never(r.is_region() && r.in_room(F_ENDLESS, 0x0303) && r.xpos() > 450.0 && r.xpos() <= 510.0 && r.ypos() <= 42.0)
	))
)

achievement(
	title="Echidna's Parkour Challenge",
	description="After entering via the ladder, cross Echidna's Chamber without taking damage",
	points=3,
	trigger=any_of(REGIONS, r => (
		// challenge starts when entering Echidna's chamber from the surface
		once(r.is_region() && prev(r.in_room(F_SURFACE, 0x0402)) && r.in_room(F_INFERNO, 0x0901)) &&
		// challenge is won when entering the door on the far side of Echidna's chamber
		trigger_when(r.in_room(F_INFERNO, 0x0900) && prev(r.boss_shop_gamestate()) == 0x00 && r.boss_shop_gamestate() == 0x01) &&
		// leaving Echidna's chamber fails the challenge
		never(r.is_region() && r.field_id() != F_INFERNO && r.room_id() != 0x09) &&
		// taking damage fails the challenge
		never(r.is_region() && r.health() < prev(r.health()))
	))
)

achievement(
	title="Taking in the Scenery",
	description="Empower the key sword before collecting the holy grail",
	points=100,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_ILLUSION, 0x0000) &&
		prev(r.flag(292)) < 0x04 && r.flag(292) == 0x04 &&
		r.inventory(ITEM_HOLY_GRAIL) == 0 &&
		r.inventory(ITEM_HOLY_GRAIL_EMPOWERED) == 0 &&
		r.inventory(ITEM_HOLY_GRAIL_BROKEN) == 0
	))
)

achievement(
	title="Ours Is Another Road",
	description="Take the hidden entrance into the Tower of the Goddess",
	points=2,
	trigger=any_of(REGIONS, r => (
		r.is_region() &&
		prev(r.in_room(F_TIME_MAUS, 0x0102)) &&
		r.in_room(F_TOWER_GODDESS, 0x0400)
	))
)

achievement(
	title="Do the Mario!",
	description="Take the hidden entrance into the Spring in the Sky",
	points=2,
	trigger=any_of(REGIONS, r => (
		r.is_region() &&
		prev(r.in_room(F_MAUSOLEUM, 0x0802)) &&
		r.in_room(F_SPRING, 0x0200)
	))
)

item_achievement(ITEM_SEAL_2_BIRTH, F_SURFACE, 0x0701, "Something New", "Collect the Birth Seal", 3)

achievement(
	title="Something Blue",
	description="Collect the Death Seal",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && 
		__ornext(any_of([F_SHRINE_MOTHER, F_TRUE_SHRINE], x => r.screen_id() == x)) && 
		r.screen_id() == 0x0900 &&
		prev(r.inventory(ITEM_SEAL_4_DEATH)) == 0 && r.inventory(ITEM_SEAL_4_DEATH) > 0
	))
)

LAPTOP_CASES = [ITEM_CASE_WATERPROOF, ITEM_CASE_HEATPROOF]
achievement(
	title="Protected from the Elements",
	description="Purchase the Waterproof Case and the Heatproof Case",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.boss_shop_gamestate() == 0x41 &&
		prev(sum_of(LAPTOP_CASES, x => r.inventory(x) / r.inventory(x))) == 1 &&
		measured(sum_of(LAPTOP_CASES, x => r.inventory(x) / r.inventory(x)) == 2, when=r.in_game())
	))
)

item_achievement(ITEM_GLOVE, F_SPRING, 0x0200, "For His Glove's a Glove of Power", "Collect the Glove", 2)
item_achievement(ITEM_ISIS_PENDANT, F_SUN_TEMPLE, 0x0200, "You Who Guide the Wanderers' Steps", "Collect Isis' Pendant", 5)
item_achievement(ITEM_HELMET, F_TWIN_LABS, 0x0302, "OSHA Approved!", "Purchase the Helmet", 5)
item_achievement(ITEM_BRONZE_MIRROR, F_SUN_TEMPLE, 0x0500, "Another Side of the Story", "Collect the Bronze Mirror", 5)
item_achievement(ITEM_RING, F_TWIN_LABS, 0x0200, "__ItemRing", "Collect the Ring", 3)
item_achievement(ITEM_GAUNTLET, F_GRAVEYARD, 0x0401, "Dark Legacy", "Collect the Gauntlet", 5)
item_achievement(ITEM_ANCHOR, F_ILLUSION, 0x0800, "That Sinking Feeling", "Collect the Anchor", 3)
item_achievement(ITEM_OCARINA, F_MOONLIGHT, 0x0500, "The Sound of Silence", "Collect the Philosopher's Ocarina", 5)
item_achievement(ITEM_BOOK_OF_THE_DEAD, F_SUN_TEMPLE, 0x0300, "It Is Essential for a Hamburger", "Collect the Book of the Dead", 3)
item_achievement(ITEM_SCRIPTURES, F_MOONLIGHT, 0x0700, "Bat Insurance", "Purchase the Scriptures", 5)
item_achievement(ITEM_FRUIT_OF_EDEN, F_MOONLIGHT, 0x0200, "Moonlight Scavenger Hunt", "Collect the Fruit of Eden", 5)
item_achievement(ITEM_BRACELET, F_TWIN_LABS, 0x0E00, "I Hate Porcelain! It's a Long Story", "Purchase the Bracelet", 5)
item_achievement(ITEM_SPAULDER, F_TOWER_GODDESS, 0x0700, "Natural Flail Enhancement", "Collect the Spaulder", 5)
item_achievement(ITEM_ICE_CAPE, F_INFERNO, 0x0701, "Prepare for Frostbite", "Collect the Ice Cape", 3)
item_achievement(ITEM_WHIP_FLAIL, F_TOWER_GODDESS, 0x0500, "Bloody Tears", "Collect the Flail Whip", 10)
item_achievement(ITEM_AXE, F_MOONLIGHT, 0x0300, "__ItemAxe", "Collect the Axe", 5)
item_achievement(ITEM_KEY_SWORD, F_ENDLESS, 0x0201, "__ItemKeySword", "Collect the Key Sword", 5)
item_achievement(ITEM_ROLLING_SHURIKEN, F_MAUSOLEUM, 0x0300, "__ItemRollingShuriken", "Collect the Rolling Shuriken", 5)
item_achievement(ITEM_FLARE_GUN, F_INFERNO, 0x0400, "__ItemFlareGun", "Collect the Flare Gun", 5)
item_achievement(ITEM_CALTROPS, F_SPRING, 0x0100, "__ItemCaltrops", "Collect the Caltrops", 2)
item_achievement(ITEM_PISTOL, F_SURFACE, 0x0201, "That's Right, We're Gonna Cheat", "Purchase the Pistol", 5)
item_achievement(ITEM_SHIELD_SILVER, F_GRAVEYARD, 0x0101, "__ItemSilverShield", "Collect the Silver Shield", 5)
item_achievement(ITEM_SCANNER, F_SURFACE, 0x0201, "__ItemHandScanner", "Purchase the Hand Scanner", 3)

achievement(
	title="Prove Thou Art Small",
	description="Collect the Clay Doll and prove thou art small",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.field_id() == F_MAUSOLEUM &&
		r.inventory(ITEM_MINI_DOLL) != 0 &&
		prev(r.flag(344)) == 0 && r.flag(344) > 0
	))
)

item_achievement(ITEM_COG, F_ILLUSION, 0x0001, "__ItemCogofLife", "Collect the Cog of Life", 10)
item_achievement(ITEM_POCHETTE_KEY, F_BIRTH_GRAIL, 0x0301, "__ItemPochetteKey", "Collect the Pochette Key", 5)
item_achievement(ITEM_CRYSTAL_SKULL, F_SHRINE_MOTHER, 0x0100, "__ItemCrystalSkull", "Collect the Crystal Skull", 5)
item_achievement(ITEM_STATUE_WOMAN, F_BIRTH_ALT, 0x0400, "__ItemWomanStatue", "Collect the Woman Statue", 5)
item_achievement(ITEM_SERPENT_STAFF, F_MOONLIGHT, 0x0A00, "__ItemSerpentStaff", "Collect the Serpent Staff", 5)
item_achievement(ITEM_DIARY, F_SHRINE_MOTHER, 0x0201, "__ItemDiary", "Collect the Diary", 5)

achievement(
	title="1 vs 100",
	description="Defeat Backbeard & Tai Sui",
	points=5,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.field_id() == F_ENDLESS && r.room_id() == 0x05 &&
		prev(r.flag(500)) == 0 && r.flag(500) == 1
	))
)

achievement(
	title="Jack of All Blades; Master of Gun",
	description="Survive being shot by a pistol",
	points=5,
	trigger=any_of(REGIONS, r => (
		// check for Chi You's room
		r.is_region() && r.in_room(F_ILLUSION, 0x0202) &&
		// I lived, bitch
		r.health() > 0 &&
		// low enough to get hit by a bullet (ensuring this isn't spikes damage)
		r.ypos() > 72.0 &&
		(
			// without fairy clothes, pistol does 64 damage
			(r.inventory(ITEM_FAIRY_CLOTHES) == 0 && r.health() - prev(r.health()) == 64) ||
			// with fairy clothes, pistol does 30% less damage (44 damage)
			(r.inventory(ITEM_FAIRY_CLOTHES) == 1 && r.health() - prev(r.health()) == 44)
		) // TODO: check hard mode numbers
	))
)

achievement(
	title="Kara's Wrath",
	description="Defeat Nuckalevee without using any weapons or subweapon ammo",
	points=5,
	trigger=any_of(REGIONS, r => (
		once(r.is_region() && prev(r.in_room(F_SPRING, 0x0302)) && r.in_room(F_SPRING, 0x0501)) &&
		trigger_when(prev(r.flag(401)) == 0 && r.flag(401) == 1) &&
		never(r.is_region() && !r.in_room(F_SPRING, 0x0501)) &&
		never(r.is_region() && r.weapon_used() >= 0x01 && r.weapon_used() <= 0x08) &&
		never(r.is_region() && r.subweapon_used() >= 0x08 && r.subweapon_used() <= 0x0F)
	))
)

achievement(
	title="And This Is How You Repay Me?",
	// title="You Have One Wish Left, Professor",
	description="Defeat Pazuzu",
	points=3,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_INFERNO, 0x0301) &&
		prev(r.flag(431)) < 3 && r.flag(431) == 3
	))
)

achievement(
	title="Properly Grounded",
	description="Defeat Thunderbird",
	points=2,
	trigger=any_of(REGIONS, r => (
		r.is_region() && r.in_room(F_RUIN, 0x0301) &&
		prev(r.flag(654)) == 0 && r.flag(654) == 1
	))
)

achievement(
	title="An Unruly Child",
	description="Defeat Skanda on hard mode without using the Lamp of Time",
	points=10,
	trigger=any_of(REGIONS, r => (
		once(r.is_region() && r.is_hard_mode() && prev(r.in_room(F_BIRTH_GRAIL, 0x0300)) && r.in_room(F_BIRTH_GRAIL, 0x0301)) &&
		trigger_when(prev(r.flag(678)) < 2 && r.flag(678) == 2) &&
		never(r.is_region() && !r.in_room(F_BIRTH_GRAIL, 0x0301)) &&
		never(r.lamp_active())
	))
)

achievement(
	title="Shortcut to Treasure",
	description="Collect the Dimensional Corridor sacred orb while Ushumgallu is still alive and without using the Lamp of Time",
	points=5,
	trigger=any_of(REGIONS, r => (
		// enter Ushumgallu's room from Tiamat's room
		once(r.is_region() && prev(r.in_room(F_DIMENSIONAL, 0x0900)) && r.in_room(F_DIMENSIONAL, 0x0A01)) &&
		// check that the Dimensional Corridor sacred orb has been collected
		trigger_when(prev(r.flag(199+9)) < 2 && r.flag(199+9) == 2) &&
		// leaving the field or room fails the challenge
		never(r.is_region() && r.field_id() != F_DIMENSIONAL) &&
		never(r.is_region() && r.room_id() != 0x0A) &&
		// killing Ushumgallu fails the challenge
		never(r.is_region() && r.flag(716) == 1) &&
		// using the Lamp of Time fails the challenge
		never(r.is_region() && r.lamp_active())
	))
)

achievement(
	title="Let's Play All Together",
	description="Find the three secret developer rooms and speak with each developer",
	points=5,
	trigger=any_of(REGIONS, r => (
		prev(sum_of(range(904,906), x => r.flag(x))) == 2 &&
		measured(sum_of(range(904,906), x => r.flag(x)) == 3, when=r.in_game())
	))
)

/*

achievement(
	title="",
	description="",
	points=5,
	trigger=any_of(REGIONS, r => (
		
	))
)
*/

// --- LEADERBOARDS -------------------------------------------------------------------
