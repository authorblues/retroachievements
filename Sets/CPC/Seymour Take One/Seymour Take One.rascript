// ~Demo~ Seymour: Take One!
// #ID = 41279

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

// --- MEMORY -------------------------------------------------------------------

// $0604: Train Status at Recording Start [8 bit]
//        copied from 0x40c4 when activating camera
function train_status_at_recording_start() => byte(0x0604)

// $0627: Read Script at Recording Start [8 bit]
//        copied from 0x4100 when activating camera
//        correct, but not the actual distinguishing value
function read_script_at_recording_start() => byte(0x0627)

// $0638: Faye State at Recording Start [8 bit]
//        copied from 0x4119 when activating camera
function faye_state_at_recording_start() => byte(0x0638)

// $0646: Movie Recording Starts Here [594 bytes minimum]
//        each entry is variable size
//        
//        +0 | Entry type
//            1 = Seymour location entry (6 byte entry)
//                +1 | Seymour X position [8 bit]
//                +2 | Seymour Y position [8 bit]
//                +5 | Seymour current screen [8 bit]
//            2 = Dialogue entry (2 byte entry)
//                +1 | Which message? [8 bit]
//                    0x42 = Seymour! What are you doing?
//                    0x43 = Stay still, Fay, while I tie you to this railway!
//                    0x44 = Oops! Guess who tied the ropes too tight!
//                    0x45 = Fear not, Fay! I'll soon cut you free!
//                    0x46 = Fear not, Kathy! I'll soon cut you free!
//                    0x47 = Dex, my hero!
//                    0x48 = Hi there!
//                    0x49 = Hello, Seymour!
RECORDING_HEADER = 0x0600
RECORDING_DATA = 0x0646

// $3563: Movie Result Message [8 bit]
//        0x32 = If undeveloped film's exposed to light, then you don't get a result!
//        0x33 = The film's supposed to start with the train moving!
//        0x34 = The film's supposed to start with the heroine tied to the railway track
//        0x35 = (unused?) (pertains to not rescuing the girl)
//        0x36 = In the film, the heroine isn't called Fay! (Read the script next time!)
//        0x37 = (unused?) (pertains to not leaping out of the way of the train)
//        0x38 = The hero's not supposed to die during the big rescue scene!
//        0x39 = Really, Seymour, why were you carrying the script around during a take?
//        0x3a = Really, Seymour, why was the script in the shot?
//        0x3b = Bravo! You captured the whole scene! This means you make it as an international Megastar!
function movie_result_message() => byte(0x3563)

// $356D: Y Position [8 bit]
//        screen top is ~0x48
//        screen btm is ~0xb4
function y_position() => byte(0x356D)

// $356E: X Position [8 bit]
//        screen left is ~0x02
//        screen right is ~0x38
function x_position() => byte(0x356E)

// $3572: Seymour State [8 bit]
//        0 = Walking Left
//        1 = Idle
//        2 = Walking Right
//        4 = Jumping Left
//        5 = Jumping Up
//        6 = Jumping Right
//        8 = Falling
function seymour_state() => byte(0x3572)

// $3575: Room [8 bit]
//        0x00 = Title Screen
//        0x01 = Well Done!
//        0x0a = The "U" Shaped Room
//        0x0b = Highpoint
//        0x0c = A Room With No View
//        0x0d = Play It Again, Sam
//        0x14 = Working Girl
//        0x15 = Terminate-Her
//        0x16 = Fatal Attraction
//        0x17 = Stakeout
function room() => byte(0x3575)

// $3576: Inventory Slot #1 [16 bit]
//        0x40c8 = A Fresh Reel of Film
//        0x40d4 = A Used Reel of Film
//        0x40e0 = A Developed Reel of Film
//        0x40ec = A Sharp Knife
//        0x4104 = A Long Rope
function inventory(i) => word(0x3576 + 2*i)

// $357E: Score [8 bit]
function score() => byte(0x357E)

// $357F: Controls [8 bit] (1 = off, 0 = on)
//        bit0 | Right
//        bit1 | Left
//        bit2 | Down
//        bit3 | Up
//        bit4 | Fire
function controls() => byte(0x357F)

// $35C2: Lives [8 bit]
//        start at 3, game over at 0
function lives() => byte(0x35C2)

// $35C4: Health [8 bit]
//        starts at 20, dead at 0
function health() => byte(0x35C4)

// $35C7: Demo Control [8 bit]
//        0 = player control
//        1 = demo control
//        2 = ending
//        
//        seems reliable for demo/title vs gameplay
function game_state() => byte(0x35C7)

// $3723: Film Overexposed [8 bit]
//        0xFF = darkroom lights on (film ruined)
//        0x00 = darkroom lights off
function film_overexposed() => byte(0x3723)

// $40C2: Train Position [8 bit]
//        train hits Faye at 0x79
function train_position() => byte(0x40C2)

// $40C3: Train Timer [8 bit] (frames)
//        starts at 100f when lever is pulled
//        0x40c4 becomes 2 when timer reaches 0
function train_timer() => byte(0x40C3)

// $40C4: Train Active [8 bit]
//        0 = initial state
//        1 = train counting down
//        2 = train running
function train_active() => byte(0x40C4)

// $4100: Read Script from Pippa [8 bit]
//        0x00 = not read ("Fay")
//        0x01 = read script ("Kathy")
function read_script_from_pippa() => byte(0x4100)

// $4119: Faye State [8 bit]
//        0x16 = initial state
//        0xFF = tied to tracks
function faye_state() => byte(0x4119)

// $413C: Darkroom State [8 bit]
//        0x00 = lights on
//        0xFF = lights off
function darkroom_state() => byte(0x413C)

// $4178: Talked to Pippa [8 bit]
//        0 = initial state
//        1 = asked what's wrong
function talked_to_pippa() => byte(0x4178)

// $418E: Camera Timer [8 bit]
//        when 0x4190 changes 1->2, set to 100
//        counts down every 4f
//        stops at 1 and sets 0x4190 to 3
function camera_timer() => byte(0x418E)

// $4190: Camera State [8 bit]
//        0 = initial state
//        1 = loaded film
//        2 = recording in progress
//        3 = recording complete
//        4 = removed film
function camera_state() => byte(0x4190)

// $67B2: Pointer to Current Frame of Movie [16 bit]
//        works during recording and playback
//        
//        intial state is 0x600 (start of movie header)
//        during recording (0x4190 goes 1->2):
//        starts at 0x646 and moves to each new entry
//        when playback is about to start in projector room:
//        value is set to 0x646 and moves to each entry
function recording_frame() => word(0x67B2)

// --- MAIN DATA -------------------------------------------------------------------

ROOM_TITLES = {
	0x00: "Title Screen",
	0x01: "Well Done!",
	0x0a: "The \"U\" Shaped Room",
	0x0b: "Highpoint",
	0x0c: "A Room With No View",
	0x0d: "Play It Again, Sam",
	0x14: "Working Girl",
	0x15: "Terminate-Her",
	0x16: "Fatal Attraction",
	0x17: "Stakeout",
}

ROOM_DESC = { // following "Seymour is..."
	0x00: "on the title screen",
	0x01: "celebrating making a successful movie",
	0x0a: "at the top of the studio elevator",
	0x0b: "looking out over the studio set",
	0x0c: "in the darkroom",
	0x0d: "in the projector room",
	0x14: "at the front desk of the studio offices",
	0x15: "at the back door of the studio offices",
	0x16: "on set, recording the big runaway train scene",
	0x17: "behind the scenes on the set",
}

ITEM_NAMES = {
	0x40c8: "film",
	0x40d4: "film",
	0x40e0: "film",
	0x40ec: "a knife",
	0x40f8: "a script",
	0x4104: "rope",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => game_state() == 0
function new_game() => prev(game_state()) == 1 && in_game()

function win_the_game() => (
	prev(game_state()) == 0 && game_state() == 2 &&
	prev(room()) == 0x16 && room() == 0x01
)

function movie_result(x) => (
	game_state() == 0 &&
	room() == 0x16 && // the film overwrites the room
	prior(room()) == 0x0d && // actually in the projector room
	prev(movie_result_message()) == 0x5d &&
	movie_result_message() == x
)

// --- RICH PRESENCE -------------------------------------------------------------------

rp_location = rich_presence_lookup("ROOM", room(), ROOM_DESC, fallback="at the studio")
rp_room_name = rich_presence_lookup("ROOMNAME", room(), ROOM_TITLES, fallback="Fatal Attraction")
rp_score = rich_presence_value("SCORE", score(), "SCORE")

function rp_item(i) => rich_presence_lookup("ITEM", inventory(i), ITEM_NAMES, fallback="")

rich_presence_conditional_display(game_state() == 1 || room() == 0x00,
	"Seymour is on the title screen"
)

rich_presence_conditional_display(game_state() <= 2 && all_of(range(0,2), i => inventory(i) == 0),
	"Seymour is {0}, holding nothing · {2} · Score: {1}",
	rp_location, rp_score, rp_room_name
)

rich_presence_conditional_display(game_state() <= 2,
	"Seymour is {0}, holding {3}{4}{5}{6}{7} · {2} · Score: {1}",
	rp_location, rp_score, rp_room_name,
	rp_item(0),
	rich_presence_flag(", ", inventory(0) != 0 && inventory(1) != 0, lookupname="COMMA"),
	rp_item(1),
	rich_presence_flag(", ", (inventory(0) != 0 || inventory(1) != 0) && inventory(2) != 0, lookupname="COMMA"),
	rp_item(2)
)

rich_presence_display(
	"Seymour: Take One!"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Over-Exposed (1956)",
	description="If undeveloped film's exposed to light, then you don't get a result!",
	points=2,
	trigger=movie_result(0x32)
)

achievement(
	title="The Interrupted Journey (1949)",
	description="The film's supposed to start with the train moving!",
	points=2,
	trigger=movie_result(0x33)
)

achievement(
	title="Safe in Hell (1931)",
	description="The film's supposed to start with the heroine tied to the railway track",
	points=2,
	trigger=movie_result(0x34)
)

achievement(
	title="The Absent-Minded Professor (1961)",
	description="In the film, the heroine isn't called Fay! Read the script next time!",
	points=2,
	trigger=movie_result(0x36)
)

achievement(
	title="The Big Sleep (1946)",
	description="The hero's not supposed to die during the big rescue scene!",
	points=2,
	trigger=movie_result(0x38)
)

achievement(
	title="The Stooge (1952)",
	description="Really, Seymour, why were you carrying the script around during a take?",
	points=2,
	trigger=movie_result(0x39)
)

achievement(
	title="The Uninvited (1944)",
	description="Really, Seymour, why was the script in the shot?",
	points=2,
	trigger=movie_result(0x3a)
)

achievement(
	title="The Greatest Show on Earth (1952)",
	description="Bravo! You captured the whole scene! This means you make it as an international Megastar!",
	type="win_condition",
	points=10,
	trigger=win_the_game()
)

// --- LEADERBOARDS -------------------------------------------------------------------
