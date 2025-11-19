// ~Homebrew~ Transball
// #ID = 34905

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------
// https://github.com/santiontanon/transballmsx/blob/master/src/transball-main-en.asm

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $0004: Ship State [8 bit]
//        0 = Alive
//        otherwise a frame counter since death
function ship_state() => byte(addr_offset() + 0x000004)

// $0005: Ship Angle [8 bit]
function ship_angle() => byte(addr_offset() + 0x000005)

// $0006: Ship Position Y [16 bit]
// $0008: Ship Position X [16 bit]
function ship_y() => word(addr_offset() + 0x000006)
function ship_x() => word(addr_offset() + 0x000008)

// $0076: Level [8 bit]
//        0 = Level 01
//        1 = Level 02
//        ...
//        15 = Level 16
//        16 = Congratulations!
function level() => byte(addr_offset() + 0x000076) + 1

// $0077: Time - Minutes [8 bit]
// $0078: Time - Seconds 10s [8 bit]
// $0079: Time - Seconds 1s [8 bit]
// $007A: Time - Frames [8 bit]
function time_min() => byte(addr_offset() + 0x000077)
function time_sec_tens() => byte(addr_offset() + 0x000078)
function time_sec_ones() => byte(addr_offset() + 0x000079)
function time_f() => byte(addr_offset() + 0x00007A)

// $007B: Fuel Left - Pips [8 bit]
//        stage starts with 10
function fuel_left_pips() => byte(addr_offset() + 0x00007B)

// $007C: Fuel Left - Fraction [8 bit]
//        counts down 1 per frame while thrusters held
//        rollover from 0 to 0x80 decrements 0x007b
function fuel_left_partial() => byte(addr_offset() + 0x00007C)

// $0085: Map Width [8 bit]
function map_width() => byte(addr_offset() + 0x000085)

// $0086: Map Height [8 bit]
function map_height() => byte(addr_offset() + 0x000086)

// $0087: Map Size [16 bit]
//        width x height
function map_size() => word(addr_offset() + 0x000087)

// $0089: Map Layout [4096 bytes]
MAP_LAYOUT = addr_offset() + 0x000089

// $120A: Enemy Count [8 bit]
function enemy_count() => byte(addr_offset() + 0x00120A)

// $120B: Enemy Data [352 bytes, 32 x 11 byte data]
//        struct:
//        +0 | type [8 bit]
//        +1 | map pointer [16 bit]
//        +3 | enemy type pointer [16 bit]
//        +5 | y position [16 bit]
//        +7 | x position [16 bit]
//        +9 | state [8 bit]
//        +10 | health [8 bit]
//        
//        types:
//        0x02 = cannon
//        0x03 = cannon
function _enemy_addr(x) => addr_offset() + 0x00120B + 11*x
function enemy_type(x) => byte(_enemy_addr(x) + 0)
function enemy_health(x) => byte(_enemy_addr(x) + 10)

// $136B: Tank Count [8 bit]
function tank_count() => byte(addr_offset() + 0x00136B)

// $136C: Tank Data [32 bytes, 4 x 8 byte data]
//        struct:
//        +0 | health [8 bit]
//        +1 | fire state [8 bit]
//        +2 | movement state [8 bit]
//        +3 | y position [8 bit]
//        +4 | x position [8 bit]
//        +5 | map pointer [16 bit]
//        +7 | turret angle [8 bit] (0 = left, 1 = left-up, 2 = right-up, 3 = right)
function _tank_addr(x) => addr_offset() + 0x00136C + 8*x
function tank_health(x) => byte(_tank_addr(x) + 0)

// $138C: Player Bullets Active [4 bytes] (0/1)
//        checking 0->1 is reliable for counting bullets fired
//        firing on the same frame as a respawn doesn't reuse a slot
function player_bullet_active(x) => byte(0x00138C + x)

// $1390: Player Bullet Positions [16 bytes, 4 x (16 bit, 16 bit) pairs]
// $13A0: Player Bullet Velocities [16 bytes, 4 x (16 bit, 16 bit) pairs]

// $13D4: Ball State [8 bit]
//        0 = inactive
//        1 = active
function ball_state() => byte(addr_offset() + 0x0013D4)

// $13D5: Level Complete [8 bit]
//        0 = incomplete
//        1 = complete
function _level_complete() => byte(addr_offset() + 0x0013D5)

// $13D6: Toggle Door Count [8 bit]
function toggle_door_count() => byte(addr_offset() + 0x0013D6)

// $13D7: Toggle Door Data [30 bytes, 10 x 3 byte data]
//        struct:
//        +0 | state [8 bit] (0 = closed, 1 = open)
//        +1 | map pointer [16 bit]
function _toggle_door_addr(x) => addr_offset() + 0x0013D7 + 3*x
function toggle_door_state(x) => byte(_toggle_door_addr(x) + 0)

// $13F5: Ball Door Count [8 bit]
function ball_door_count() => byte(0x0013F5)

// $13F6: Ball Door Data [30 bytes, 10 x 3 byte data]
//        struct:
//        +0 | state [8 bit] (0 = closed, 1 = open)
//        +1 | map pointer [16 bit]
function _ball_door_addr(x) => addr_offset() + 0x0013F6 + 3*x

// $1414: Explosions Active [2 bytes] (0/1)
// $1416: Explosion Data [8 bytes, 2 x 4 byte data]
//        +0 | map pointer [16 bit]
//        +2 | pointer to replacement pattern [16 bit]

// $1421: Fire Button Status [8 bit] (0/1)
//        could use this to detect firing if we don't care about bullet count
function fire_button() => byte(addr_offset() + 0x001421)

// $1C5A: Current Time Buffer [5 bytes]
//        struct:
//        +0 | minutes [8 bit] (0-9)
//        +1 | seconds tens [8 bit] (0-9)
//        +2 | seconds ones [8 bit] (0-9)
//        +3 | centi tens [8 bit] (0-9)
//        +4 | centi ones [8 bit] (0-9)
// $1C5F: Best Times [80 bytes, 16 x 5 byte data]
//        struct:
//        +0 | minutes [8 bit] (0-9)
//        +1 | seconds tens [8 bit] (0-9)
//        +2 | seconds ones [8 bit] (0-9)
//        +3 | centi tens [8 bit] (0-9)
//        +4 | centi ones [8 bit] (0-9)
//        
//        when minutes = 0x0a, that means no best time recorded

// --- MAIN DATA -------------------------------------------------------------------

MAX_ENEMIES = 32
MAX_DOORS = 10
MAX_TANKS = 4

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function player_bullet_fired() => any_of(range(0,3), i => is_set(player_bullet_active(i)))

function start_any_level() => (
	time_min() == 0 && time_sec_tens() == 0 & time_sec_ones() == 0 && 
	prev(time_f()) == 0 && time_f() == 1
)
function level_start(x) => level() == x && start_any_level()

function complete_any_level() => ball_state() == 1 && is_set(_level_complete())
function level_complete(x) => level() == x && complete_any_level()

function total_centiseconds() => 2 * (
	time_min() * 60 * 50 +
	time_sec_tens() * 10 * 50 +
	time_sec_ones() * 50 +
	time_f()
)

// this is zeroed out between stages, so we can use it for an in-level check, I think...
function blank_time() => time_min() == 0 && time_sec_tens() == 0 && time_sec_ones() == 0 && time_f() == 0
function in_stage() => !blank_time()
function on_title_screen() => map_size() == 768 && dword(addr_offset() + 0x00008c) == 0x49544e41

function all_enemies_destroyed(n=MAX_ENEMIES) => all_of(range(0,n-1), i => enemy_health(i) == 0)
function toggle_doors_closed(n=MAX_DOORS) => all_of(range(0,n-1), i => toggle_door_state(i) == 0)
function all_tanks_destroyed(n=MAX_TANKS) => all_of(range(0,n-1), i => tank_health(i) == 0)

function fuel() => (fuel_left_pips() - 1) * 0x80 + fuel_left_partial()
function fuel_perc() => fuel() / 1280.0

// --- RICH PRESENCE -------------------------------------------------------------------

rp_ballstate = rich_presence_lookup("BallState", ball_state(), {1: "🔵"}, fallback="⚪")

rich_presence_conditional_display(on_title_screen(),
	"[Title Screen] 🏳️‍⚧️ Transball | © Santiago Ontañón 2016"
)

rich_presence_conditional_display(blank_time(),
	"🏳️‍⚧️ Starting Stage {0}",
	rich_presence_number(level())
)

rich_presence_conditional_display(_level_complete() == 1,
	"🏳️‍⚧️ Stage {1} Complete! · ⏱️ Time: {3}",
	rp_ballstate,
	rich_presence_number(level()),
	rich_presence_number(fuel_perc() * 100),
	rich_presence_value("Time", total_centiseconds(), "MILLISECS")
)

rich_presence_display(
	"{0} Stage {1} · ⛽ Fuel: {2}% · ⏱️ Time: {3}",
	rp_ballstate,
	rich_presence_number(level()),
	rich_presence_number(fuel_perc() * 100),
	rich_presence_value("Time", total_centiseconds(), "MILLISECS")
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// 01 under 8 seconds
// 02 under 15 seconds
// 03 under 10 seconds
// 04 without destroying the cannon
// 05 under 1 minute
// 06 destroy all cannons
// 07 close the door before ending the level
// 08 destroy the tank
// 09 destroy the tank before 0:20 ("mutually assured destruction")
// 10 fire 1 bullet
// 11 reach the ball in under 15 seconds
// 12 under 1 minute
// 13 
// 14 
// 15 
// 16 

achievement(
	title="Search and Rescue",
	description="Complete Level 01",
	type="progression",
	points=1,
	trigger=level_complete(1)
)

achievement(
	title="Precision Extraction",
	description="Complete Level 01 in under 8 seconds",
	points=4,
	trigger=level_complete(1) && total_centiseconds() < 800
)

achievement(
	title="Around the Bend",
	description="Complete Level 02",
	type="progression",
	points=2,
	trigger=level_complete(2)
)

achievement(
	title="Then There's No Time to Waste",
	description="Complete Level 02 in under 15 seconds",
	points=5,
	trigger=level_complete(2) && total_centiseconds() < 1500
)

achievement(
	title="Underline",
	description="Complete Level 03",
	type="progression",
	points=3,
	trigger=level_complete(3)
)

achievement(
	title="Efficiency Is Key",
	description="Complete Level 03 in under 10 seconds",
	points=5,
	trigger=level_complete(3) && total_centiseconds() < 1000
)

achievement(
	title="First Hostility",
	description="Complete Level 04",
	type="progression",
	points=4,
	trigger=level_complete(4)
)

achievement(
	title="Turning the Other Cheek",
	description="Complete Level 04 without destroying the wall cannon",
	points=2,
	trigger=level_complete(4) && enemy_health(0) > 0
)

achievement(
	title="Get the Point",
	description="Complete Level 05",
	type="progression",
	points=5,
	trigger=level_complete(5)
)

achievement(
	title="No Dawdling",
	description="Complete Level 05 in under 60 seconds",
	points=5,
	trigger=level_complete(5) && total_centiseconds() < 6000
)

achievement(
	title="Increasing Firepower",
	description="Complete Level 06",
	type="progression",
	points=5,
	trigger=level_complete(6)
)

achievement(
	title="Machina Cleanup Detail",
	description="Complete Level 06 after destroying all cannons",
	points=10,
	trigger=level_complete(6) && measured(6 - sum_of(range(0,5), i => enemy_health(i) / enemy_health(i)) >= 6)
)

achievement(
	title="Featuring Jim Morrison",
	description="Complete Level 07",
	type="progression",
	points=5,
	trigger=level_complete(7)
)

achievement(
	title="Call the Rescue Team! Wait, We *Are* the Rescue Team",
	description="In Level 07, softlock the ship in the room holding the ball",
	points=1,
	trigger=(
		level() == 7 && in_stage() && toggle_door_state(0) == 0 &&
		ship_y() > 0x0a80 && ship_y() < 0x1080 && ship_x() < 0x0e80
	)
)

achievement(
	title="Tanks for the Memories",
	description="Complete Level 08",
	type="progression",
	points=5,
	trigger=level_complete(8)
)

achievement(
	title="This Town Ain't Big Enough for the Both of Us",
	description="In Level 08, destroy the tank",
	points=2,
	trigger=level() == 8 && prev(tank_health(0)) > 0 && tank_health(0) == 0
)

achievement(
	title="A Brief Detour",
	description="Complete Level 09",
	type="progression",
	points=5,
	trigger=level_complete(9)
)

achievement(
	title="Mutually Assured Destruction",
	description="In Level 09, destroy the tank in under 20 seconds",
	points=2,
	trigger=(
		level() == 9 && in_stage() && total_centiseconds() < 2000 && 
		trigger_when(prev(tank_health(0)) > 0 && tank_health(0) == 0)
	)
)

achievement(
	title="There and Back Again",
	description="Complete Level 10",
	type="progression",
	points=5,
	trigger=level_complete(10)
)

achievement(
	title="All I Need Is One Bullet!",
	description="Complete Level 10 without firing more than one bullet",
	type="progression",
	points=10,
	trigger=(
		level() == 10 && in_stage() &&
		disable_when(tally(2, player_bullet_fired()), until=!in_stage()) &&
		trigger_when(complete_any_level())
	)
)

achievement(
	title="Z-Force",
	description="Complete Level 11",
	type="progression",
	points=3,
	trigger=level_complete(11)
)

achievement(
	title="Just Getting My Hand on the Ball",
	description="In Level 11, reach the ball in under 15 seconds",
	points=5,
	trigger=(
		level() == 11 && in_stage() && total_centiseconds() < 1500 &&
		trigger_when(prev(ball_state()) == 0 && ball_state() == 1)
	)
)

achievement(
	title="A Quick Top Up Should Do Me",
	description="Complete Level 12",
	type="progression",
	points=3,
	trigger=level_complete(12)
)

achievement(
	title="No Time for Petrol",
	description="Complete Level 12 in under 60 seconds",
	points=25,
	trigger=level_complete(12) && total_centiseconds() < 6000
)

achievement(
	title="The Shaft of Doom",
	description="Complete Level 13",
	type="progression",
	points=3,
	trigger=level_complete(13)
)

achievement(
	title="Down Where the Air Gets Thinner",
	description="Complete Level 14",
	type="progression",
	points=3,
	trigger=level_complete(14)
)

achievement(
	title="Antechambers",
	description="Complete Level 15",
	type="progression",
	points=5,
	trigger=level_complete(15)
)

achievement(
	title="Transball Says: Trans Rights",
	description="Complete Level 16",
	type="win_condition",
	points=10,
	trigger=level_complete(16)
)

// --- LEADERBOARDS -------------------------------------------------------------------

for stage in range(1,16)
{
	stagetxt = substring(format("0{0}", stage), -2, 2)
	leaderboard(
		title=format("Stage {0} Speedrun", stagetxt),
		description=format("Fastest time to complete Stage {0}", stagetxt),
	
		start=level_complete(stage),
		cancel=always_false(),
		submit=always_true(),
	
		value=measured(total_centiseconds()),
		format="MILLISECS",
		lower_is_better=true
	)
}