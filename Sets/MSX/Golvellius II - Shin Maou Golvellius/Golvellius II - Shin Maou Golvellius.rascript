// Golvellius II - Shin Maou Golvellius
// #ID = 16404

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

function rich_presence_condition_table(lookupname, list)
{ // highest priority needs to be listed first in the pairs list
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

// --- MEMORY -------------------------------------------------------------------

// $0001: Map Type [8 bit]
//        0 = Talking Cave/Paused
//        1 = Overworld
//        2 = Side Platformer
//        4 = Talk Bubble/Box
//        5 = Boss Arena
function map_type() => byte(0x000001)

// $0002: Current Zone Width [8 bit]
// $0003: Current Zone Height [8 bit]
function current_zone_width() => byte(0x000002)
function current_zone_height() => byte(0x000003)

// $0004: Overworld Screen ID [8 bit] row-major
function overworld_screen() => byte(0x000004)

// $0020: Player X Position [8 bit]
// $0021: Player Y Position [8 bit]
function player_x_position() => byte(0x000020)
function player_y_position() => byte(0x000021)

// $0045: Text Reveal in Progress [8 bit] (0/1)
function text_reveal() => byte(0x000045)

// $0058: Dialogue ID [8 bit]
//        screen=10,0x07 - 3->4 indicates stabbing Reena 3x
function dialogue_id() => byte(0x000058)

// $006F: Number of Enemies Killed in Current Room [8 bit]
function enemies_killed() => byte(0x00006F)

// $0B01: Item - Basic Sword [8 bit] (0/1)
//        screen=0,0x12 -- loc_check(0, 0x12)
function has_basic_sword() => byte(0x000B01)

// $0B02: Item - Valley Sword [8 bit] (0/1)
//        screen=3,0x1d -- loc_check(3, 0x1d)
function has_valley_sword() => byte(0x000B02)

// $0B03: Item - Legend Sword [8 bit] (0/1)
//        screen=8,0x11 -- loc_check(8, 0x11)
function has_legend_sword() => byte(0x000B03)

// $0B04: Item - Aqua Boots [8 bit] (0/1)
//        screen=4,0x28 -- loc_check(4, 0x28)
function has_aqua_boots() => byte(0x000B04)

// $0B05: Item - Ascent Boots [8 bit] (0/1)
//        screen=8,0x1f -- loc_check(8, 0x1f)
function has_ascent_boots() => byte(0x000B05)

// $0B06: Item - Winkle Rod [8 bit] (0/1)
//        screen=0,0x1c -- loc_check(0, 0x1c)
function has_winkle_rod() => byte(0x000B06)

// $0B07: Item - Alzas Shield [8 bit] (0/1)
//        screen=3,0x11 -- loc_check(3, 0x11)
function has_alzas_shield() => byte(0x000B07)

// $0B08: Item - Remedia Shield [8 bit] (0/1)
//        screen=7,0x20 -- loc_check(7, 0x20)
function has_remedia_shield() => byte(0x000B08)

// $0B09: Item - Brave Ring [8 bit] (0/1)
//        screen=???
function has_brave_ring() => byte(0x000B09)

// $0B0A: Item - Holy Harp [8 bit] (0/1)
//        screen=6,0x16 -- loc_check(6, 0x16)
function has_holy_harp() => byte(0x000B0A)

// $0B0B: Item - Ramras Pendant [8 bit] (0/1)
//        screen=6,0x1b -- loc_check(6, 0x1b)
function has_ramras_pendant() => byte(0x000B0B)

// $0B0C: Item - Light Candle [8 bit] (0/1)
//        screen=7,0x09 -- loc_check(7, 0x09)
function has_light_candle() => byte(0x000B0C)

// $0B0D: Item - Magic Mirror [8 bit] (0/1)
//        screen=5,0x2b -- loc_check(5, 0x2b)
function has_magic_mirror() => byte(0x000B0D)

// $0B0E: Item - Vanish Ring [8 bit] (0/1)
//        screen=5,0x09 -- loc_check(5, 0x09)
function has_vanish_ring() => byte(0x000B0E)

// $0B0F: Item - Pure Water [8 bit] (0/1)
//        screen=5,0x2c -- loc_check(5, 0x2c)
function has_pure_water() => byte(0x000B0F)

// $0B10: Item - Polished Diamond [8 bit] (0/1)
//        screen=6,???
//        given away at 9,0x1f
function has_polished_diamond() => byte(0x000B10)

// $0B11: Item - Raw Diamond [8 bit] (0/1)
//        screen=8,0x20 -- loc_check(8, 0x20)
function has_raw_diamond() => byte(0x000B11)

// $0B12: Item - Fruit [8 bit] (0/1)
//        screen=5,0x13 -- loc_check(5, 0x13)
function has_fruit() => byte(0x000B12)

// $0B13: Item - Fairy Child [8 bit] (0/1)
//        screen=7,0x2c -- loc_check(7, 0x2c)
function has_fairy_child() => byte(0x000B13)

// $0B14: Item - Shell Necklace [8 bit] (0/1)
//        screen=4,0x26 -- loc_check(4, 0x26)
function has_shell_necklace() => byte(0x000B14)

// $0B15: Item - Miria's Bracelet [8 bit] (0/1)
//        screen=0,0x1b -- loc_check(0, 0x1b)
//        screen=3,0x18 -- loc_check(3, 0x18)
function has_mirias_bracelet() => byte(0x000B15)

// $0B16: Item - Letter for Jim [8 bit] (0/1)
//        screen=0,0x1a -- loc_check(0, 0x1a)
function has_letter_for_jim() => byte(0x000B16)

// $0B17: Item - Key to House in the Woods [8 bit] (0/1)
//        screen=0,0x1a -- loc_check(0, 0x1a)
function has_key_to_house_in_the_woods() => byte(0x000B17)

// $0B18: Item - Mea [8 bit] (0/1)
//        screen=0,0x08 -- loc_check(0, 0x08)
function has_mea_herb() => byte(0x000B18)

// $0B1A: Crystal Count [8 bit] (max=7)
function crystal_count() => byte(0x000B1A)

// $0B1B: Event Flag - Shell Necklace Delivered [8 bit] (0/1)
//        screen=4,0x10 -- loc_check(4, 0x10)
function event_delivered_shell_necklace() => byte(0x000B1B)

// $0B1C: Event Flag - Sluice Opened [8 bit] (0/1)
//        screen=4,0x2e -- loc_check(4, 0x2e)
function event_opened_sluice() => byte(0x000B1C)

// $0B1D: Event Flag - Delivered Fruit to Karon [8 bit] (0/1)
//        screen=5,0x26 -- loc_check(5, 0x26)
function event_delivered_fruit() => byte(0x000B1D)

// $0B1F: Event Flag - Delivered Fairy Child [8 bit] (0/1)
//        screen=7,0x34 -- loc_check(7, 0x34)
function event_delivered_fairy_child() => byte(0x000B1F)

// $0B20: Event Flag - Gave Away Light Candle [8 bit] (0/1)
//        screen=8,0x20 -- loc_check(8, 0x20)
function event_delivered_light_candle() => byte(0x000B20)

// $0B21: Event Flag - Got Diamond from Stoth [8 bit] (0/1)
//        screen=8,0x20 -- loc_check(8, 0x20)
function event_got_diamond() => byte(0x000B21)

// $0B24: Potion - Despa's Dell #1 [8 bit] (0/1)
// $0B25: Potion - Growth's Wood #2 [8 bit] (0/1)
// $0B26: Potion - Growth's Wood #1 [8 bit] (0/1)
// $0B27: Potion - Skell's Graveyard #1 [8 bit] (0/1)
// $0B28: Potion - Dusa's Pond #2 [8 bit] (0/1)
// $0B29: Potion - Dusa's Pond #1 [8 bit] (0/1)
// $0B2A: Potion - Phinx' Rocks #1 [8 bit] (0/1)
// $0B2B: Potion - Phinx' Rocks #3 [8 bit] (0/1)
// $0B2C: Potion - Phinx' Rocks #2 [8 bit] (0/1)
// $0B2D: Potion - Lychi's Forest #1 [8 bit] (0/1)
// $0B2E: Potion - Lychi's Limestone Cave #1 [8 bit] (0/1)
// $0B2F: Potion - Doran's Forest #2 [8 bit] (0/1)
// $0B30: Potion - Doran's Forest #1 [8 bit] (0/1)
// $0B31: Potion - Doran's Cavern #2 [8 bit] (0/1)
// $0B32: Potion - Doran's Cavern #1 [8 bit] (0/1)
// $0B33: Potion - Doran's Cavern #2 [8 bit] (0/1)
TOTAL_POTIONS = 16
function has_potion(i) => byte(0x000B24 + i)
function potion_count() => sum_of(range(0, TOTAL_POTIONS-1), i => has_potion(i))

// $0B34: Bible - Despa's Dell #1 [8 bit] (0/1)
// $0B35: Bible - Growth's Wood #2 [8 bit] (0/1)
// $0B36: Bible - Growth's Wood #3 [8 bit] (0/1)
// $0B37: Bible - Growth's Wood #1 [8 bit] (0/1)
// $0B38: Bible - Skell's Graveyard #1 [8 bit] (0/1)
// $0B39: Bible - Skell's Graveyard #2 [8 bit] (0/1)
// $0B3A: Bible - Dusa's Pond #3 [8 bit] (0/1)
// $0B3B: Bible - Dusa's Pond #1 [8 bit] (0/1)
// $0B3C: Bible - Dusa's Pond #2 [8 bit] (0/1)
// $0B3D: Bible - Phinx' Rocks #4 [8 bit] (0/1)
// $0B3E: Bible - Phinx' Rocks #1 [8 bit] (0/1)
// $0B3F: Bible - Phinx' Rocks #3 [8 bit] (0/1)
// $0B40: Bible - Phinx' Rocks #2 [8 bit] (0/1)
// $0B41: Bible - Lychi's Forest #2 [8 bit] (0/1)
// $0B42: Bible - Lychi's Forest #1 [8 bit] (0/1)
// $0B43: Bible - Lychi's Limestone Cave #2 [8 bit] (0/1)
// $0B44: Bible - Lychi's Limestone Cave #1 [8 bit] (0/1)
// $0B45: Bible - Lychi's Limestone Cave #3 [8 bit] (0/1)
// $0B46: Bible - Doran's Forest #1 [8 bit] (0/1)
// $0B47: Bible - Doran's Cavern #1 [8 bit] (0/1)
TOTAL_BIBLES = 20
function has_bible(i) => byte(0x000B34 + i)

// $0B80: Current Zone [8 bit]
//        0 = Castle Town
//        1 = Despa's Dell
//        2 = Growth's Wood
//        3 = Skell's Graveyard
//        4 = Dusa's Pond
//        5 = Phinx' Rocks
//        6 = Lychi's Forest
//        7 = Lychi's Limestone Cave
//        8 = Doran's Forest
//        9 = Doran's Cavern
//        10 = Golvellius's Valley
function current_zone() => byte(0x000B80)

// $0B9D: Health Max [16 bit BCD]
//        max=0x210 - all potions collected
function health_max() => bcd(word(0x000B9D))

// $0BA1: Health [16 bit BCD]
function health() => bcd(word(0x000BA1))

// $0BA5: Find Max [24 bit BCD]
//        max=0x100000 - all bibles collected
function find_max() => bcd(tbyte(0x000BA5))

// $0BAB: Find [24 bit BCD]
function find() => bcd(tbyte(0x000BAB))

// $0BB1: Boss 1 Flags - Despa [8 bit]
//        bit0 | boss dead (0/1)
// $0BB2: Boss 2 Flags - Growth [8 bit]
//        bit0 | boss dead (0/1)
//        bit7 | entrance to boss accessible
// $0BB3: Boss 3 Flags - Skell [8 bit]
//        bit0 | boss dead (0/1)
//        bit1 | entered the boss fight
//        bit7 | entrance to boss accessible
// $0BB4: Boss 4 Flags - Dusa [8 bit]
//        bit0 | boss dead (0/1)
//        bit7 | entrance to boss accessible
// $0BB5: Boss 5 Flags - Phinx [8 bit]
//        bit0 | boss dead (0/1)
//        bit7 | entrance to boss accessible
// $0BB6: Boss 6 Flags - Lychi [8 bit]
//        bit0 | boss dead (0/1)
// $0BB7: Boss 7 Flags - Doran [8 bit]
//        bit0 | boss dead (0/1)
// $0BB8: Boss Flags - Golvellius [8 bit]
//        bit0 | boss dead (0/1)
function boss_dead(i) => bit0(0x000BB1 + i)

// $0BBA: Mea Bottles [8 bit] (max=3)
function mea_bottles() => byte(0x000BBA)

// $0BBB: Number of Bibles [8 bit]
//        subtract 1 to get actual collected number
function bible_count() => byte(0x000BBB)

// $0BC4: Event Flag - Killed Plant Monster Guarding Doran's Cavern [8 bit] (0/1)
//        screen=8,0x20 -- loc_check(8, 0x20)
function event_plant_monster_dead() => byte(0x000BC4)

// $0BC6: Event Flags - Laser Statues Destroyed in Golvellius' Valley [8 bit]
//        each bit corresponds to a different statue
function event_guardian_statues_destroyed() => byte(0x000BC6)

// $0BC9: Event Flag - Entrance to Golvellius' Valley Opened [8 bit] (0/1)
//        screen=9,0x25 -- loc_check(9, 0x25)
function event_gvalley_open() => byte(0x000BC9)

// $0C17: Facing Direction [8 bit]
//        0x00 = Right
//        0x04 = Down
//        0x08 = Left
//        0x0c = Up
function facing_direction() => byte(0x000C17)

// --- MAIN DATA -------------------------------------------------------------------

BOSS_1_DESPA = 0
BOSS_2_GROWTH = 1
BOSS_3_SKELL = 2
BOSS_4_DUSA = 3
BOSS_5_PHINX = 4
BOSS_6_LYCHI = 5
BOSS_7_DORAN = 6
BOSS_GOLVELLIUS = 7

MAP_TALKING = 0
MAP_OVERWORLD = 1
MAP_PLATFORMER = 2
MAP_BUBBLE = 4
MAP_BOSSFIGHT = 5

ZONES = {
	0: "Castle Town",
	1: "Despa's Dell",
	2: "Growth's Wood",
	3: "Skell's Graveyard",
	4: "Dusa's Pond",
	5: "Phinx' Rocks",
	6: "Lychi's Forest",
	7: "Lychi's Cave",
	8: "Doran's Forest",
	9: "Doran's Cavern",
	10: "Golvellius's Valley",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// set to zero in the title screen, obviously any in-game map would have to be wider than 0
function in_game() => current_zone_width() != 0 && current_zone_width() != 0xFF

// check zone and screen
function loc_check(zone, screen) => in_game() && current_zone() == zone && overworld_screen() == screen

// --- RICH PRESENCE -------------------------------------------------------------------

rp_herbs = rich_presence_lookup("Herbs", mea_bottles(), {1: " 🌿", 2: " 🌿🌿", 3: " 🌿🌿🌿"}, fallback="")
rp_sword = rich_presence_condition_table("Sword", [
	[has_legend_sword() == 1, " · 🗡️ Legend Sword"],
	[has_valley_sword() == 1, " · 🗡️ Valley Sword"],
	[has_basic_sword() == 1, " · 🗡️ Basic Sword"],
	[always_true(), ""],
])
rp_shield = rich_presence_condition_table("Shield", [
	[has_remedia_shield() == 1, " · 🛡️ Remedia Shield"],
	[has_alzas_shield() == 1, " · 🛡️ Alzas Shield"],
	[always_true(), ""],
])

rich_presence_conditional_display(in_game(),
	"🗺️ {0} · 🔮 {1}/7 crystal{2} · ❤️ {3}/{4} power{5} · 🪙 {6}/{7} find{8}{9}",
	rich_presence_lookup("Zone", current_zone(), ZONES, fallback=ZONES[0]),
	rich_presence_number(crystal_count()), plural(crystal_count()),
	rich_presence_number(health()),
	rich_presence_number(health_max()),
	rp_herbs,
	rich_presence_number(find()),
	rich_presence_number(find_max()),
	rp_sword,
	rp_shield
)

rich_presence_display(
	"[Title Screen] Shin Maou Golvellius | © Compile 1988"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="You Can Count on Mea",
	description="Bring Mea herbs to the castle to help the king",
	type="progression",
	points=3,
	trigger=(
		current_zone() == 0 && overworld_screen() == 0x16 && 
		prev(bible_count()) == 0 && bible_count() == 1
	)
)

achievement(
	title="A Real Cunning Linguist",
	description="Raise your max FIND by purchasing a bible from Obaba",
	points=2,
	trigger=map_type() == MAP_TALKING && any_of(range(0,TOTAL_BIBLES-1), i => has_bible(i) > prev(has_bible(i)))
)

achievement(
	title="Thanks, Obaba",
	description="Raise your max health by purchasing a potion from Obaba",
	points=3,
	trigger=map_type() == MAP_TALKING && any_of(range(0,TOTAL_POTIONS-1), i => has_potion(i) > prev(has_potion(i)))
)

achievement(
	title="Despa-ration",
	description="Defeat Despa",
	type="progression",
	points=5,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_1_DESPA))
)

achievement(
	title="Whispy's Gritty Reboot",
	description="Defeat Growth",
	type="progression",
	points=5,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_2_GROWTH))
)

achievement(
	title="The Arm Bone's Connected to the Leg Bone",
	description="Defeat Skell",
	type="progression",
	points=10,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_3_SKELL))
)

achievement(
	title="I Was Too Distracted to Come Up With a Better Achievement Title",
	description="Defeat Dusa",
	type="progression",
	points=10,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_4_DUSA))
)

achievement(
	title="A Bird-Brained Strategy",
	description="Defeat Phinx",
	type="progression",
	points=10,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_5_PHINX))
)

achievement(
	title="Don't Lose Your Head",
	description="Defeat Lychi",
	type="progression",
	points=10,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_6_LYCHI))
)

achievement(
	title="Mantrap Peepwood",
	description="Defeat the Mantrap Plant guarding Doran's Cavern",
	type="progression",
	points=2,
	trigger=map_type() == MAP_OVERWORLD && loc_check(8, 0x0b) && is_set(event_plant_monster_dead())
)

achievement(
	title="Binexx",
	description="Defeat Doran",
	type="progression",
	points=10,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_7_DORAN))
)

achievement(
	title="Our New Best Friend",
	description="Defeat Golvellius and rescue Princess Reena",
	type="win_condition",
	points=25,
	trigger=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_GOLVELLIUS))
)

achievement(
	title="John's Last Will and Testament",
	description="Find the Valley Sword",
	points=3,
	trigger=loc_check(3, 0x1d) && is_set(has_valley_sword())
)

achievement(
	title="A Gift from the Gods",
	description="Find the Legend Sword",
	points=5,
	trigger=loc_check(8, 0x11) && is_set(has_legend_sword())
)

achievement(
	title="Call Me Jesus the Way I'm Walkin' on Water",
	description="Find the Aqua Boots",
	points=3,
	trigger=loc_check(4, 0x28) && is_set(has_aqua_boots())
)

achievement(
	title="Like a Jetpack for Your Feet",
	description="Find the Ascent Boots",
	points=5,
	trigger=loc_check(8, 0x1f) && is_set(has_ascent_boots())
)

achievement(
	title="Blocking for Dummies",
	description="Find the Alzas Shield",
	points=3,
	trigger=loc_check(3, 0x11) && is_set(has_alzas_shield())
)

achievement(
	title="Trading In for a Newer Model",
	description="Find the Remedia Shield",
	points=5,
	trigger=loc_check(7, 0x20) && is_set(has_remedia_shield())
)

achievement(
	title="My Gardener Has One Just Like It",
	description="Find the Vanish Ring",
	points=5,
	trigger=loc_check(5, 0x09) && is_set(has_vanish_ring())
)

achievement(
	title="For Sale: Ramras Pendant, Never Worn",
	description="Find the Ramras Pendant",
	points=5,
	trigger=loc_check(6, 0x1b) && is_set(has_ramras_pendant())
)

achievement(
	title="Who's the Fairest of Them All?",
	description="Find the Magic Mirror",
	points=5,
	trigger=loc_check(5, 0x2b) && is_set(has_magic_mirror())
)

BRAVE_RING_WOMEN_LOCATIONS = [
	loc_check(6, 0x24), // harp is hidden
	loc_check(9, 0x0d), // bring crystal to knight
	loc_check(9, 0x19), // look into my crystal
	loc_check(7, 0x31), // golvellius' minions were fake!
]

achievement(
	title="Let My Haters Be My Motivators",
	description="Find and speak to the four wise women who only recognize the mark of a hero, the Brave Ring",
	points=5,
	trigger=(
		measured(tally_of(BRAVE_RING_WOMEN_LOCATIONS, length(BRAVE_RING_WOMEN_LOCATIONS), p => (
			once(p && prev(map_type()) == MAP_OVERWORLD && map_type() == MAP_TALKING && has_brave_ring() == 1)
		))) &&
		never(!in_game())
	)
)

achievement(
	title="Buying Potions by the Case",
	description="Buy all 16 potions and maximize Keresis' health capacity",
	points=10,
	trigger=map_type() == MAP_TALKING && prev(potion_count()) == TOTAL_POTIONS-1 && measured(potion_count() == TOTAL_POTIONS)
)

achievement(
	title="Luckily, I Brought My Smart Sword",
	description="Don't be fooled by Golvellius's devious trick",
	points=1,
	trigger=loc_check(10, 0x07) && prev(dialogue_id()) == 3 && dialogue_id() == 4
)

/*
achievement(
	title="I Just Don't Like the Taste",
	description="Defeat Golvellius without having ever purchased a potion to raise your max health",
	type="missable",
	points=50,
	trigger=(
		in_game() && all_of(range(0, TOTAL_POTIONS-1), i => has_potion(i) == 0) &&
		// trigger_when(map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_GOLVELLIUS))) 
		trigger_when(map_type() == MAP_OVERWORLD && prev(current_zone()) == 9 && current_zone() == 10)
	)
)
*/

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Riskiest Knight",
	description="Beat the game with the fewest potions collected.",

	start=map_type() == MAP_BOSSFIGHT && is_set(boss_dead(BOSS_GOLVELLIUS)),
	cancel=always_false(),
	submit=always_true(),

	value=measured(potion_count()),
	format="VALUE",
	lower_is_better=true
)
