// ~Unlicensed~ Hyper Sports 2
// #ID = 24545
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0000: Game State [8 bit]
//        0 = Loading Title
//        1 = Title
//        2 = Demo
//        3 = Start Game Fanfare
//        4 = Starting New
//        5 = Setup Attempt
//        6 = Attempt
//        7 = Post-Attempt
//        8 = Game Over (9->8)
//        9 = Loading Postgame
//        10 = Podium (9->10)
function game_state() => byte(0x0000)

// $0001: Game Sub State [8 bit]
function game_sub_state() => byte(0x0001)

// $0053: World Record - Weight Lifting [24 bit BCD]
// $0056: World Record - Archery [24 bit BCD]
// $0059: World Record - Skeet Shooting [24 bit BCD]
function world_record_weight_lifting() => bcd(tbyte(0x0053))
function world_record_archery() => bcd(tbyte(0x0056))
function world_record_skeet_shooting() => bcd(tbyte(0x0059))
function world_record_by_event(i) => bcd(tbyte(0x0059 - 3*i))

// $0060: High Score [24 bit BCD]
function high_score() => bcd(tbyte(0x0060))

// $0063: Player Score [24 bit BCD]
function player_score() => bcd(tbyte(0x0063))

// $0072: Current Try [8 bit]
//        2 = 1st Try
//        1 = 2nd Try
//        0 = 3rd Try
function current_try() => 3 - byte(0x0072)

// $0080: Current Round [8 bit] (mask & 0x03)
//        0 = Skeet Shooting
//        1 = Archery
//        2 = Weight Lifting
//        3 = Podium
//        continues counting up through events, can use to detect later loops
function current_round() => byte(0x0080)
function current_loop() => 1 + byte(0x0080) / 4
function event_type() => byte(0x0080) & 0x03

// $0084: Qualify Score [24 bit BCD]
function qualify_score() => bcd(tbyte(0x0084))

// $0087: Current Round Score [24 bit BCD]
function current_round_score() => bcd(tbyte(0x0087))

// $0090: Best Try Score [24 bit BCD]
function _best_try_score_raw() => tbyte(0x0090)
function best_try_score() => bcd(_best_try_score_raw())

// $0096: 3rd Try Score [24 bit BCD]
// $0099: 2nd Try Score [24 bit BCD]
// $009C: 1st Try Score [24 bit BCD]
//        in weight lifting, 0xF2 in the upper byte corresponds to `kg`
function try_score() => bcd(tbyte(0x0096 + (3 - i) * 3))

// $0105: (Weight) Player Animation [8 bit]
//        0x00 = weight down
//        0x01-0x15 = initial pre-clean lift
//        0x16 = holding ready for turnover
//        0x17-0x1c = lift post-turnover
//        0x1d = drop barbell
//        0x1e = part of both endings
//        0x1f = victory celebration (alternates with 0x1e)
//        0x20 = failure (alternates with 0x1e)
function weight_player_animation() => byte(0x0105)

// $0111: (Archery) Arrows Remaining [8 bit]
function archery_arrows_remaining() => byte(0x0111)

// $0113: (Archery) Angle [16 bit BCD]
function archery_angle_sec() => bcd(byte(0x0113))
function archery_angle_deg() => bcd(byte(0x0114))

// $011D: (Archery) Last Shot Score [24 bit BCD]
function archery_last_shot() => bcd(tbyte(0x011D))

// $0123: (Weight) Judge Lights [8 bit] (0-3)
function weight_judge_lights() => byte(0x0123)

// $0124: (Weight) Weight Selected [16 bit BCD]
//        0x0150 = Fly Weight
//        0x0165 = Bantam Weight
//        0x0180 = Feather Weight
//        0x0195 = Light Weight
//        0x0210 = Middle Weight
//        0x0225 = Middle Heavy
//        0x0240 = Heavy Weight
//        0x0260 = Super Heavy
function weight_selected() => bcd(word(0x0124))

// $0132: (Weight) Inputs After Lights
//        counts inputs after 3 lights ($0123 = 3)
//        only inputs that count are dpad right and button 2
function weight_post_inputs() => byte(0x0132)

// $0133: (Weight) Flower Bonus State
//        bonus earned when 5 inputs post-lights ($0132 = 5, $0138 = 1->2)
//        0x00 = no bonus
//        0x91 = bonus + flowers
function weight_flower_bonus_state() => byte(0x0133)

// $0138: (Weight) Barbell State
//        0 = Lifting
//        1 = Dropped/Falling
//        2 = Hit Ground
function weight_barbell_state() => byte(0x0138)

// $0145: (Archery) Bullseyes Needed for Bonus [8 bit]
//        only seems to track the final 3 arrows in a round
//        to track general bullseyes, look for 600 score
function archery_bullseyes_needed() => byte(0x0145)

// $01A5: (Weight/Shooting) Time Remaining - Subseconds [8 bit BCD]
// $01A6: (Weight/Shooting) Time Remaining - Seconds [8 bit BCD]
function time_remaining_sub() => bcd(byte(0x01A5))
function time_remaining_sec() => bcd(byte(0x01A6))

// $0202: (Archery) Wind Direction [8 bit]
//        low4 is wind speed, bit7 is direction (1 = up, 0 = down)
function archery_wind_direction() => bit7(0x0202)
function archery_wind_strength() => low4(0x0202)

// --- MAIN DATA -------------------------------------------------------------------

EVENT_SHOOTING = 0
EVENT_ARCHERY = 1
EVENT_WEIGHTS = 2
EVENT_PODIUM = 3

EVENT_NAMES = {
	EVENT_SHOOTING: "Skeet Shooting",
	EVENT_ARCHERY: "Archery",
	EVENT_WEIGHTS: "Weight Lifting",
}

EVENT_ICON = {
	EVENT_SHOOTING: "🔫",
	EVENT_ARCHERY: "🎯",
	EVENT_WEIGHTS: "🏋️",
}

ALL_EVENTS = [EVENT_SHOOTING, EVENT_ARCHERY, EVENT_WEIGHTS]

TEXT_TRY = {
	1: "1st Try",
	2: "2nd Try",
	3: "3rd Try",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function watching_demo() => game_state() == 2
function title_screen() => game_state() <= 3 && game_state() != 2
function in_game() => game_state() > 3

function finish_loop(loop) => in_game() && prev(current_round()) < loop*4 && current_round() == loop*4

function improve_record(event) => (
	in_game() && event_type() == event && 
	world_record_by_event(event) > prev(world_record_by_event(event))
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(title_screen(),
	"Title Screen"
)

rich_presence_conditional_display(event_type() == EVENT_PODIUM,
	"On the Podium"
)

for event in ALL_EVENTS
{
	rich_presence_conditional_display(event_type() == event && current_try() > 1,
		"{2}{1} {0} (Loop {3}) · {4} · Qualify: {7}/{6} {8} · Score: {5}",
		EVENT_NAMES[event],
		EVENT_ICON[event],
		rich_presence_lookup("DEMOTEXT", game_state(), {2: "[DEMO] "}, fallback=""),
		rich_presence_number(current_loop()),
		rich_presence_lookup("TRYTEXT", current_try(), TEXT_TRY, fallback="1st Try"),
		rich_presence_value("SCORE", player_score(), "SCORE"),
		rich_presence_number(qualify_score()),
		rich_presence_number(best_try_score()),
		rich_presence_lookup("QUALIFYICON", max_of(measured(1, when=best_try_score() >= qualify_score()), measured(0)), {1: "⭕"}, "❌")
	)

	rich_presence_conditional_display(event_type() == event,
		"{2}{1} {0} (Loop {3}) · {4} · Qualify: {6} · Score: {5}",
		EVENT_NAMES[event],
		EVENT_ICON[event],
		rich_presence_lookup("DEMOTEXT", game_state(), {2: "[DEMO] "}, fallback=""),
		rich_presence_number(current_loop()),
		rich_presence_lookup("TRYTEXT", current_try(), TEXT_TRY, fallback="1st Try"),
		rich_presence_value("SCORE", player_score(), "SCORE"),
		rich_presence_number(qualify_score()),
		rich_presence_number(best_try_score()),
		rich_presence_lookup("QUALIFYICON", max_of(measured(1, when=best_try_score() >= qualify_score()), measured(0)), {1: "⭕"}, "❌")
	)
}

rich_presence_display(
	"Playing Hyper Sports 2"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Ready for the Big Leagues",
	description="Complete one loop of all events",
	type="progression",
	points=5,
	trigger=finish_loop(1)
)

achievement(
	title="On the World Stage",
	description="Complete three loops of all events",
	type="win_condition",
	points=25,
	trigger=finish_loop(3)
)

achievement(
	title="Mastering the Over & Under",
	description="Improve the Skeet Shooting world record",
	points=10,
	trigger=improve_record(EVENT_SHOOTING)
)

achievement(
	title="Tae Kwon Bow",
	description="Improve the Archery world record",
	points=10,
	trigger=improve_record(EVENT_ARCHERY)
)

achievement(
	title="Getting a PhD in Bro Science",
	description="Improve the Weight Lifting world record",
	points=10,
	trigger=improve_record(EVENT_WEIGHTS)
)

achievement(
	title="Duck Hunt",
	description="Earn 9000+ points in a single attempt of Skeet Shooting",
	points=25,
	trigger=(
		in_game() && event_type() == EVENT_SHOOTING &&
		prev(current_round_score()) < 9000 &&
		current_round_score() >= 9000
	)
)

achievement(
	title="Burn a Hole in the Yellow",
	description="Get a perfect bullseye in Archery",
	points=5,
	trigger=(
		in_game() && event_type() == EVENT_ARCHERY &&
		prev(archery_last_shot()) != 600 && archery_last_shot() == 600
	)
)

achievement(
	title="Penta-thalon",
	description="Shoot an apple in the Archery bonus round",
	points=25,
	trigger=(
		in_game() && event_type() == EVENT_ARCHERY &&
		archery_bullseyes_needed() == 0 &&
		prev(archery_last_shot()) != 3000 && archery_last_shot() == 3000
	)
)

achievement(
	title="Spring Awakening",
	description="Earn a bonus and flowers in Weight Lifting",
	points=5,
	trigger=(
		in_game() && event_type() == EVENT_WEIGHTS &&
		weight_judge_lights() == 3 &&
		weight_post_inputs() == 5 &&
		prev(weight_flower_bonus_state()) == 0 &&
		weight_flower_bonus_state() == 0x91
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

for event in ALL_EVENTS
{
	leaderboard(
		title=format("{0} World Record", EVENT_NAMES[event]),
		description=format("Highest single attempt on {0}", EVENT_NAMES[event]),

		start=(
			// in the correct event
			in_game() && event_type() == event && 
			// best try score is not defaulted
			_best_try_score_raw() != 0xFFFFFF &&
			// the best try score just changed
			best_try_score() != prev(best_try_score()) &&
			// did the best try score improve?
			__ornext(
				// either this is the first score set
				prev(_best_try_score_raw()) == 0xFFFFFF ||
				// or this is an improvement over the previous best try score
				best_try_score() > prev(best_try_score())
			)
		),
		cancel=always_false(),
		submit=always_true(),

		value=measured(best_try_score()),
		format="VALUE",
		lower_is_better=false
	)
}