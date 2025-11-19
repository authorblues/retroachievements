// Golvellius
// #ID = 3263

// --- HELPERS -------------------------------------------------------------------

function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $1000: Map Type [8 bit]
//        0x00 = Single Screen Room
//        0x01 = Overworld
//        0x1c = Autoscrolling Vertical "Shmup"
//        0x1e = Boss Fight Arena
//        0x28 = Side Scrolling Room
function map_type() => byte(addr_offset() + 0x001000)

// $1001: Player Y Position on Screen [8 bit]
function ypos() => byte(addr_offset() + 0x001001)

// $1002: Player X Position on Screen [8 bit]
function xpos() => byte(addr_offset() + 0x001002)

// $1008: Unknown Player State [8 bit]
//        - almost always 0
//        - on overworld, this goes to 1 when entering a cave
//        - in a side-scrolling cave, this goes to 0x26 when autowalking out
//        - in a vertical scrolling cave, this goes to 0x25 when autowalking out
function player_state() => byte(addr_offset() + 0x001008)

// $100C: Horizontal Speed (Caves) [8 bit]
//        range from -2 to 2
//        auto-walk at end of cave is 1
function hspeed_caves() => byte(addr_offset() + 0x00100C)

// $101A: Invincibility Frames [8 bit]
//        when hit, set to 0x20, counts down to zero -1/f if non-zero
//        without Zest Boots, cannot move until 0 again
//        with Zest Boots, can move when less than or equal to 0x18
function iframes() => byte(addr_offset() + 0x00101A)

// $101E: Sword Drawn [8 bit]
//        0x00 = no sword
//        0x01 = sword attack on overworld
//        0x80 = sword attack in scrolling cave (flanked by timer counter 0xe#)
function sword_state() => byte(addr_offset() + 0x00101E)

// $201D: Items Collected [8 bit]
//        bit0 | Vanish Ring (10000) [screen=125]
//        bit1 | Zest Boots (300) [screen=140]
//        bit2 | Aqua Boots (20000) [screen=64]
function has_vanish_ring() => bit0(addr_offset() + 0x00201D)
function has_zest_boots() => bit1(addr_offset() + 0x00201D)
function has_aqua_boots() => bit2(addr_offset() + 0x00201D)

// $201E: Bosses Killed [8 bit]
//        bit0 | #1 Desva [screen=143]
//        bit1 | #2 Cypa [screen=47]
//        bit2 | #3 Talbur [screen=23]
//        bit3 | #4 Fothbus [screen=112]
//        bit4 | #5 Walso [screen=132]
//        bit5 | #6 Jespa [screen=0]
//        bit6 | #7 Haidee [screen=106]
//        bit7 | Golvellius [screen=115]
BOSSES = addr_offset() + 0x00201E
function boss_killed(i) => bit(i, BOSSES)
BOSS_LOCATIONS = [143, 47, 23, 112, 132, 0, 106, 115]

// $201F: Progressive Shield [8 bit]
//        bit0 | Alzas Shield (5000) [screen=92] or (500) [screen=31]
//        bit1 | Remedia Shield (20000) [screen=133], requires Alzas Shield
SHIELDS = addr_offset() + 0x00201F
function has_alzas_shield() => bit0(SHIELDS)
function has_remedia_shield() => bit1(SHIELDS)

// $2020: Progressive Sword [8 bit]
//        bit1 | Valley Sword (6000) [screen=78] or (3000) [screen=21]
//        bit2 | Legend Sword (30000) [screen=90], requires Valley Sword
SWORDS = addr_offset() + 0x002020
function has_valley_sword() => bit1(SWORDS)
function has_legend_sword() => bit2(SWORDS)

// $2021: Progressive Pendant [8 bit]
//        bit0 | Ramras Pendant (6000) [screen=72]
//        bit1 | Aleste Pendant (20000) [screen=127], removes Ramras
PENDANTS = addr_offset() + 0x002021
function has_ramras_pendant() => bit0(PENDANTS)
function has_aleste_pendant() => bit1(PENDANTS)

// $2022: Power (Health) Max [8 bit]
//        starts at 0x20, each potion adds 0x10
//        max 0xF0 (13 potions)
function health_max() => byte(addr_offset() + 0x002022)

// $203D: Power (Health) [8 bit]
function health() => byte(addr_offset() + 0x00203D)

// $2042: Frames Until Scroll [8 bit]
function cave_ticks() => byte(addr_offset() + 0x002042)

// $2043: Overworld Screen ID [8 bit]
function overworld_screen() => byte(addr_offset() + 0x002043)

// $2048: Is Overworld Cave Opened? [8 bit]
//        0 = no open cave
//        1 = cave is opened
function is_overworld_cave_opened() => byte(addr_offset() + 0x002048)

// $2049: Enemies Killed on Current Screen [8 bit]
function enemies_killed() => byte(addr_offset() + 0x002049)

// $204E: Find (Money) Max [16 bit]
//        multiply by 10 to get displayed value
function find_max() => word(addr_offset() + 0x00204E) * 10

// $2050: Find (Money) [16 bit]
//        multiply by 10 to get displayed value
function find() => word(addr_offset() + 0x002050) * 10

// $205B: Screen Scroll Progress [16 bit]
//        another vert end = 0x300 [screen=86]
//        another hori end = 0x400 [screen=15]
function scroll_progress() => word(addr_offset() + 0x00205B)

// $205F: Crystals [8 bit]
//        bit0 | #1 Desva [screen=116]
//        bit1 | #2 Cypa [screen=58]
//        bit2 | #3 Talbur [screen=33]
//        bit3 | #4 Fothbus [screen=113]
//        bit4 | #5 Walso [screen=120]
//        bit5 | #6 Jespa [screen=24]
//        bit6 | #7 Haidee [screen=96]
CRYSTALS = addr_offset() + 0x00205F
function has_crystal(i) => bit(i, CRYSTALS)

// $2061: Potions Collected [8 bit]
//        bit0 | Potion (500) [screen=128]
//        bit1 | Potion (1200) [screen=118]
//        bit2 | Potion (1500) [screen=27]
//        bit3 | Potion (10000) [screen=3]
//        bit4 | Potion (2500) [screen=35]
//        bit5 | Potion (500) [screen=8]
//        bit6 | Potion (5000) [screen=10]
//        bit7 | Potion (1000) [screen=36]
// $2062: Potions Collected [8 bit]
//        bit0 | Potion (5000) [screen=40]
//        bit1 | Potion (1000) [screen=44]
//        bit2 | Potion (2500) [screen=50]
//        bit3 | Potion (2000) [screen=73]
//        bit4 | Potion (2000) [screen=139]
TOTAL_POTIONS = 13
function potion_count() => bitcount(addr_offset() + 0x002061) + bitcount(addr_offset() + 0x002062)

// $2063: Bibles Collected [8 bit]
//        bit0 | Bible (500) [screen=119]
//        bit1 | Bible (2000) [screen=81]
//        bit2 | Bible (1500) [screen=71]
//        bit3 | Bible (500) [screen=7]
//        bit4 | Bible (2000) [screen=11]
//        bit5 | Bible (10000) [screen=14]
//        bit6 | Bible (4000) [screen=30]
//        bit7 | Bible (3000) [screen=42]
// $2064: Bibles Collected [8 bit]
//        bit0 | Bible (1000) [screen=48]
//        bit1 | Bible (2000) [screen=65]
//        bit2 | Bible (3000) [screen=67]
//        bit3 | Bible (3000) [screen=75]
//        bit4 | Bible (1500) [screen=134]
//        bit5 | Bible (2000) [screen=137]
TOTAL_BIBLES = 14
function bible_count() => bitcount(addr_offset() + 0x002063) + bitcount(addr_offset() + 0x002064)

// $2080: Input Buffer for Title Screen Easter Egg [8 bytes ASCII]
//        all values transition at once to 0x20 on successful input
//        input is [return] + name + [return]
//        
//        easter egg inputs are:
//        KELESIS - default; don't check for this one
//        JEMINI - Takayuki "Jemini" Hirono
//        MOO - Masamitsu "Moo" Niitani
//        WAO - Tadashi "Wao" Ishimaru
//        LUNARIAN - Kenji "Lunarian" Shintani
//        HOMME - Ryuichi "Homme" Okazaki
//        MIYAMOTO - Masatomo Miyamoto
//        JANUS - Koji "Janus" Teramoto
//        YORIKI - unknown
//        PAC - Satoshi "Pac" Fujishima
TITLE_INPUT_BUFFER = addr_offset() + 0x002080

// $20A4: Mea Herbs Count [8 bit]
function herb_count() => byte(addr_offset() + 0x0020A4)

// --- MAIN DATA -------------------------------------------------------------------

BOSS_1_DESVA = 0
BOSS_2_CYPA = 1
BOSS_3_TALBUR = 2
BOSS_4_FOTHBUS = 3
BOSS_5_WALSO = 4
BOSS_6_JESPA = 5
BOSS_7_HAIDEE = 6
BOSS_GOLVELLIUS = 7

MAP_SINGLECAVE = 0
MAP_OVERWORLD = 1
MAP_VERTICAL = 0x1c
MAP_HORIZONTAL = 0x28
MAP_BOSSFIGHT = 0x1e

LOCATION_DESCRIPTIONS = {
	0x1c8f: " · #1 Desva's Cave",
	0x1e8f: " · Fighting Desva",
	0x282f: " · #2 Cypa's Cave",
	0x1e2f: " · Fighting Cypa",
	0x1c17: " · #3 Talbur's Cave",
	0x1e17: " · Fighting Talbur",
	0x2870: " · #4 Fothbus's Cave",
	0x1e70: " · Fighting Fothbus",
	0x1c84: " · #5 Walso's Cave",
	0x1e84: " · Fighting Walso",
	0x2800: " · #6 Jespa's Cave",
	0x1e00: " · Fighting Jespa",
	0x1c6a: " · #7 Haidee's Cave",
	0x1e6a: " · Fighting Haidee",
	0x2873: " · #8 Golvellius's Cave",
	0x1e73: " · Fighting Golvellius",
	0x280f: " · Another Cave (H)",
	0x1c56: " · Another Cave (V)",
	0x0004: " · RNG Cave (1/65535 chance)",
}

TITLE_NAMES = [
	"JEMINI  ",
	"MOO     ",
	"WAO     ",
	"LUNARIAN",
	"HOMME   ",
	"MIYAMOTO",
	"JANUS   ",
	"YORIKI  ",
	"PAC     ",
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function on_title_screen() => (
	byte(0x002354) == 0xF7 &&
	byte(0x002358) == 0x8C &&
	byte(0x00236c) == 0x04 &&
	byte(0x002392) == 0x04 &&
	byte(0x0023a4) == 0x8D &&
	byte(0x0023b8) == 0x04
)

function start_boss(x) => overworld_screen() == BOSS_LOCATIONS[x] && prev(map_type()) != MAP_BOSSFIGHT && map_type() == MAP_BOSSFIGHT
function kill_boss(x) => map_type() == MAP_BOSSFIGHT && overworld_screen() == BOSS_LOCATIONS[x] && boss_killed(x) > prev(boss_killed(x))

function buy_item(locations, flag) => (
	map_type() == MAP_SINGLECAVE &&
	any_of(locations, x => overworld_screen() == x) &&
	find() < prev(find()) && flag > prev(flag)
)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_location_desc = rich_presence_lookup("Desc", map_type() * 0x100 + overworld_screen(), LOCATION_DESCRIPTIONS, fallback="")
rp_herbs = rich_presence_lookup("Herbs", herb_count(), {1: " 🌿", 2: " 🌿🌿", 3: " 🌿🌿🌿"}, fallback="")
rp_sword = rich_presence_lookup("Sword", byte(SWORDS), {2: "Valley ", 6: "Legend "}, fallback="")
rp_shield = rich_presence_lookup("Shield", byte(SHIELDS), {1: " · 🛡️ Alzas Shield", 3: " · 🛡️ Remedia Shield"}, fallback="")

rich_presence_conditional_display(on_title_screen() || bitcount(CRYSTALS) == 8 || find_max() == 0,
	"Title Screen"
)

rich_presence_display(
	"🗺️ x={0},y={1}{2} · 🔮 {3}/7 crystal{4} · ❤️ {5}/{6} power{7} · 🪙 {8}/{9} find · 🗡️ {10}Sword{11} · ⚗️ {12} potion{13} · 📚 {14} bible{15}",
	rich_presence_number(overworld_screen() % 12),
	rich_presence_number(overworld_screen() / 12),
	rp_location_desc,
	rich_presence_number(bitcount(CRYSTALS)), plural(bitcount(CRYSTALS)),
	rich_presence_number(health()),            
	rich_presence_number(health_max()),
	rp_herbs,
	rich_presence_number(find()),
	rich_presence_number(find_max()),
	rp_sword,
	rp_shield,
	rich_presence_number(potion_count()), plural(potion_count()),
	rich_presence_number(bible_count()), plural(bible_count())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Face-Off",
	description="Change Keresis' face on the title screen",
	points=1,
	trigger=(
		on_title_screen() && any_of(TITLE_NAMES, name => (
			ascii_string_equals(TITLE_INPUT_BUFFER, name, transform=a => prev(a))
		)) &&
		ascii_string_equals(TITLE_INPUT_BUFFER, "        ")
	)
)

achievement(
	title="Rock and Rolled",
	description="Defeat Desva",
	type="progression",
	points=5,
	trigger=kill_boss(BOSS_1_DESVA)
)

achievement(
	title="Nothing Personnel, Kid",
	description="Defeat Cypa",
	type="progression",
	points=5,
	trigger=kill_boss(BOSS_2_CYPA)
)

achievement(
	title="Mighty Morphin' Mecha Demon",
	description="Defeat Talbur",
	type="progression",
	points=5,
	trigger=kill_boss(BOSS_3_TALBUR)
)

achievement(
	title="Foam Sweet Foam",
	description="Defeat Fothbus",
	type="progression",
	points=5,
	trigger=kill_boss(BOSS_4_FOTHBUS)
)

achievement(
	title="Horn to Be Wild",
	description="Defeat Walso",
	type="progression",
	points=5,
	trigger=kill_boss(BOSS_5_WALSO)
)

achievement(
	title="Another One Bytes the Dust",
	description="Defeat Jespa",
	type="progression",
	points=10,
	trigger=kill_boss(BOSS_6_JESPA)
)

achievement(
	title="Nice Shootin', Four-Eyes!",
	description="Defeat Haidee",
	type="progression",
	points=10,
	trigger=kill_boss(BOSS_7_HAIDEE)
)

achievement(
	title="Seven Crystal Keys",
	description="Buy 7 crystals to get access to Golvellius's lair",
	type="progression",
	points=10,
	trigger=map_type() == MAP_SINGLECAVE && prev(bitcount(CRYSTALS)) == 6 && measured(bitcount(CRYSTALS) == 7)
)

achievement(
	title="Keresis, Exorcist Extraordinaire",
	description="Defeat Golvellius",
	type="win_condition",
	points=25,
	trigger=kill_boss(BOSS_GOLVELLIUS)
)

achievement(
	title="A Knight in the Valley",
	description="Buy the Valley Sword",
	points=3,
	trigger=buy_item([78, 21], has_valley_sword())
)

achievement(
	title="The Legend of Reena",
	description="Buy the Legend Sword",
	points=5,
	trigger=buy_item([90,], has_legend_sword())
)

achievement(
	title="All That Alzas",
	description="Buy the Alzas Shield",
	points=3,
	trigger=buy_item([92, 31], has_alzas_shield())
)

achievement(
	title="Getting Sent Back to Knight School",
	description="Buy the Remedia Shield",
	points=3,
	trigger=buy_item([133,], has_remedia_shield())
)

achievement(
	title="Strike the Earth",
	description="Buy the Vanish Ring",
	type="progression",
	points=5,
	trigger=buy_item([125,], has_vanish_ring())
)

achievement(
	title="Put Your Zest Foot Forward",
	description="Buy the Zest Boots",
	points=2,
	trigger=buy_item([140,], has_zest_boots())
)

achievement(
	title="Tide and Tested",
	description="Buy the Aqua Boots",
	type="progression",
	points=5,
	trigger=buy_item([64,], has_aqua_boots())
)

achievement(
	title="Glamorous Ramras",
	description="Buy the Ramras Pendant",
	points=3,
	trigger=buy_item([72,], has_ramras_pendant())
)

achievement(
	title="Blessed Aleste",
	description="Buy the Aleste Pendant",
	points=5,
	trigger=buy_item([127,], has_aleste_pendant())
)

achievement(
	title="Brewed for Bravery",
	description="Buy all potions and maximize your power capacity",
	points=10,
	trigger=(
		map_type() == MAP_SINGLECAVE && 
		prev(potion_count()) == TOTAL_POTIONS-1 && 
		measured(potion_count() == TOTAL_POTIONS)
	)
)

achievement(
	title="Pages of Prosperity",
	description="Buy all bibles and maximize your find capacity",
	points=10,
	trigger=(
		map_type() == MAP_SINGLECAVE && 
		prev(bible_count()) == TOTAL_BIBLES-1 && 
		measured(bible_count() == TOTAL_BIBLES)
	)
)

achievement(
	title="Leaf It up to Mea",
	description="Buy and hold three mea herbs at once",
	points=4,
	trigger=(
		map_type() == MAP_SINGLECAVE && 
		prev(herb_count()) == 2 && 
		measured(herb_count() == 3)
	)
)

achievement(
	title="Another Cave",
	description="Complete Another Cave", // horiz
	points=10,
	trigger=(
		overworld_screen() == 15 && is_overworld_cave_opened() == 1 &&
		map_type() == MAP_HORIZONTAL &&
		scroll_progress() == 0 && prior(scroll_progress()) == 0x400 &&
		prev(player_state()) == 0 && player_state() == 0x26
	)
)

achievement(
	title="Yet Another Cave",
	description="Complete yet another Another Cave", // vert
	points=10,
	trigger=(
		overworld_screen() == 86 && is_overworld_cave_opened() == 1 &&
		map_type() == MAP_VERTICAL &&
		scroll_progress() == 0 && prior(scroll_progress()) == 0x300 &&
		prev(player_state()) == 0 && player_state() == 0x25
	)
)

achievement(
	title="And Now a Word from our Sponsors",
	description="Find and enter one of the caves advertising Compile's other games",
	points=2,
	trigger=(
		any_of([109, 53], x => overworld_screen() == x) &&
		is_overworld_cave_opened() == 1 &&
		prev(map_type()) == MAP_OVERWORLD && map_type() == MAP_SINGLECAVE
	)
)

achievement(
	title="Controller? I Hardly Know 'er",
	description="Find and enter one of the caves that can only be opened by using the MSX keyboard",
	points=2,
	trigger=(
		// MSX spacebar and MSX stop rooms
		any_of([25, 136], x => overworld_screen() == x) &&
		is_overworld_cave_opened() == 1 &&
		prev(map_type()) == MAP_OVERWORLD && map_type() == MAP_SINGLECAVE
	)
)

achievement(
	title="Brother, They Don't Even Let *Me* Test the Sound",
	description="Find and enter the secret sound test",
	points=2,
	trigger=(
		overworld_screen() == 142 && is_overworld_cave_opened() == 1 &&
		prev(map_type()) == MAP_OVERWORLD && map_type() == MAP_SINGLECAVE
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Riskiest Knight",
	description="Beat the game with the fewest potions collected. You probably don't need them *all*, right?",

	start=kill_boss(BOSS_GOLVELLIUS),
	cancel=always_false(),
	submit=always_true(),

	value=measured(potion_count()),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="RNG Gods",
	description="Give praise to these RNG gods who have been blessed to reveal the hidden RNG room and enter it. It only appears with a 1/65535 chance!",

	start=(
		overworld_screen() == 5 && is_overworld_cave_opened() == 1 &&
		prev(map_type()) == MAP_OVERWORLD && map_type() == MAP_SINGLECAVE
	),
	cancel=always_false(),
	submit=always_true(),

	value=measured(1),
	format="VALUE",
	lower_is_better=false
)