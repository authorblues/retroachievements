// ~Hack~ The Adventure of Mario
// #ID = 39071

// --- HELPERS -------------------------------------------------------------------

function unset(acc) => acc < prev(acc)
function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function rich_presence_condition_table(lookupname, list)
{ // highest priority needs to be listed first in the pairs list
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

// --- MEMORY -------------------------------------------------------------------

// $0027: In Game State [8 bit]
//        bit5 | title screen
function in_game() => bit5(0x0027) == 0

// $0070: X Speed in Side View [8 bit] [signed]
function xspeed() => byte(0x0070)

// $0073: Player Y on Overworld [8 bit]
function overworldY() => byte(0x0073)

// $0074: Player X on Overworld [8 bit]
//        
//        map id, y position, x position
//        0x00,0x5b,0x08 = exiting Saria
function overworldX() => byte(0x0074)

// $00A1: Enemy #6 ID [8 bit]
// $00A2: Enemy #5 ID [8 bit]
// $00A3: Enemy #4 ID [8 bit]
// $00A4: Enemy #3 ID [8 bit]
// $00A5: Enemy #2 ID [8 bit]
// $00A6: Enemy #1 ID [8 bit]
//        0x01 = key
//        0x0a = rebonack's horse
//        0x1e = big gel GP -> 0x04 small gels
//        0x20 = horse head P1, rebonack P3
//        0x21 = helmet head boss P2
//        0x21 = gooma P5
//        0x21 = barba P6
//        0x22 = helmet head floating helmets
//        0x22 = carrock P4
//        could detect boss dying by the boss object turning into 0x01
ENEMY_IDS = 0x00A1

// $00C2: Enemy #6 Health [8 bit]
// $00C3: Enemy #5 Health [8 bit]
// $00C4: Enemy #4 Health [8 bit]
// $00C5: Enemy #3 Health [8 bit]
// $00C6: Enemy #2 Health [8 bit]
// $00C7: Enemy #1 Health [8 bit]
ENEMY_HEALTH = 0x00C2

// $015B: Is Grounded [8 bit]
//        0 = grounded
//        1 = jumping
//        2 = not on ground for other reason (fall off ledge, hit by enemy)
function is_grounded() => byte(0x015B)

// $0518: Invincibility Frames [8 bit]
//        when hit, set to 4, counts down to 0
//        non-zero means no damage taken
function invincibility_frames() => byte(0x0518)

// $0561: Room ID [8 bit]
//        
//        area,room
//        0x02,0x00 = North Castle
//        
//        0x02,0x09 = Jump Cave 1
//        0x02,0x0a = Jump Cave 2
//        0x02,0x0b = Jump Cave 3
//        
//        P1 parapa palace
//        0x08,0x0c = room before boss
//        0x08,0x01 = boss chamber
//        
//        P2 midoro palace
//        0x0a,0x22 = room before boss
//        0x0a,0x0a = boss chamber
//        
//        P3 island palace
//        0x12,0x0e = room before boss
//        0x12,0x01 = boss chamber
//        
//        P4 maze palace
//        0x14,0x20 = room before boss
//        0x14,0x10 = boss chamber
//        
//        P5 palace by the sea
//        0x16,0x35 = room before boss
//        0x16,0x24 = boss chamber
//        
//        P6 three eye palace
//        0x18,0x3d = room before boss
//        0x16,0x25 = boss chamber
//        
//        P7 great palace
//        0x0c,0x02 = thunderbird
//        0x0c,0x01 = dark mario
//        0x0e,0x3d = ending 1
//        0x0e,0x3e = ending 2
function room_id() => byte(0x0561)

// $056B: Town ID [8 bit]
//        0 = Rauru
//        1 = Ruto
//        2 = Saria
//        3 = Mido
//        4 = Nabooru
//        5 = Darunia
//        6 = new Kasuto
//        7 = old Kasuto
function town_id() => byte(0x056B)

// $0700: Lives [8 bit]
function lives() => byte(0x0700)

// $0706: Overworld Map ID [8 bit]
//        0 = West Hyrule
//        1 = Death Mountain
//        2 = East Hyrule
//        3 = Maze Island
function overworld_map_id() => byte(0x0706)

// $0728: Screen Locked [8 bit]
//        0 = unlocked
//        1 = locked
function screen_locked() => byte(0x0728)

// $076E: Area ID [8 bit]
//        0x00 = Title/File Select
//        0x02 = Assorted Overworld & Caves
//        0x04 = Assorted Overworld & Caves
//        0x06 = Town
//        0x08 = Parapa Palace
//        0x0a = Midoro Palace
//        0x0c = Great Palace
//        0x0e = Ending
//        0x12 = Island Palace
//        0x14 = Maze Island Palace
//        0x16 = Palace on the Sea
//        0x18 = Three-Eye Rock Palace
function area_id() => byte(0x076E)

// $076F: Powerup State [8 bit]
//        bit0 | Shield Active
//        bit1 | Tanooki Tail
//        bit3 | Fairy
//        bit4 | Fire
//        bit5 | Reflect
function shield_active() => bit0(0x076F)
function tanooki_powerup() => bit1(0x076F)
function fairy_active() => bit3(0x076F)
function fire_powerup() => bit4(0x076F)
function reflect_active() => bit5(0x076F)

// $0770: Next Exp [16 bit BE]
function next_exp() => word_be(0x0770)

// $0773: Magic [8 bit] (0-255, 32 per block)
function magic() => byte(0x0773)

// $0774: Health [8 bit] (0-255, 32 per block)
function health() => byte(0x0774)

// $0775: Exp [16 bit BE]
function exp() => word_be(0x0775)

// $0777: Attack Level [8 bit]
function attack_level() => byte(0x0777)

// $0778: Magic Level [8 bit]
function magic_level() => byte(0x0778)

// $0779: Life Level [8 bit]
function life_level() => byte(0x0779)

// $077B: Learned Shield Spell [8 bit] (0/1)
//        0x06,0x30
function learned_shield_spell() => byte(0x077B)

// $077C: Learned Tanooki Spell [8 bit] (0/1)
//        0x06,0x31
function learned_tanooki_spell() => byte(0x077C)

// $077D: Learned Life Spell [8 bit] (0/1)
//        0x06,0x32
function learned_life_spell() => byte(0x077D)

// $077E: Learned Fairy Spell [8 bit] (0/1)
//        0x06,0x33
function learned_fairy_spell() => byte(0x077E)

// $077F: Learned Fire Spell [8 bit] (0/1)
//        0x06,0x34
function learned_fire_spell() => byte(0x077F)

// $0780: Learned Reflect Spell [8 bit] (0/1)
//        0x06,0x35
function learned_reflect_spell() => byte(0x0780)

// $0781: Learned Spell Spell [8 bit] (0/1)
//        0x06,0x2a
function learned_spell_spell() => byte(0x0781)

// $0782: Learned Thunder Spell [8 bit] (0/1)
//        0x06,0x37
function learned_thunder_spell() => byte(0x0782)

// $0783: Magic Containers [8 bit] (1-8)
function magic_containers() => byte(0x0783)

// $0784: Health Containers [8 bit] (1-8)
function health_containers() => byte(0x0784)

// $0785: Have Candle [8 bit] (0/1)
function have_candle() => byte(0x0785)

// $0786: Have Glove [8 bit] (0/1)
function have_glove() => byte(0x0786)

// $0787: Have Raft [8 bit] (0/1)
function have_raft() => byte(0x0787)

// $0788: Have Boots [8 bit] (0/1)
function have_boots() => byte(0x0788)

// $0789: Have Flute [8 bit] (0/1)
function have_flute() => byte(0x0789)

// $078A: Have Cross [8 bit] (0/1)
function have_cross() => byte(0x078A)

// $078B: Have Hammer [8 bit] (0/1)
//        0x02,0x15
function have_hammer() => byte(0x078B)

// $078C: Have Magical Key [8 bit] (0/1)
function have_magical_key() => byte(0x078C)

// $0793: Keys [8 bit]
function keys() => byte(0x0793)

// $0794: Gems [8 bit]
function gems() => byte(0x0794)

// $0796: Combat Abilities [8 bit]
//        bit2 | hammer on small mario 0x06,0x2d
//        bit4 | pierce shield 0x06,0x2c
function small_hammer() => bit2(0x0796)
function shield_pierce() => bit4(0x0796)

// $0799: Have Mirror [8 bit] (0/1)
function have_mirror() => byte(0x0799)

// $079A: bit3 | Talked to Bagu
function talked_to_bagu() => bit3(0x079A)

// $079B: Have Water [8 bit] (0/1)
//        0x06,0x0d
function have_water() => byte(0x079B)

// $079F: Continues Used [8 bit]
function continues_used() => byte(0x079F)

// $773C: Game Timer [24 bit]
function game_timer() => tbyte(0x773C)

// $773F: Death Count [8 bit]
function death_count() => byte(0x773F)

// $7740: Hammer Count [16 bit]
function hammer_count() => word(0x7740)

// $7742: Fireball Count [16 bit]
function fireball_count() => word(0x7742)

// $7744: Jump Count [16 bit]
//        rolls over at 65535, so can't be trusted in endgame
function jump_count() => word(0x7744)

// $7746: Stomp Count [16 bit]
function stomp_count() => word(0x7746)

// $7748: Time Spent in Ambushes [24 bit]
function time_spent_in_ambushes() => tbyte(0x7748)

// $774B: Time Spent in Palace 1 [24 bit]
function time_spent_in_palace_1() => tbyte(0x774B)

// $774E: Time Spent in Palace 2 [24 bit]
function time_spent_in_palace_2() => tbyte(0x774E)

// $7751: Time Spent in Palace 3 [24 bit]
function time_spent_in_palace_3() => tbyte(0x7751)

// $7754: Time Spent in Palace 4 [24 bit]
function time_spent_in_palace_4() => tbyte(0x7754)

// $7757: Time Spent in Palace 5 [24 bit]
function time_spent_in_palace_5() => tbyte(0x7757)

// $775A: Time Spent in Palace 6 [24 bit]
function time_spent_in_palace_6() => tbyte(0x775A)

// $775D: Time Spent in Great Palace [24 bit]
function time_spent_in_great_palace() => tbyte(0x775D)

// $7760: Number of Journey Rows [8 bit]
function number_of_journey_rows() => byte(0x7760)

// $7761: Journey IDs [16 bytes]
//        0x00 = Glove
//        0x01 = Raft
//        0x02 = Boots
//        0x03 = Hammer
//        0x04 = Jump
//        0x05 = Fairy
//        0x06 = Reflect
//        0x07 = Thunder
//        0x08 = Palace 1
//        0x09 = Palace 2
//        0x0a = Palace 3
//        0x0b = Palace 4
//        0x0c = Palace 5
//        0x0d = Palace 6
//        0x0e = Great Palace
//        
//        order of ids indicates the order it appears in the Journey list in the postgame stats. serves as an index into the list of journey times to follow.
JOURNEY_TABLE = 0x7761

// $7771: Journey Time - Glove [24 bit]
function journey_time_glove() => tbyte(0x7771)

// $7774: Journey Time - Raft [24 bit]
function journey_time_raft() => tbyte(0x7774)

// $7777: Journey Time - Boots [24 bit]
function journey_time_boots() => tbyte(0x7777)

// $777A: Journey Time - Hammer [24 bit]
function journey_time_hammer() => tbyte(0x777A)

// $777D: Journey Time - Jump Spell [24 bit]
function journey_time_jump_spell() => tbyte(0x777D)

// $7780: Journey Time - Fairy Spell [24 bit]
function journey_time_fairy_spell() => tbyte(0x7780)

// $7783: Journey Time - Reflect Spell [24 bit]
function journey_time_reflect_spell() => tbyte(0x7783)

// $7786: Journey Time - Thunder Spell [24 bit]
function journey_time_thunder_spell() => tbyte(0x7786)

// $7789: Journey Time - Palace 1 [24 bit]
function journey_time_palace_1() => tbyte(0x7789)

// $778C: Journey Time - Palace 2 [24 bit]
function journey_time_palace_2() => tbyte(0x778C)

// $778F: Journey Time - Palace 3 [24 bit]
function journey_time_palace_3() => tbyte(0x778F)

// $7792: Journey Time - Palace 4 [24 bit]
function journey_time_palace_4() => tbyte(0x7792)

// $7795: Journey Time - Palace 5 [24 bit]
function journey_time_palace_5() => tbyte(0x7795)

// $7798: Journey Time - Palace 6 [24 bit]
function journey_time_palace_6() => tbyte(0x7798)

// $779B: Journey Time - Great Palace [24 bit]
function journey_time_great_palace() => tbyte(0x779B)

// --- MAIN DATA -------------------------------------------------------------------

PALACE_LOOKUP = {
	0x08: "Parapa Palace",
	0x0a: "Midoro Palace",
	0x12: "Island Palace",
	0x14: "Maze Island Palace",
	0x16: "the Palace on the Sea",
	0x18: "Three-Eye Rock Palace",
	0x0c: "the Great Palace",
}

TOWN_LOOKUP = {
	0: "Rauru",
	1: "Ruto",
	2: "Saria",
	3: "Mido",
	4: "Nabooru",
	5: "Darunia",
	6: "new Kasuto",
	7: "old Kasuto",
}

OVERWORLD_LOOKUP = {
	0: "West Hyrule",
	1: "Death Mountain",
	2: "East Hyrule",
	3: "Maze Island",
}

_1UPS = [
	bit2(0x0619), // 1UP post jump cave 0x02,0x33
	bit1(0x061c), // 1UP west of king's tomb 0x02,0x39
	bit1(0x0659), // 1UP swamp north of P6 0x04,0x33
	bit1(0x065c), // 1UP near bridge to maze island 0x04,0x39
	bit4(0x06bd), // 1UP P6 dead end before Barba pit 0x18,0x3a
	bit4(0x06da), // 1UP GP near fairy 0x0c,0x34
]

PALETTES = [
	shield_active() == 1,
	shield_active() == 0 && fire_powerup() == 1,
	shield_active() == 0 && fire_powerup() == 0,
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function enemy_id(i) => byte(ENEMY_IDS + i)
function enemy_hp(i) => byte(ENEMY_HEALTH + i)

function start_boss(area, room) => (
	area_id() == area && room_id() == room &&
	prev(screen_locked()) == 0 && screen_locked() == 1
)

function defeat_boss(area, room, id, start=always_true()) => (
	// challenge starts when in room and other start conditions
	once(start_boss(area, room) && start) &&
	// reset if you leave the area
	never(area_id() != area) &&
	// reset if you leave the room
	never(room_id() != room) &&
	// reset if you die
	never(health() == 0) && never(lives() < prev(lives())) &&
	// challenge ends when...
	trigger_when(any_of(range(0,5), 
		// boss object becomes a key
		i => prev(enemy_id(i)) == id && enemy_id(i) == 0x01)
	)
)

function collect_hammer() => area_id() == 0x02 && room_id() == 0x15 && is_set(have_hammer())

function player_name(p1, p2) => dword_be(0x0FA1) == p1 && dword_be(0x0FA5) == p2

function start_the_game() => prev(area_id()) == 0x00 && area_id() == 0x02 && game_timer() == 0

function collect_any_1up() => any_of(_1UPS, x => unset(x))

// --- RICH PRESENCE -------------------------------------------------------------------

rp_overworld = rich_presence_lookup("OVERWORLD", overworld_map_id(), OVERWORLD_LOOKUP, fallback="Hyrule")
rp_palace = rich_presence_lookup("PALACE", area_id(), PALACE_LOOKUP, fallback="Hyrule")
rp_town = rich_presence_lookup("TOWN", town_id(), TOWN_LOOKUP, fallback="Rauru")
rp_powerup = rich_presence_condition_table("POWERUP", [
	[health() < 64, "Small"],
	[tanooki_powerup() == 1, "Tanooki"],
	[fire_powerup() == 1, "Fire"],
	[always_true(), "Super"],
])

rp_lives = rich_presence_number(lives())
rp_lifeword = rich_presence_lookup("LIFEWORD", lives(), {1: "Life"}, fallback="Lives")

rp_atk_lvl = rich_presence_number(attack_level())
rp_mag_lvl = rich_presence_number(magic_level())
rp_lif_lvl = rich_presence_number(life_level())

rich_presence_conditional_display(area_id() == 0x00,
	"Blinded by a milk-fueled rage, Mario stomped down the pipe to Hyrule to prove Link wrong and save Princess Zelda"
)

rich_presence_conditional_display(area_id() < 0x06,
	"{0} Mario is exploring {1} · {2} {3} · 🗡️{4} ✨{5} 🛡️{6}",
	rp_powerup, rp_overworld,
	rp_lives, rp_lifeword,
	rp_atk_lvl, rp_mag_lvl, rp_lif_lvl
)

rich_presence_conditional_display(area_id() == 0x06,
	"{0} Mario is visiting the town of {1} · {2} {3} · 🗡️{4} ✨{5} 🛡️{6}",
	rp_powerup, rp_town,
	rp_lives, rp_lifeword,
	rp_atk_lvl, rp_mag_lvl, rp_lif_lvl
)

rich_presence_conditional_display(area_id() == 0x0e,
	"Mario has saved Princess Zelda! · 🗡️{4} ✨{5} 🛡️{6}",
	rp_powerup, "",
	"", "",
	rp_atk_lvl, rp_mag_lvl, rp_lif_lvl
)

rich_presence_display(
	"{0} Mario is fighting through {1} · {2} {3} · 🗡️{4} ✨{5} 🛡️{6}",
	rp_powerup, rp_palace,
	rp_lives, rp_lifeword,
	rp_atk_lvl, rp_mag_lvl, rp_lif_lvl
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Parapa Attacka",
	description="Place the gem in Parapa Palace",
	type="progression",
	points=5,
	trigger=area_id() == 0x08 && room_id() == 0x01 && unset(bit0(0x0680))
)

achievement(
	title="Midoro Master",
	description="Place the gem in Midoro Palace",
	type="progression",
	points=10,
	trigger=area_id() == 0x0a && room_id() == 0x0f && unset(bit0(0x0687))
)

achievement(
	title="Just Like Yoshi's Island",
	description="Place the gem in Island Palace",
	type="progression",
	points=10,
	trigger=area_id() == 0x12 && room_id() == 0x01 && unset(bit0(0x06a0))
)

achievement(
	title="A-Maze-ing Razing",
	description="Place the gem in Maze Island Palace",
	type="progression",
	points=10,
	trigger=area_id() == 0x14 && room_id() == 0x10 && unset(bit4(0x06a8))
)

achievement(
	title="The Palace by the Soda Lake",
	description="Place the gem in the Palace on the Sea",
	type="progression",
	points=10,
	trigger=area_id() == 0x16 && room_id() == 0x24 && unset(bit4(0x0692))
)

achievement(
	title="Three-Eye-jah Rock",
	description="Place the gem in Three-Eye Rock Palace",
	type="progression",
	points=10,
	trigger=area_id() == 0x18 && room_id() == 0x25 && unset(bit0(0x06b2))
)

achievement(
	title="Take-a That, You-a Pointy-Eared Wimp!",
	description="Awaken Princess Zelda and become a real hero... unlike Link",
	type="win_condition",
	points=25,
	trigger=(
		area_id() == 0x0c && room_id() == 0x01 &&
		number_of_journey_rows() > prev(number_of_journey_rows()) &&
		byte(JOURNEY_TABLE + number_of_journey_rows() - 1) == 0x0e
	)
)

achievement(
	title="The Only Horse I Need Is Yoshi",
	description="Defeat Horsehead with Attack level 1",
	type="missable",
	points=5,
	trigger=attack_level() == 1 && defeat_boss(0x08, 0x01, 0x20)
)

achievement(
	title="Don't Lose Your Head",
	description="Defeat Helmethead without knocking his helmet off",
	type="missable",
	points=5,
	trigger=(
		defeat_boss(0x0a, 0x0f, 0x21) && 
		never(any_of(range(0,5), i => enemy_id(i) == 0x22))
	)
)

achievement(
	title="Beating Rebonack Fair and Squire",
	description="Defeat Rebonack in Island Palace without the shield-piercing combat ability",
	type="missable",
	points=10,
	trigger=shield_pierce() == 0 && defeat_boss(0x12, 0x01, 0x0a)
)

achievement(
	title="Through the Fire and Flames - Full Combo",
	description="Defeat Carock without taking damage",
	type="missable",
	points=10,
	trigger=defeat_boss(0x14, 0x10, 0x22) && never(health() < prev(health()))
)

achievement(
	title="No More Hammers, Bro",
	description="Defeat Gooma without throwing hammers",
	type="missable",
	points=5,
	trigger=defeat_boss(0x16, 0x24, 0x21) && never(hammer_count() > prev(hammer_count()))
)

achievement(
	title="Water Beats Fire",
	description="Defeat Barba with the fairy spell active. You must activate the fairy spell before starting the fight",
	type="missable",
	points=1,
	trigger=defeat_boss(0x18, 0x25, 0x21, start=fairy_active() == 1)
)

achievement(
	title="No Items, Mario Only, Final Destination",
	description="Defeat the final boss in the Great Palace without shield and without using magic",
	type="missable",
	points=5,
	trigger=(
		once(start_boss(0x0c, 0x01)) &&
		never(area_id() == 0) &&
		never(health() == 0) && never(lives() < prev(lives())) &&
		never(magic() < prev(magic())) &&
		never(shield_active() == 1) &&
		trigger_when(prev(enemy_hp(0)) > 0 && enemy_hp(0) == 0)
	)
)

achievement(
	title="Full of Mushrooms",
	description="Collect all heart containers",
	points=5,
	trigger=(
		prev(health_containers()) == 7 && 
		measured(health_containers() == 8, when=area_id() != 0x00)
	)
)

achievement(
	title="All-Stars",
	description="Collect all magic containers",
	points=5,
	trigger=(
		prev(magic_containers()) == 7 && 
		measured(magic_containers() == 8, when=area_id() != 0x00)
	)
)

achievement(
	title="Boots of Steel",
	description="Upgrade Mario's Attack level to 8",
	points=10,
	trigger=area_id() != 0x00 && prev(attack_level()) == 7 && attack_level() == 8
)

achievement(
	title="Flower Point Economist",
	description="Upgrade Mario's Magic level to 8",
	points=10,
	trigger=area_id() != 0x00 && prev(magic_level()) == 7 && magic_level() == 8
)

achievement(
	title="A Few Mushrooms in Reserve",
	description="Upgrade Mario's Life level to 8",
	points=10,
	trigger=area_id() != 0x00 && prev(life_level()) == 7 && life_level() == 8
)

achievement(
	title="Jumpman's Classic Outfit",
	description="Learn the Shield spell in Rauru town",
	points=2,
	trigger=area_id() == 0x06 && room_id() == 0x30 && is_set(learned_shield_spell())
)

achievement(
	title="Thank You, Kind Raccoon. Please Tell Me Your Name",
	description="Learn the Tanooki spell in Ruto town",
	points=3,
	trigger=area_id() == 0x06 && room_id() == 0x31 && is_set(learned_tanooki_spell())
)

achievement(
	title="Dr. Mario",
	description="Learn the Life spell in Saria town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x32 && is_set(learned_life_spell())
)

achievement(
	title="Here Comes the Rain Again",
	description="Learn the Fairy spell in Mido town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x33 && is_set(learned_fairy_spell())
)

achievement(
	title="Fire Flower Power",
	description="Learn the Fire spell in Nabooru town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x34 && is_set(learned_fire_spell())
)

achievement(
	title="Mirror, Mirror",
	description="Learn the Reflect spell in Darunia town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x35 && is_set(learned_reflect_spell())
)

achievement(
	title="Mario's Early Years! Learn to Spell",
	description="Learn the Spell spell in new Kasuto town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x2a && is_set(learned_spell_spell())
)

achievement(
	title="Thunderhand",
	description="Learn the Thunder spell in old Kasuto town",
	points=5,
	trigger=area_id() == 0x06 && room_id() == 0x37 && is_set(learned_thunder_spell())
)

achievement(
	title="Ultra Boots",
	description="Learn the ability to pierce shields in Mido town",
	points=2,
	trigger=area_id() == 0x06 && room_id() == 0x2c && is_set(shield_pierce())
)

achievement(
	title="The Strongest Little Plumber in Hyrule",
	description="Learn the ability to throw hammers as small Mario in Darunia town",
	points=2,
	trigger=area_id() == 0x06 && room_id() == 0x2d && is_set(small_hammer())
)

achievement(
	title="They Called Him Jumpman for a Reason",
	description="Enter Death Mountain without talking to Bagu",
	type="missable",
	points=1,
	trigger=talked_to_bagu() == 0 && prev(area_id()) == 0 && area_id() == 1
)

achievement(
	title="Exploring the Pipe Network",
	description="Collect the hammer in Death Mountain before collecting the candle",
	type="missable",
	points=5,
	trigger=have_candle() == 0 && collect_hammer()
)

achievement(
	title="Taking the Secret Exit",
	description="Place the gem in Three-Eye Rock Palace without obtaining the Magical Key",
	type="missable",
	points=10,
	trigger=(
		area_id() == 0x18 && room_id() == 0x25 && 
		have_magical_key() == 0 && unset(bit0(0x06b2))
	)
)

achievement(
	title="Gotta Collect Them All",
	description="In one session, collect three differently colored Mario 1-UP dolls",
	points=5,
	trigger=(
		measured(tally_of(PALETTES, length(PALETTES), 
			p => once(p && collect_any_1up())
		)) &&
		never(area_id() == 0x00)
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------
