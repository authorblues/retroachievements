// Athletic Land
// #ID = 27466

// --- HELPERS -------------------------------------------------------------------

function if_else(p, t, f) { if (p) { return t } else return f }
function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")

function zfill(num, c)
{
	if (length(format("{0}", num)) >= c) return format("{0}", num)
	return substring(format("0000000000000000000{0}", num), -c, c)
}

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $2002: Game State [8 bit]
//        bit5 = number of players (0 = 1 player, 1 = 2 players)
//        bit6 = active game (0 = title or demo, 1 = playing)
//        bit7 = current player (0 = P1, 1 = P2)
function player_count() => bit5(addr_offset() + 0x002002) + 1
function _in_game() => bit6(addr_offset() + 0x002002)
function current_player() => bit7(addr_offset() + 0x002002)

// $2008: Actual User Input [8 bit]
//        use 0x2009 for achievement logic
function actual_user_input() => byte(addr_offset() + 0x002008)

// $2009: User Input [8 bit]
//        bit0 = up
//        bit1 = down
//        bit2 = left
//        bit3 = right
//        bit4 = jump
//        bit5 = jump
//        
//        simulated during attract mode
function user_input() => byte(addr_offset() + 0x002009)

// $201C: Music ID possibly [8 bit]
//        0x00 = out of game, loading
//        0x8e = gameplay
//        0x90 = death jingle before next life
//        0x9c = end of level fanfare, starting game
//        
//        0x16 = dying, falling over
//        0x19 = dying by drowning
function music_id() => byte(addr_offset() + 0x00201C)

// $2040: High Score [24 bit BCD]
function high_score() => bcd(tbyte(addr_offset() + 0x002040))

// $2043: P1 Score [24 bit BCD]
function p1_score() => bcd(tbyte(addr_offset() + 0x002043))

// $2046: P2 Score [24 bit BCD]
function p2_score() => bcd(tbyte(addr_offset() + 0x002046))

// $2050: Life Count [8 bit]
//        starts at 2
function life_count() => byte(addr_offset() + 0x002050)

// $2051: Current Stage [8 bit BCD]
//        rollover after 99 gives All Stage Clear
function current_stage() => bcd(byte(addr_offset() + 0x002051))

// $2053: Direction [8 bit]
//        0 = Going Right
//        1 = Going Left
function direction() => byte(addr_offset() + 0x002053)

// $2054: Current Scene [8 bit]
function current_scene() => byte(addr_offset() + 0x002054)

// $2055: Time Remaining [8 bit]
function time_remaining() => byte(addr_offset() + 0x002055)

// --- MAIN DATA -------------------------------------------------------------------

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// backup in_game check (sketchy, uses music id)
// function in_game() => once(never(music_id() == 0x93) && music_id() == 0x9c && prev(music_id()) == 0x00)

function in_game() => _in_game() == 1 && player_count() == 1

function complete_stage(x) => in_game() && prev(current_stage()) == x && current_stage() == x+1

function game_over() => prev(_in_game()) == 1 && _in_game() == 0 && player_count() == 1

function stage_fanfare() => prev(music_id()) == 0x8e && music_id() == 0x9c

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(in_game(),
	"🏃x{0} Stage {1}{2} | Score {3}",
	rich_presence_number(life_count()),
	rich_presence_number(current_stage()),
	rich_presence_lookup("Direction", direction(), {1: " (R)"}, fallback=""),
	rich_presence_value("_S", max_of(
		measured(p1_score(), when=current_player() == 0),
		measured(p2_score(), when=current_player() == 1)
	), "SCORE")
)

rich_presence_display(
	"🏃 Athletic Land | © Konami 1984"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="It's Child's Play",
	description="Complete stage 01",
	type="progression",
	points=1,
	trigger=complete_stage(1)
)

achievement(
	title="Swinging Through the Trees",
	description="Complete stage 05",
	type="progression",
	points=10,
	trigger=complete_stage(5)
)

achievement(
	title="King of Child Park",
	description="Complete stage 10",
	type="win_condition",
	points=50,
	trigger=complete_stage(10)
)

/*
achievement(
	title="Swinging Through the Trees",
	description="Complete stage 20",
	type="progression",
	points=10,
	trigger=complete_stage(20)
)

achievement(
	title="King of Child Park",
	description="Complete stage 30",
	type="win_condition",
	points=25,
	trigger=complete_stage(30)
)
*/

achievement(
	title="A Playdate in the Park",
	description="Earn an extra life by reaching 10,000 points",
	points=1,
	trigger=in_game() && prev(high_score()) < 10000 && high_score() >= 10000
)

achievement(
	title="Sustainability",
	description="Earn a second extra life by reaching 30,000 points. Every additional 20,000 points is another life from here onward",
	points=3,
	trigger=in_game() && prev(high_score()) < 30000 && high_score() >= 30000
)

achievement(
	title="Track & Field Gold Medalist",
	description="Earn 100,000 points",
	points=5,
	trigger=in_game() && prev(high_score()) < 100000 && high_score() >= 100000
)

achievement(
	title="The Shortest Distance",
	description="Complete stage 01 with 82% or more of bonus time remaining",
	points=5,
	trigger=(
		time_remaining() >= 48 &&
		measured(time_remaining() <= 58, 
			when=in_game() && current_stage() == 1, 
			format="percent"
		) &&
		current_scene() == 10 && stage_fanfare()
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Furthest Stage",
	description="Reach the furthest stage of Child Park",

	start=game_over() || (current_stage() == 99 && stage_fanfare()),
	cancel=current_stage() == 0,
	submit=always_true(),

	value=measured(current_stage()),
	format="VALUE",
	lower_is_better=false
)

leaderboard(
	title="Highest Score",
	description="Earn the highest score possible",

	start=player_count() == 1 && prev(_in_game()) == 0 && _in_game() == 1,
	cancel=player_count() != 1,
	submit=game_over(),

	value=max_of(array_map(range(0,20), 
		n => measured(1000000 * n + p1_score(), 
			when=if_else(n == 0, always_true(), tally(n, high4(0x002045) < prev(high4(0x002045))))
		)
	)),
	format="SCORE",
	lower_is_better=false
)
