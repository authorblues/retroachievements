// Lupin III: The Castle of Cagliostro
// #ID = 34906

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $1A97: In Game [8 bit] (0/1)
//        0 on title screen
//        1 in game
//        0 at the end in the clock tower, for some reason
function in_game_flag() => byte(0x001A97)

// $1AB1: Stage [8 bit]
//        0 = title screen
//        8 = ending
function stage() => byte(0x001AB1)

// $1AB9: Room ID [8 bit]
//        not unique between levels
function room_id() => byte(0x001AB9)

// $2163: Score (Upper 4 Digits) [16 bit]
// $2165: Score (Lower 4 Digits) [16 bit]
function score_hi() => word(0x002163)
function score_lo() => word(0x002165)

// $216D: Coins [8 bit]
function coins() => byte(0x00216D)

// $216F: Bullets [8 bit]
function bullets() => byte(0x00216F)

// $2171: Lives [8 bit]
function lives() => byte(0x002171)

// $218B: Cup [8 bit]
function cup() => byte(0x00218B)

// $218C: Cup [8 bit] (manipulable)
//        0xf7 = full
//        0xd9 = empty
function cup_manipulable() => byte(0x00218C)

// $218E: Life Remaining [8 bit]
function life_remaining() => byte(0x00218E)

// $218F: Health [8 bit] (manipulable)
//        0xf7 = full
//        0xd9 = death
function health_manipulable() => byte(0x00218F)

// $219F: Clock Freeze Active [8 bit]
function clock_freeze_active() => byte(0x00219F)

// $21C4: Handcuffs Active [8 bit]
function handcuffs_active() => byte(0x0021C4)

// $21C7: Current Sword [8 bit]
//        1 = default sword
//        2 = broken sword
//        3 = Zantetsuken
function sword() => byte(0x0021C7)

// $21C8: Sword Damage [8 bit]
//        at 60, if you don't have the Zantetsuken, the sword is shortened
function sword_damage() => byte(0x0021C8)

// $21CA: Winch/Rope [8 bit]
//        bit0 | collected (in inventory)
//        bit7 | using/used
function winch_rope() => bit0(0x0021CA)

// $21CB: Zenigata's Coat Active [8 bit] (0/1)
function zeni_coat() => byte(0x0021CB)

// $21CD: Rings [8 bit]
//        bit0 | red ring
//        bit1 | green ring
function rings() => byte(0x0021CD)
function red_ring() => bit0(0x0021CD)
function green_ring() => bit1(0x0021CD)

// $21D4: Green Potion [8 bit] (0/1)
function green_potion() => byte(0x0021D4)

// --- MAIN DATA -------------------------------------------------------------------

STAGE_TITLE = 0
STAGE_ENDING = 8

LIFE_MAX = 30
CUP_MAX = 30

SWORD_NORMAL = 1
SWORD_BROKEN = 2
SWORD_ZANTETSUKEN = 3

SWORD_NAMES = {
	SWORD_NORMAL: "Longsword",
	SWORD_BROKEN: "Broken Longsword",
	SWORD_ZANTETSUKEN: "Zantetsuken",
}

RINGS = {
	0: "",
	1: " 💍(🟥)",
	2: " 💍(🟩)",
	3: " 💍(🟥🟩)",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => stage() > STAGE_TITLE && stage() < STAGE_ENDING

function score() => score_hi()*10000 + score_lo()

function level_progression(x, flag=1) => in_game_flag() == flag && prev(stage()) == x && stage() == x+1

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(stage() == STAGE_TITLE || stage() == 0xFF,
	"[Title Screen] Lupin III: The Castle of Cagliostro"
)

rich_presence_conditional_display(stage() >= STAGE_ENDING,
	"[Ending] Lupin III: The Castle of Cagliostro (go watch the movie now)"
)

rich_presence_display(
	"Level {0} · 🏃 {1} {2} ❤️ {3}% health · 🍜 {4}% cup · 🗡️ {5} · 🔫 {6} bullet{7} · 💯 Score: {8} · Items:{9}{10}{11}",
	rich_presence_number(stage()),
	rich_presence_number(lives()), rich_presence_lookup("LifeWord", lives(), {1: "life"}, fallback="lives"),
	rich_presence_number(life_remaining() * 100 / 30),
	rich_presence_number(cup() * 100 / 30),
	rich_presence_lookup("Sword", sword(), SWORD_NAMES, fallback=SWORD_NAMES[SWORD_NORMAL]),
	rich_presence_number(bullets()), plural(bullets()),
	rich_presence_value("Score", score(), "SCORE"),
	rich_presence_lookup("Rings", rings(), RINGS, fallback=""),
	rich_presence_lookup("Winch", winch_rope(), {1: " 🪢"}, fallback=""),
	rich_presence_lookup("Potion", green_potion(), {1: " 💣"}, fallback="")
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Zoinks, Scoob!",
	description="Complete stage 1, outside the castle",
	type="progression",
	points=5,
	trigger=level_progression(1)
)

achievement(
	title="Ask Jeeves",
	description="Complete stage 2, inside the castle",
	type="progression",
	points=5,
	trigger=level_progression(2)
)

achievement(
	title="The Worst Pipe Maze in Gaming",
	description="Complete stage 3, the underground sewers",
	type="progression",
	points=5,
	trigger=level_progression(3)
)

achievement(
	title="Combating Inflation",
	description="Complete stage 4, the counterfeit money factory",
	type="progression",
	points=3,
	trigger=level_progression(4)
)

achievement(
	title="Til Death Do You Part",
	description="Complete stage 5, the chapel",
	type="progression",
	points=5,
	trigger=level_progression(5)
)

achievement(
	title="What Have the Romans Ever Done for Us?",
	description="Complete stage 6, the aquaduct",
	type="progression",
	points=5,
	trigger=level_progression(6)
)

achievement(
	title="All Along the Clock Tower",
	description="Complete stage 7, the clock tower",
	type="win_condition",
	points=25,
	trigger=level_progression(7, flag=0)
)

achievement(
	title="Ganbare Lupin!",
	description="Find Goemon and get the Zentetsuken. Finally a sword that won't break!",
	points=5,
	trigger=stage() == 3 && prev(sword()) != SWORD_ZANTETSUKEN && sword() == SWORD_ZANTETSUKEN
)

achievement(
	title="DoorDash Delivery for \"Arsene Lupin\"",
	description="Get some help from Fujiko. Wait, I didn't know I'd have to pay!",
	points=3,
	trigger=in_game() && prev(coins()) - coins() >= 30 && prev(coins()) > coins()
)

achievement(
	title="Hey, Stupid! Don't Wolf It Down like That",
	description="Max out your cup meter. This many instant noodles, looks like my college pantry",
	points=5,
	trigger=(
		prev(cup()) < 30 && prev(cup()) >= 28 && 
		measured(cup() >= 30, when=in_game(), format="percent")
	)
)

achievement(
	title="The Ideal of the Shōwa Period",
	description="Find Inspector Zenigata's coat. They'll all be fooled by my disguise!",
	points=5,
	trigger=in_game() && is_set(zeni_coat())
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="High Score",
	description="Highest score after game over or completing the game",

	start=(
		(stage() != 0 && lives() == 0 && prev(life_remaining()) > 0 && life_remaining() == 0) ||
		level_progression(7)
	),
	cancel=always_false(),
	submit=always_true(),

	value=measured(score()),
	format="SCORE",
	lower_is_better=false
)