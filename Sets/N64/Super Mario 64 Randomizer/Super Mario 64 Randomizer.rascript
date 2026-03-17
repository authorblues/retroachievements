// ~Hack~ Super Mario 64: Randomizer
// #ID = 10509

// HELPERS
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x

function vptr_to_addr(x) => (x & 0x00FFFFFF)

// $1787C8: Current File [8 bit]
//          1 = File A
//          2 = File B
//          3 = File C
//          4 = File D
function current_file() => byte(0x1787C8)

// $041220: File A - Save Game [64 bytes]
SAVE_GAME_OFFSETS = 0x041220
function save_game(i) => SAVE_GAME_OFFSETS + 0x40 * (i - 1)
function current_save_game() => save_game(current_file())
//          +0 = Lost cap location? (seems unused)
//          +4 = Seed [32 bit] (0-99999)
function seed() => dword(current_save_game() + 4)
//          +8 = Settings [32 bit]
function settings() => dword(current_save_game() + 8)
//              +0
//                  b0 = Green Demon Mode active
function is_green_demon() => bit0(current_save_game() + 8)
//                  b1-4 = BitS Stars Needed (0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 119)
//                         **not quite accurate, because b1100 should map to 119, not 120**
function stars_needed() => bit1(current_save_game() + 8) * 10 + bit2(current_save_game() + 8) * 20 + 
                           bit3(current_save_game() + 8) * 40 + bit4(current_save_game() + 8) * 80
//                  b5 = Randomize Level Spawn active
function random_level_spawn() => bit5(current_save_game() + 8)
//                  b6 = Randomize Star Doors on
function random_star_doors() => bit6(current_save_game() + 8)
//                  b7 = Star Door restrictions disabled (including wing cap)
function star_door_restrictions_disabled() => bit7(current_save_game() + 8)
//              +1
//                  b0 = Randomize Star Spawns active
function random_star_spawns() => bit0(current_save_game() + 9)
//                  b1-2 = Spawn Difficulty (00 = Safe, 01 = Normal, 10 = Danger)
function spawn_difficulty() => bit1(current_save_game() + 9) * 2 + bit2(current_save_game() + 9)
//                  b3 = Nonstop Mode - save
//                  b4 = Nonstop Mode - nosave
function is_nonstop() => bit3(current_save_game() + 9) + bit4(current_save_game() + 9)
//                  b5 = Object Types (0 = key, 1 = all)
function randomize_all() => bit5(current_save_game() + 9)
//                  b6 = Adjust Warp Exits active
function adjust_warp_exits() => bit6(current_save_game() + 9)
//              +2
//                  b0 = Randomize Level Warps active
function random_level_warps() => bit0(current_save_game() + 10)
//                  b1 = Keep Structure on
function keep_structure() => bit1(current_save_game() + 10)
//          +12 = Cosmetic Settings [32 bit]
//              +3
//                  b0-1 = Star Colors (00 = Off, 01 = Per Star, 10 = Per Level, 11 = Global)
//                  b2 = Coin Colors
//                  b3 = Random Skyboxes
//                  b4 = Random Music
//                  b5 = Music Muted
//                  b6 = Randomize Clothes Colors
//                  b7 = Randomize All Colors + Clothes
//          +16
//              b0 = File exists
function file_exists(i) => bit0(i + 16)
//              b1 = Red Switch pressed
//              b2 = Green Switch pressed
//              b3 = Blue Switch pressed
//              b4 = Bowser 1 Key obtained
//              b5 = Bowser 2 Key obtained
//              b6 = Basement Door opened
//              b7 = 2F Door opened
//          +17
//              b1 = Moat-Water lowered
//              b2 = Secret Slide Door opened
//              b3 = Course 2 Door opened
//              b4 = Course 4 Door opened
//              b5 = Course 3 Door opened
//              b6 = Star Door (8) opened
//              b7 = Star Door (30) opened
//          +18
//              b0 = Mario's Cap is lying somewhere
//              b1 = Klepto has Mario's Cap
//              b2 = Ukiki has Mario's Cap
//              b3 = Mr Blizzard has Mario's Cap
//              b4 = Star Door (50) opened
//              b5 = Set Seed (vs Random Seed)
function is_set_seed() => bit5(current_save_game() + 18)
//          +19
//              b0 = Toad Star (12) collected
//              b1 = Toad Star (25) collected
//              b2 = Toad Star (35) collected
//              b3 = MIPS Star (15) collected
//              b4 = MIPS Star (50) collected
//          +20 = Course 04 - Stars [b0-6] / Course 03 - Cannon [b7] X
//          +21 = Course 03 - Stars [b0-6] / Course 02 - Cannon [b7] X
//          +22 = Course 02 - Stars [b0-6] / Course 01 - Cannon [b7] X
//          +23 = Course 01 - Stars [b0-6]
//          +24 = Course 08 - Stars [b0-6] / Course 07 - Cannon [b7]
//          +25 = Course 07 - Stars [b0-6] / Course 06 - Cannon [b7]
//          +26 = Course 06 - Stars [b0-6] / Course 05 - Cannon [b7]
//          +27 = Course 05 - Stars [b0-6] / Course 04 - Cannon [b7] X
//          +28 = Course 12 - Stars [b0-6] / Course 11 - Cannon [b7] X
//          +29 = Course 11 - Stars [b0-6] / Course 10 - Cannon [b7] X
//          +30 = Course 10 - Stars [b0-6] / Course 09 - Cannon [b7]
//          +31 = Course 09 - Stars [b0-6] / Course 08 - Cannon [b7] X
//          +32 = Bowser 01 - Stars [b0-6] / Course 15 - Cannon [b7] X
//          +33 = Course 15 - Stars [b0-6] / Course 14 - Cannon [b7]
//          +34 = Course 14 - Stars [b0-6] / Course 13 - Cannon [b7] X
//          +35 = Course 13 - Stars [b0-6] / Course 12 - Cannon [b7] X
//          +36 = Secret 02 - Stars [b0-6] / Secret 01 - Cannon [b7]
//          +37 = Secret 01 - Stars [b0-6] / Bowser 03 - Cannon [b7]
//          +38 = Bowser 03 - Stars [b0-6] / Bowser 02 - Cannon [b7]
//          +39 = Bowser 02 - Stars [b0-6] / Bowser 01 - Cannon [b7]
//          +40 = Secret 06 - Stars [b0-6] / Secret 05 - Cannon [b7] X
//          +41 = Secret 05 - Stars [b0-6] / Secret 04 - Cannon [b7]
//          +42 = Secret 04 - Stars [b0-6] / Secret 03 - Cannon [b7]
//          +43 = Secret 03 - Stars [b0-6] / Secret 02 - Cannon [b7]
function star_count_by_course(c) => bitcount(current_save_game() + c) - bit7(current_save_game() + c)
function cannon_open(c) => bit7(current_save_game() + c)
//          +44 = Course 3 - Jolly Roger Bay [8 bit]
//          +45 = Course 2 - Whomp's Fortress [8 bit]
//          +46 = Course 1 - Bob-omb Battlefield [8 bit]
//          +47 =
//          +48 = Course 7 - Lethal Lava Land [8 bit]
//          +49 = Course 6 - Hazy Maze Cave [8 bit]
//          +50 = Course 5 - Big Boo's Haunt [8 bit]
//          +51 = Course 4 - Cool, Cool Mountain [8 bit]
//          +52 = Course 11 - Wet-Dry World [8 bit]
//          +53 = Course 10 - Snowman's Land [8 bit]
//          +54 = Course 9 - Dire, Dire Docks [8 bit]
//          +55 = Course 8 - Shifting Sand Land [8 bit]
//          +56 = Course 15 - Rainbow Ride [8 bit]
//          +57 = Course 14 - Tick Tock Clock [8 bit]
//          +58 = Course 13 - Tiny-Huge Island [8 bit]
//          +59 = Course 12 - Tall, Tall Mountain [8 bit]
//          +60 = Checksum [32 bits]
//          
//          Presets:
//              Default = 0x1236e
//              Extreme = 0x36574
//              Easy = 0x1288a
//              New Game = 0x36a50
//              Calm = 0x2020e
//              Sprint = 0x133a6

PRESET_DEFAULT = 0x1236e
PRESET_EXTREME = 0x36574
PRESET_EASY = 0x1288a
PRESET_NEW_GAME = 0x36a50
PRESET_CALM = 0x2020e
PRESET_SPRINT = 0x133a6

PRESETS = {
    PRESET_DEFAULT: "Default",
    PRESET_EXTREME: "⚠️ Extreme",
    PRESET_EASY: "Easy",
    PRESET_NEW_GAME: "New Game",
    PRESET_CALM: "🏖️ Calm",
    PRESET_SPRINT: "🏃‍♂️ Sprint",
}

// $1787CA: Map ID [8 bit]
//          0x00 = Starting the game
//          0x01 = File Select
//          0x04 = in Course 5 'Big Boo's Haunt'
//          0x05 = in Course 4 'Cool, Cool Mountain'
//          0x06 = inside the Castle
//          0x07 = in Course 6 'Hazy Maze Cave'
//          0x08 = in Course 8 'Shifting Sand Land'
//          0x09 = in Course 1 'Bob-omb Battlefield'
//          0x0a = in Course 10 'Snowman's Land'
//          0x0b = in Course 11 'Wet-Dry World'
//          0x0c = in Course 3 'Jolly Roger Bay'
//          0x0d = in Course 13 'Tiny-Huge Island'
//          0x0e = in Course 14 'Tick Tock Clock'
//          0x0f = in Course 15 'Rainbow Ride'
//          0x10 = outside the Castle
//          0x11 = in 'Bowser in the Dark World'
//          0x12 = in 'Vanish Cap Under the Moat'
//          0x13 = in 'Bowser in the Fire Sea'
//          0x14 = in 'Secret Aquarium'
//          0x15 = in 'Bowser in the Sky'
//          0x16 = in Course 7 'Lethal Lava Land'
//          0x17 = in Course 9 'Dire, Dire Docks'
//          0x18 = in Course 2 'Whomp's Fortress'
//          0x19 = in the Credits
//          0x1a = in the Castle Courtyard
//          0x1b = in 'Princess's Secret Slide'
//          0x1c = in 'Cavern of the Metal Cap'
//          0x1d = in 'Tower of the Wing Cap'
//          0x1e = in Bowser's Dark Arena
//          0x1f = in 'Wing Mario Over the Rainbow'
//          0x21 = in Bowser's Sea Arena
//          0x22 = in Bowser's Sky Arena
//          0x24 = in Course 12 'Tall, Tall Mountain'

MAP_MIN = 4
function map_id() => byte(0x1787CA)
function in_game() => map_id() >= MAP_MIN

// $17A916: Selected Star for Course [8 bit]
function selected_star_for_course() => byte(0x17A916)

// $17AA5B: Pause Menu Type [8 bit]
//          0 = Unpaused
//          1 = Stage Pause
//          2 = Castle Pause
function pause_menu_type() => byte(0x17AA5B)

// $17AD9C: Pointer to The Mario [32 bit]
//          .. +0x0C = action [32 bit bitfield]
function ptr_to_mario() => vptr_to_addr(dword(0x17AD9C))
function mario_action() => dword(ptr_to_mario() + 0x0C)
function mario_held_obj() => vptr_to_addr(dword(ptr_to_mario() + 0x7C))

function mario_y_pos() => float(ptr_to_mario() + 0x40)
function mario_floor_height() => float(ptr_to_mario() + 0x70)

// https://github.com/arthurtilly/SM64Randomizer/blob/randomizer/include/sm64.h#L239
ACT_GROUP_CUTSCENE    = 0x00000100
ACT_GROUP_SUBMERGED   = 0x000000C0
ACT_FLYING            = 0x10880899
ACT_FLAG_RIDING_SHELL = 0x00010000

function mario_is(mario, act) => (mario & act) == act
function mario_in(mario, act) => (mario & act) != 0

// $17C2D2: (TTC) Clock State [8 bit]
//          0 = Slow (3:00)
//          1 = Fast (9:00)
//          2 = Random (6:00)
//          3 = Stopped (12:00)
function ttc_clock_state() => byte(0x17C2D2)

TTC_SLOW = 0
TTC_FAST = 1
TTC_RAND = 2
TTC_STOP = 3

// $17CEEA: Last Star Collected - Stage Number [8 bit]
function last_star_stage() => byte(0x17CEEA)

// $17CEEB: Last Star Collected - Star Number [8 bit]
function last_star_number() => byte(0x17CEEB)

// $1858EE: Stage ID [8 bit]
//          0 = Castle
//          1 = Bob-omb Battlefield
//          2 = Whomp's Fortress
//          3 = Jolly Roger Bay
//          4 = Cool, Cool Mountain
//          5 = Big Boo's Haunt
//          6 = Hazy Maze Cave
//          7 = Lethal Lava Land
//          8 = Shifting Sand Land
//          9 = Dire, Dire Docks
//          10 = Snowman's Land
//          11 = Wet-Dry World
//          12 = Tall, Tall Mountain
//          13 = Tiny-Huge Island
//          14 = Tick Tock Clock
//          15 = Rainbow Ride
//          16 = Bowser in the Dark World
//          17 = Bowser in the Fire Sea
//          18 = Bowser in the Sky
//          19 = Princess's Secret Slide
//          20 = Metal Cap
//          21 = Wing Cap
//          22 = Vanish Cap
//          23 = Wing Mario Over the Rainbow
//          24 = Aquarium
function stage_id() => byte(0x1858EE)

// $1858F1: Warp Transition Length (Time) [8 bit]
// $1858F2: Warp Transition Type [8 bit]
//          0x00, 0x01 = from/to color
//          0x08, 0x09 = from/to star
//          0x0a, 0x0b = from/to circle
//          0x0e, 0x0f = from/to large
//          0x10, 0x11 = from/to mario
//          0x12, 0x13 = from/to bowser
// $1858F3: Warp Transition Active? [8 bit]
function trans_len() => byte(0x1858F1)
function trans_type() => byte(0x1858F2)
function trans_active() => byte(0x1858F3)

FADE_IN_FROM_COLOR = 0x00

// $1870DB: Red Coin Count [8 bit]
function red_coin_count() => byte(0x1870DB)

// $187153: Race Timer Running [8 bit]
function race_timer_running() => byte(0x187153)

// $18716C: Game Pause State [8 bit]
//          b1 = Paused
//          b2 = Loading
PAUSE_STATE = 0x18716C
function is_paused() => bit1(PAUSE_STATE)
function is_loading() => bit2(PAUSE_STATE)

// $18717E: Race Timer [16 bit] (frames)
//          divide by 30 to get seconds
function race_timer_frames() => word(0x18717E)

// $187F64: Time since loading [32 bit]
function level_timer() => dword(0x187F64)

// $1871F8: Pointer to Interacted Object [32 bit]
//          .. +0x130 = interaction type (0x00001000 for stars)
//          .. +0x190 = interaction subtype (0x00000800 for grand star)
function ptr_to_last_interacted_obj() => dword(0x1871F8)

// $187228: Star Count [8 bit] (displayed)
function star_count() => byte(0x187228)

// $18722A: Coins [8 bit]
// $187170: Coins (HUD) [8 bit]
function coins() => byte(0x18722A)
function coins_hud() => byte(0x187170)

// $18722C: Air Frames [8 bit]
function air() => byte(0x18722C)
function drowning() => (
    // air timer rolled over during this frame, so damage is due to drowning
    prev(air()) == 0x00 && air() == 0xFF

    // can only drown underwater
    // && mario_in(mario_action(), ACT_GROUP_SUBMERGED)
)

// $18722D: Health Remaining [8 bit] (0-8)
function health() => byte(0x18722D)
function take_damage() => health() < prev(health()) && !drowning()

// $18722E: Lives [8 bit]
function lives() => byte(0x18722E)

// $187230: Healing Frames [8 bit]
function healing_frames() => byte(0x187230)

// $187231: Damage Frames [8 bit]
function damage_frames() => byte(0x187231)

// $1B1978: Current Settings [32 bit]
function setup_settings() => dword(0x1B1978)

// $1B197C: Current Cosmetic Settings [32 bit]
function setup_cosmetics() => dword(0x1B197C)

// $1B1E30: Current Seed [32 bit] (0-99999)
function setup_seed() => dword(0x1B1E30)

// $2BFF88: Last Loaded Number [8 bit]
//          used for collecting red coins, secrets, and numbered stars
function last_loaded_number() => byte(0x2BFF88)

MAP_BBH = 0x04
MAP_CCM = 0x05
MAP_CASTLE_INSIDE = 0x06
MAP_HMC = 0x07
MAP_SSL = 0x08
MAP_BOB = 0x09
MAP_SL = 0x0a
MAP_WDW = 0x0b
MAP_JRB = 0x0c
MAP_THI = 0x0d
MAP_TTC = 0x0e
MAP_RR = 0x0f
MAP_CASTLE_OUTSIDE = 0x10
MAP_BITDW = 0x11
MAP_CAP_VANISH = 0x12
MAP_BITFS = 0x13
MAP_AQUA = 0x14
MAP_BITS = 0x15
MAP_LLL = 0x16
MAP_DDD = 0x17
MAP_WF = 0x18
MAP_CREDITS = 0x19
MAP_CASTLE_COURTYARD = 0x1a
MAP_PSS = 0x1b
MAP_CAP_METAL = 0x1c
MAP_CAP_WING = 0x1d
MAP_BITDW_ARENA = 0x1e
MAP_WMOTR = 0x1f
MAP_BITFS_ARENA = 0x21
MAP_BITS_ARENA = 0x22
MAP_TTM = 0x24

MapLookup = {
    MAP_CASTLE_OUTSIDE: "outside Peach's Castle",
    MAP_CASTLE_INSIDE: "inside Peach's Castle",
    MAP_CASTLE_COURTYARD: "in the Castle Courtyard",

    MAP_BOB: "avoiding the fight in Bob-omb Battlefield",
    MAP_WF: "storming Whomp's Fortress",
    MAP_JRB: "going for a swim in Jolly Roger Bay",
    MAP_CCM: "chilling out in Cool, Cool Mountain",
    MAP_BBH: "getting spooked in Big Boo's Haunt",
    MAP_HMC: "getting lost in Hazy Maze Cave",
    MAP_LLL: "burning up in Lethal Lava Land",
    MAP_SSL: "sinking into Shifting Sand Land",
    MAP_DDD: "submerged in Dire, Dire Docks",
    MAP_SL: "losing his cool in Snowman's Land",
    MAP_WDW: "raising the bar in Wet-Dry World",
    MAP_TTM: "climbing Tall, Tall Mountain",
    MAP_THI: "changing perspectives in Tiny-Huge Island",
    MAP_TTC: "passing time in Tick Tock Clock",
    MAP_RR: "riding high in Rainbow Ride",

    MAP_PSS: "sliding down the Princess's Secret Slide",
    MAP_AQUA: "getting comfy in the Secret Aquarium",
    MAP_WMOTR: "Winging Over the Rainbow",

    MAP_BITDW: "in the Dark World",
    MAP_BITFS: "in the Fire Sea",
    MAP_BITS: "in the Sky",

    MAP_BITDW_ARENA: "fighting Bowser in the Dark World",
    MAP_BITFS_ARENA: "fighting Bowser in the Fire Sea",
    MAP_BITS_ARENA: "fighting Bowser in the Sky",

    MAP_CAP_WING: "high above the Tower of the Wing Cap",
    MAP_CAP_VANISH: "hiding in Vanish Cap Under the Moat",
    MAP_CAP_METAL: "in the Cavern of the Metal Cap",

    MAP_CREDITS: "watching the credits",
}

MAIN_COURSES = [
    {"c": 1, "offset": 23, "map": MAP_BOB, "red": 4, "name": "Bob-omb Battlefield"},
    {"c": 2, "offset": 22, "map": MAP_WF, "red": 4, "name": "Whomp's Fortress"},
    {"c": 3, "offset": 21, "map": MAP_JRB, "red": 4, "name": "Jolly Roger Bay"},
    {"c": 4, "offset": 20, "map": MAP_CCM, "red": 4, "name": "Cool, Cool Mountain"},
    {"c": 5, "offset": 27, "map": MAP_BBH, "red": 4, "name": "Big Boo's Haunt"},
    {"c": 6, "offset": 26, "map": MAP_HMC, "red": 2, "name": "Hazy Maze Cave"},
    {"c": 7, "offset": 25, "map": MAP_LLL, "red": 3, "name": "Lethal Lava Land"},
    {"c": 8, "offset": 24, "map": MAP_SSL, "red": 5, "name": "Shifting Sand Land"},
    {"c": 9, "offset": 31, "map": MAP_DDD, "red": 3, "name": "Dire, Dire Docks"},
    {"c": 10, "offset": 30, "map": MAP_SL, "red": 5, "name": "Snowman's Land"},
    {"c": 11, "offset": 29, "map": MAP_WDW, "red": 5, "name": "Wet-Dry World"},
    {"c": 12, "offset": 28, "map": MAP_TTM, "red": 3, "name": "Tall, Tall Mountain"},
    {"c": 13, "offset": 35, "map": MAP_THI, "red": 5, "name": "Tiny-Huge Island"},
    {"c": 14, "offset": 34, "map": MAP_TTC, "red": 6, "name": "Tick Tock Clock"},
    {"c": 15, "offset": 33, "map": MAP_RR, "red": 3, "name": "Rainbow Ride"},
]

LEVELS_CONTAINING_STARS = [
    // main 15 courses
    MAP_BOB, MAP_WF, MAP_JRB, MAP_CCM, MAP_BBH,
    MAP_HMC, MAP_SSL, MAP_LLL, MAP_DDD, MAP_SL,
    MAP_WDW, MAP_TTM, MAP_THI, MAP_TTC, MAP_RR,

    // three secret courses
    MAP_PSS, MAP_AQUA, MAP_WMOTR,

    // three bowser stages
    MAP_BITDW, MAP_BITFS, MAP_BITS,
]

CANNON_OFFSETS = [20, 21, 22, 27, 28, 29, 31, 32, 34, 35, 40]

SetSeedLookup = {
    0: "",
    1: "✍️",
}

GreenDemonLookup = {
    0: "",
    1: " 😈",
}

NonstopLookup = {
    0: "",
    1: " ♾️",
}

ClockLookup = {
    TTC_SLOW: "🕒🐢",
    TTC_FAST: "🕘🐇",
    TTC_RAND: "🕕🔀",
    TTC_STOP: "🕛⏸️",
}

rp_loc = rich_presence_lookup("Map", map_id(), MapLookup, fallback="in the Mushroom Kingdom")
rp_stars = rich_presence_value("Number_", star_count(), "VALUE")
rp_seed = rich_presence_value("Number_", seed(), "VALUE")
rp_set_seed = rich_presence_lookup("SetSeed", is_set_seed(), SetSeedLookup, fallback="")
rp_preset = rich_presence_lookup("Preset", settings(), PRESETS, fallback="Default")
rp_settings = rich_presence_value("Number_", settings(), "VALUE")
rp_gdemon = rich_presence_lookup("GreenDemon", is_green_demon(), GreenDemonLookup, fallback="")
rp_nonstop = rich_presence_lookup("NonStop", is_nonstop(), NonstopLookup, fallback="")
rp_ttc_clock = rich_presence_lookup("Clock", ttc_clock_state(), ClockLookup, fallback=ClockLookup[TTC_STOP])

rich_presence_conditional_display(!in_game(),
    "🔀 Setting up a New Randomizer 🎲"
)

rich_presence_conditional_display(map_id() == MAP_TTC && any_of(PRESETS, (x) => settings() == x),
    "Mario is {0} {5} | ⭐{1} | 🌱{2}{3} | {4} Preset",
    rp_loc, rp_stars, rp_seed, rp_set_seed,
    rp_preset,
    rp_ttc_clock
)

rich_presence_conditional_display(map_id() == MAP_TTC,
    "Mario is {0} {7} | ⭐{1} | 🌱{2}{3} | 🎲{4}{5}{6}",
    rp_loc, rp_stars, rp_seed, rp_set_seed,
    rp_settings, rp_gdemon, rp_nonstop,
    rp_ttc_clock
)

rich_presence_conditional_display(any_of(PRESETS, (x) => settings() == x),
    "Mario is {0} | ⭐{1} | 🌱{2}{3} | {4} Preset",
    rp_loc, rp_stars, rp_seed, rp_set_seed,
    rp_preset
)

rich_presence_display(
    "Mario is {0} | ⭐{1} | 🌱{2}{3} | 🎲{4}{5}{6}",
    rp_loc, rp_stars, rp_seed, rp_set_seed,
    rp_settings, rp_gdemon, rp_nonstop
)

// 
function interacted_key() =>
(
    // an interaction just occurred
    prev(ptr_to_last_interacted_obj()) != ptr_to_last_interacted_obj() &&

    // type is star (obj->oInteractType == INTERACT_STAR_OR_KEY)
    dword(vptr_to_addr(ptr_to_last_interacted_obj()) + 0x130) == 0x00001000
)

// check for collecting any star (or key)
function collect_a_key() => interacted_key() || (mario_action() & 0x1FE) == 0x102

// collecting a star has a few other possible ways to detect
function collect_a_star() =>
(
    // if the last star collected info changes, we got a star
    prev(last_star_number()) != last_star_number() || prev(last_star_stage()) != last_star_stage() ||

    // checking the interacted object should be sufficient, honestly
    collect_a_key()
)

// check for collecting a specific star
function collect_star(num) => (collect_a_star() && last_star_number() == num)

// check for collecting the grand star
// https://github.com/arthurtilly/SM64Randomizer/blob/271db474a4d878b22bc7822de4333de8a409c29a/src/game/interaction.h#L46
function collect_grand_star() => 
(
    // either we identify the end of the game by the star we collected
    (interacted_key() && dword(vptr_to_addr(ptr_to_last_interacted_obj()) + 0x190) == 0x00000800) || 

    // or by Mario's grand star animation
    mario_action() == 0x1909
)

// new random seed started (leave the file select on a file that doesn't exist)
function new_file_created() => (prev(map_id()) < MAP_MIN && map_id() >= MAP_MIN && file_exists(current_save_game()) == 0)

// start when a new file is created (cannot start from an existing file or set seed, generally)
function start_game() => new_file_created() && is_set_seed() == 0

// submit when you collect the grand star at the end of the game
function end_game() => map_id() == MAP_BITS_ARENA && collect_grand_star()

// we have "left the game" if...
function leave_game() => (
    // the file we were playing on is deleted
    (!in_game() && file_exists(current_save_game()) == 0) || 

    // or, we change which slot we are playing (from the menu)
    prev(current_file()) != current_file() ||

    // or, the settings are changed somehow (some are able to be changed at will)
    prev(settings()) != settings()
)

// count frames
function frame_count() => measured(tally(0, always_true())) // measured(tally(0, is_loading() == 0))

// check if entering a level
function enter_level() =>
(
    // loading a stage is always a fade-from-color type
    // could check color if we're picky (seems to always be white, ff ff ff)
    trans_type() == FADE_IN_FROM_COLOR &&

    // stage loading transitions seem to specifically be the 0x1a type
    // this is different from the 0x10 len for the star select menu?
    trans_len() == 0x1A &&

    // transition is complete (this seems to flip after the previously mentioned
    // number of frames have passed)
    prev(trans_active()) == 1 && trans_active() == 0
)

// the required settings for completion-based achievements
function minimum_completion_settings() =>
(
    randomize_all() == 1 &&
    random_star_spawns() == 1 &&
    is_set_seed() == 0
)

// the required settings for progression-based achievements
function minimum_progression_settings() =>
(
    random_level_spawn() == 1 &&
    random_level_warps() == 1 &&
    // spawn_difficulty() >= 1 &&
    minimum_completion_settings()
)

achievement(
    title="[Warning] Minimum Randomization Settings Required",
    description="All achievements require minimum randomization settings (see forum)",
    points=0,
    trigger=(in_game() || (map_id() == 1 && prev(setup_settings()) == PRESET_DEFAULT && setup_settings() != PRESET_DEFAULT))
)

STAR_MILESTONES = [
    {"stars": 8, "points": 5, "title": "Build Ursa Minor"},
    {"stars": 30, "points": 5, "title": "Build Ursa Major"},
    {"stars": 50, "points": 10, "title": "Build Cassiopeia (Tenfold)"},
    {"stars": 70, "points": 10, "title": "Build Ursa Major-er"},
    {"stars": 120, "points": 50, "title": "Across the Milky Way"},
]

for m in STAR_MILESTONES
{
    // progression achievements require BitS door setting to be 70+
    SETTINGS = minimum_progression_settings()
    if (m["stars"] <= 70) SETTINGS = SETTINGS && stars_needed() >= 70

    achievement(
        title=m["title"],
        description=format("Collect {0} stars (see comments for required settings)", m["stars"]),
        points=m["points"],
        type=if_else(m["stars"] <= 70, "progression", ""),
        trigger=(
            // in game with minimum requirements
            in_game() && SETTINGS &&

            // collected enough stars to reach the milestone
            prev(star_count()) < m["stars"] && star_count() >= m["stars"]
        )
    )
}

achievement(
    title="Everything Back in its Place",
    description="Defeat Bowser and restore the power of the Grand Star to Peach's Castle",
    points=25,
    type="win_condition",
    trigger=(
        // correct settings (requires 70+ stars BitS door)
        minimum_progression_settings() && stars_needed() >= 70 &&

        // collect the grand star
        map_id() == MAP_BITS_ARENA && collect_grand_star()
    )
)

KEYS = [
    {"map": MAP_BITDW_ARENA, "name": "Dark World"}, 
    {"map": MAP_BITFS_ARENA, "name": "Fire Sea"},
]

for key in KEYS
{
    achievement(
        title=format("A Useless Key in {0}", key["name"]),
        description="This key doesn't do anything, but you got it anyways. Cool! (keep structure must be off)",
        points=5,
        trigger=(
            // keys only matter when keep structure is on
            keep_structure() == 0 &&

            // collect a key from the correct stage
            map_id() == key["map"] && collect_a_key()
        )
    )
}

for course in MAIN_COURSES
{
    achievement(
        title=format("Extremely Jumbled up in {0}", course["name"]),
        description=format("Collect all 7 stars in {0} on the EXTREME preset", course["name"]),
        points=5,
        trigger=(
            // previously did not have 7 stars from this stage
            prev(star_count_by_course(course["offset"])) == 6 &&

            // the player collected 7 stars from the same stage
            measured(star_count_by_course(course["offset"]) == 7,
                when=settings() == PRESET_EXTREME && is_set_seed() == 0 && map_id() == course["map"])
        )
    )
}

GREEN_DEMON_STARS = 10
achievement(
    title="Always on the Run",
    description=format("In one session, collect any {0} stars in Green Demon mode", GREEN_DEMON_STARS),
    points=10,
    trigger=(
        // green demon mode active in-game
        is_green_demon() == 1 && is_set_seed() == 0 &&

        // setup initial checkpoint hit
        once(prev(map_id()) <= MAP_MIN && in_game() && star_count() == 0) &&

        // collected any 10 stars
        prev(star_count()) < GREEN_DEMON_STARS && trigger_when(star_count() == GREEN_DEMON_STARS) &&

        // reset if the leaves their file
        never(leave_game())
    )
)

achievement(
    title="Shoutouts to Simpleflips",
    description="Collect any red coin star from one of the main courses in Green Demon mode",
    points=10,
    trigger=(
        // green demon mode active in-game
        in_game() && is_green_demon() == 1 && is_set_seed() == 0 &&

        // must have collected 8 red coins
        trigger_when(red_coin_count() == 8) &&

        // check all 15 main courses
        any_of(MAIN_COURSES, course => (
            // currently in the correct map/stage
            map_id() == course["map"] && stage_id() == course["c"] &&

            // trigger when the star is collected
            trigger_when(collect_star(course["red"]))
        ))
    )
)

SPRINT_MINUTES = 40
achievement(
    title="Better Than Sonic",
    description=format("In one session, defeat Bowser in under {0} minutes on the Sprint preset", SPRINT_MINUTES),
    points=10,
    trigger=(
        // start on new file on sprint preset
        once(start_game() && settings() == PRESET_SPRINT) &&

        // time passed is still under goal time
        disable_when(tally(SPRINT_MINUTES * 60 * 60, always_true()),
            until=leave_game()) &&

        // trigger on collecting grand star
        trigger_when(star_count() >= 30 && end_game())
    )
)

achievement(
    title="One-Stop Shopping",
    description="Collect all 7 stars in any course in one trip in non-stop mode",
    points=10,
    trigger=(
        // add a hit for each of the stars
        measured(tally_of(range(1,7), 7, x => once(collect_star(x) && last_star_stage() == stage_id())),
            when=in_game() && minimum_completion_settings() && is_nonstop() != 0) &&

        // reset if you ever leave the level
        never(prev(map_id()) != map_id()) &&

        // reset if this isn't a main course
        never(stage_id() < 1 || stage_id() > 15)
    )
)

achievement(
    title="Chaotic Coin Collection above the Tower",
    description="Without landing, collect all 8 red coins above the Tower of the Wing Cap",
    points=10,
    trigger=(
        // checkpoint hit upon entering the stage
        once(prev(map_id()) != MAP_CAP_WING && map_id() == MAP_CAP_WING) &&

        // trigger on collecting 8 red coins
        trigger_when(red_coin_count() == 8) &&

        // reset if this wing cap stage
        never(map_id() != MAP_CAP_WING) &&

        // reset if mario is ever standing on the ground
        never(prev(mario_y_pos()) > prev(mario_floor_height()) && mario_y_pos() <= mario_floor_height())
    )
)

achievement(
    title="A Randomizer in my Randomizer",
    description="Collect 100 coins in Tick Tock Clock while the clock is set to random (6:00)",
    points=10,
    trigger=(
        // randomize all required
        randomize_all() == 1 && is_set_seed() == 0 &&

        // in TTC with random clock state
        map_id() == MAP_TTC && ttc_clock_state() == TTC_RAND &&

        // trigger on collecting 100 coins
        trigger_when(coins() >= 100)
    )
)

STAR_COLLECT_SECONDS = 10
achievement(
    title="It's Just That Easy!",
    description=format("Collect a star within {0} seconds of entering a main course", STAR_COLLECT_SECONDS),
    points=1,
    trigger=(
        // no set seeds
        in_game() && is_set_seed() == 0 &&

        // checkpoint hit on entering a stage
        once(enter_level()) &&

        // trigger on collecting a star
        trigger_when(collect_a_star()) &&

        // pause if enough frames have passed, reset the timer
        // timer is 30 fps because that's how often the level_timer() updates, every other frame
        disable_when(repeated(STAR_COLLECT_SECONDS * 30, trans_active() == 0 && prev(level_timer()) != level_timer()),
            until=prev(map_id()) != map_id() || enter_level()) &&

        // reset if this isn't a main course
        never(stage_id() < 1 || stage_id() > 15)
    )
)

achievement(
    title="The Great Pink Bob-omb Scavenger Hunt",
    description=format("Unlock all {0} cannons in the game", length(CANNON_OFFSETS)),
    points=10,
    trigger=(
        // check if all cannons are open
        measured(sum_of(CANNON_OFFSETS, i => cannon_open(i)) == length(CANNON_OFFSETS),
            when=in_game() && is_set_seed() == 0 && randomize_all() == 1)
    )
)

LLL_SHELL_COINS = 50
achievement(
    title=format("Shell Surfing for {0} Hot Coins", LLL_SHELL_COINS),
    description=format("Collect {0} coins while riding a green shell in Lethal Lava Land", LLL_SHELL_COINS),
    points=5,
    trigger=(
        // measure the number of coins collected since starting to ride the shell
        measured(tally(LLL_SHELL_COINS, coins_hud() > prev(coins_hud())),
            when=
            (
                // correct settings
                randomize_all() == 1 && is_set_seed() == 0 &&

                // correct stage
                map_id() == MAP_LLL &&

                // checkpoint hit on starting to ride a shell
                once(!mario_is(prev(mario_action()), ACT_FLAG_RIDING_SHELL) && mario_is(mario_action(), ACT_FLAG_RIDING_SHELL))
            )
        ) &&

        // reset if mario is not riding a shell anymore
        never(!mario_is(mario_action(), ACT_FLAG_RIDING_SHELL)) &&

        // reset if leaving LLL
        never(map_id() != MAP_LLL)
    )
)

achievement(
    title="Holiday at the Fire Sea Coast",
    description="Collect the Fire Sea red coin star without taking damage",
    points=5,
    trigger=(
        // no set seeds
        is_set_seed() == 0 &&

        // checkpoint hit on entering the stage
        once(enter_level()) &&

        // trigger on collecting the red coin star
        trigger_when(red_coin_count() == 8 && collect_star(1)) &&

        // reset if not in fire sea
        never(map_id() != MAP_BITFS) &&

        // reset if mario takes any damage
        never(take_damage())
    )
)

leaderboard(
    title="70 Star Speedrun - Default",
    description="On the Default preset, collect 70 stars and defeat Bowser",

    start=(start_game() && settings() == PRESET_DEFAULT),
    cancel=leave_game(),
    submit=(star_count() >= 70 && end_game()),
    
    value=frame_count(),
    format="FRAMES",
    lower_is_better=true
)

leaderboard(id=95145,
    title="100 Star Speedrun - Extreme, Set Seed",
    description="On the Extreme preset, with seed 10509, collect 100 stars and defeat Bowser",

    start=(new_file_created() && seed() == 10509 && settings() == PRESET_EXTREME),
    cancel=leave_game(),
    submit=(star_count() >= 100 && end_game()),
    
    value=frame_count(),
    format="FRAMES",
    lower_is_better=true
)

leaderboard(
    title="Sprint to the Grand Star",
    description="On the Sprint preset, collect 30 stars and defeat Bowser",

    start=(start_game() && settings() == PRESET_SPRINT),
    cancel=leave_game(),
    submit=(star_count() >= 30 && end_game()),
    
    value=frame_count(),
    format="FRAMES",
    lower_is_better=true
)

leaderboard(
    title="Max Stars Damageless - Default",
    description="Collect as many stars as possible without taking damage on the Default preset",

    start=(start_game() && settings() == PRESET_DEFAULT),
    cancel=leave_game(),
    submit=(star_count() == 120 || end_game() || take_damage()),
    
    // value is the star count
    value=measured(star_count()),
    format="VALUE",
    lower_is_better=false
)