// Star Wars Trilogy: Apprentice of the Force
// #ID = 5577

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => dword(x)
function rich_presence_number(x) => rich_presence_value("_Number", x, "VALUE")

function zfill(num, c)
{
	result = format("{0}", num)
	for i in range(0, 10)
	{
		if (length(result) >= c) return result
		result = format("0{0}", result)
	}
	return result
}

function commas(x)
{
	function comma_join(list)
	{
		res = ""
		for i in range(0, length(list)-1)
		{
			if (i == length(list) - 1)
				res = format("{0}", list[i]) + res
			else res = "," + zfill(list[i], 3) + res
		}
		return res
	}

	parts = []
	for i in range(1, 10)
	{
		if (x == 0) return comma_join(parts)
		array_push(parts, x % 1000)
		x = x / 1000
	}
}

// --- MEMORY -------------------------------------------------------------------

// $1258: Language [8 bit] {USA}
//        0 = English
//        1 = French
//        2 = Spanish
//        3 = German
//        4 = Italian
//        5 = Dutch
function language() => byte(0x001258)

// $7741: Various Flags [8 bit]
//        bit0 | rancor health bar shown
//        bit4 | weapon, 1 = lightsaber, 0 = blaster
function is_lightsaber() => bit4(0x007741) == 1
function rancor_fight() => bit0(0x007741)

// $7742: Return State [8 bit]
//        0x00 = not in game
//        0x40 = Story Mode
//        0x80 = Replay Mode
function return_state() => byte(0x007742)

// $7790: File Loaded [8 bit]
//        0 = out of game
//        1 = in game
//        
//        doesn't transition back to 0 if you win a mission on replay mode
function file_loaded() => byte(0x007790)

// $7791: Save File Name [ASCII Text] (3 bytes)
SAVE_NAME = 0x007791

// $77A5: Current Force Power [8 bit]
function force_power() => byte(0x0077A5)

// $77A6: Mission ID [8 bit]
//        
//        Episode IV: A New Hope
//        0x00 = Meet Uncle Owen in the Front of the Farm
//        0x01 = Locate R2-D2
//        0x02 = Meet Obi-Wan at the Cantina
//        0x03 = Sell the Land Speeder
//        0x04 = Meet Obi-Wan and Han Solo
//        0x05 = Find R2-D2 and Reach the Control Room
//        0x06 = Escort Leia to the Millenium Falcon
//        0x07 = Destroy the TIE Fighters (0x00)
//        0x07 = Destroy the Main Reactor (0x01)
//        
//        Episode V: The Empire Strikes Back
//        0x08 = Escape from the Cavern
//        0x09 = Locate your X-wing
//        0x0a = Escape the Battleground
//        0x0b = Find Yoda
//        0x0c = Learn to Use the Force
//        0x0d = Learn to Use the Force
//        0x0e = Locate Han, Leia, and the Others
//        0x0f = Fight Darth Vader
//        
//        Episode VI: The Return of the Jedi
//        0x10 = Find Han Solo
//        0x11 = Find a Way to Destroy the Rancor
//        0x12 = Destroy the Main Barge
//        0x13 = Stop the Scout Troopers
//        0x14 = Locate Han, Leia, and the Others
//        0x15 = Meet Darth Vader
//        0x16 = Fight Darth Vader
//        
//        0x18 = Arena
//        0x64 = Ending
function mission_id() => byte(0x0077A6)

// $77A7: Room/Section ID [8 bit]
//        
//        Fight Darth Vader (0x0f):
//        0x00 = Phase 1 (100 -> 40)
//        0x01 = Waves of Stormtroopers and Droids
//        0x02 = Phase 2 [throwing debris]
//        0x03 = Phase 3 [central reactor shaft] (50 -> 10)
//        
//        Fight Darth Vader (0x16):
//        0x00 = Fight Scene (brief transition to mission = 0x64 for cutscene)
//        0x01 = Ending and Credits
//        
//        Arena (0x18):
//        0x00 = First (-> 56)
//        0x01 = Second (-> 126)
//        0x02 = Third (-> 216)
function room_id() => byte(0x0077A7)

// $77A8: Items [8 bit bitfield]
//        bit2 = red keycard (tatooine)
function has_keycard() => bit2(0x0077A8)

// $77DC: Arena Counter [16 bit]
//        counter maxes at 9999
function arena_counter() => word(0x0077DC)

// $77E0: Tie Fighters Remaining [8 bit]
function tie_fighters_remaining() => byte(0x0077E0)

// $77E1: R2-D2 Health (mission = 0x07) [Lower4]
function r2d2_ship_health() => low4(0x0077E1)

// $77E5: Secondary Weapon Ammo [8 bit]
function blaster_ammo() => byte(0x0077E5)

// $77E6: Mixed [8 bit]
//        
//        R2-D2 Health (mission = 0x02, 0x0e) [bit4 + bit5]
//        Blaster Weapon Type [Lower4]
//        0 = Red (default)
//        1 = Blue (fast)
//        2 = Pink
//        3 = Green (strong)
function r2d2_npc_health() => bit5(0x0077E6) * 2 + bit4(0x0077E6)
function blaster_type() => low4(0x0077E6)

// $77E8: Mixed [8 bit]
//        
//        Leia Health [Lower4]
function leia_health() => low4(0x0077E8)

// $77E9: Max Health [8 bit]
//        increases the bar size
//        starts game at 30, largest bar is 94
//        when out of game, this value is 0
//        safe to use to detect in-game
function max_health() => byte(0x0077E9)

// $77EA: Current Health [8 bit]
function current_health() => byte(0x0077EA)

// $77EB: Current Boss Health [8 bit]
//        controls boss health display, 0 = don't show
function boss_health() => byte(0x0077EB)

// $77F9: Save File Slot [8 bit] (0-indexed)
function save_slot() => byte(0x0077F9)

// $7C60: Paused [8 bit]
function paused() => byte(0x007C60)

// --- MAIN DATA -------------------------------------------------------------------

LANG_EN = 0
LANG_FR = 1
LANG_ES = 2
LANG_DE = 3
LANG_IT = 4
LANG_NL = 5

LANG_FLAGS = {
	LANG_EN: "🇬🇧 🇺🇸",
	LANG_FR: "🇫🇷",
	LANG_ES: "🇪🇸",
	LANG_DE: "🇩🇪",
	LANG_IT: "🇮🇹",
	LANG_NL: "🇳🇱",
}

MAX_FORCE_POWER = 0x0f

MISSION_NAMES = {
//	Episode IV: A New Hope
	0x00: "Meet Uncle Owen in the Front of the Farm",
	0x01: "Locate R2-D2",
	0x02: "Meet Obi-Wan at the Cantina",
	0x03: "Sell the Land Speeder",
	0x04: "Meet Obi-Wan and Han Solo",
	0x05: "Find R2-D2 and Reach the Control Room",
	0x06: "Escort Leia to the Millenium Falcon",
	0x07: "Destroy the TIE Fighters & the Main Reactor",

//	Episode V: The Empire Strikes Back
	0x08: "Escape from the Cavern",
	0x09: "Locate your X-wing",
	0x0a: "Escape the Battleground",
	0x0b: "Find Yoda",
	0x0c: "Learn to Use the Force",
	0x0d: "Learn to Use the Force",
	0x0e: "Locate Han, Leia, and the Others",
	0x0f: "Fight Darth Vader",

//	Episode VI: The Return of the Jedi
	0x10: "Find Han Solo",
	0x11: "Find a Way to Destroy the Rancor",
	0x12: "Destroy the Main Barge",
	0x13: "Stop the Scout Troopers",
	0x14: "Locate Han, Leia, and the Others",
	0x15: "Meet Darth Vader",
	0x16: "Fight Darth Vader",

	0x18: "Arena",
	0x64: "Ending",
}

FILM = {
	0x00: "Episode IV: A New Hope",
	0x01: "Episode IV: A New Hope",
	0x02: "Episode IV: A New Hope",
	0x03: "Episode IV: A New Hope",
	0x04: "Episode IV: A New Hope",
	0x05: "Episode IV: A New Hope",
	0x06: "Episode IV: A New Hope",
	0x07: "Episode IV: A New Hope",

	0x08: "Episode V: The Empire Strikes Back",
	0x09: "Episode V: The Empire Strikes Back",
	0x0a: "Episode V: The Empire Strikes Back",
	0x0b: "Episode V: The Empire Strikes Back",
	0x0c: "Episode V: The Empire Strikes Back",
	0x0d: "Episode V: The Empire Strikes Back",
	0x0e: "Episode V: The Empire Strikes Back",
	0x0f: "Episode V: The Empire Strikes Back",

	0x10: "Episode VI: The Return of the Jedi",
	0x11: "Episode VI: The Return of the Jedi",
	0x12: "Episode VI: The Return of the Jedi",
	0x13: "Episode VI: The Return of the Jedi",
	0x14: "Episode VI: The Return of the Jedi",
	0x15: "Episode VI: The Return of the Jedi",
	0x16: "Episode VI: The Return of the Jedi",
}

BLASTER_COLORS = {
	0x00: "🟥",
	0x01: "🟦",
	0x02: "🟪",
	0x03: "🟩",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => file_loaded() == 1 && max_health() > 0

function has_r2d2_npc() => (
	any_of([0x02, 0x0e], x => mission_id() == x) ||
	(mission_id() == 0x05 && room_id() >= 0x07)
)

function get_mission_name(m, r)
{
	if (m == 0x07)
	{
		if (r == 0x00) return "Destroy the TIE Fighters"
		else return "Destroy the Main Reactor"
	}
	return MISSION_NAMES[m]
}

function mission_desc(m, r=0) => format("Complete \"{0}\" in {1}", get_mission_name(m, r), FILM[m])

function mission_achievement(title, points, mission, room=0)
{
	achievement(
		title=title,
		description=mission_desc(mission, room),
		type="progression",
		points=points,
		trigger=in_game() && prev(mission_id()) == mission && any_of([mission+1, 0x64], x => mission_id() == x)
	)
}

function collected_health_upgrade() => max_health() == prev(max_health()) + 5

function health_upgrade_achievement(title, mission, room, points=2)
{
	achievement(
		title=title,
		description=format("Collect the health upgrade in \"{0}\" in {1}", get_mission_name(mission, room), FILM[mission]),
		type="missable",
		points=points,
		trigger=prev(max_health()) > 0 && mission_id() == mission && room_id() == room && collected_health_upgrade()
	)
}

// --- RICH PRESENCE -------------------------------------------------------------------

rp_movie = rich_presence_lookup("Film", mission_id(), FILM, fallback="Star Wars Trilogy")
rp_mission = rich_presence_lookup("Mission", mission_id(), MISSION_NAMES, fallback=MISSION_NAMES[0x00])

rp_health_perc = rich_presence_number(100 * current_health() / max_health())
rp_ship_health_perc = rich_presence_number(current_health())
rp_force_perc = rich_presence_number(100 * force_power() / 15)

rp_r2d2_npc_health = rich_presence_number(r2d2_npc_health())
rp_r2d2_ship_health = rich_presence_number(r2d2_ship_health())
rp_leia_health = rich_presence_number(leia_health())

rp_blaster_type = rich_presence_lookup("BlasterColor", blaster_type(), BLASTER_COLORS, fallback=BLASTER_COLORS[0x00])
rp_blaster_ammo = rich_presence_number(blaster_ammo())

rp_boss_health = rich_presence_number(boss_health())
rp_arena_kills = rich_presence_number(arena_counter())
rp_tie_fighters_remaining = rich_presence_number(tie_fighters_remaining())

// --- all language intros
rich_presence_conditional_display(!in_game() && language() == LANG_EN,
	"🇬🇧 🇺🇸 A long time ago in a galaxy far, far away..."
)
rich_presence_conditional_display(!in_game() && language() == LANG_FR,
	"🇫🇷 Il y a bien longtemps, dans une galaxie lointaine, très lointaine..."
)
rich_presence_conditional_display(!in_game() && language() == LANG_ES,
	"🇪🇸 Hace mucho tiempo, en una galaxia muy, muy lejana..."
)
rich_presence_conditional_display(!in_game() && language() == LANG_DE,
	"🇩🇪 Es war einmal vor langer Zeit in einer weit, weit entfernten Galaxis..."
)
rich_presence_conditional_display(!in_game() && language() == LANG_IT,
	"🤌 🇮🇹 Tanto tempo fa, in una galassia lontana lontana..."
)
rich_presence_conditional_display(!in_game() && language() == LANG_NL,
	// "🌷 🇳🇱 Lang, lang geleden, in een galaxie ver, ver vandaan.."
	"🌷 🇳🇱 Lang geleden in een sterrenstelsel heel ver weg..."
)

// --- mission 0x0e (has force power too)
rich_presence_conditional_display(mission_id() == 0x0e && !is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {5}] • ✨ {3}% • weapon: 🔫{4}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type,
	rp_r2d2_npc_health
)

rich_presence_conditional_display(mission_id() == 0x0e && !is_lightsaber(),
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {6}] • ✨ {3}% • weapon: 🔫{4} ({5})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type, rp_blaster_ammo,
	rp_r2d2_npc_health
)

rich_presence_conditional_display(mission_id() == 0x0e,
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {4}] • ✨ {3}% • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_r2d2_npc_health
)

// --- escorting r2d2
rich_presence_conditional_display(has_r2d2_npc() && !is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {4}] • weapon: 🔫{3}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type,
	rp_r2d2_npc_health
)

rich_presence_conditional_display(has_r2d2_npc() && !is_lightsaber(),
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {5}] • weapon: 🔫{3} ({4})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type, rp_blaster_ammo,
	rp_r2d2_npc_health
)

rich_presence_conditional_display(has_r2d2_npc(),
	"📽️ {0} • 📋 {1} • ❤️ {2}% [🤖 {3}] • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_r2d2_npc_health
)

// --- mission 0x06 (leia escort)
rich_presence_conditional_display(mission_id() == 0x06 && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • ❤️ {2}% [👸 {4}] • weapon: 🔫{3}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type,
	rp_leia_health
)

rich_presence_conditional_display(mission_id() == 0x06,
	"📽️ {0} • 📋 {1} • ❤️ {2}% [👸 {5}] • weapon: 🔫{3} ({4})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type, rp_blaster_ammo,
	rp_leia_health
)

// --- mission 0x07 (spaceship)
rich_presence_conditional_display(mission_id() == 0x07 && room_id() == 0x00,
	"📽️ {0} • 📋 Destroy the TIE Fighters • 🚀 {1}% [🤖 {2}] • {3} TIE fighters remaining",
	rp_movie,
	rp_ship_health_perc,
	rp_r2d2_ship_health,
	rp_tie_fighters_remaining
)

rich_presence_conditional_display(mission_id() == 0x07 && room_id() == 0x01,
	"📽️ {0} • 📋 Destroy the Main Reactor • 🚀 {1}% [🤖 {2}]",
	rp_movie,
	rp_ship_health_perc,
	rp_r2d2_ship_health
)

// --- mission 0x13
rich_presence_conditional_display(mission_id() == 0x13,
	"📽️ {0} • 📋 {1} • ❤️ {2}%",
	rp_movie, rp_mission,
	rp_health_perc
)

// --- ending/credits
rich_presence_conditional_display(in_game() && (mission_id() == 0x64 || (mission_id() == 0x16 && room_id() > 0)),
	"📽️ Credits • Written and Directed by George Lucas"
)

// --- arena
rich_presence_conditional_display(mission_id() == 0x18 && !is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} (☠️ {4} kill{5}) • ❤️ {2}% • weapon: 🔫{3}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type,
	rp_arena_kills, plural(arena_counter())
)

rich_presence_conditional_display(mission_id() == 0x18 && !is_lightsaber(),
	"📽️ {0} • 📋 {1} (☠️ {5} kill{6}) • ❤️ {2}% • weapon: 🔫{3} ({4})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type, rp_blaster_ammo,
	rp_arena_kills, plural(arena_counter())
)

rich_presence_conditional_display(mission_id() == 0x18,
	"📽️ {0} • 📋 {1} (☠️ {3} kill{4}) • ❤️ {2}% • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_arena_kills, plural(arena_counter())
)

// --- boss health is visible
rich_presence_conditional_display(boss_health() > 0 && !is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • 😈 {5}% • ❤️ {2}% • ✨ {3}% • weapon: 🔫{4}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type,
	rp_boss_health
)

rich_presence_conditional_display(boss_health() > 0 && !is_lightsaber(),
	"📽️ {0} • 📋 {1} • 😈 {6}% • ❤️ {2}% • ✨ {3}% • weapon: 🔫{4} ({5})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type, rp_blaster_ammo,
	rp_boss_health
)

rich_presence_conditional_display(boss_health() > 0,
	"📽️ {0} • 📋 {1} • 😈 {4}% • ❤️ {2}% • ✨ {3}% • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_boss_health
)

// --- normal stage with force power
rich_presence_conditional_display(mission_id() > 0x0b && !is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • ❤️ {2}% • ✨ {3}% • weapon: 🔫{4}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type
)

rich_presence_conditional_display(mission_id() > 0x0b && !is_lightsaber(),
	"📽️ {0} • 📋 {1} • ❤️ {2}% • ✨ {3}% • weapon: 🔫{4} ({5})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc,
	rp_blaster_type, rp_blaster_ammo
)

rich_presence_conditional_display(mission_id() > 0x0b,
	"📽️ {0} • 📋 {1} • ❤️ {2}% • ✨ {3}% • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_force_perc
)

// --- normal stage without force power
rich_presence_conditional_display(!is_lightsaber() && blaster_ammo() == 0,
	"📽️ {0} • 📋 {1} • ❤️ {2}% • weapon: 🔫{3}",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type
)

rich_presence_conditional_display(!is_lightsaber(),
	"📽️ {0} • 📋 {1} • ❤️ {2}% • weapon: 🔫{3} ({4})",
	rp_movie, rp_mission,
	rp_health_perc,
	rp_blaster_type, rp_blaster_ammo
)

rich_presence_display(
	"📽️ {0} • 📋 {1} • ❤️ {2}% • weapon: 🗡️",
	rp_movie, rp_mission,
	rp_health_perc
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// Episode IV: A New Hope
mission_achievement(
	title="\"It Looks Like I'm Going Nowhere\"",
	points=2,
	mission=0x00
)

mission_achievement(
	title="\"A Half-Sized Thermocapsulary Dehousing Assister\"",
	points=3,
	mission=0x01
)

mission_achievement(
	title="\"Just a Crazy Old Wizard\"",
	points=5,
	mission=0x02
)

health_upgrade_achievement(
	title="\"He Has Too Much of His Father in Him\"",
	mission=0x03, room=0x00
)

mission_achievement(
	title="\"Since the XP-38 Came Out, They're Just Not in Demand\"",
	points=5,
	mission=0x03
)

mission_achievement(
	title="\"She's Got It Where It Counts, Kid\"",
	points=5,
	mission=0x04
)

health_upgrade_achievement(
	title="\"Where Did You Dig Up That Old Fossil?\"",
	mission=0x05, room=0x01
)

mission_achievement(
	title="\"Prisoner Transfer from Block 1138\"",
	points=5,
	mission=0x05
)

mission_achievement(
	title="\"Maybe You'd Like It Back in Your Cell, Your Highness\"",
	points=5,
	mission=0x06
)

achievement(
	title="\"That Little Droid and I Have Been Through a Lot Together\"",
	description=mission_desc(0x07, 0x00) + " with full ship health and full R2-D2 health",
	points=5,
	trigger=(
		// in-game, correct stage
		in_game() && mission_id() == 0x07 && room_id() == 0 &&
		// health is max (maybe allow some grace here?)
		current_health() == 100 && r2d2_ship_health() == 3 &&
		// allow a bit of wiggle room on the outside chance that more than one tie fighter is killed on the same frame
		trigger_when(prev(tie_fighters_remaining()) <= 3 && prev(tie_fighters_remaining()) > 0 && tie_fighters_remaining() == 0)
	)
)

achievement(
	title="\"Just Like Beggar's Canyon Back Home\"",
	description=mission_desc(0x07, 0x01),
	type="progression",
	points=10,
	// trigger=current_health() > 0 && prev(mission_id()) == 0x07 && prev(room_id()) == 0x01 && any_of([0x08, 0x64], x => mission_id() == x)
	trigger=prev(mission_id()) == 0x07 && prev(room_id()) == 0x01 && any_of([0x08, 0x64], x => mission_id() == x)
)

// Episode V: The Empire Strikes Back
health_upgrade_achievement(
	title="\"Isn't Enough Life on This Ice Cube to Fill a Space Cruiser\"",
	mission=0x08, room=0x01
)

mission_achievement(
	title="\"I Thought They Smelled Bad on the Outside!\"",
	points=5,
	mission=0x08
)

mission_achievement(
	title="\"It's a Good Bet the Empire Knows We're Here\"",
	points=5,
	mission=0x09
)

health_upgrade_achievement(
	title="\"There's Nothing Wrong, Artoo. I'm Just Setting a New Course\"",
	mission=0x0a, room=0x01
)

mission_achievement(
	title="\"We're Not Going to Regroup With the Others\"",
	points=5,
	mission=0x0a
)

mission_achievement(
	title="\"We're Going to the Dagobah System\"",
	points=5,
	mission=0x0b
)

mission_achievement(
	title="\"Much Anger in Him, Like His Father\"",
	points=5,
	mission=0x0d
)

mission_achievement(
	title="\"They're My Friends. I've Got to Help Them\"",
	points=5,
	mission=0x0e
)

health_upgrade_achievement(
	title="\"You Have Only Begun to Discover Your Power\"",
	mission=0x0f, room=0x01
)

mission_achievement(
	title="\"He Told Me Enough! It Was You Who Killed Him\"",
	points=10,
	mission=0x0f
)

// Episode VI: The Return of the Jedi
health_upgrade_achievement(
	title="\"I Warn You Not to Underestimate My Powers\"",
	mission=0x10, room=0x01
)

mission_achievement(
	title="\"You Stuck Up, Half-Witted, Scruffy-Looking, Nerf-Herder!\"",
	points=5,
	mission=0x10
)

RANCOR_CHALLENGE_SECONDS = 45
achievement(
	title="\"They Will All Suffer for This Outrage\"",
	description=mission_desc(0x11) + format(" in less than {0} seconds", RANCOR_CHALLENGE_SECONDS),
	points=5,
	trigger=(
		disable_when(tally(60 * RANCOR_CHALLENGE_SECONDS,
			paused() == 0 &&
			(
				never(!in_game()) &&
				never(mission_id() != 0x11) && 
				never(rancor_fight() == 0) &&
				never(current_health() == 0) &&
				never(prev(boss_health()) == 0)
			)
		)) && 
		in_game() && mission_id() == 0x11 && current_health() > 0 &&
		trigger_when(prev(boss_health()) > 0 && boss_health() == 0)
	)
)

mission_achievement(
	title="\"There Will Be No Bargain, Young Jedi\"",
	points=5,
	mission=0x11
)

health_upgrade_achievement(
	title="\"You Should Have Bargained, Jabba\"",
	mission=0x12, room=0x02
)

achievement(
	title="\"This Bounty Hunter is My Kind of Scum. Fearless and Inventive\"",
	description=mission_desc(0x12) + " without chasing off Boba Fett",
	type="missable",
	points=5,
	trigger=(
		// 0x1203 is the end of the stage
		in_game() && mission_id() == 0x12 && room_id() == 0x03 &&
		// if the previous room was 0x02 and boba fett was still alive
		prev(room_id()) == 0x02 && prev(boss_health()) > 0
	)
)

mission_achievement(
	title="\"Let's Get Off This Miserable Dust Ball\"",
	points=5,
	mission=0x12
)

achievement(
	title="\"This Whole Party'll Be For Nothing If They See Us\"",
	description=mission_desc(0x13),
	type="progression",
	points=5,
	trigger=current_health() > 0 && prev(mission_id()) == 0x13 && any_of([0x14, 0x64], x => mission_id() == x)
)

health_upgrade_achievement(
	title="\"It's Against My Programming to Impersonate a Deity\"",
	mission=0x14, room=0x00
)

mission_achievement(
	title="\"As Long as I Stay, I'm Endangering the Group\"",
	points=5,
	mission=0x14
)

mission_achievement(
	title="\"You Don't Know the Power of the Dark Side\"",
	points=5,
	mission=0x15
)

achievement(
	title="\"Obi-Wan Has Taught You Well\"",
	description=mission_desc(0x16),
	type="win_condition",
	points=25,
	trigger=in_game() && prev(mission_id()) == 0x16 && mission_id() == 0x64
)

achievement(
	title="\"Your Hate Has Made You Powerful\"",
	description="Clear the third room of the secret Arena stage",
	points=10,
	trigger=(
		once(in_game() && mission_id() == 0x18 && prev(room_id()) == 1 && room_id() == 2) &&
		prev(room_id()) == 2 && room_id() == 0 &&
		never(!in_game()) &&
		never(mission_id() != 0x18) &&
		never(current_health() == 0) &&
		never(arena_counter() == 0)
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Fastest Rancor Kill",
	description="Kill the Rancor as quickly as possible",

	start=(
		in_game() && mission_id() == 0x11 && 
		rancor_fight() == 1 && boss_health() > 0 &&
		(prev(rancor_fight()) == 0 || prev(boss_health()) == 0)
	),
	cancel=!in_game() || mission_id() != 0x11 || current_health() == 0 || rancor_fight() == 0,
	submit=boss_health() == 0,

	value=measured(tally(0, paused() == 0)),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Arena - Most Kills",
	description="Kill as many enemies in the secret Arena stage as possible. Counter maxes out at 9999",

	start=in_game() && mission_id() == 0x18 && prev(current_health()) > 0 && current_health() == 0,
	cancel=always_false(),
	submit=always_true(),

	value=measured(arena_counter()),
	format="VALUE",
	lower_is_better=false
)