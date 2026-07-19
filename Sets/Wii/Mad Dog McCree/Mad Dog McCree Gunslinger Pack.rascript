// Mad Dog McCree: Gunslinger Pack
// #ID = 35261

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function ptr(x) => dword_be(x) & 0x1fffffff

// --- MEMORY -------------------------------------------------------------------

// $003180: Game ID [4 Bytes ASCII]
//          RQ5E = Mad Dog McCree Gunslinger Pack (USA)
function game_id() => dword(0x003180)

// $32E948: Loaded Scene [ASCII Text, null-terminated]
//          
//          prefixes:
//          "Common/" = Menus
//          "MD/" = Mad Dog McCree
//          "MD2/" = Mad Dog II: the Lost Gold
//          "LBH/" = The Last Bounty Hunter
//          
//          Mad Dog 1 uses "Common/MenuGrid" for selecting stage, which is the same as the title screen. Otherwise, useful address.
//          
//          Game selection screen:
//          "Common/DLLogo.bik" = Digital Leisure Logo
//          "Common/MDLogo.bik" = MDM Logo
//          "Common/MDTrailer.bik" = MDM Trailer
//          "Common/MD2Trailer.bik" = MD2 Trailer
//          "Common/LBHTrailer.bik" = LBH Trailer
SCENE_FILENAME = 0x32E948

// $331CC0: Wiimote 1 Connected [32 bit BE]
//          0 = Connected
//          -1 = Disconnected (0xffffffff)
function wiimote_connected(x) => dword_be(0x331CC0 + x*4) + 1

// $331F18: P1 Score [32 bit BE]
function score(x) => dword_be(0x331F18 + x*4)

// $3ADD7A: Game Mode [16 bit BE]
//          0 = Single Player
//          1 = Posse (Cooperative)
//          2 = Rebel (Competitive)
function game_mode() => word_be(0x3ADD7A)

// $3ADD82: Difficulty [16 bit BE]
//          1 = Deputy
//          2 = Sheriff
//          3 = US Marshal
function difficulty() => word_be(0x3ADD82)

// $3AE3B9: Game Loaded [8 bit]
//          0 = Mad Dog McCree
//          1 = Mad Dog II: the Lost Gold
//          2 = The Last Bounty Hunter
//          
//          Title screen seems to use whatever game corresponds to the trailer, which is weird.
function game_loaded() => byte(0x3AE3B9)

// $3AE434: Current Bonus [16 bit BE]
function current_bonus() => word_be(0x3AE434)

// $3AE45A: Showing "Game Paused" [16 bit BE]
//          0 = Not Shown
//          1 = Shown
function showing_game_paused() => word_be(0x3AE45A)

// $3AE4D0: Pointer to Video Information [32 bit BE pointer]
//          +0x08: Scene ID [32 bit BE] (values noted at 0x0000)
//          +0x10: Video Frames [32 bit BE]
//          +0xEE: Is Paused? [16 bit BE] (0/1)
VIDEO_PTR = 0x3AE4D0
function video_pointer() => dword_be(VIDEO_PTR)
function scene_id() => dword_be(ptr(VIDEO_PTR) + 0x08)
function scene_frames() => dword_be(ptr(VIDEO_PTR) + 0x10)
function video_paused() => word_be(ptr(VIDEO_PTR) + 0xEE)

// $3AE546: LBH Handsome Harry Status [16 bit BE]
//          0 = Alive
//          1 = Dead
//          2 = Captured
//          3 = (captured transition?)
//          4 = (dead transition?)
function lbh_handsome_harry_status() => word_be(0x3AE546)

// $3AE548: LBH Nasty Dan Status [16 bit BE]
//          0 = Alive
//          1 = Dead
//          2 = Captured
function lbh_nasty_dan_status() => word_be(0x3AE548)

// $3AE54A: LBH El Loco Status [16 bit BE]
//          0 = Alive
//          1 = Dead
//          2 = Captured
function lbh_el_loco_status() => word_be(0x3AE54A)

// $3AE54C: LBH Cactus Kid Status [16 bit BE]
//          0 = Alive
//          1 = Dead
//          2 = Captured
function lbh_cactus_kid_status() => word_be(0x3AE54C)

// $3AE6DA: MD2 Route [16 bit BE]
//          0 = No route chosen
//          1 = Shooting Beaver
//          2 = Buckskin Bonnie
//          3 = The Professor
function md2_route() => word_be(0x3AE6DA)

// $3AE764: MD1 Corral Progress [32 bit BE]
function md1_corral_progress() => dword_be(0x3AE764)

// $3AE768: MD1 Corral Complete [32 bit BE] (0/1)
//          set when video pointer for scene 0x064f deloads
function md1_corral_complete() => dword_be(0x3AE768)

// $3AE76C: MD1 Sheriff's Office Progress [32 bit BE]
function md1_sheriffs_office_progress() => dword_be(0x3AE76C)

// $3AE770: MD1 Sheriff's Office Complete [32 bit BE] (0/1)
//          set when video pointer for scene 0x07a6 deloads
function md1_sheriffs_office_complete() => dword_be(0x3AE770)

// $3AE774: MD1 Bank Progress [32 bit BE]
function md1_bank_progress() => dword_be(0x3AE774)

// $3AE778: MD1 Bank Complete [32 bit BE] (0/1)
//          set when video pointer for scene 0x0495 deloads
function md1_bank_complete() => dword_be(0x3AE778)

// $3AE77C: MD1 Saloon Progress [32 bit BE]
function md1_saloon_progress() => dword_be(0x3AE77C)

// $3AE780: MD1 Saloon Complete [32 bit BE] (0/1)
//          set when video pointer for scene 0x0bde deloads
function md1_saloon_complete() => dword_be(0x3AE780)

// $3AE788: MD1 Bartender Dead? [32 bit BE] (0/1)
//          set to 1 at 1786f of 0x0bde
//          
//          this is the last frame before action is locked out
//          do not use this for an achievement!
function md1_bartender_dead() => dword_be(0x3AE788)

// $3AE880: P1 Reticule Y coords [16 bit BE]
function p1_reticule_y_coords() => word_be(0x3AE880)

// $3AE888: P1 Reticule X coords [16 bit BE]
function p1_reticule_x_coords() => word_be(0x3AE888)

// $3AE898: P1 Bullets [16 bit BE]
function bullets(x) => word_be(0x3AE898 + x*2)

// $3AE8A0: P1 Lives [16 bit BE]
function lives(x) => word_be(0x3AE8A0 + x*2)

// --- MAIN DATA -------------------------------------------------------------------

DIFFICULTY = {
	1: "Deputy",
	2: "Sheriff",
	3: "US Marshal",
}

GAME_MD1 = 0
GAME_MD2 = 1
GAME_LBH = 2

GAMES = {
	GAME_MD1: "Mad Dog McCree",
	GAME_MD2: "Mad Dog II: The Lost Gold",
	GAME_LBH: "The Last Bounty Hunter",
}

MODE_SINGLE = 0
MODE_POSSE = 1
MODE_REBEL = 2

GAMEMODES = {
	MODE_SINGLE: "Single Player",
	MODE_POSSE: "Posse",
	MODE_REBEL: "Rebel",
}

MD2GUIDES = {
	1: " (guided by Shooting Beaver)",
	2: " (guided by Buckskin Bonnie)",
	3: " (guided by The Professor)",
}

LBHOUTLAW = {
	0: "🤠",
	1: "☠️",
	2: "⭐",
	3: "⭐",
	4: "☠️",
}

TRAILER_IDS = [
	0x015b, // Publisher Credits
	0x0179, // Mad Dog McCree Logo
	0x066a, // Mad Dog McCree Trailer
	0x0bb4, // Mad Dog II Trailer
	0x0e01, // Last Bounty Hunter Trailer
]

TRAILER_FILENAMES = [
	"Common/DLLogo.bik",
	"Common/MDLogo.bik",
	"Common/MDTrailer.bik",
	"Common/MD2Trailer.bik",
	"Common/LBHTrailer.bik",
]

MD1_SHOWDOWNS = [
	{"scene": 0x00ff, "f": 147, },
	{"scene": 0x010e, "f": 153, },
]

MD1_BONUS_TARGETS = [
	{"scene": 0x0bde, "flag": 0x3398C4, }, // Skull
	{"scene": 0x07a6, "flag": 0x3398C8, }, // Skull
	{"scene": 0x07a6, "flag": 0x3398CC, }, // Skull
	{"scene": 0x05c2, "flag": 0x3398D0, }, // Skull
	{"scene": 0x0355, "flag": 0x3398D4, }, // Skull
	{"scene": 0x064f, "flag": 0x3398E0, }, // Skull
	{"scene": 0x0495, "flag": 0x3398E4, }, // spitoon
	{"scene": 0x03b7, "flag": 0x3398E8, }, // Spitoon
]

MD2_SHOWDOWNS = [
	{"scene": 0x0093, "f": 72, },
]

MD2_BONUS_TARGETS = [
	{"scene": 0x0ec9, "flag": 0x3398C0, }, // Skull
	{"scene": 0x0f81, "flag": 0x3398C4, }, // Skull
	{"scene": 0x151b, "flag": 0x3398C8, }, // Skull
	{"scene": 0x021c, "flag": 0x3398CC, }, // Skull
	{"scene": 0x090a, "flag": 0x3398D0, }, // Skull
	{"scene": 0x151b, "flag": 0x3398D4, }, // Skull
]

LBH_SHOWDOWNS = [

]

LBH_BONUS_TARGETS = [
	{"scene": 0x0a10, "flag": 0x3398C0, }, // Skull
	{"scene": 0x0a10, "flag": 0x3398C4, }, // Skull
	{"scene": 0x11ff, "flag": 0x3398C8, }, // Skull
	{"scene": 0x07ed, "flag": 0x3398CC, }, // Skull
	{"scene": 0x07ed, "flag": 0x3398D0, }, // Skull
	{"scene": 0x09ec, "flag": 0x3398D4, }, // Skull
	{"scene": 0x025d, "flag": 0x3398D8, }, // Skull
	{"scene": 0x06af, "flag": 0x3398DC, }, // Skull
	{"scene": 0x06af, "flag": 0x3398E0, }, // Skull
	{"scene": 0x0557, "flag": 0x3398E4, }, // skull
	{"scene": 0x0f60, "flag": 0x3398EC, }, // Skull
	{"scene": 0x0f60, "flag": 0x3398F0, }, // Skull
	{"scene": 0x11ff, "flag": 0x3398F8, }, // Skull
	{"scene": 0x11ff, "flag": 0x3398FC, }, // Skull
	{"scene": 0x11ff, "flag": 0x339904, }, // left lantern
	{"scene": 0x11ff, "flag": 0x339908, }, // Lantern
	{"scene": 0x11ff, "flag": 0x33990C, }, // Lantern
	{"scene": 0x11ff, "flag": 0x339910, }, // Wagon Wheel
	{"scene": 0x11ff, "flag": 0x339914, }, // Jug
	{"scene": 0x0a10, "flag": 0x339918, }, // Jug
	{"scene": 0x07ed, "flag": 0x33991C, }, // Wagon Wheel
	{"scene": 0x07ed, "flag": 0x339920, }, // Lantern
	{"scene": 0x07ed, "flag": 0x339924, }, // Wagon Wheel
	{"scene": 0x07ed, "flag": 0x339928, }, // Lantern
	{"scene": 0x09ec, "flag": 0x33992C, }, // Jug
	{"scene": 0x025d, "flag": 0x339934, }, // Wagon Wheel
	{"scene": 0x0d98, "flag": 0x339938, }, // Wagon Wheel
	{"scene": 0x0d98, "flag": 0x33993C, }, // Jug
	{"scene": 0x0d98, "flag": 0x339940, }, // Skull
	{"scene": 0x06af, "flag": 0x339944, }, // Jug
	{"scene": 0x0557, "flag": 0x339948, }, // Wagon Wheel
	{"scene": 0x0557, "flag": 0x33994C, }, // Jug
	{"scene": 0x0f60, "flag": 0x339950, }, // Jug
	{"scene": 0x0f60, "flag": 0x339954, }, // Wagon Wheel
	{"scene": 0x0f60, "flag": 0x339958, }, // Wagon Wheel
	{"scene": 0x0f60, "flag": 0x33995C, }, // Lantern
	{"scene": 0x032a, "flag": 0x339960, }, // Wagon Wheel
	{"scene": 0x032a, "flag": 0x339964, }, // Lantern
	{"scene": 0x032a, "flag": 0x339968, }, // Skull
	{"scene": 0x11ff, "flag": 0x33996C, }, // Wagon Wheel
	{"scene": 0x11ff, "flag": 0x339970, }, // Jug
	{"scene": 0x0a10, "flag": 0x339974, }, // Lantern
	{"scene": 0x06af, "flag": 0x339978, }, // Jug
	{"scene": 0x025d, "flag": 0x33997C, }, // Lantern
	{"scene": 0x0557, "flag": 0x33997C, }, // Lantern
	{"scene": 0x025d, "flag": 0x339980, }, // Jug
	{"scene": 0x025d, "flag": 0x339984, }, // Skull
	{"scene": 0x0a10, "flag": 0x339988, }, // Jug
	{"scene": 0x0a10, "flag": 0x33998C, }, // Lantern
	{"scene": 0x0a10, "flag": 0x339990, }, // Wagon Wheel
	{"scene": 0x07ed, "flag": 0x339994, }, // Jug
	{"scene": 0x11ff, "flag": 0x339998, }, // right lantern
	{"scene": 0x11ff, "flag": 0x33999C, }, // circle on top floor
]

LBH_OUTLAWS = [
	lbh_handsome_harry_status(),
	lbh_nasty_dan_status(),
	lbh_el_loco_status(),
	lbh_cactus_kid_status(),
]

OUTLAW_ATLARGE = 0
OUTLAW_DEAD = 1
OUTLAW_CAPTURED = 2

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function scene_ended(x) => (
	// previously, the scene was playing
	prev(video_pointer()) != 0 && prev(scene_id()) == x && 
	// but now the video is unloaded
	video_pointer() == 0
)

// scene is playing and we have hit the frame exactly
function scene_frame_exact(x, f) => (
	video_pointer() != 0 && scene_id() == x && 
	scene_frames() == f
)

// check if game and scene are playing, and delta on frame
function scene_frame(g, x, f) => (
	game_loaded() == g && 
	scene_frame_exact(x, f) && 
	prev(scene_frames()) == f-1
)

// function on_title_screen() => any_of(TRAILER_FILENAMES, x => ascii_string_equals(SCENE_FILENAME, x))
function on_title_screen() => dword_be(0x003ae4bc) == 1

function playing_md1() => (
	once(
		game_loaded() == GAME_MD1 && 
		any_of([0x02d1, 0x071e], x => scene_id() == x)
	) && 
	never(on_title_screen()) && 
	never(game_loaded() != GAME_MD1)
)

function playing_md2() => (
	once(
		game_loaded() == GAME_MD2 && 
		scene_id() == 0x0ec9
	) && 
	never(on_title_screen()) && 
	never(game_loaded() != GAME_MD2)
)

function playing_lbh() => (
	once(
		game_loaded() == GAME_LBH && 
		scene_id() == 0x074d
	) && 
	never(on_title_screen()) && 
	never(game_loaded() != GAME_LBH)
)

function bounty_collected(x) => (
	game_loaded() == GAME_LBH && 
	prev(x) != 1 && prev(x) != 2 && x <= 2 && x > 0
)

function player_count() => sum_of(range(0,3), i => wiimote_connected(i))

function md1_win() => scene_frame(GAME_MD1, 0x07aa, 1755)
function md2_win() => scene_frame(GAME_MD2, 0x029f, 604) || scene_frame(GAME_MD2, 0x058c, 1353)
function lbh_win() => scene_frame(GAME_LBH, 0x0d98, 3256)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_gamename = rich_presence_lookup("GAME", game_loaded(), GAMES, fallback=GAMES[GAME_MD1])
rp_difficulty = rich_presence_lookup("DIFF", difficulty(), DIFFICULTY, fallback=DIFFICULTY[1])
rp_multimode = rich_presence_lookup("MODE", game_mode(), GAMEMODES, fallback="???")

rich_presence_conditional_display(playing_md1() && game_mode() == MODE_SINGLE,
	"Playing {0} ({1}) · {2} {3} · Score: {4}",
	rp_gamename,
	rp_difficulty,
	rich_presence_number(lives(0)),
	rich_presence_lookup("LIFE", lives(0), {1: "Life"}, fallback="Lives"),
	rich_presence_value("_S", score(0), "SCORE")
)

rich_presence_conditional_display(playing_md1(),
	"Playing {0} ({1}) with {2} players ({3})",
	rp_gamename,
	rp_difficulty,
	rich_presence_number(player_count()),
	rp_multimode
)

rp_md2guide = rich_presence_lookup("MD2GUIDE", md2_route(), MD2GUIDES, fallback="")

rich_presence_conditional_display(playing_md2() && game_mode() == MODE_SINGLE,
	"Playing {0} ({1}){2} · {3} {4} · Score: {5}",
	rp_gamename,
	rp_difficulty,
	rp_md2guide,
	rich_presence_number(lives(0)),
	rich_presence_lookup("LIFE", lives(0), {1: "Life"}, fallback="Lives"),
	rich_presence_value("_S", score(0), "SCORE")
)

rich_presence_conditional_display(playing_md2(),
	"Playing {0} ({1}) with {2} players ({3}){4}",
	rp_gamename,
	rp_difficulty,
	rich_presence_number(player_count()),
	rp_multimode,
	rp_md2guide
)

function rp_outlaw(x) => rich_presence_lookup("LBHOUTLAW", x, LBHOUTLAW, fallback=LBHOUTLAW[0])

rich_presence_conditional_display(playing_lbh() && game_mode() == MODE_SINGLE,
	"Playing {0} ({1}) · {2} {3} · Score: {4} · Outlaws: [{5}{6}{7}{8}]",
	rp_gamename,
	rp_difficulty,
	rich_presence_number(lives(0)),
	rich_presence_lookup("LIFE", lives(0), {1: "Life"}, fallback="Lives"),
	rich_presence_value("_S", score(0), "SCORE"),
	rp_outlaw(lbh_handsome_harry_status()),
	rp_outlaw(lbh_nasty_dan_status()),
	rp_outlaw(lbh_el_loco_status()),
	rp_outlaw(lbh_cactus_kid_status())
)

rich_presence_conditional_display(playing_lbh(),
	"Playing {0} ({1}) with {2} players ({3}) · Outlaws: [{4}{5}{6}{7}]",
	rp_gamename,
	rp_difficulty,
	rich_presence_number(player_count()),
	rp_multimode,
	rp_outlaw(lbh_handsome_harry_status()),
	rp_outlaw(lbh_nasty_dan_status()),
	rp_outlaw(lbh_el_loco_status()),
	rp_outlaw(lbh_cactus_kid_status())
)

rich_presence_display(
	"Howdy, Pardner! 🤠"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

/* Mad Dog McCree */

achievement(
	title="Spray a Little Lead in Harm's Way",
	description="Complete Mad Dog McCree's Practice in under 10 seconds",
	points=1,
	trigger=(
		once(
			game_loaded() == GAME_MD1 &&
			video_pointer() != 0 && scene_id() == 0x0122 &&
			prev(scene_frames()) == 0xffffffff && scene_frames() == 1
		) &&
		never(video_pointer() == 0) &&
		never(scene_id() != 0x0122) &&
		never(scene_frames() == 0xffffffff) &&
		never(tally(10*60, always_true())) &&
		trigger_when(scene_frames() == 233)
	)
)

/*
achievement(
	title="From the Frying Pan Into the Fire",
	description="Win any quick-draw showdown against a stranger",
	points=2,
	trigger=any_of(MD1_SHOWDOWNS, x => scene_frame(GAME_MD1, x["scene"], x["f"]+1))
)
*/

achievement(
	title="You're in the Middle of a Hurricane Now",
	description="Build a Sharpshooter Bonus of 600",
	points=5,
	trigger=(
		game_loaded() == GAME_MD1 && 
		prev(current_bonus()) < 600 && current_bonus() >= 600
	)
)

achievement(
	title="Some People Were Born Lucky",
	description="Survive the ambush at the Corral",
	type="progression",
	points=5,
	trigger=(
		game_loaded() == GAME_MD1 &&
		// prev(video_pointer()) != 0 &&
		// prev(scene_id()) == 0x064f &&
		// video_pointer() == 0 &&
		prev(md1_corral_complete()) == 0 &&
		md1_corral_complete() == 1
	)
)

achievement(
	title="Show Him How We Do It in Tumbleweed",
	description="Get the keys from the bartender at the Saloon",
	type="progression",
	points=5,
	trigger=(
		game_loaded() == GAME_MD1 &&
		// prev(video_pointer()) != 0 &&
		// prev(scene_id()) == 0x0bde &&
		// video_pointer() == 0 &&
		prev(md1_saloon_complete()) == 0 &&
		md1_saloon_complete() == 1
	)
)

achievement(
	title="I'd Rather Be Lucky Than Good",
	description="Survive an ambush after failing to rescue the Sheriff",
	type="missable",
	points=2,
	trigger=scene_frame(GAME_MD1, 0x02ae, 536)
)

achievement(
	title="Good Thing He's in There and We're Out Here",
	description="Rescue the Sheriff from the Sheriff's Office",
	type="progression",
	points=5,
	trigger=(
		game_loaded() == GAME_MD1 &&
		// prev(video_pointer()) != 0 &&
		// prev(scene_id()) == 0x07a6 &&
		// video_pointer() == 0 &&
		prev(md1_sheriffs_office_complete()) == 0 &&
		md1_sheriffs_office_complete() == 1
	)
)

achievement(
	title="You Looking for Trouble Stranger?",
	description="Stop the outlaws at the Bank",
	type="progression",
	points=5,
	trigger=(
		game_loaded() == GAME_MD1 &&
		// prev(video_pointer()) != 0 &&
		// prev(scene_id()) == 0x0495 &&
		// video_pointer() == 0 &&
		prev(md1_bank_complete()) == 0 &&
		md1_bank_complete() == 1
	)
)

achievement(
	title="One Tough Hombre to Make it This Far",
	description="Find Mad Dog's hideout and survive the ambush",
	type="progression",
	points=10,
	trigger=scene_frame(GAME_MD1, 0x05c2, 1474)
)

achievement(
	title="Mad Dog McWii",
	description="Defeat Mad Dog McCree on any difficulty",
	type="progression",
	points=25,
	trigger=md1_win()
)

achievement(
	title="What We Need's a Gun Slinger",
	description="Defeat Mad Dog McCree on US Marshal difficulty",
	points=10,
	trigger=md1_win() && difficulty() == 3
)

achievement(
	title="Never Seen Boot Hill",
	description="Complete the game without continuing",
	points=10,
	trigger=(
		playing_md1() &&
		never(any_of(range(0,3), i => lives(i) == 0)) &&
		trigger_when(md1_win())
	)
)

achievement(
	title="A Cool Head and a Keen Eye",
	description="In one playthrough, shoot all bonus targets in every scene",
	type="missable",
	points=10,
	trigger=(
		measured(tally_of(
			MD1_BONUS_TARGETS, length(MD1_BONUS_TARGETS), 
			x => once(video_pointer() != 0 && scene_id() == x["scene"] && is_set(dword_be(x["flag"])))
		)) &&
		never(game_loaded() != GAME_MD1) &&
		never(on_title_screen())
	)
)

/* Mad Dog II: The Lost Gold */

achievement(
	title="You Think You're Man Enough to Ride Shotgun With Me?",
	description="Hit all practice targets during the intro without reloading",
	type="missable",
	points=2,
	trigger=(
		once(scene_frame(GAME_MD2, 0x0ec9, 2)) &&
		never(game_loaded() != GAME_MD2) &&
		never(on_title_screen()) &&
		// missed any target
		all_of([430, 600, 750], x => never(scene_frame_exact(0x0ec9, x))) &&
		// none of the players reloaded
		all_of(range(0,3), i => never(bullets(i) > prev(bullets(i)))) &&
		trigger_when(scene_frame(GAME_MD2, 0x0ec9, 800))
	)
)

/*
achievement(
	title="It's a Cauldron of the Devil's Own Making",
	description="Win any quick-draw showdown against a stranger",
	points=2,
	trigger=any_of(MD2_SHOWDOWNS, x => scene_frame(GAME_MD2, x["scene"], x["f"]+1))
)
*/

achievement(
	// title="Your Bullets Are Faster Than Arrows",
	title="You Good Shot, White Eyes",
	description="Build a Sharpshooter Bonus of 600",
	points=5,
	trigger=(
		game_loaded() == GAME_MD2 && 
		prev(current_bonus()) < 600 && current_bonus() >= 600
	)
)

achievement(
	title="Receive Your Reward... in Heaven",
	description="Come face to face with the imposter Padre... and live to tell the tale",
	points=2,
	trigger=scene_frame(GAME_MD2, 0x0ec9, 3339)
)

achievement(
	title="A Shortcut Through Renegade Country",
	description="Reach the top of Superstition Mountain with Shooting Beaver",
	points=10,
	trigger=game_loaded() == GAME_MD2 && md2_route() == 1 && scene_ended(0x00fa)
)

achievement(
	title="I've Got a Short Fuse Too, Stranger",
	description="Reach the top of Superstition Mountain with Buckskin Bonnie",
	points=10,
	trigger=game_loaded() == GAME_MD2 && md2_route() == 2 && scene_ended(0x007d)
)

achievement(
	title="Something of a Gambling Quack",
	description="Reach the top of Superstition Mountain with the Professor",
	points=10,
	trigger=game_loaded() == GAME_MD2 && md2_route() == 3 && scene_ended(0x00bc)
)

achievement(
	title="They Stick Like Rotten Glue",
	description="Protect the Spanish treasure from Mad Dog's posse on the train",
	type="progression",
	points=5,
	trigger=scene_frame(GAME_MD2, 0x098d, 2445)
)

achievement(
	title="Maybe You Should Have Played a Better Game",
	description="Defeat Mad Dog McCree on any difficulty",
	points=5,
	trigger=scene_frame(GAME_MD2, 0x029c, 668)
)

achievement(
	title="Bury Me With My Money",
	description="Defeat Mad Dog McCree and reach THE END",
	type="progression",
	points=25,
	trigger=md2_win()
)

achievement(
	title="The Scourge of Tumbleweed",
	description="Defeat Mad Dog McCree and reach THE END on US Marshal",
	points=10,
	trigger=md2_win() && difficulty() == 3
)

achievement(
	title="You Beat Mad Dog to the Spanish Treasure",
	description="Defeat Mad Dog McCree without continuing and get the good ending",
	points=10,
	trigger=scene_frame(GAME_MD2, 0x029f, 604)
)

achievement(
	title="That's Strong Medicine",
	description="In one session, shoot all bonus targets in every scene",
	type="missable",
	points=10,
	trigger=(
		measured(tally_of(
			MD2_BONUS_TARGETS, length(MD2_BONUS_TARGETS), 
			x => once(video_pointer() != 0 && scene_id() == x["scene"] && is_set(dword_be(x["flag"])))
		)) &&
		// this is the publisher credits, which would be a reset?
		never(video_pointer() != 0 && scene_id() == 0x015b)
	)
)

/* The Last Bounty Hunter */

achievement(
	title="Try Another One",
	description="Complete The Last Bounty Hunter's Practice without ever reloading",
	points=3,
	trigger=(
		once(
			game_loaded() == GAME_LBH &&
			video_pointer() != 0 && scene_id() == 0x0256 &&
			prev(scene_frames()) == 0xffffffff && scene_frames() == 1
		) &&
		never(on_title_screen()) &&
		never(any_of(range(0,3), i => bullets(i) > prev(bullets(i)))) &&
		trigger_when(scene_frame_exact(0x0256, 595))
	)
)

/*
achievement(
	title="__LBHShowdown",
	description="Win any quick-draw showdown against a stranger",
	points=2,
	trigger=any_of(LBH_SHOWDOWNS, x => scene_frame(GAME_LBH, x["scene"], x["f"]+1))
)
*/

achievement(
	title="I Don't Ever Recall Seeing Shootin' That Good",
	description="Build a Sharpshooter Bonus of 600",
	points=5,
	trigger=(
		game_loaded() == GAME_LBH && 
		prev(current_bonus()) < 600 && current_bonus() >= 600
	)
)

achievement(
	title="The House Always Wins",
	description="Save the roulette dealer",
	type="missable",
	points=2,
	trigger=scene_frame(GAME_LBH, 0x00c4, 135)
)

achievement(
	title="Unhand Her, You Knave!",
	description="Save the interloper in the saloon",
	type="missable",
	points=2,
	trigger=scene_frame(GAME_LBH, 0x11ff, 1176)
)

achievement(
	title="Not Just a Pretty Face",
	description="Claim the bounty on Handsome Harry",
	type="progression",
	points=5,
	trigger=bounty_collected(lbh_handsome_harry_status())
)

achievement(
	title="Like Robbin' and Killin' Was Something to Be Ashamed Of",
	description="Claim the bounty on Nasty Dan",
	type="progression",
	points=5,
	trigger=bounty_collected(lbh_nasty_dan_status())
)

achievement(
	title="Money Is His Loco Motive",
	description="Claim the bounty on El Loco",
	type="progression",
	points=5,
	trigger=bounty_collected(lbh_el_loco_status())
)

achievement(
	title="Child's Play",
	description="Claim the bounty on the Cactus Kid",
	type="progression",
	points=5,
	trigger=bounty_collected(lbh_cactus_kid_status())
)

achievement(
	title="Send 'Em to Boot Hill",
	description="Kill all outlaws in a single game",
	type="missable",
	points=10,
	trigger=(
		measured(tally_of(LBH_OUTLAWS, 4, x => once(x == OUTLAW_DEAD))) &&
		any_of(LBH_OUTLAWS, x => prev(x) != OUTLAW_DEAD) &&
		never(game_loaded() != GAME_LBH) &&
		all_of(LBH_OUTLAWS, x => never(x == OUTLAW_CAPTURED))
	)
)

achievement(
	title="Filling the Jail Cells",
	description="Capture all outlaws in a single game",
	type="missable",
	points=10,
	trigger=(
		measured(tally_of(LBH_OUTLAWS, 4, x => once(x == OUTLAW_CAPTURED))) &&
		any_of(LBH_OUTLAWS, x => prev(x) != OUTLAW_CAPTURED) &&
		never(game_loaded() != GAME_LBH) &&
		all_of(LBH_OUTLAWS, x => never(x == OUTLAW_DEAD))
	)
)

achievement(
	title="Looking the Other Way",
	description="Accept a bribe",
	type="missable",
	points=5,
	trigger=scene_frame(GAME_LBH, 0x0d98, 1926)
)

achievement(
	title="You Saved the Territory",
	description="Rid the town of the threat of outlaws on any difficulty",
	type="progression",
	points=25,
	trigger=lbh_win()
)

achievement(
	title="Hey Bounty Hunter, You Got a Death Wish?",
	description="Rid the town of the threat of outlaws on US Marshal",
	points=10,
	trigger=lbh_win() && difficulty() == 3
)

achievement(
	title="The Tequila Always Comes with a Little Trouble",
	description="Complete the game without continuing",
	points=10,
	trigger=(
		playing_lbh() &&
		never(any_of(range(0,3), i => lives(i) == 0)) &&
		trigger_when(lbh_win())
	)
)

LBH_TARGET_COUNT = 35
achievement(
	title="Clean-Up Duty",
	description=format("In one playthrough, shoot {0} unique bonus targets", LBH_TARGET_COUNT),
	type="missable",
	points=10,
	trigger=(
		measured(tally_of(
			LBH_BONUS_TARGETS, LBH_TARGET_COUNT, 
			x => once(video_pointer() != 0 && scene_id() == x["scene"] && is_set(dword_be(x["flag"])))
		)) &&
		never(game_loaded() != GAME_LBH) &&
		never(on_title_screen())
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

/* Mad Dog McCree */

leaderboard(
	title="Mad Dog McCree - Fastest Practice",
	description="Fastest time to complete Practice mode on Mad Dog McCree",

	start=(
		game_loaded() == GAME_MD1 &&
		video_pointer() != 0 && scene_id() == 0x0122 &&
		prev(scene_frames()) == 0xffffffff && scene_frames() == 1
	),
	cancel=on_title_screen() || game_loaded() != GAME_MD1 || scene_id() != 0x0122,
	submit=scene_frames() == 233,

	value=measured(tally(0, always_true())),
	format="FRAMES",
	lower_is_better=true
)

leaderboard(
	title="Mad Dog McCree - High Score (Single Player)",
	description="Highest score at the end of Mad Dog McCree in Single Player mode",

	start=md1_win() && game_mode() == MODE_SINGLE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)

leaderboard(
	title="Mad Dog McCree - High Score (Posse)",
	description="Highest score at the end of Mad Dog McCree in Posse mode",

	start=md1_win() && game_mode() == MODE_POSSE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)

/* Mad Dog II: The Lost Gold */

leaderboard(
	title="Mad Dog II - High Score (Single Player)",
	description="Highest score at the end of Mad Dog II in Single Player mode",

	start=md2_win() && game_mode() == MODE_SINGLE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)

leaderboard(
	title="Mad Dog II - High Score (Posse)",
	description="Highest score at the end of Mad Dog II in Posse mode",

	start=md2_win() && game_mode() == MODE_POSSE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)

/* The Last Bounty Hunter */

leaderboard(
	title="The Last Bounty Hunter - High Score (Single Player)",
	description="Highest score at the end of The Last Bounty Hunter in Single Player mode",

	start=lbh_win() && game_mode() == MODE_SINGLE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)

leaderboard(
	title="The Last Bounty Hunter - High Score (Posse)",
	description="Highest score at the end of The Last Bounty Hunter in Posse mode",

	start=lbh_win() && game_mode() == MODE_POSSE,
	cancel=always_false(),
	submit=always_true(),

	value=measured(score(0)),
	format="SCORE",
	lower_is_better=false
)
