// Super Mario All-Stars
// #ID = 34617
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $461FB8: (NTSC) (SMB2) Frame Counter [8 bit]
function frame_counter(r) => byte(r.offset() + 0x461FB8)

// $461FBC: (NTSC) (SMB2) Player X Position, high byte [8 bit]
function player_x_position_high_byte(r) => byte(r.offset() + 0x461FBC)

// $461FBD: (NTSC) (SMB2) Sprite X Position, high byte [9 bytes]
function sprite_x_position_high_byte(r, i) => byte(r.offset() + 0x461FBD + i)

// $461FC6: (NTSC) (SMB2) Player Y Position, high byte [8 bit]
function player_y_position_high_byte(r) => byte(r.offset() + 0x461FC6)

// $461FC7: (NTSC) (SMB2) Sprite Y Position, high byte [9 bytes]
function sprite_y_position_high_byte(r, i) => byte(r.offset() + 0x461FC7 + i)

// $461FD0: (NTSC) (SMB2) Player X Position, low byte [8 bit]
function player_x_position_low_byte(r) => byte(r.offset() + 0x461FD0)

// $461FD1: (NTSC) (SMB2) Sprite X Position, low byte [9 bytes]
//          
//          (NTSC) (SMB2) Slot 1 Status [8 bit]
//          0 = Stopped
//          1 = Slowing
//          2 = Spinning
// $461FD2: (NTSC) (SMB2) Slot 2 Status [8 bit]
// $461FD3: (NTSC) (SMB2) Slot 3 Status [8 bit]

function sprite_x_position_low_byte(r, i) => byte(r.offset() + 0x461FD1 + i)
function slot_1_status(r) => byte(r.offset() + 0x461FD1)
function slot_2_status(r) => byte(r.offset() + 0x461FD2)
function slot_3_status(r) => byte(r.offset() + 0x461FD3)

// $461FD7: (NTSC) (SMB2) Slot 1 Result [8 bit]
//          0 = Cherry
//          1 = Sniffit
//          2 = Star
//          3 = Turnip
//          4 = [ 7 ]
// $461FD8: (NTSC) (SMB2) Slot 2 Result [8 bit]
// $461FD9: (NTSC) (SMB2) Slot 3 Result [8 bit]
function slot_1_result(r) => byte(r.offset() + 0x461FD7)
function slot_2_result(r) => byte(r.offset() + 0x461FD8)
function slot_3_result(r) => byte(r.offset() + 0x461FD9)

// $461FDA: (NTSC) (SMB2) Player Y Position, low byte [8 bit]
function player_y_position_low_byte(r) => byte(r.offset() + 0x461FDA)

// $461FDB: (NTSC) (SMB2) Sprite Y Position, low byte [9 bytes]
function sprite_y_position_low_byte(r, i) => byte(r.offset() + 0x461FDB + i)

// $461FE4: (NTSC) (SMB2) Player X Speed [8 bit]
function player_x_speed(r) => byte(r.offset() + 0x461FE4)

// $461FE5: (NTSC) (SMB2) Sprite X Speed [9 bytes]
//          bit7 | Direction (1 = left, 0 = right)
function sprite_x_speed(r, i) => byte(r.offset() + 0x461FE5 + i)

// $461FEE: (NTSC) (SMB2) Player Y Speed [8 bit]
//          bit7 | Direction (1 = up, 0 = down)
function player_y_speed(r) => byte(r.offset() + 0x461FEE)

// $461FEF: (NTSC) (SMB2) Sprite Y Speed [9 bytes]
//          bit7 | Direction (1 = up, 0 = down)
function sprite_y_speed(r, i) => byte(r.offset() + 0x461FEF + i)

// $461FF8: (NTSC) (SMB2) Player State [8 bit]
//          0x00 = Normal
//          0x01 = Climbing/Vine
//          0x02 = Lifting
//          0x04 = Entering Jar
//          0x05 = Exiting Jar
//          0x06 = Entering Hawkmouth
//          0x07 = Dying?
//          0x08 = Growing?
function player_state(r) => byte(r.offset() + 0x461FF8)

// $461FF9: (NTSC) (SMB2) Sprite State [9 bytes]
function sprite_state(r, i) => byte(r.offset() + 0x461FF9 + i)

// $462002: (NTSC) (SMB2) Player Flags? [8 bit]
function player_flags(r) => byte(r.offset() + 0x462002)

// $462003: (NTSC) (SMB2) Sprite Flags [9 bytes]
//          bit2 | moving freely
//          bit5 | player standing on
//          bit6 | player controlled?
function sprite_moving_freely(r, i) => bit2(r.offset() + 0x462003 + i)
function sprite_stood_on(r, i) => bit5(r.offset() + 0x462003 + i)

// $462037: (NTSC) (SMB2) Character [8 bit]
//          0 = Mario
//          1 = Princess
//          2 = Toad
//          3 = Luigi
function character(r) => byte(r.offset() + 0x462037)

// $462038: (NTSC) (SMB2) Sprite IDs [9 bytes]
//          0x00 = Floating Heart
//          0x01 = Red Shy Guy
//          0x02 = Tweeter
//          0x03 = Blue Shy Guy
//          0x04 = Porcupo
//          0x05 = Red Sniffit
//          0x06 = Grey Sniffit
//          0x07 = Blue Sniffit
//          0x0d = Ninji Running
//          0x0e = Ninji Hopping
//          0x0f = Beezo
//          0x12 = Pidgit
//          0x17 = Phanto
//          0x1c = Birdo
//          0x1d = Mouser
//          0x1e = Birdo Egg
//          0x20 = Birdo Fireball
//          0x2e = Spark
//          0x32 = Plant
//          0x33 = Vegetable
//          0x35 = Red Shell
//          0x37 = Bomb
//          0x39 = Mushroom Block
//          0x3a = POW Block
//          0x3d = Key
//          0x3e = Potion
//          0x3f = Mushroom
//          0x40 = 1-Up Mushroom
//          0x41 = Carpet
//          0x42 = Hawkmouth R
//          0x43 = Hawkmouth L
//          0x44 = Crystal Orb
//          0x45 = Star
//          0x46 = Stopwatch
function sprite_id(r, i) => byte(r.offset() + 0x462038 + i)

// $462041: (NTSC) (SMB2) Player In Air [8 bit] (0/1)
function player_in_air(r) => byte(r.offset() + 0x462041)

// $462044: (NTSC) (SMB2) Player Holding Item [8 bit] (0/1)
//          cannot go through doors when 1
//          attached sprites from 0x462050 stay attached however
function player_holding_item(r) => byte(r.offset() + 0x462044)

// $462045: (NTSC) (SMB2) Player Facing Direction [8 bit] (0/1)
function player_facing_direction(r) => byte(r.offset() + 0x462045)

// $462050: (NTSC) (SMB2) Sprite is Held [9 bytes]
//          0 = not held
//          7 = starting lift
//          counts down to 1 and stops while overhead
function sprite_is_held(r, i) => byte(r.offset() + 0x462050 + i)

// $46209E: (NTSC) (SMB2) Controller Input [8 bit]
//          bit0 | right
//          bit1 | left
//          bit2 | down
//          bit3 | up
//          bit4 | start
//          bit5 | select?
//          bit6 | B
//          bit7 | A
function input(r, b) => bit(b, r.offset() + 0x46209E)

// $4623AD: (NTSC) (SMB2) World ID [8 bit]
//          0 = World 1
//          1 = World 2
//          ...
function world_id(r) => byte(r.offset() + 0x4623AD)

// $462410: (NTSC) (SMB2) Boss Health [8 bit]
//          Birdo: 2->0, 0xFF = dead
function boss_health(r) => byte(r.offset() + 0x462410)

// $462411: (NTSC) (SMB2) Boss Health [8 bit]
//          Wart: 6->0
function boss_health_2(r) => byte(r.offset() + 0x462411)

// $462456: (NTSC) (SMB2) In Stage Check [8 bit] (0/1)
function in_stage_check(r) => byte(r.offset() + 0x462456)

// $46245D: (NTSC) (SMB2) Hawkmouth State [8 bit]
//          0x00 = Unprimed
//          0x01 = Closed
//          0x02->0x2F = Opening
//          0x30 = Opened
function hawkmouth_state(r) => byte(r.offset() + 0x46245D)

// $46245F: (NTSC) (SMB2) Subspace Timer [8 bit]
//          96 on entering, count down every 4f, kicked out at 0
function subspace_timer(r) => byte(r.offset() + 0x46245F)

// $46246B: (NTSC) (SMB2) Current Health [8 bit]
//          0x0F = 1 heart
//          0x1F = 2 hearts
//          0x2F = 3 hearts
//          0x3F = 4 hearts
//          
//          could check bit3 for "alive" and 1+upper4 for hearts
function alive(r) => bit3(r.offset() + 0x46246B)
function current_health(r) => 1 + high4(r.offset() + 0x46246B)

// $46246C: (NTSC) (SMB2) Extra Heart Containers [8 bit]
//          this number +2 is the number of heart containers available
function heart_containers(r) => 2+byte(r.offset() + 0x46246C)

// $462472: (NTSC) (SMB2) Princess Hover Timer [8 bit]
//          0x3c on jump, counts down and hover runs out at 0
function princess_hover_timer(r) => byte(r.offset() + 0x462472)

// $462473: (NTSC) (SMB2) Super Jump Charge [8 bit]
//          0 = no charge
//          increases while crouched
//          60 = fully charged (locked)
function super_jump_charge(r) => byte(r.offset() + 0x462473)

// $462489: (NTSC) (SMB2) Star/Invincibility Timer [8 bit]
//          collecting star sets to 0x3f, counts down every 8f
function star_invincibility_timer(r) => byte(r.offset() + 0x462489)

// $462490: (NTSC) (SMB2) Stage ID [8 bit]
//          0x00 = 1-1
//          0x01 = 1-2
//          0x02 = 1-3
//          0x03 = 2-1
//          0x04 = 2-2
//          0x05 = 2-3
//          0x06 = 3-1
//          0x07 = 3-2
//          0x08 = 3-3
//          0x09 = 4-1
//          0x0a = 4-2
//          0x0b = 4-3
//          0x0c = 5-1
//          0x0d = 5-2
//          0x0e = 5-3
//          0x0f = 6-1
//          0x10 = 6-2
//          0x11 = 6-3
//          0x12 = 7-1
//          0x13 = 7-2
function stage_id(r) => byte(r.offset() + 0x462490)

// $462491: (NTSC) (SMB2) Level Checkpoint [8 bit]
function level_checkpoint(r) => byte(r.offset() + 0x462491)

// $462492: (NTSC) (SMB2) Level Sub-Checkpoint [8 bit]
//          lower value means higher on screen?
function level_subcheckpoint(r) => byte(r.offset() + 0x462492)

// $462493: (NTSC) (SMB2) Checkpoint Type [8 bit]
//          0 = Drop
//          1 = Door
//          3 = Vine
function checkpoint_type(r) => byte(r.offset() + 0x462493)

// $462496: (NTSC) (SMB2) Lives [8 bit]
function lives(r) => byte(r.offset() + 0x462496)

// $4624A4: (NTSC) (SMB2) Mushroom #1 Collected [8 bit] (0/1)
// $4624A5: (NTSC) (SMB2) Mushroom #2 Collected [8 bit] (0/1)
function mushroom_collected(r, i) => byte(r.offset() + 0x4624A4 + i-1)

// $4624A8: (NTSC) (SMB2) Stopwatch Timer [8 bit]
//          when picking up a stopwatch, goes from 0->255
//          counts down 1f until 0
function stopwatch_timer(r) => byte(r.offset() + 0x4624A8)

// $4624DC: (NTSC) (SMB2) Room ID [8 bit]
function room_id(r) => byte(r.offset() + 0x4624DC)

// $4625C8: (NTSC) (SMB2) 1-Up Collected [8 bit] (0/1)
function collected_1up(r) => byte(r.offset() + 0x4625C8)

// $4625C9: (NTSC) (SMB2) Completed Trips to Subspace [8 bit]
//          when this value is 2, coins no longer appear in subspace
function completed_trips_to_subspace(r) => byte(r.offset() + 0x4625C9)

// $4625D0: (NTSC) (SMB2) Room Type [8 bit]
//          0 = Normal Stage
//          1 = Jar
//          2 = Subspace
function room_type(r) => byte(r.offset() + 0x4625D0)

// $4625D3: (NTSC) (SMB2) Coins [8 bit]
function coins(r) => byte(r.offset() + 0x4625D3)

// $4625D5: (NTSC) (SMB2) Completed Level Count for Mario [8 bit]
// $4625D6: (NTSC) (SMB2) Completed Level Count for Princess [8 bit]
// $4625D7: (NTSC) (SMB2) Completed Level Count for Toad [8 bit]
// $4625D8: (NTSC) (SMB2) Completed Level Count for Luigi [8 bit]
function completed_level_count(r, char) => byte(r.offset() + 0x4625D5 + char)

// $4625DD: (NTSC) (SMB2) World Number [8 bit]
function world_number(r) => byte(r.offset() + 0x4625DD)

// $463D8E: (NTSC) (SMB2) Music ID [8 bit]
//          bit7 | Silence
//          
//          0x01 = Ground BGM
//          0x04 = Character Select
//          0x05 = Subspace BGM
//          0x06 = Underground BGM
//          0x07 = Final Boss BGM
//          0x08 = Boss BGM
//          0x09 = Bonus Chance - Lose
//          0x0b = Course Clear (after world boss)
//          0x0c = Bonus Chance
//          0x0d = Star Fanfare
//          0x10 = Victory Fanfare (after stage boss)
//          0x11 = Title Music
//          0x13 = Warp Music
function music_id(r) => byte(r.offset() + 0x463D8E)

// $481EA8: (NTSC) [8-Bit] Game ID
//          0x00 = Menus
//          0x02 = Super Mario Bros.
//          0x04 = Super Mario Bros.: The Lost Levels
//          0x06 = Super Mario Bros. 2
//          0x08 = Super Mario Bros. 3
function game_id(r) => byte(r.offset() + 0x481EA8)

// $483FB0: (NTSC) [8-Bit] Demo Screen - Game ID
//          0x00 = Super Mario Bros. 3
//          0x01 = Super Mario Bros.
//          0x02 = Super Mario Bros.: The Lost Levels
//          0x03 = Super Mario Bros. 2
function demo_screen_game_id(r) => byte(r.offset() + 0x483FB0)

// $483FB2: (UNTSCSA) [8-Bit] [Boolean] Demo Screen
function demo_screen(r) => byte(r.offset() + 0x483FB2)

// $003180: [4-Bytes ASCII] Serial Code
//          SVME = Super Mario All-Stars (USA)
//          SVMP = Super Mario All-Stars (Europe, Australia)
//          SVMJ = Super Mario Collection (Japan)
//          SVMK = Super Mario Collection (Korea)
class Region
{
	regionname = ""
	diskname = ""
	baseaddr = 0

	function is_region() => ascii_string_equals(0x3180, this.diskname)
	function offset() => this.baseaddr - 0x461FA8
}

REGIONS = [
	Region(regionname="NTSC",  diskname="SVME", baseaddr=0x461FA8),
	Region(regionname="Japan", diskname="SVMJ", baseaddr=0x460F68),
	Region(regionname="PAL",   diskname="SVMP", baseaddr=0x4620E8),
	Region(regionname="Korea", diskname="SVMK", baseaddr=0x4657A8),
]

// --- MAIN DATA -------------------------------------------------------------------

GAME_SMB2 = 0x06

function _level(w, s) => (w-1)*3 + (s-1)

LEVELS = {
	_level(1, 1): "1-1",
	_level(1, 2): "1-2",
	_level(1, 3): "1-3",
	_level(2, 1): "2-1",
	_level(2, 2): "2-2",
	_level(2, 3): "2-3",
	_level(3, 1): "3-1",
	_level(3, 2): "3-2",
	_level(3, 3): "3-3",
	_level(4, 1): "4-1",
	_level(4, 2): "4-2",
	_level(4, 3): "4-3",
	_level(5, 1): "5-1",
	_level(5, 2): "5-2",
	_level(5, 3): "5-3",
	_level(6, 1): "6-1",
	_level(6, 2): "6-2",
	_level(6, 3): "6-3",
	_level(7, 1): "7-1",
	_level(7, 2): "7-2",
}

CHAR_MARIO = 0
CHAR_PRINCESS = 1
CHAR_TOAD = 2
CHAR_LUIGI = 3

CHARS = {
	CHAR_MARIO: "Mario",
	CHAR_PRINCESS: "Princess",
	CHAR_TOAD: "Toad",
	CHAR_LUIGI: "Luigi",
}

INPUT_RIGHT = 0
INPUT_LEFT = 1
INPUT_DOWN = 2
INPUT_UP = 3
INPUT_START = 4
INPUT_SELECT = 5
INPUT_B = 6
INPUT_A = 7

MUSHROOM_COUNT = {
	_level(1, 1): 2,
	_level(1, 2): 2,
	_level(1, 3): 2,
	_level(2, 1): 1,
	_level(2, 2): 2,
	_level(2, 3): 2,
	_level(3, 1): 2,
	_level(3, 2): 2,
	_level(3, 3): 2,
	_level(4, 1): 2,
	_level(4, 2): 2,
	_level(4, 3): 2,
	_level(5, 1): 2,
	_level(5, 2): 2,
	_level(5, 3): 2,
	_level(6, 1): 2,
	_level(6, 2): 1,
	_level(6, 3): 2,
	_level(7, 1): 2,
	_level(7, 2): 2,
	_level(7, 3): 0, // i promise there is a reason for this
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game(r) => unless(!r.is_region()) && demo_screen(r) == 0 && game_id(r) == GAME_SMB2

function use_warp(stage) => any_of(REGIONS, r => (
	in_game(r) && in_stage_check(r) == 1 &&
	// going down pipe with warp music playing
	player_state(r) == 0x04 && music_id(r) == 0x13 &&
	// level changes to a later level during the transition
	prev(stage_id(r)) == stage && stage_id(r) > stage
))

function pull_up(r, item) => any_of(range(0,8), i => (
	sprite_id(r, i) == item && 
	// this is one frame before items like stopwatches are consumed, safe for other objects too
	prev(sprite_is_held(r, i)) == 3 && sprite_is_held(r, i) == 2
))

function boss_challenge(r, stage, checkpoint) => (
	in_game(r) && in_stage_check(r) == 1 &&
	// music updates while stage and checkpoint already set
	once(
		stage_id(r) == stage && level_checkpoint(r) == checkpoint && 
		prev(music_id(r)) != 0x08 && music_id(r) == 0x08
	) &&
	// win if the boss dead music plays
	trigger_when(prev(music_id(r)) != 0x0b && music_id(r) == 0x0b) &&
	// reset if the player dies
	never(alive(r) == 0) &&
	// reset if we leave the level
	never(stage_id(r) != stage) &&
	// reset if we leave the game
	never(game_id(r) != GAME_SMB2)
)

function player_x(r) => player_x_position_high_byte(r) * 0x100 + player_x_position_low_byte(r)
function player_y(r) => player_y_position_high_byte(r) * 0x100 + player_y_position_low_byte(r)
function sprite_x(r, i) => sprite_x_position_high_byte(r, i) * 0x100 + sprite_x_position_low_byte(r, i)
function sprite_y(r, i) => sprite_y_position_high_byte(r, i) * 0x100 + sprite_y_position_low_byte(r, i)

function boss_killed(stage) => any_of(REGIONS, r => (
	// might be worth adding a checkpoint check
	in_game(r) && stage_id(r) == stage &&
	prev(music_id(r)) == 0x08 && music_id(r) == 0x0b
))

function win_the_game(r) => stage_id(r) == _level(7, 2) && prev(music_id(r)) == 0x0b && music_id(r) == 0x80

function collect_all_mushrooms(r, w)
{
	mushrooms = []
	for s in range(1,3) for m in range(0,MUSHROOM_COUNT[_level(w, s)]) if (m != 0)
		array_push(mushrooms, stage_id(r) == _level(w, s) && is_set(mushroom_collected(r, m)))

	// no reset because you might choose to save+quit to restart the world
	return in_game(r) && measured(tally_of(mushrooms, length(mushrooms), x => once(x)))
}

// --- RICH PRESENCE -------------------------------------------------------------------

for r in REGIONS
{
	rich_presence_conditional_display(in_game(r),
		"[SMB2] {0} in {1} · ❤️ {2}/{3} · 🍄 {4} · 🪙 {5}",
		rich_presence_lookup("SMB2CHAR", character(r), CHARS, fallback="???"),
		rich_presence_lookup("SMB2LEVEL", stage_id(r), LEVELS, fallback="???"),
		rich_presence_number(current_health(r)),
		rich_presence_number(heart_containers(r)),
		rich_presence_number(lives(r)),
		rich_presence_number(coins(r))
	)
}

rich_presence_display(
	"Playing Super Mario All-Stars"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Bombchucker",
	description="Defeat Mouser at the end of World 1",
	points=5,
	trigger=boss_killed(_level(1, 3))
)

achievement(
	title="Three Heads Are Better than One",
	description="Defeat Triclyde at the end of World 2",
	points=5,
	trigger=boss_killed(_level(2, 3))
)

achievement(
	title="Sheriff Mouser",
	description="Defeat Mouser at the end of World 3",
	points=5,
	trigger=boss_killed(_level(3, 3))
)

achievement(
	title="Firefighter",
	description="Defeat Fryguy at the end of World 4",
	points=5,
	trigger=boss_killed(_level(4, 3))
)

achievement(
	title="Scatterbrain",
	description="Defeat Clawglip at the end of World 5",
	points=5,
	trigger=boss_killed(_level(5, 3))
)

achievement(
	title="A Precarious Perch",
	description="Defeat Triclyde at the end of World 6",
	points=5,
	trigger=boss_killed(_level(6, 3))
)

achievement(
	title="Wart and the Dream Machine",
	description="Defeat Wart and save Subcon",
	type="progression",
	points=25,
	trigger=any_of(REGIONS, r => in_game(r) && win_the_game(r))
)

achievement(
	title="The Hero",
	description="Complete the game using only Mario",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && trigger_when(win_the_game(r)) &&
		completed_level_count(r, CHAR_MARIO) > 0 &&
		completed_level_count(r, CHAR_LUIGI) == 0 &&
		completed_level_count(r, CHAR_PRINCESS) == 0 &&
		completed_level_count(r, CHAR_TOAD) == 0
	))
)

achievement(
	title="The Sidekick",
	description="Complete the game using only Luigi",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && trigger_when(win_the_game(r)) &&
		completed_level_count(r, CHAR_MARIO) == 0 &&
		completed_level_count(r, CHAR_LUIGI) > 0 &&
		completed_level_count(r, CHAR_PRINCESS) == 0 &&
		completed_level_count(r, CHAR_TOAD) == 0
	))
)

achievement(
	title="The Sovereign",
	description="Complete the game using only Princess",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && trigger_when(win_the_game(r)) &&
		completed_level_count(r, CHAR_MARIO) == 0 &&
		completed_level_count(r, CHAR_LUIGI) == 0 &&
		completed_level_count(r, CHAR_PRINCESS) > 0 &&
		completed_level_count(r, CHAR_TOAD) == 0
	))
)

achievement(
	title="The Retainer",
	description="Complete the game using only Toad",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && trigger_when(win_the_game(r)) &&
		completed_level_count(r, CHAR_MARIO) == 0 &&
		completed_level_count(r, CHAR_LUIGI) == 0 &&
		completed_level_count(r, CHAR_PRINCESS) == 0 &&
		completed_level_count(r, CHAR_TOAD) > 0
	))
)

achievement(
	title="Mushrooms in the Plains",
	description="In one session, collect all mushrooms in World 1",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 1))
)

achievement(
	title="Mushrooms in the Desert",
	description="In one session, collect all mushrooms in World 2",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 2))
)

achievement(
	title="Mushrooms Under the Falls",
	description="In one session, collect all mushrooms in World 3",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 3))
)

achievement(
	title="Mushrooms in the Snow",
	description="In one session, collect all mushrooms in World 4",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 4))
)

achievement(
	title="Mushrooms in the Forest",
	description="In one session, collect all mushrooms in World 5",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 5))
)

achievement(
	title="Mushrooms in the Gorge",
	description="In one session, collect all mushrooms in World 6",
	points=5,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 6))
)

achievement(
	title="Mushrooms in the Skies",
	description="In one session, collect all mushrooms in World 7",
	points=3,
	trigger=any_of(REGIONS, r => collect_all_mushrooms(r, 7))
)

achievement(
	title="A Secret Beyond the Tower",
	description="Take a secret warp pipe in 1-3",
	points=3,
	trigger=use_warp(_level(1, 3))
)

achievement(
	title="A Secret Behind the Waterfall",
	description="Take a secret warp pipe in 3-1",
	points=3,
	trigger=use_warp(_level(3, 1))
)

achievement(
	title="A Secret Amongst the Whales",
	description="Take a secret warp pipe in 4-2",
	points=3,
	trigger=use_warp(_level(4, 2))
)

achievement(
	title="A Secret in the Forest",
	description="Take a secret warp pipe in 5-3",
	points=3,
	trigger=use_warp(_level(5, 3))
)

achievement(
	title="An Idyllic Life in the Plains",
	description="Find a hidden 1-Up mushroom in 1-1",
	points=2,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		stage_id(r) == _level(1, 1) && is_set(collected_1up(r))
	))
)

achievement(
	title="Life with the Ninji Clan",
	description="Find a hidden 1-Up mushroom in 1-2",
	points=2,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		stage_id(r) == _level(1, 2) && is_set(collected_1up(r))
	))
)

achievement(
	title="Cave Dwelling with the Hunter-Gatherers",
	description="Find a hidden 1-Up mushroom in 2-2",
	points=2,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		stage_id(r) == _level(2, 2) && is_set(collected_1up(r))
	))
)

achievement(
	title="A Picturesque Waterfall Come to Life",
	description="Find a hidden 1-Up mushroom in 5-1",
	points=2,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		stage_id(r) == _level(5, 1) && is_set(collected_1up(r))
	))
)

achievement(
	title="Pottery Storage in the Desert",
	description="Find a hidden 1-Up mushroom in 6-1",
	points=2,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		stage_id(r) == _level(6, 1) && is_set(collected_1up(r))
	))
)

achievement(
	title="Subspace Emissary",
	description="Enter subspace",
	points=1,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		prev(room_type(r)) == 0 && room_type(r) == 2
	))
)

achievement(
	title="Field of Dreams",
	description="Pull up a plant in subspace",
	points=3,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		room_type(r) == 2 &&
		// completed_trips_to_subspace(r) >= 2 &&
		pull_up(r, 0x32)
	))
)

achievement(
	title="Union-Mandated Break Time",
	description="Pull up a stopwatch and freeze time",
	points=3,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		pull_up(r, 0x46)
	))
)

achievement(
	title="A Fistful of Dollars",
	description="Reach a Bonus Chance with 20 or more coins in reserve",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && coins(r) >= 20 &&
		prev(music_id(r)) != 0x0c && music_id(r) == 0x0c
	))
)

achievement(
	title="One-Armed Sniffit",
	description="Match three symbols in the Bonus Chance game",
	points=5,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 0 &&
		slot_1_status(r) == 0 &&
		slot_2_status(r) == 0 &&
		slot_3_status(r) == 0 && prev(slot_3_status(r)) == 1 &&
		slot_1_result(r) == slot_2_result(r) &&
		slot_1_result(r) == slot_3_result(r)
	))
)

achievement(
	title="Starstruck",
	description="Defeat any Birdo with star power active",
	points=5,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		// star is active
		star_invincibility_timer(r) > 0 &&
		// for all sprite slots
		any_of(range(0,8), i => (
			// sprite is birdo
			sprite_id(r, i) == 0x1c &&
			// sprite is falling from screen (state 2)
			prev(sprite_state(r, i)) == 1 && sprite_state(r, i) == 2
		))
	))
)

achievement(
	title="Shooting from Half Court",
	description="Defeat Triclyde in 2-3 in one throw",
	points=5,
	trigger=any_of(REGIONS, r => (
		boss_challenge(r, _level(2, 3), checkpoint=6) &&
		// for all sprite slots
		never(tally_of(range(0,8), 2, i => (
			// the object is no longer held
			prev(sprite_is_held(r, i)) == 1 && sprite_is_held(r, i) == 0 &&
			// and not because it changed state
			sprite_state(r, i) == prev(sprite_state(r, i))
		))) &&
		// ensure we don't come in with some hits on our first visit to the boss room
		never(prev(level_checkpoint(r)) != level_checkpoint(r))
	))
)

achievement(
	title="An Albatoss Around My Neck",
	description="Complete the second room of 6-2 without ever riding a right-moving enemy",
	points=10,
	trigger=any_of(REGIONS, r => (
		in_game(r) && in_stage_check(r) == 1 &&
		// checkpoint at the start of the room
		once(stage_id(r) == _level(6, 2) && room_id(r) == 1 && player_x(r) < 0x50) &&
		// for all sprite slots
		all_of(range(0,8), i => never(
			// sprite is moving right
			sprite_x_speed(r, i) < 0x80 &&
			// standing on the sprite
			sprite_stood_on(r, i) == 1 &&
			// sprite is in its main state
			sprite_state(r, i) == 1
		)) &&
		// reset if the player dies or leaves the level/room
		never(alive(r) == 0) && never(stage_id(r) != _level(6, 2)) && never(room_id(r) != 1) &&
		// trigger on the other side of the gap
		trigger_when(player_x(r) > 0x0940)
	))
)

achievement(
	title="Waste Not, Want Not",
	description="Defeat Triclyde in 6-3 without losing any mushroom blocks down the pit",
	points=5,
	trigger=any_of(REGIONS, r => (
		boss_challenge(r, _level(6, 3), checkpoint=6) &&
		// for all sprite slots
		all_of(range(0,8), i => never(
			// reset if the sprite is a mushroom block, low enough on screen, and it must exist
			sprite_id(r, i) == 0x39 && sprite_y(r, i) > 0x00c4 && sprite_state(r, i) != 0
		))
	))
)

// --- LEADERBOARDS -------------------------------------------------------------------