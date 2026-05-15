// Excitebike: World Rally
// #ID = 34663

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

// $003180: [4 bytes] [ASCII] WiiWare Game ID
//          "WWRE" = North America (NA/US)
//          "WWRJ" = Japan (JP)
//          "WWRP" = Europe (EU)
function game_id() => dword(0x003180)

// $4955A0: Game State [32-bit BE]
//          0 = Menu
//          1 = Loading
//          2 = Playing
function game_state() => dword_be(0x4955A0)

// $54E090: Race Ended when 0xFFFFFFFF [32-bit BE]
// function is_race_ended() => dword_be(0x54E090) == 0xFFFFFFFF

// $56A6B8: Current File Medals [32 bytes]
//          index is cup*8 + track
//          
//          0x00 = S
//          0x01 = A
//          0x02 = B
//          0x03 = C
//          0x04 = D
//          0x05 = none
CURRENT_FILE_MEDAL_BLOCK = 0x56A6B8

// $5772C4: Current Cup [32-bit BE]
//          0 = Bronze
//          1 = Silver
//          2 = Gold
//          3 = Platinum
function current_cup() => dword_be(0x5772C4)

// $5772C8: Current Course [32-bit BE]
//          0-0 = Training
//          0-1 = Kyoto
//          0-2 = Canada
//          0-3 = Mexico
//          0-4 = London
//          1-0 = Fiji
//          1-1 = Mexico
//          1-2 = Madrid
//          1-3 = Canada
//          2-0 = Paris
//          2-1 = Fiji
//          2-2 = Mexico
//          2-3 = China
//          3-0 = Canada
//          3-1 = China
//          3-2 = Fiji
//          3-3 = New York
function current_course() => dword_be(0x5772C8)

// $5BE714: Training Progress [32-bit BE]
//          6 = All Complete
//          only updates in the Training menu
function training_progress() => dword_be(0x5BE714)

// $5BF058: Loaded Profile [32-bit BE]
//          -1 = no profile loaded
//          0-3 are the four profile slots
//          
//          changes when selecting file on "Select a Profile"
//          or after entering name when creating a new file
function loaded_profile() => dword_be(0x5BF058)

// $5C03C4: Pointer to Time Info [32-bit BE]
//          +0x1C = Current Race Timer [Float BE]
function raw_track_time() => float_be(ptr(0x5C03C4) + 0x1C)

// $B9A080: Profile Blocks [64 bytes x 4 profiles]
//          +0x09 = Profile Name [8 bytes ASCII]
//          +0x2C = Controller Type [32-bit BE] (0 = normal, 1 = classic)
function profile_blocks() => byte(0xB9A080)

// $C6B5C4: File Info [5120 Bytes]
//          each file is 1280 bytes x 4 files
//          4 bytes per track
//          
//          +1 = has played [8 bit]
//          +2 = medal (0 = S, 4 = D, 5 = none) [8 bit]
//          +3 = completed [8 bit]
ALL_FILE_DATA = 0xC6B5C4

function bike_ptr() => 0x00551880 + dword_be(ptr_chain(0x005C5680-0x67CC, [0x0024,]))*4
function temp_gauge() => float_be(ptr(bike_ptr()) + 0x0784)

// top lane is 0.0, bottom lane is 3.0
function current_lane() => float_be(ptr(0x575F4C) + 0x0048)

RACE_STATUS = ptr_chain(0x005C0450, [0x04, 0x14]) + 3
function is_race_started() => bit0(RACE_STATUS)
function is_race_ended() => bit1(RACE_STATUS)

// TODO: find time out timer to determine cause of race ending

// --- MAIN DATA -------------------------------------------------------------------

STATE_MENUS = 0
STATE_LOADING = 1
STATE_PLAYING = 2

MEDAL_S = 0
MEDAL_A = 1
MEDAL_B = 2
MEDAL_C = 3
MEDAL_D = 4
MEDAL_NONE = 5

CUPS = {0: "Bronze", 1: "Silver", 2: "Gold", 3: "Platinum"}

TRACKS = {
	00: "Training",
	01: "Kyoto",
	02: "Canada",
	03: "Mexico",
	04: "London",
	10: "Fiji",
	11: "Mexico",
	12: "Madrid",
	13: "Canada",
	20: "Paris",
	21: "Fiji",
	22: "Mexico",
	23: "China",
	30: "Canada",
	31: "China",
	32: "Fiji",
	33: "New York",
}

GAME_TITLES = {
	"WWRE": "Excitebike: World Rally",
	"WWRJ": "Excitebike: World Race",
	"WWRP": "Excitebike: World Challenge",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function get_medal(cup, course) => byte(ALL_FILE_DATA + loaded_profile()*1280 + 4*(1 + cup*4 + course))

function track() => current_cup()*10 + current_course()

function track_time() => raw_track_time() - 1.0/60

function crossed_finish_line() => is_set(is_race_ended()) && raw_track_time() < 5*60 + 30 // 5:30 seems to be the cutoff for timeout on all tracks, afaik

function get_course_index(cup, course) => if_else(cup == 0, course, 1 + cup*4 + course)
function get_course_offset(file, cup, course) => ALL_FILE_DATA + 1280*file + 4*get_course_index(cup, course)

function get_course_played(file, cup, course) => byte(get_course_offset(file, cup, course) + 1)
function get_course_medal(file, cup, course) => byte(get_course_offset(file, cup, course) + 2)
function get_course_completed(file, cup, course) => byte(get_course_offset(file, cup, course) + 3)

function rank_stage(cup, course, rank) => (
	loaded_profile() != 0xffffffff &&
	game_state() == 0 && 
	prev(current_cup()) == cup &&
	prev(current_course()) == course &&
	prev(get_course_medal(loaded_profile(), cup, course)) > rank &&
	current_cup() == 0xffffffff &&
	current_course() == 0xffffffff &&
	get_course_medal(loaded_profile(), cup, course) <= rank
)

function complete_cup(cup, courses) => (
	loaded_profile() != 0xffffffff &&
	game_state() == 0 && 
	prev(current_cup()) == cup &&
	prev(current_course()) != 0xffffffff &&
	current_cup() == 0xffffffff &&
	current_course() == 0xffffffff &&
	sum_of(courses, i => prev(get_course_completed(loaded_profile(), cup, i))) == 3 &&
	sum_of(courses, i => get_course_completed(loaded_profile(), cup, i)) == 4
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(loaded_profile() == -1,
	"Title Screen"
)

rich_presence_conditional_display(game_state() != STATE_PLAYING,
	"🏁 Getting Ready to Race"
)

rich_presence_conditional_display(is_race_ended() == 1,
	"🏁 Race Ended · 🏆 {0} Cup · 🗺️ {1} · ⏱️ {2}",
	rich_presence_lookup("Cup", current_cup(), CUPS, fallback=CUPS[0]),
	rich_presence_lookup("Course", track(), TRACKS, fallback="???"),
	rich_presence_value("_T", measured(track_time()*100) && unless(is_race_ended() == 1), "MILLISECS")
)

rich_presence_conditional_display(is_race_started() == 1,
	"🏁 Racing · 🏆 {0} Cup · 🗺️ {1} · ⏱️ {2}",
	rich_presence_lookup("Cup", current_cup(), CUPS, fallback=CUPS[0]),
	rich_presence_lookup("Course", track(), TRACKS, fallback="???"),
	rich_presence_value("_T", track_time()*100, "MILLISECS")
)

rich_presence_conditional_display(game_state() == STATE_PLAYING,
	"🏁 Race Starting · 🏆 {0} Cup · 🗺️ {1}",
	rich_presence_lookup("Cup", current_cup(), CUPS, fallback=CUPS[0]),
	rich_presence_lookup("Course", track(), TRACKS, fallback="???")
)

rich_presence_display(
	"Playing {0}",
	rich_presence_ascii_string_lookup("Title", game_id(), GAME_TITLES, fallback=GAME_TITLES["WWRE"])
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// progression achievements
achievement(
	title="Road Warrior",
	description="Complete all courses in the Bronze cup with a B rank or higher to unlock the Silver cup",
	type="progression",
	points=5,
	trigger=complete_cup(0, range(1,4))
)

achievement(
	title="Cosmopolitan",
	description="Complete all courses in the Silver cup with a B rank or higher to unlock the Gold cup",
	type="progression",
	points=5,
	trigger=complete_cup(1, range(0,3))
)

achievement(
	title="World Traveller",
	description="Complete all courses in the Gold cup with a B rank or higher to unlock the Platinum cup",
	type="progression",
	points=10,
	trigger=complete_cup(2, range(0,3))
)

achievement(
	title="Globetrotter",
	description="Complete all courses in the Platinum cup with a B rank or higher",
	type="win_condition",
	points=25,
	trigger=complete_cup(3, range(0,3))
)

// builds an achievement for achieving an s-rank
function s_rank_achievement(cup, course, points, title)
{
	achievement(
		title=title,
		description=format("Earn an S rank on the {0} course in the {1} cup", TRACKS[cup*10 + course], CUPS[cup]),
		points=points,
		trigger=rank_stage(cup, course, MEDAL_S)
	)
}

// bronze cup
s_rank_achievement(cup=0, course=1, points=3, title="Turning Japanese")
s_rank_achievement(cup=0, course=2, points=3, title="Toonies and Loonies")
s_rank_achievement(cup=0, course=3, points=3, title="Ándale")
s_rank_achievement(cup=0, course=4, points=3, title="Absolute Legend, Innit?")

// silver cup
s_rank_achievement(cup=1, course=0, points=3, title="Sun and Sand Dunes")
s_rank_achievement(cup=1, course=1, points=3, title="Chichén Itzá")
s_rank_achievement(cup=1, course=2, points=3, title="A Tour of Iberia")
s_rank_achievement(cup=1, course=3, points=3, title="Goin' Out for a Rip")

// gold cup
s_rank_achievement(cup=2, course=0, points=4, title="Le Petit Galop")
s_rank_achievement(cup=2, course=1, points=4, title="Making Waves")
s_rank_achievement(cup=2, course=2, points=4, title="Que Milagro")
s_rank_achievement(cup=2, course=3, points=4, title="Over the Great Wall")

// platinum cup
s_rank_achievement(cup=3, course=0, points=5, title="Look Out for Moose")
s_rank_achievement(cup=3, course=1, points=5, title="Jiayou")
s_rank_achievement(cup=3, course=2, points=5, title="Castles in the Sand")
s_rank_achievement(cup=3, course=3, points=5, title="The Big Apple")

achievement(
	title="Clean Racing",
	description="Complete any track in the Platinum cup without crashing or overheating",
	points=3,
	trigger=(
		once(game_state() == STATE_PLAYING && is_set(is_race_started())) &&
		trigger_when(crossed_finish_line()) &&
		// only trigger on Platinum cup
		never(current_cup() != 3) &&
		// just to catch it earlier. this will still move the player out of
		// their lane
		never(temp_gauge() >= 1.0) &&
		// this catches generic crashes. player is moved out of lane
		never(current_lane() < 0.0) &&
		never(current_lane() > 3.0) &&
		// clear if not playing
		never(game_state() != STATE_PLAYING) &&
		// or if the race is ended without triggering the achievement
		never(prev(is_race_ended()) == 1)
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

for cup in range(0,3)
	for _course in range(0,3)
	{
		course = _course
		if (cup == 0) course = _course + 1

		leaderboard(
			title=format("{0} ({1} Cup) Speedrun", TRACKS[cup*10+course], CUPS[cup]),
			description=format("Fastest time on {0} in the {1} cup", TRACKS[cup*10+course], CUPS[cup]),
		
			start=loaded_profile() != 0xffffffff && current_cup() == cup && current_course() == course && crossed_finish_line(),
			cancel=always_false(),
			submit=always_true(),
		
			value=measured(track_time()*100),
			format="MILLISECS",
			lower_is_better=true
		)
	}