// Dragon Hopper
// #ID = 41276
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0424: Controller Input [8 bit]
//        bit2 | A
//        bit3 | B
//        bit4 | R Shoulder
//        bit5 | L Shoulder
//        bit6 | Right Dpad Up
//        bit7 | Right Dpad Right
function input_Lshoulder() => bit5(0x0424)

// $0425: Controller Input [8 bit]
//        bit0 | Left Dpad Right
//        bit1 | Left Dpad Left
//        bit2 | Left Dpad Down
//        bit3 | Left Dpad Up
//        bit4 | Start
//        bit5 | Select
//        bit6 | Right Dpad Left
//        bit7 | Right Dpad Down
function input_select() => bit5(0x0425)

// $049E: [16 bit] Title Screen Discriminator
//        including title menus, load screen, lore, second title screen
//        0x00e4 = Title Screen
function title_screen_discriminator() => word(0x049E)

// $04B1: [8 bit] Demo State
//        bit1 | demo playing
function demo_playing() => bit1(0x04B1)

// $04C2: Easy Mode Cheat [8 bit]
//        0 = not enabled
//        1 = enabled in Secret Options
function easy_mode_cheat() => byte(0x04C2)

// $04C3: All Magic Cheat [8 bit]
//        0 = not enabled
//        1 = enabled in Secret Options
function all_magic_cheat() => byte(0x04C3)

// $2808: [16-bit] Countdown on title screen
//        counts down to 0, where demo begins playing
function title_screen_countdown() => word(0x2808)

// $280D: Secret Options Cheat Input [8 bit]
//        when $a812=0, $a813=0: 0x09->0x0a entering secret options menu
//        L-Right, R-Left, L-Up, R-Down, L-Left, R-Right, L-Down, R-Up, Select, Start
function secret_options_cheat_input() => byte(0x280D)

// $280F: [8-bit] Star Coins earned in Flap Flap Minigame
function star_medals_final_flap_flap() => byte(0x280F)

// $2810: [8-bit] Star Coins collected in Jump Jump Minigame
//        [8-bit] Star Coins countdown after Flap Flap Minigame completed
function star_medals_final_jump_jump() => byte(0x2810)
function star_medals_post_flap_flap() => byte(0x2810)

// $2811: [8-bit] Star Coins countdown after Jump Jump Minigame completed
function star_medals_post_jump_jump() => byte(0x2811)

// $2A60: [16-bit] Total Score (calculated at end screen)
//        0-400 = Bronze Dragon
//        401-700 = Silver Dragon
//        701-900 = Gold Dragon
//        901-1000 = Star Dragon
//        
//        max 1000 pts
//        600 pts from time bonus, 600 pts starting at 1h 15m and counting down
//        400 pts from star medals, 90 to be found in the game
function total_score() => word(0x2A60)

// $A810: [8-bit] World*
//        in most stages, this is the same as $a812
//        0x09 = in shop/bonus/item rooms
function zone() => byte(0xA810)

// $A811: [8-bit] Room
//        in most stages, this is the same as $a813
//        
//        when $a810 = 0x09:
//        0x01 = Earth Spirit Prison
//        0x02 = Water Spirit Prison
//        0x03 = Fire Spirit Prison
//        0x04 = Wind Spirit Prison
//        0x06 = Small Key room
//        0x15 = Bonus Stars (6-1)
//        0x1B = Shop
//        0x1E = Flap Flap
//        0x1F = Jump Jump
//        0x20 = Flap Flap
//        0x21 = Jump Jump
//        0x22 = Flap Flap
function room() => byte(0xA811)

// $A812: [8-bit] Current World (0-indexed)
function real_world() => byte(0xA812)

// $A813: [8-bit] Current Stage in World
//        starts counting at 1, 0-0 is title screen
function real_stage() => byte(0xA813)

// $CAB5: [8-bit] Area
//        0x00 = Fearon
//        0x01 = Great Tunnel
//        0x02 = Earth
//        0x03 = Tower of Infinity
//        0x04 = Cirrus
//        0x06 = Celestial Road
//        0x08 = Celestia
function area() => byte(0xCAB5)

// $CBE4: X Position [32 bit]
function x_position() => dword(0xCBE4)

// $CBE8: Y Position [32 bit]
function y_position() => dword(0xCBE8)

// $CBEC: Height [32 bit]
function height() => dword(0xCBEC)

// $CC15: Left/Right Speed [8 bit]
function h_speed() => byte(0xCC15)

// $CC17: Up/Down Speed [8 bit]
function v_speed() => byte(0xCC17)

// $CC1F: Y Speed [8 bit]
function y_speed() => byte(0xCC1F)

// $CC42: [8-bit] Player State
//        0x00 = Standing
//        0x01 = Walking
//        0x02 = Jumping
//        0x04 = Falling
//        0x05 = Landing
//        0x06 = Recoil (stopping or reversing direction)
//        0x07 = Fluttering
//        0x08 = Idle anim
//        0x09 = Dashing
//        0x0A = Attacking
//        0x0B = Coyote Time
//        0x0D = Taking Damage
function player_state() => byte(0xCC42)

// $CC49: [8-bit] Direction you are facing
//        0x00 = up
//        0x01 = right
//        0x02 = down
//        0x03 = left
function facing_direction() => byte(0xCC49)

// $CC5C: [8-bit] Current dragon form
//        0x00 = Base form
//        0x01 = Earth form
//        0x02 = Water form
//        0x03 = Fire form
//        0x04 = Air form
//        0x05 = Tiny form
function current_dragon_form() => byte(0xCC5C)

// $CC5F: [8-bit] Health Meter
//        0x14 = Max
//        0x00 = Death
function health() => byte(0xCC5F)

// $CC60: [8-bit] Magic Meter
//        0x00 = Empty
//        0x1F = Full
function magic_meter() => byte(0xCC60)

// $CC61: [8-bit] Star Coins
function star_medals() => byte(0xCC61)

// $CC69: [8-bit] Dragon forms unlocked
//        bit0 = Normal form
//        bit1 = Earth form
//        bit2 = Water form
//        bit3 = Fire form
//        bit4 = Air form
function earth_form_unlocked() => bit1(0xCC69)
function water_form_unlocked() => bit2(0xCC69)
function fire_form_unlocked() => bit3(0xCC69)
function air_form_unlocked() => bit4(0xCC69)

// $CC6C: [8-bit] Number of total star coins collected. Bonus stage medals do not count.
function tracked_star_medal_count() => byte(0xCC6C)

// $CE78: [8-bit] Unlocked spells
//        bit0 = Explosion
//        bit1 = Stop
//        bit2 = Speed
//        bit3 = Star Protection
//        bit4 = Recovery
//        bit5 = Invisibility
//        bit6 = Meteor Strike
//        bit7 = Guided Missile
// $CE79: [8-bit] Unlocked spells
//        bit0 = Frog Prince
//        bit1 = Rabbit
//        bit2 = Small Dorin
//        bit3 = Flashback
function spell_unlock(i) => bit(i-1, 0xCE78)

// $CF74: Active Spell [8 bit]
//        0x01 = Explosion
//        0x02 = Stop
//        0x03 = Speed
//        0x04 = Star Protection
//        0x05 = Recovery
//        0x06 = Invisibility
//        0x07 = Meteor Strike
//        0x08 = Guided Missile
//        0x09 = Frog prince
//        0x0a = Rabbit
//        0x0b = Small Dorin
//        0x0c = Flashback
function active_spell() => byte(0xCF74)

// $E5AC: Collectable Table [12 bytes x ??]
//        [+0] = X Position [16 bit]
//        [+2] = Y Position [16 bit]
//        [+4] = Z Position [16 bit]
//        [+6] = Type [8 bit]
//        .... 0 = Nothing (becomes 0 when collected)
//        .... 1 = Large Heart
//        .... 2 = Small Heart
//        .... 3 = Large Magic
//        .... 4 = Small Magic
//        .... 5 = Star Medal
//        [+8] = Reveal timer [8 bit]
//        .... counts down to 0, when the collectable appears
function object_type(i) => byte(0xE5AC + 12*i + 6)

// $E8B1: [8-bit] Collectables in current stage
function collectables(offset, b) => bit(b, 0xE8B0+offset)

// $E8E1: Key State [8 bit]
//        0 = Uncollected
//        1 = Collected
//        2 = Placing in Lock
//        3 = Lock Unlocked
function key_state() => byte(0xE8E1)

// $E8E5: [8-bit] Fairy Boss Cutscene Check
//        0x00 = Not started
//        0x01 = Started
//        0x02 = After fight
function fairy_boss_cutscene_check() => byte(0xE8E5)

// $EB5C: [8-bit] Boss health. For the first boss at least, starts at 32, goes down 5 every hit, boss defeated at 4
function elsus_health() => byte(0xEB5C)

// --- MAIN DATA -------------------------------------------------------------------

SPELL_EXPLOSION = 0x01
SPELL_STOP = 0x02
SPELL_SPEED = 0x03
SPELL_STAR_PROTECTION = 0x04
SPELL_RECOVERY = 0x05
SPELL_INVISIBILITY = 0x06
SPELL_METEOR_STRIKE = 0x07
SPELL_GUIDED_MISSILE = 0x08
SPELL_FROG_PRINCE = 0x09
SPELL_RABBIT = 0x0A
SPELL_SMALL_DORIN = 0x0b
SPELL_FLASHBACK = 0x0c

WORLD_NAMES = {
	0: "Faeron",
	1: "Great Tunnel",
	2: "Earth",
	3: "Tower of Infinity",
	4: "Cirrus",
	6: "Celestial Road",
	8: "Celestia",
}

WORLD_NUMBER = {
	0: "0",
	1: "1",
	2: "2",
	3: "3",
	4: "4",
	6: "5",
	8: "6",
}

SPELL_NAMES = {
	SPELL_EXPLOSION: "Explosion",
	SPELL_STOP: "Stop",
	SPELL_SPEED: "Speed",
	SPELL_STAR_PROTECTION: "Star Protection",
	SPELL_RECOVERY: "Recovery",
	SPELL_INVISIBILITY: "Invisibility",
	SPELL_METEOR_STRIKE: "Meteor Strike",
	SPELL_GUIDED_MISSILE: "Guided Missile",
	SPELL_FROG_PRINCE: "Frog Prince",
	SPELL_RABBIT: "Rabbit",
	SPELL_SMALL_DORIN: "Small Dorin",
	SPELL_FLASHBACK: "Flashback",
}

FORM_NAMES = {
	0x00: "Normal",
	0x01: "Earth",
	0x02: "Water",
	0x03: "Fire",
	0x04: "Air",
	0x05: "Tiny",
}

ALL_MEDALS = [
	{"world": 0, "stage": 1, "addr": 0x00e8b1, "bit": 0, },
	{"world": 0, "stage": 2, "addr": 0x00e8b1, "bit": 0, },
	{"world": 0, "stage": 2, "addr": 0x00e8b1, "bit": 1, },
	{"world": 0, "stage": 2, "addr": 0x00e8b1, "bit": 2, },
	{"world": 0, "stage": 2, "addr": 0x00e8b1, "bit": 3, },
	{"world": 0, "stage": 2, "addr": 0x00e8b1, "bit": 4, },
	{"world": 1, "stage": 1, "addr": 0x00e8b1, "bit": 0, },
	{"world": 1, "stage": 1, "addr": 0x00e8b1, "bit": 1, },
	{"world": 1, "stage": 1, "addr": 0x00e8b1, "bit": 3, },
	{"world": 1, "stage": 1, "addr": 0x00e8b1, "bit": 5, },
	{"world": 1, "stage": 2, "addr": 0x00e8b1, "bit": 0, },
	{"world": 1, "stage": 2, "addr": 0x00e8b1, "bit": 1, },
	{"world": 1, "stage": 2, "addr": 0x00e8b1, "bit": 4, },
	{"world": 1, "stage": 2, "addr": 0x00e8b1, "bit": 6, },
	{"world": 1, "stage": 3, "addr": 0x00e8b1, "bit": 0, },
	{"world": 1, "stage": 4, "addr": 0x00e8b1, "bit": 0, },
	{"world": 1, "stage": 4, "addr": 0x00e8b1, "bit": 2, },
	{"world": 1, "stage": 4, "addr": 0x00e8b1, "bit": 3, },
	{"world": 1, "stage": 5, "addr": 0x00e8b1, "bit": 1, },
	{"world": 1, "stage": 5, "addr": 0x00e8b1, "bit": 5, },
	{"world": 2, "stage": 1, "addr": 0x00e8b1, "bit": 4, },
	{"world": 2, "stage": 1, "addr": 0x00e8b9, "bit": 0, },
	{"world": 2, "stage": 1, "addr": 0x00e8b9, "bit": 1, },
	{"world": 2, "stage": 1, "addr": 0x00e8b9, "bit": 2, },
	{"world": 2, "stage": 2, "addr": 0x00e8b1, "bit": 0, },
	{"world": 2, "stage": 2, "addr": 0x00e8b1, "bit": 2, },
	{"world": 2, "stage": 2, "addr": 0x00e8b1, "bit": 4, },
	{"world": 2, "stage": 3, "addr": 0x00e8b1, "bit": 1, },
	{"world": 2, "stage": 3, "addr": 0x00e8b1, "bit": 2, },
	{"world": 2, "stage": 3, "addr": 0x00e8b1, "bit": 3, },
	{"world": 2, "stage": 3, "addr": 0x00e8b1, "bit": 4, },
	{"world": 2, "stage": 3, "addr": 0x00e8b1, "bit": 5, },
	{"world": 2, "stage": 4, "addr": 0x00e8b1, "bit": 1, },
	{"world": 2, "stage": 4, "addr": 0x00e8b1, "bit": 4, },
	{"world": 3, "stage": 1, "addr": 0x00e8b1, "bit": 1, },
	{"world": 3, "stage": 1, "addr": 0x00e8b1, "bit": 3, },
	{"world": 3, "stage": 1, "addr": 0x00e8b1, "bit": 5, },
	{"world": 3, "stage": 2, "addr": 0x00e8b1, "bit": 0, },
	{"world": 3, "stage": 2, "addr": 0x00e8b1, "bit": 3, },
	{"world": 3, "stage": 2, "addr": 0x00e8b1, "bit": 5, },
	{"world": 3, "stage": 4, "addr": 0x00e8b1, "bit": 0, },
	{"world": 3, "stage": 4, "addr": 0x00e8b1, "bit": 3, },
	{"world": 3, "stage": 4, "addr": 0x00e8b1, "bit": 5, },
	{"world": 3, "stage": 4, "addr": 0x00e8b1, "bit": 7, },
	{"world": 3, "stage": 5, "addr": 0x00e8b1, "bit": 0, },
	{"world": 3, "stage": 5, "addr": 0x00e8b1, "bit": 5, },
	{"world": 3, "stage": 5, "addr": 0x00e8b2, "bit": 0, },
	{"world": 4, "stage": 1, "addr": 0x00e8b1, "bit": 1, },
	{"world": 4, "stage": 1, "addr": 0x00e8b1, "bit": 3, },
	{"world": 4, "stage": 1, "addr": 0x00e8b1, "bit": 4, },
	{"world": 4, "stage": 1, "addr": 0x00e8b1, "bit": 5, },
	{"world": 4, "stage": 1, "addr": 0x00e8b2, "bit": 0, },
	{"world": 4, "stage": 2, "addr": 0x00e8b1, "bit": 0, },
	{"world": 4, "stage": 2, "addr": 0x00e8b1, "bit": 2, },
	{"world": 4, "stage": 2, "addr": 0x00e8b1, "bit": 3, },
	{"world": 4, "stage": 2, "addr": 0x00e8b1, "bit": 5, },
	{"world": 4, "stage": 3, "addr": 0x00e8b1, "bit": 0, },
	{"world": 4, "stage": 3, "addr": 0x00e8b1, "bit": 2, },
	{"world": 4, "stage": 3, "addr": 0x00e8b1, "bit": 3, },
	{"world": 4, "stage": 3, "addr": 0x00e8b1, "bit": 5, },
	{"world": 4, "stage": 4, "addr": 0x00e8b1, "bit": 1, },
	{"world": 4, "stage": 4, "addr": 0x00e8b1, "bit": 3, },
	{"world": 6, "stage": 1, "addr": 0x00e8b1, "bit": 3, },
	{"world": 6, "stage": 1, "addr": 0x00e8b1, "bit": 5, },
	{"world": 6, "stage": 1, "addr": 0x00e8b9, "bit": 0, },
	{"world": 6, "stage": 1, "addr": 0x00e8b9, "bit": 1, },
	{"world": 6, "stage": 1, "addr": 0x00e8b9, "bit": 2, },
	{"world": 6, "stage": 2, "addr": 0x00e8b1, "bit": 1, },
	{"world": 6, "stage": 2, "addr": 0x00e8b1, "bit": 3, },
	{"world": 6, "stage": 2, "addr": 0x00e8b1, "bit": 4, },
	{"world": 6, "stage": 3, "addr": 0x00e8b1, "bit": 1, },
	{"world": 6, "stage": 3, "addr": 0x00e8b1, "bit": 3, },
	{"world": 6, "stage": 3, "addr": 0x00e8b1, "bit": 4, },
	{"world": 6, "stage": 4, "addr": 0x00e8b1, "bit": 0, },
	{"world": 6, "stage": 4, "addr": 0x00e8b1, "bit": 3, },
	{"world": 6, "stage": 4, "addr": 0x00e8b1, "bit": 4, },
	{"world": 6, "stage": 5, "addr": 0x00e8b1, "bit": 0, },
	{"world": 8, "stage": 1, "addr": 0x00e8b2, "bit": 1, },
	{"world": 8, "stage": 1, "addr": 0x00e8b2, "bit": 4, },
	{"world": 8, "stage": 1, "addr": 0x00e8b2, "bit": 5, },
	{"world": 8, "stage": 1, "addr": 0x00e8b2, "bit": 7, },
	{"world": 8, "stage": 2, "addr": 0x00e8b9, "bit": 0, },
	{"world": 8, "stage": 2, "addr": 0x00e8b9, "bit": 1, },
	{"world": 8, "stage": 2, "addr": 0x00e8b9, "bit": 2, },
	{"world": 8, "stage": 3, "addr": 0x00e8b1, "bit": 0, },
	{"world": 8, "stage": 3, "addr": 0x00e8b1, "bit": 2, },
	{"world": 8, "stage": 3, "addr": 0x00e8b1, "bit": 3, },
	{"world": 8, "stage": 4, "addr": 0x00e8b1, "bit": 0, },
	{"world": 8, "stage": 4, "addr": 0x00e8b1, "bit": 1, },
	{"world": 8, "stage": 4, "addr": 0x00e8b1, "bit": 3, },
]

STAGE_MEDALS = [{"world": -1, "stage": -1, "medals": [], "check": always_true()}]
for w in range(0,8) for s in range(1,6)
{
	medals = []
	for m in ALL_MEDALS
		if (m["world"] == w && m["stage"] == s)
			array_push(medals, m)
	
	if (length(medals) > 0)
		array_push(STAGE_MEDALS, {"world": w, "stage": s, "medals": medals, "check": real_world() == w && real_stage() == s})
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function on_title_screen() => title_screen_discriminator() == 0x00e4

function cheat_menu_lockout() => disable_when(
	on_title_screen() &&
	prev(title_screen_countdown()) > 0 &&
	prev(secret_options_cheat_input()) == 9 &&
	secret_options_cheat_input() == 10,
	until=on_title_screen() && title_screen_countdown() == 385 && secret_options_cheat_input() == 0
)

function cheats_blocked() => unless(easy_mode_cheat() == 1) && unless(all_magic_cheat() == 1)

function in_flap_flap() => zone() == 0x09 && __ornext(any_of([30, 32, 34], x => room() == x))
function in_jump_jump() => zone() == 0x09 && __ornext(any_of([31, 33, 35], x => room() == x))

function purchase_spell(s) => cheats_blocked() && zone() == 0x09 && is_set(spell_unlock(s))

function advance_stage() => real_world() > prev(real_world()) || real_stage() > prev(real_stage())

function star_medal_tracking_start(w) => (
	cheats_blocked() &&
	once(real_world() == w && real_stage() == 1) &&
	// this is just to make sure we don't have more than one medal tracker active at once
	never(prev(real_world()) != w) &&
	never(on_title_screen()) && never(demo_playing() == 1)
)

function star_medal_failure(w) => all_of(STAGE_MEDALS, data => (
	if_else(data["world"] != w, always_true(), (
		never(
			prev(real_world()) == data["world"] &&
			prev(real_stage()) == data["stage"] &&
			advance_stage() &&
			if_else(length(data["medals"]) == 0, always_false(), 
				sum_of(data["medals"], m => prev(bit(m["bit"], m["addr"]))) < length(data["medals"])
			)
		)
	))
))

function all_star_medals(w, s, nextw) => (
	star_medal_tracking_start(w) &&
	star_medal_failure(w) &&
	trigger_when(prev(real_world()) == w) &&
	trigger_when(prev(real_stage()) == s) &&
	trigger_when(real_world() == nextw) &&
	trigger_when(real_stage() == 1)
)

function win_the_game() => (
	real_world() == 8 && 
	real_stage() == 8 &&
	prev(zone()) == 8 && 
	prev(room()) == 8 &&
	zone() == 6 && 
	room() == 4
)

function computed_score() => (
	cheats_blocked() &&
	real_world() == 8 &&
	real_stage() == 8 &&
	zone() == 0 &&
	room() == 1 &&
	prev(total_score()) == 0 &&
	total_score() > 0
)

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(on_title_screen() || demo_playing() == 1 || (real_world() == 0 && real_stage() == 0),
	"On Title Screen"
)

// Faeron 0-1 · 5❤️ 5💠 [Normal form] [Recovery spell] · 🪙 77/90
rich_presence_display(
	"{0} {1}-{2} · {3}❤️ {5}💠 [{7} form] [{8} spell] · 🪙 {9}/90",
	rich_presence_lookup("WNAME", real_world(), WORLD_NAMES, fallback="Faeron"),
	rich_presence_lookup("WNUM", real_world(), WORLD_NUMBER, fallback="0"),
	rich_presence_number(real_stage()),
	rich_presence_number(health()/4),
	"",
	rich_presence_number(magic_meter()/5),
	"",
	rich_presence_lookup("DFORM", current_dragon_form(), FORM_NAMES, fallback="Normal"),
	rich_presence_lookup("SPELL", active_spell(), SPELL_NAMES, fallback="Recovery"),
	rich_presence_number(tracked_star_medal_count())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Beyond the Reaches of the Fae Court",
	description="Defeat Elsus and leave Faeron. Accessing the cheat menu will block all progression achievements. Using cheats block all achievements!",
	type="progression",
	points=3,
	trigger=(
		cheat_menu_lockout() &&
		prev(!on_title_screen()) &&
		prev(real_world()) == 0 && 
		prev(real_stage()) == 3 &&
		real_world() == 1 && 
		real_stage() == 1
	)
)

achievement(
	title="Land of Milk and Honey",
	description="Defeat Cutter and complete your journey on Earth",
	type="progression",
	points=5,
	trigger=(
		cheat_menu_lockout() &&
		prev(!on_title_screen()) &&
		prev(real_world()) == 2 && 
		prev(real_stage()) == 5 &&
		real_world() == 3 && 
		real_stage() == 1
	)
)

achievement(
	title="Cumulonimrod",
	description="Defeat Terror Eyes and complete Cirrus",
	type="progression",
	points=5,
	trigger=(
		cheat_menu_lockout() &&
		prev(!on_title_screen()) &&
		prev(real_world()) == 4 && 
		prev(real_stage()) == 5 &&
		real_world() == 6 && 
		real_stage() == 1
	)
)

achievement(
	title="Savior of Celestia",
	description="Defeat King Hades, rescue Diana, and save Celestia",
	type="win_condition",
	points=25,
	trigger=(
		cheat_menu_lockout() &&
		prev(!on_title_screen()) &&
		win_the_game()
	)
)

achievement(
	title="Wet and Wild",
	description="Save the Water Spirit and unlock the Water form",
	points=3,
	trigger=(
		cheats_blocked() &&
		real_world() == 2 &&
		real_stage() == 3 &&
		zone() == 9 &&
		room() == 2 &&
		is_set(water_form_unlocked())
	)
)

achievement(
	title="Thank You for Flying Air Dragon",
	description="Save the Air Spirit and unlock the Air form",
	points=3,
	trigger=(
		cheats_blocked() &&
		real_world() == 4 &&
		real_stage() == 3 &&
		zone() == 9 &&
		room() == 4 &&
		is_set(air_form_unlocked())
	)
)

achievement(
	title="Medals in Faeron",
	description="In one session, collect all star medals in Faeron without returning to the title screen",
	points=5,
	trigger=all_star_medals(0, 3, nextw=1)
)

achievement(
	title="Medals in the Great Tunnel",
	description="In one session, collect all star medals in Great Tunnel without returning to the title screen",
	points=10,
	trigger=all_star_medals(1, 6, nextw=2)
)

achievement(
	title="Medals on Earth",
	description="In one session, collect all star medals on Earth without returning to the title screen",
	points=10,
	trigger=all_star_medals(2, 5, nextw=3)
)

achievement(
	title="Medals in the Tower of Infinity",
	description="In one session, collect all star medals in Tower of Infinity without returning to the title screen",
	points=10,
	trigger=all_star_medals(3, 6, nextw=4)
)

achievement(
	title="Medals in Cirrus",
	description="In one session, collect all star medals in Cirrus without returning to the title screen",
	points=10,
	trigger=all_star_medals(4, 5, nextw=6)
)

achievement(
	title="Medals Along Celestial Road",
	description="In one session, collect all star medals in Celestial Road without returning to the title screen",
	points=10,
	trigger=all_star_medals(6, 5, nextw=8)
)

achievement(
	title="Medals in Celestia",
	description="In one session, collect all star medals in Celestia without returning to the title screen",
	points=10,
	trigger=(
		star_medal_tracking_start(8) &&
		star_medal_failure(8) &&
		win_the_game()
	)
)

achievement(
	title="You Are Star Dragon",
	description="Complete the game and earn the Star Dragon ranking",
	points=50,
	trigger=computed_score() && total_score() > 900
)

achievement(
	title="Za Warudo",
	description="Purchase the Stop spell",
	points=2,
	trigger=purchase_spell(SPELL_STOP)
)

achievement(
	title="Blessings of Heaven",
	description="Purchase the Star Protection spell",
	points=2,
	trigger=purchase_spell(SPELL_STAR_PROTECTION)
)

achievement(
	title="Calling in an Air Strike",
	description="Purchase the Meteor Strike spell",
	points=2,
	trigger=purchase_spell(SPELL_METEOR_STRIKE)
)

achievement(
	title="Hop Away!",
	description="Purchase the Frog Prince spell",
	points=2,
	trigger=purchase_spell(SPELL_FROG_PRINCE)
)

achievement(
	title="Little Birthday Boy",
	description="Purchase the Small Dorin spell",
	points=2,
	trigger=purchase_spell(SPELL_SMALL_DORIN)
)

achievement(
	title="Flap Flap All the Way Across the Sky",
	description="Earn a perfect score on the Flap Flap minigame",
	points=10,
	trigger=(
		cheats_blocked() &&
		in_flap_flap() &&
		star_medals_final_flap_flap() == 10 &&
		prev(star_medals_post_flap_flap()) == 1 &&
		star_medals_post_flap_flap() == 0
	)
)

achievement(
	title="Bouncing Baby Boy",
	description="Defeat the Elf Knight, Elsus, in one continuous bounce",
	points=5,
	trigger=(
		cheats_blocked() &&
		// checkpoint at start of the fight
		once(
			real_world() == 0 && real_stage() == 3 && 
			prev(fairy_boss_cutscene_check()) == 0 &&
			fairy_boss_cutscene_check() == 1
		) &&
		// never leave the stage or return to title
		never(real_world() != 0) && never(real_stage() != 3) &&
		never(on_title_screen()) &&
		// landing after a jump is banned
		never(elsus_health() < 50 && player_state() == 0x05) &&
		// reset all hits if the fight restarts
		never(fairy_boss_cutscene_check() == 0) &&
		// never take damage from a direct ground attack
		never(elsus_health() < prev(elsus_health()) && player_state() == 0x09) &&
		never(elsus_health() < prev(elsus_health()) && player_state() == 0x0A) &&
		// never(elsus_health() < prev(elsus_health()) && height() == 0x000c00) &&
		trigger_when(prev(fairy_boss_cutscene_check()) == 1 && fairy_boss_cutscene_check() == 2)
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Star Medal Tracker",
	description="Shows remaining star medals in current stage. Hold L for 3 seconds to activate, press L again to deactivate",

	start=(
		!on_title_screen() && demo_playing() == 0 &&
		tally(3*60, input_Lshoulder() == 1) &&
		never(input_Lshoulder() == 0)
	),
	cancel=on_title_screen() || demo_playing() == 1 || is_set(input_Lshoulder()),
	submit=always_false(),

	value=max_of(array_map(STAGE_MEDALS, data => (
		measured(
			length(data["medals"]) - sum_of(data["medals"], m => bit(m["bit"], m["addr"])), 
			when=data["check"]
		)
	))),
	format="VALUE",
	lower_is_better=false
)

leaderboard(
	title="Total Score",
	description="Highest total score after credits",

	start=computed_score(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(total_score()),
	format="VALUE",
	lower_is_better=false
)