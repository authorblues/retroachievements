// Nemesis 2 | Gradius 2
// #ID = 10498

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $FC48: Address of beginning of available RAM area [16 bit]
//        MSX mode = 0x8000
//        MSX2 mode = 0xFFFF
//        check bit0 for address shifting by $C000
function addr_offset() => ~bit0(0x00FC48) * 0x00C000

// $21C0: Game State [8 bit]
//        0 = Konami Presents
//        1 = Title Screen
//        2 = Story / Demo
//        3 = New Game / Cutscene
//        4 = Loading Stage
//        5 = Playing
//        6 = Death (lasts for 1 frame, transitions back to 4 or 7)
//        7 = Continue Screen
//        10 = In Game Cutscene
function game_state() => byte(addr_offset() + 0x0021C0)

// $21C2: Game Status [8 bit]
//        bit5 | is two player?
//        bit6 | game active
//        bit7 | is player 2 active?
function player_count() => bit5(addr_offset() + 0x0021C2) + 1
function game_active() => bit6(addr_offset() + 0x0021C2)
function player_turn() => bit7(addr_offset() + 0x0021C2) + 1

// $21F5: P2 Score [40 bit BCD]
// $21FA: P1 Score [40 bit BCD]
P1_SCORE = addr_offset() + 0x0021FA
P2_SCORE = addr_offset() + 0x0021F5

// $2200: Lives - Current Player [8 bit]
function lives() => byte(addr_offset() + 0x002200)

// $2201: Map [8 bit]
//        0 = Venom's Ship
//        1 = Collosus Planet
//        2 = Plant Planet
//        3 = Ancient Planet
//        4 = Floating Continent
//        5 = Planet of Fire
//        6 = Life Planet
//        7 = Fortress Planet
//        8 = Core Invade
//        9 = Hidden Stage #1 (from 3)
//        10 = Hidden Stage #2 (from 6)
//        11 = Hidden Stage #3 (from 10)
function map() => byte(addr_offset() + 0x002201)

// $2202: Progress "Timer" [8 bit]
//        counts by bits -- 0x01, 0x02, 0x04, 0x08
//        roll over from 0x80 -> 0x01 increments 0x2203
function progress_timer() => byte(addr_offset() + 0x002202)

// $2203: Stage Progress [16 bit]
//        notable locations listed below
//        
//        Core Invasion absorb - 0x009f
//        Stage 7 Boss end - 0x02ff
//        Venom's Ship core (final boss) - 0x01bf
//        Clear Hidden Stage #3 - 0x015e
function stage_progress() => word(addr_offset() + 0x002203)

// $2206: Stage [8 bit]
//        01 = Collosus Planet outbound
//        02 = Plant Planet outbound
//        03 = Ancient Planet outbound
//        04 = Floating Continent outbound
//        05 = Planet of Fire outbound
//        06 = Life Planet outbound
//        07 = Fortress Planet
//        08 = Life Planet inbound
//        09 = Planet of Fire inbound
//        10 = Floating Continent inbound
//        11 = Ancient Planet inbound
//        12 = Plant Planet inbound
//        13 = Collosus Planet inbound
//        14 = Venom's Ship
function stage() => byte(addr_offset() + 0x002206)

// $220A: Route Direction [8 bit]
//        0 = outbound
//        1 = inbound
function direction() => byte(addr_offset() + 0x00220A)

// $220F: Unlocked Powerups [8 bit]
//        0 = default powerups
//        1 = unlocked up laser
//        2 = unlocked down laser
//        3 = unlocked napalm missile
//        4 = unlocked reflex ring
//        5 = unlocked extend laser
//        6 = unlocked back beam
//        7 = unlocked fire blaster
function unlocked_powerups() => byte(addr_offset() + 0x00220F)

// $2330: Selected Powerup [8 bit]
function selected_powerup() => byte(addr_offset() + 0x002330)

// $2331: Upgrades Table Tail [8 bit]
//        0x07 = intial upgrade table (6 elements)
//        0x08 = add up laser #1
//        0x09 = add down laser #1
//        0x0a = add back beam
function upgrades_table_tail() => byte(addr_offset() + 0x002331)

// $2334: Powerup Bar [9 bytes]
//        contents of powerup bar depend on 0x00220f
//        values shift to make room for newly unlocked powerups
//        
//        - Speed
//        - Missile
//        - Back Beam (if 6+)
//        - Double
//        - Up Laser (if 1+)
//        - Down Laser (if 2+)
//        - Laser
//        - Option
//        - Force Field
function powerup_bar(i) => byte(addr_offset() + 0x002334 + i)

// $2357: Bonus Chain [8 bit]
//        0 = no bonus collected
//        1 = 100 points
//        ...
//        7 = 10000 points
function bonus_chain() => byte(addr_offset() + 0x002357)

// $2401: Force Field Health [8 bit]
//        new force field has 10 health
function force_field_health() => byte(addr_offset() + 0x002401)

// $2402: Speed [8 bit] (0-7)
function speed() => byte(addr_offset() + 0x002402)

// $240B: Option Count [8 bit] (0-2)
function option_count() => byte(addr_offset() + 0x00240B)

// $2430: Standard Shot Limit [8 bit]
//        0 = no standard bullets fired
//        1 = one bullet allowed on screen
//        2 = two bullets allowed on screen (default)
function standard_shot_limit() => byte(addr_offset() + 0x002430)

// $2431: Double Shot Active [8 bit] (0/1)
function double_shot_active() => byte(addr_offset() + 0x002431)

// $2432: Special Shot [8 bit]
//        0 = none
//        1 = laser #1
//        2 = laser #2
//        3 = double laser
//        4 = reflex ring
//        5 = napalm missile
//        6 = fire blaster
function special_shot() => byte(addr_offset() + 0x002432)

// $2433: Missile Level [8 bit]
//        0 = no missle
//        1 = missile #1
//        2 = missile #2
//        3 = napalm missile
function missile_level() => byte(addr_offset() + 0x002433)

// $2434: Up Laser [8 bit] (0-2)
function up_laser() => byte(addr_offset() + 0x002434)

// $2435: Down Laser [8 bit] (0-2)
function down_laser() => byte(addr_offset() + 0x002435)

// $2436: Back Beam Active [8 bit] (0/1)
function back_beam_active() => byte(addr_offset() + 0x002436)

// $2439: Special Powerup ID [8 bit]
//        3 = Option Warrior
//        4 = Rotating Drill
//        5 = Enemy Slow
//        7 = Vector
function special_powerup_id() => byte(addr_offset() + 0x002439)

// $243A: Special Powerup - Seconds Remaining [8 bit BCD]
//        all start at 0x15, clear special powerup when 0
function special_powerup_seconds() => bcd(byte(addr_offset() + 0x00243A))
// $243B: Special Powerup - Frame Counter [8 bit]
//        when rollover from 1->60, decrement 0x243a

// --- MAIN DATA -------------------------------------------------------------------

MODE_KONAMI = 0
MODE_TITLE = 1
MODE_DEMO = 2
MODE_NEWGAME = 3
MODE_LOADING = 4
MODE_PLAYING = 5
MODE_DEATH = 6
MODE_CONTINUE = 7
MODE_CUTSCENE = 10

TEMP_OWARRIOR = 3
TEMP_RDRILL = 4
TEMP_ESLOW = 5
TEMP_VECTOR = 7

MAP_VENOM_SHIP = 0
MAP_COLLOSUS = 1
MAP_PLANT = 2
MAP_ANCIENT = 3
MAP_FLOATING = 4
MAP_FIRE = 5
MAP_LIFE = 6
MAP_FORTRESS = 7
MAP_CORE_INVADE = 8
MAP_HIDDEN_1 = 9
MAP_HIDDEN_2 = 10
MAP_HIDDEN_3 = 11

MAP_NAMES = {
	MAP_VENOM_SHIP: "Inside Venom's Ship",
	MAP_COLLOSUS: "Colossus Planet",
	MAP_PLANT: "Plant Planet",
	MAP_ANCIENT: "Ancient Planet",
	MAP_FLOATING: "Floating Continent",
	MAP_FIRE: "Planet of Fire",
	MAP_LIFE: "Life Planet",
	MAP_FORTRESS: "Fortress Planet",
	MAP_CORE_INVADE: "Boss Core Invasion",
	MAP_HIDDEN_1: "Hidden Stage",
	MAP_HIDDEN_2: "Hidden Stage",
	MAP_HIDDEN_3: "Hidden Stage",
}

WEAPON_NAMES = {
	0: "Standard Gun",
	1: "Laser",
	2: "Laser",
	3: "Double Laser",
	4: "Reflex Ring",
	5: "Napalm Missile",
	6: "Fire Blaster",
}

OPTION_INFO = {
	0: "",
	1: " + 1 option",
	2: " + 2 options",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// append 00 to the end to get the display value
// theoretically the game supports the final 2 digits, but I haven't seen them get used
function score(x) => bcd(dword(x+1))
function current_player_score() => score(P1_SCORE - 5 * bit7(addr_offset() + 0x0021C2))

function sanity_check() => game_active() == 1 && player_turn() == prev(player_turn())

function has_temp_powerup() => special_powerup_id() != 0 && special_powerup_seconds() > 0
function activate_temp_powerup(x) => special_powerup_id() == x && prev(special_powerup_seconds()) < 15 && special_powerup_seconds() == 15

// inferring the level number from the map number
function fixed_stage() => max_of(
	measured(map(),           when=direction() == 0 && map() != MAP_CORE_INVADE),
	measured(prior(map()),    when=direction() == 0 && map() == MAP_CORE_INVADE),
	measured(14-map(),        when=direction() == 1 && map() != MAP_CORE_INVADE),
	measured(14-prior(map()), when=direction() == 1 && map() == MAP_CORE_INVADE)
)

function start_new_game() => game_active() == 1 && prev(game_state()) == MODE_NEWGAME && game_state() == MODE_LOADING

function win_the_game() => (
	sanity_check() && stage() == 14 && stage_progress() == 0x01bf &&
	prev(game_state()) == MODE_PLAYING && game_state() == MODE_CUTSCENE
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(game_active() == 1 && map() >= MAP_HIDDEN_1,
	"Stage ??? (Hidden Stage) · Metalion{2} 🛩️x{3} · 🔫 {4} · 💯 {5}00",
	rich_presence_number(fixed_stage()),
	rich_presence_lookup("Map", map(), MAP_NAMES, fallback="Hidden Stage"),
	rich_presence_lookup("OptionInfo", option_count(), OPTION_INFO, fallback=""),
	rich_presence_number(lives()),
	rich_presence_lookup("Weapon", special_shot(), WEAPON_NAMES, fallback="None"),
	rich_presence_value("_S", current_player_score(), "SCORE")
)

rich_presence_conditional_display(game_active() == 1,
	"Stage {0} ({1}) · Metalion{2} 🛩️x{3} · 🔫 {4} · 💯 {5}00",
	rich_presence_number(fixed_stage()),
	rich_presence_lookup("Map", map(), MAP_NAMES, fallback="Hidden Stage"),
	rich_presence_lookup("OptionInfo", option_count(), OPTION_INFO, fallback=""),
	rich_presence_number(lives()),
	rich_presence_lookup("Weapon", special_shot(), WEAPON_NAMES, fallback="None"),
	rich_presence_value("_S", current_player_score(), "SCORE")
)

rich_presence_display(
	"[Title Screen] Gradius 2 MSX | © Konami 1987"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

DIRECTION_NAME = ["outbound", "inbound"]
DIRECTION_OFFSET = [1, -1]
function progression_achievement(id, title, points)
{
	map = id
	dir = 0
	if (id > 7)
	{
		map = 14 - id
		dir = 1
	}
	achievement(
		title=title,
		description=format("Complete stage {0}, {1} through the {2}", id, DIRECTION_NAME[dir], MAP_NAMES[map]),
		type="progression",
		points=points,
		trigger=(
			// should only fire if the map is changing
			sanity_check() && map() != prev(map()) &&
			// the map we are looking for is reaching this specific map in this specific direction
			direction() == dir && map() == map+DIRECTION_OFFSET[dir]
		)
	)
}

progression_achievement(1, "Clam Chowder", 5)
progression_achievement(2, "Feed Me, Seymour", 5)
progression_achievement(3, "Ancient Aliens", 5)
progression_achievement(4, "It Only Erupts Every 1000 Years", 10)
progression_achievement(5, "Turning Up the Heat", 10)
progression_achievement(6, "Abiogenesis", 10)

achievement(
	title="Nemesis Calls for Aid",
	description="Complete stage 7, the Fortress Planet",
	type="progression",
	points=25,
	trigger=(
		sanity_check() && map() == MAP_FORTRESS && stage_progress() == 0x02ff &&
		prev(game_state()) == MODE_PLAYING && game_state() == MODE_CUTSCENE
	)
)

progression_achievement(8, "Cosmic Infancy", 10)
progression_achievement(9, "I Must Have Left the Stove On", 10)
progression_achievement(10, "Wait, How Is It Still Erupting?", 10)
progression_achievement(11, "Get Tsoukalos on the Phone", 5)
progression_achievement(12, "Lush and Verdant, Just Like I Remember", 5)
progression_achievement(13, "The Colossus Inroads", 5)

achievement(
	title="Dr. Venom Defanged",
	description="Destroy Venom's ship and save Nemesis",
	type="win_condition",
	points=25,
	trigger=win_the_game()
)

achievement(
	title="Over Control",
	description="Complete any stage on the highest speed setting, speed 7",
	points=5,
	trigger=sanity_check() && speed() == 7 && trigger_when(prev(stage()) + 1 == stage())
)

achievement(
	title="Isn't It Ionic?",
	description="Enter the first hidden stage",
	points=4,
	trigger=sanity_check() && prev(map()) == MAP_ANCIENT && map() == MAP_HIDDEN_1
)

achievement(
	title="Life Finds a Way",
	description="Enter the second hidden stage",
	points=2,
	trigger=sanity_check() && prev(map()) == MAP_LIFE && map() == MAP_HIDDEN_2
)

achievement(
	title="Hiddenception",
	description="Enter the third hidden stage... and complete it!",
	points=10,
	trigger=(
		sanity_check() && map() == MAP_HIDDEN_3 && 
		prev(stage_progress()) == 0x015d && stage_progress() == 0x015e
	)
)

achievement(
	title="Golden Bonus",
	description="Earn a 10,000 point bonus in any hidden stage",
	points=2,
	trigger=sanity_check() && map() >= MAP_HIDDEN_1 && prev(bonus_chain()) == 6 && bonus_chain() == 7
)

achievement(
	title="Invade the Core",
	description="Defeat a boss and invade the ship's core",
	points=1,
	trigger=sanity_check() && prev(map()) != MAP_CORE_INVADE && map() == MAP_CORE_INVADE
)

achievement(
	title="Aftermarket Parts",
	description="Reach the power supply inside of the boss ship's core and unlock a new powerup",
	points=3,
	trigger=sanity_check() && map() == MAP_CORE_INVADE && prev(unlocked_powerups()) + 1 == unlocked_powerups()
)

achievement(
	title="Battle Pass Complete",
	description="Unlock the Fire Blaster, the last of the optional upgrades",
	points=10,
	trigger=sanity_check() && map() == MAP_CORE_INVADE && prev(unlocked_powerups()) == 6 && unlocked_powerups() == 7
)

achievement(
	title="You Captured... Nothing?",
	description="Invade the boss core and reach the power supply after having already gotten all unlockable powerups",
	points=1,
	trigger=(
		sanity_check() && map() == MAP_CORE_INVADE && unlocked_powerups() == 7 &&
		prev(stage_progress()) < 0x009f && stage_progress() == 0x009f
	)
)

achievement(
	title="I Love the Smell of Napalm in the Morning",
	description="Activate the Napalm Missile powerup",
	points=2,
	trigger=sanity_check() && game_state() == MODE_PLAYING && prev(missile_level()) == 2 && missile_level() == 3
)

achievement(
	title="Don't Talk to Me or My Two Sons Ever Again",
	description="Activate two options. It's lonely out in space",
	points=5,
	trigger=sanity_check() && game_state() == MODE_PLAYING && prev(option_count()) == 1 && option_count() == 2
)

achievement(
	title="Use the Force",
	description="Activate a force field for a little bit of defense",
	points=3,
	trigger=sanity_check() && game_state() == MODE_PLAYING && prev(force_field_health()) < 10 && force_field_health() == 10
)

achievement(
	title="Ring Around the Metalion",
	description="Activate the O.Warrior powerup with two options",
	points=4,
	trigger=sanity_check() && activate_temp_powerup(TEMP_OWARRIOR) && option_count() == 2
)

achievement(
	title="Becoming Shaktool",
	description="Activate the R.Drill powerup",
	points=2,
	trigger=sanity_check() && activate_temp_powerup(TEMP_RDRILL)
)

achievement(
	title="What's Your Vector, Victor?",
	description="Activate the Vector powerup",
	points=2,
	trigger=sanity_check() && activate_temp_powerup(TEMP_VECTOR)
)

achievement(
	title="Entry Level Trim Package",
	description="Complete stage 1 without activating any powerups other than speed",
	points=10,
	trigger=any_of([1,2], p => (
		once(
			start_new_game() && player_count() >= p &&
			never(player_turn() == p && __ornext(any_of(range(1,8), i => powerup_bar(i) > prev(powerup_bar(i)))))
		) &&
		player_turn() == p && trigger_when(prev(stage()) == 1 && stage() == 2)
	))
)

achievement(
	title="James Burton, Reporting for Duty",
	description="From the start of the game, complete the Fortress Planet, stage 7, without dying",
	points=50,
	trigger=once(start_new_game()) && never(game_state() == MODE_DEATH) && trigger_when(prev(stage()) == 7 && stage() == 8)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="High Score",
	description="Highest score at the end of the game or on game over. Additional loops allowed",

	start=win_the_game() || (prev(game_state()) == MODE_DEATH && game_state() == MODE_CONTINUE),
	cancel=always_false(),
	submit=always_true(),

	value=max_of(
		measured(score(P1_SCORE), when=player_turn() == 1),
		measured(score(P2_SCORE), when=player_turn() == 2),
		measured(0)
	),
	format="HUNDREDS",
	lower_is_better=false
)

leaderboard(
	title="Low Powerup Run",
	description="Furthest stage reached without any powerups other than speed in one-player mode. Submits at the end of the game or on game over",

	start=(
		// set a checkpoint hit when a new game has started
		once(start_new_game() && player_count() == 1 && stage() == 1) &&
		// clear the checkpoint hit if we ever select a powerup
		never(any_of(range(1,8), i => powerup_bar(i) != 0)) &&
		// submit when the game is won or game over
		(win_the_game() || (prev(game_state()) == MODE_DEATH && game_state() == MODE_CONTINUE))
	),
	cancel=always_false(),
	submit=always_true(),

	value=measured(stage()),
	format="VALUE",
	lower_is_better=false
)