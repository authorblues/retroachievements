// ~Hack~ Super Mario Worldle
// #ID = 39042

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $00CE: Pointer to Sprite Data [24 bit]
//        0x07df94 = ice water room VOB4
//        0x07ccba = ice water room VD3
//        0x07cbc5 = ice water room VD2
function sprite_ptr() => tbyte(0x00CE)

// $0100: Game State [8 bit]
//        --- 0x00 | Loading Nintendo Presents
//        --- 0x01 | Nintendo Presents
//        --- 0x02 | Fade to Title Screen
//        --- 0x03 | Load Title Screen
//        --- 0x04 | Prepare Title Screen
//        --- 0x05 | Fade in Title Screen
//        --- 0x06 | Circle Effect in Title Screen
//        --- 0x07 | Title Screen
//        --- 0x08 | File Select
//        --- 0x09 | File Deletion
//        --- 0x0A | Player Select
//        --- 0x0B | Fade to Overworld
//        --- 0x0C | Load Overworld
//        --- 0x0D | Fade in Overworld
//        --- 0x0E | Overworld
//        --- 0x0F | Fade to Level
//        --- 0x10 | Fade to Level 2
//        --- 0x11 | Load Level
//        --- 0x12 | Prepare Level
//        --- 0x13 | Fade in Level
//        --- 0x14 | In Level
//        --- 0x15 | Fade to Game Over / Time Up
//        --- 0x16 | Load Game Over / Time Up
//        --- 0x17 | Game Over / Time Up
//        --- 0x18 | Load Credits / Cutscene
//        --- 0x19 | Load Credits / Cutscene 2
//        --- 0x1A | Load Credits / Cutscene 3
//        --- 0x1B | Credits / Cutscene
//        --- 0x1C | Fade to Yoshi's House in Credits
//        --- 0x1D | Load Yoshi's House in Credits
//        --- 0x1E | Fade in Yoshi's House in Credits
//        --- 0x1F | Yoshi's House in Credits
//        --- 0x20 | Fade to Enemies in Credits
//        --- 0x21 | Fade to Enemies 2 in Credits
//        --- 0x22 | Fade to Enemies 3 in Credits
//        --- 0x23 | Fade to Enemies 4 in Credits
//        --- 0x24 | Fade in Enemies in Credits
//        --- 0x25 | Enemies in Credits
//        --- 0x26 | Fade to End Screen
//        --- 0x27 | Load End Screen
//        --- 0x28 | Fade in End Screen
//        --- 0x29 | End Screen
function game_state() => byte(0x0100)

// $0F62: Current Streak [16 bit]
//        increments on success, zeroes on failure
//        on the same frame as 0x0100 transitions 0x0e->0x0f
function streak() => word(0x0F62)

// $13BF: Level ID [8 bit]
//        --- 0x01 | Vanilla Secret 2
//        --- 0x02 | Vanilla Secret 3
//        --- 0x03 | Top Secret Area
//        --- 0x04 | Donut Ghost House
//        --- 0x05 | Donut Plains 3
//        --- 0x06 | Donut Plains 4
//        --- 0x07 | #2 Morton
//        --- 0x08 | Green Switch Palace
//        --- 0x09 | Donut Plains 2
//        --- 0x0A | Donut Secret 1
//        --- 0x0B | Vanilla Fort
//        --- 0x0C | Butter Bridge 1
//        --- 0x0D | Butter Bridge 2
//        --- 0x0E | #4 Ludwig
//        --- 0x0F | Cheese Bridge Area
//        --- 0x10 | Cookie Mountain
//        --- 0x11 | Soda Lake
//        --- 0x14 | Yellow Switch Palace
//        --- 0x15 | Donut Plains 1
//        --- 0x18 | Sunken Ghost Ship
//        --- 0x1A | #6 Wendy
//        --- 0x1B | Chocolate Fort
//        --- 0x1C | Chocolate Island 5
//        --- 0x1D | Chocolate Island 4
//        --- 0x1F | Forest Fort
//        --- 0x20 | #5 Roy
//        --- 0x21 | Choco-Ghost House
//        --- 0x22 | Chocolate Island 1
//        --- 0x23 | Chocolate Island 3
//        --- 0x24 | Chocolate Island 2
//        --- 0x25 | #1 Iggy
//        --- 0x26 | Yoshi's Island 4
//        --- 0x27 | Yoshi's Island 3
//        --- 0x28 | Yoshi's House
//        --- 0x29 | Yoshi's Island 1
//        --- 0x2A | Yoshi's Island 2
//        --- 0x2B | Vanilla Ghost House
//        --- 0x2D | Vanilla Secret 1
//        --- 0x2E | Vanilla Dome 3
//        --- 0x2F | Donut Secret 2
//        --- 0x31 | Bowser Front Door
//        --- 0x32 | Bowser Back Door
//        --- 0x33 | Valley of Bowser 4
//        --- 0x34 | #7 Larry
//        --- 0x35 | Valley Fort
//        --- 0x37 | Valley of Bowser 3
//        --- 0x38 | Valley Ghost House
//        --- 0x39 | Valley of Bowser 2
//        --- 0x3A | Valley of Bowser 1
//        --- 0x3B | Chocolate Secret
//        --- 0x3C | Vanilla Dome 2
//        --- 0x3D | Vanilla Dome 4
//        --- 0x3E | Vanilla Dome 1
//        --- 0x3F | Red Switch Palace
//        --- 0x40 | #3 Lemmy
//        --- 0x41 | Forest Ghost House
//        --- 0x42 | Forest of Illusion 1
//        --- 0x43 | Forest of Illusion 4
//        --- 0x44 | Forest of Illusion 2
//        --- 0x45 | Blue Switch Palace
//        --- 0x46 | Forest Secret Area
//        --- 0x47 | Forest of Illusion 3
//        --- 0x49 | Funky
//        --- 0x4A | Outrageous
//        --- 0x4B | Mondo
//        --- 0x4C | Groovy
//        --- 0x4E | Gnarly
//        --- 0x4F | Tubular
//        --- 0x50 | Way Cool
//        --- 0x51 | Awesome
//        --- 0x54 | Star World 2
//        --- 0x56 | Star World 3
//        --- 0x58 | Star World 1
//        --- 0x59 | Star World 4
//        --- 0x5A | Star World 5
function level_id() => byte(0x13BF)

// $1FCE: Best Streak [16 bit]
function best_streak() => word(0x1FCE)

// --- MAIN DATA -------------------------------------------------------------------

ICE_SUBAREAS = [
	0x07cbc5,
	0x07ccba,
	0x07df94,
]

SMW_AREAS = [
	/* #1 */ [0x14, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, ], // Yoshi's Island
	/* #2 */ [0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x15, 0x2F, ], // Donut Plains
	/* #3 */ [0x01, 0x02, 0x0B, 0x2B, 0x2D, 0x2E, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, ], // Vanilla Dome
	/* #4 */ [0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, ], // Twin Bridges
	/* #5 */ [0x1F, 0x20, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, ], // Forest of Illusion
	/* #6 */ [0x1A, 0x1B, 0x1C, 0x1D, 0x21, 0x22, 0x23, 0x24, 0x3B, ], // Chocolate Island
	/* #7 */ [0x18, 0x31, 0x32, 0x33, 0x34, 0x35, 0x37, 0x38, 0x39, 0x3A, ], // Valley of Bowser
	/* St */ [0x54, 0x56, 0x58, 0x59, 0x5A, ], // Star World
	/* Sp */ [0x49, 0x4A, 0x4B, 0x4C, 0x4E, 0x4F, 0x50, 0x51, ], // Special World
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function reached_streak(n) => (
	prev(game_state()) == 0x0e && game_state() == 0x0f &&
	prev(streak()) == n-1 && streak() == n
)

function correct_answer() => (
	prev(game_state()) == 0x0e && game_state() == 0x0f &&
	streak() > prev(streak())
)

function streak_reset() => (
	prev(game_state()) == 0x0e && game_state() == 0x0f &&
	prev(streak()) > 0 && streak() == 0
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_state() <= 0x0a,
	"Title Screen"
)

rich_presence_conditional_display(game_state() <= 0x0e,
	"Searching the Map [Streak: {0}]",
	rich_presence_number(streak())
)

rich_presence_display(
	"Inspecting the Street View [Streak: {0}]",
	rich_presence_number(streak())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Welcome! This is Dinosaur Land",
	description="Successfully identify a level and reach a streak of 1. You're on your way now!",
	type="progression",
	points=1,
	trigger=reached_streak(1)
)

achievement(
	title="You Are Here",
	description="Reach a streak of 5",
	type="progression",
	points=3,
	trigger=reached_streak(5)
)

achievement(
	title="Rainbolt Road",
	description="Reach a streak of 10",
	type="progression",
	points=5,
	trigger=reached_streak(10)
)

achievement(
	title="You Are a Super Player!",
	description="Reach a streak of 25",
	type="win_condition",
	points=10,
	trigger=reached_streak(25)
)

achievement(
	title="Even the RetroAchievements Staff is Impressed",
	description="Reach a streak of 50",
	points=10,
	trigger=reached_streak(50)
)

achievement(
	title="World Traveller",
	description="In one streak, identify one level from each of the nine Super Mario World areas, including Star World and Special World",
	points=5,
	trigger=(
		measured(
			tally_of(SMW_AREAS, length(SMW_AREAS), lvls => (
				once(any_of(lvls, x => level_id() == x) && correct_answer())
			))
		) &&
		never(streak() == 0) &&
		never(game_state() <= 0x0a)
	)
)

achievement(
	title="The Joke Is That They All Look the Same",
	description="Successfully identify one of the three non-descript underground icy water subareas. You didn't remember these were here? I know.",
	points=5,
	trigger=(
		once(__ornext(any_of(ICE_SUBAREAS, x => sprite_ptr() == x)) && game_state() == 0x14) &&
		never(all_of(ICE_SUBAREAS, x => sprite_ptr() != x) && sprite_ptr() != 0) &&
		correct_answer()
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Best Streak",
	description="Highest streak earned in any game. Leaderboard submits on streak reset",

	start=streak_reset(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(prev(streak())),
	format="VALUE",
	lower_is_better=false
)