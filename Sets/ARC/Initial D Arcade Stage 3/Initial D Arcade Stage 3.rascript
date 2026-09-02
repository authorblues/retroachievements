// Initial D: Arcade Stage Ver. 3
// #ID = 19006

// HELPERS
NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function zfill(num, c)
{
	result = format("{0}", num)
	for i in range(0, 10)
	{
		if (length(result) >= c) return result
		result = format("0{0}", result)
	}
	return result
}

// should be (x & 0x01FFFFFF), but this will optimize better
function vptr(x) => dword(x) & 0x01FFFFFF
// function vptr(x) => dword(x) + 0xF4000000

// --- MEMORY --------------------------------------------------------------------

// $2F4B94: Game State [32 bit]
//          0x00000003 = X Conquered
function game_state() => dword(0x2F4B94)

// $2F4DE0: Race Complete [32 bit]
//          1 when race ends, 0 otherwise
function is_race_complete() => dword(0x2F4DE0)

// $31C99C: Mode [32 bit]
//          0 = Legend of the Street
//          1 = Time Attack
//          2 = The Bunta Challenge!!
function mode() => dword(0x31C99C)

// $31C9A0: Map [32 bit]
//          0 = Myogi
//          1 = Usui
//          2 = Akagi
//          3 = Akina
//          4 = Happogahara
//          5 = Irohazaka
//          6 = Shomaru
//          7 = Tsuchisaka
//          8 = Akina (Snow)
function map() => dword(0x31C9A0)

// $31C9A4: Map Time [32 bit]
//          0 = Day, 1 = Night
function map_time() => dword(0x31C9A4)

// $31C9A8: Map Direction [32 bit]
//          [00] 0 = Anti, 1 = Clockwise
//          [01] 0 = Anti, 1 = Clockwise
//          [02] 0 = Downhill, 1 = Uphill
//          [03] 0 = Downhill, 1 = Uphill
//          [04] 0 = Outbound, 1 = Inbound
//          [05] 0 = Downhill, 1 = Reverse
//          [06] 0 = Outbound, 1 = Inbound
//          [07] 0 = Outbound, 1 = Inbound
//          [08] 0 = Downhill, 1 = Uphill
function map_dir() => dword(0x31C9A8)

// $31C9AC: Car [32 bit]
//          0x00 = AE86 (Toyota / Trueno GT-APEX)
//          0x01 = AE86 (Toyota / Levin GT-APEX)
//          0x02 = AE85 (Toyota / Levin SR)
//          0x03 = SW20 (Toyota / MR2 G-Limited)
//          0x04 = ZZW30 (Toyota / MR-S S Edition)
//          0x05 = SXE10 (Toyota / Altezza RS-200)
//          0x06 = ST205 (Toyota / Celica GT-Four)
//          0x07 = BNR32 (Nissan / Skyline GT-R V-spec II)
//          0x08 = BNR34 (Nissan / Skyline GT-R V-spec II)
//          0x09 = S13 (Nissan / Silvia K's)
//          0x0a = S14 (Nissan / Silvia Q's)
//          0x0b = S14 (Nissan / Silvia K's Aero)
//          0x0c = S15 (Nissan / Silvia spec-R)
//          0x0d = RPS13 (Nissan / 180SX Type X)
//          0x0e = RPS13 (Nissan / Sileighty)
//          0x0f = EK9 (Honda / Civic Type R)
//          0x10 = EG6 (Honda / Civic SiR II)
//          0x11 = DC2 (Honda / Integra Type R)
//          0x12 = AP1 (Honda / S2000)
//          0x13 = CE9A (Mitsubishi / Lancer GSR Evolution III)
//          0x14 = CN9A (Mitsubishi / Lancer RS Evolution IV)
//          0x15 = CT9A (Mitsubishi / Lancer GSR Evolution VII)
//          0x16 = FD3S (Mazda / RX-7 Type R)
//          0x17 = FD3S (Mazda / RX-7 Spirit R Type A)
//          0x18 = FC3S (Mazda / RX-7 ∞ III)
//          0x19 = NA6CE (Mazda / Roadster S Special)
//          0x1a = NB8C (Mazda / Roadster RS)
//          0x1b = GC8 (Subaru / Impreza WRX STi Version VI)
//          0x1c = GDB (Subaru / Impreza WRX STi)
//          0x1d = GC8V (Subaru / Impreza WRX type R STi Version V) [Bunta]
//          0x1e = EA11R (Suzuki / Cappuccino)
//          0x1f = ER34 (Nissan / Skyline 25GT Turbo)
//          0x20 = CG9A (Mitsubishi / Lancer RS Evolution V)
//          0x21 = CP9A (Mitsubishi / Lancer GSR Evolution VI T.M.Edition)
//          0x22 = SE3P (Mazda / RX-8 Type S)
function car() => dword(0x31C9AC)

// $31C9B0: Rival Vehicle [32 bit]
function rival_car() => dword(0x31C9B0)

// $31C9B4: Story Mode Chapter [32 bit]
//          
//          -- Myogi (Easy)
//          0x00 = Iggy (Speed Stars) - 1*
//          0x01 = Kenji (Speed Stars) - 2*
//          0x02 = Shingo (Night Kids) - 3*
//          
//          -- Usui (Normal)
//          0x03 = Toru (Seven Star Racers) - 2*
//          0x04 = Kawai (Seven Star Racers) - 3*
//          0x05 = Maya & Simone (Impact Blue) - 4*
//          
//          -- Akagi (Hard)
//          0x06 = Two Guys from Tokyo - 3*
//          0x07 = Danny (Red Suns) - 4*
//          0x08 = K.T. (Red Suns) - 6*
//          
//          -- Akina (Hard)
//          0x09 = Cole (Speed Stars) - 3*
//          0x0a = Zack (Night Kids) - 5*
//          0x0b = Kyle (Emperor) - 6*
//          0x0c = Ry (Red Sun) - 7*
//          0x0d = Takumi - 8*
//          0x1e = Bunta ??
//          
//          -- Irohazaka (Expert)
//          0x0e = Hawk (Emperor) - 6*
//          0x0f = Kyle (Emperor) - 7*
//          0x10 = Caine - 8*
//          
//          -- Akina [Snow] (Expert)
//          0x11 = Miki - 7*
//          
//          -- Happogahara (Expert)
//          0x12 = Dice (Todoh Racing School) - 6*
//          0x13 = Smiley (Todoh Racing School) - 7*
//          0x14 = Touch (Todoh Graduate) - 8*
//          
//          -- Shomaru (Expert)
//          0x15 = Nobu (NW Saitama All-Star Team) - 6*
//          0x16 = Sid (NW Saitama All-Star Team) - 8*
//          0x17 = Aki (NW Saitama All-Star Team) - 8*
//          
//          -- Tsuchisaka (Expert)
//          0x18 = Kylie - 6*
//          0x19 = Ry (Project D) - 8*
//          0x1a = Man in Evo.V - 8*
//          0x1b = Man in Evo.VI - 9*
//          0x1c = K.T. (Project D) ??
//          0x1d = Tak (Project D) ??
function chapter() => dword(0x31C9B4)

// $31C9BC: Map Weather [32 bit]
//          0 = Dry, 1 = Wet
function map_weather() => dword(0x31C9BC)

// $31C9C8: License Name [5 x 32 bit]
//          0xa2-0xbb = A-Z
//          0xbc-0xc5 = 1-9..0
//          0xc6 = < (left angle)
//          0xc7 = > (right angle)
//          0xc8 = + (plus)
//          0xc9 = * (asterisk)
//          0xca = - (hyphen)
//          0xcb = = (equals)
//          0xcc = ; (semicolon)
//          0xcd = : (colon)
//          0xd2 = . (period)
//          0xd5 = ! (exclamation)
//          0xd6 = ? (question)
//          0xd7 = ( (left paren)
//          0xd8 = ) (right paren)
//          0xd9 = @ (at)
//          0xdc = space
function license_name() => dword(0x31C9C8)

// $31C9DC: Car Color [32 bit]
function car_color() => dword(0x31C9DC)

// $31C9E0: Transmission [32 bit]
//          0 = Automatic, 1 = Manual
function transmission() => dword(0x31C9E0)

// $31C9E4: Total License Points [32 bit]
function total_license_points() => dword(0x31C9E4)

// $31C9E8: License Name Length [32 bit]
function license_name_length() => dword(0x31C9E8)

// $31CA10: Defeated Opponents [31 bytes]
//          upper4 is a counter of times won against this racer (max 2?)
//          lower4 is a counter of times lost to this racer in this session
DEFEATED_OPPONENTS_TABLE = 0x31CA10
function has_defeated(i) => high4(DEFEATED_OPPONENTS_TABLE + i) / high4(DEFEATED_OPPONENTS_TABLE + i)
function rival_losses(i) => low4(DEFEATED_OPPONENTS_TABLE + i)

function required_wins() => sum_of(range(0,29), has_defeated)
function story_wins() => sum_of(range(0,30), has_defeated)

// $31CA30: Legend of the Streets Loop [32 bit]
//          increases upon defeating Takumi @ Tsuchisaka
function story_loop() => dword(0x31CA30)

// $31CA34: Customization Kit [8 bit]
function customization_kit() => byte(0x31CA34)

// $31CA40: Customization Status [8 bit]
//          0 = Normal (stock), max = 5?
function customization_status() => byte(0x31CA40)

// $31CDD4: Bunta Level - Myogi [32 bit]
// $31CDD8: Bunta Level - Usui [32 bit]
// $31CDDC: Bunta Level - Akagi [32 bit]
// $31CDE0: Bunta Level - Akina [32 bit]
// $31CDE4: Bunta Level - Happogahara [32 bit]
// $31CDE8: Bunta Level - Irohazaka [32 bit]
// $31CDEC: Bunta Level - Shomaru [32 bit]
// $31CDF0: Bunta Level - Tsuchisaka [32 bit]
function bunta_level(i) => dword(0x31CDD4 + i * 4)
function bunta_total() => sum_of(range(0,7), bunta_level)

// $31CE10: Plays Until Next Inspection [32 bit] ???
function plays_until_next_inspection() => dword(0x31CE10)

// $31CE34: Menu Timer [32 bit]
function menu_timer() => dword(0x31CE34)

// $31CE3C: BGM [8 bit]
//          0 = On, 1 = Off, 2 = Fix
function bgm() => byte(0x31CE3C)

// $31CE3E: Navigation Display [8 bit]
//          0 = On, 1 = Off, 2 = Paper Cup
function navigation_display() => byte(0x31CE3E)

// $31CE3F: Steering Control [8 bit]
//          0 = Loose, 8 = Stiff (4 = default)
function steering_control() => byte(0x31CE3F)

// $31CE40: Time Display [8 bit]
//          0 = Normal, 1 = Simple
function time_display() => byte(0x31CE40)

// $31CE41: Forced Quit [8 bit]
//          0 = Off, 1 = On
function forced_quit() => byte(0x31CE41)

// $31CE48: Wall Contacts [32 bit] (in-race)
function wall_contacts() => dword(0x31CE48)

// $31CE4C: Bunta's WRX Available [32 bit]
//          1 if available, 0 otherwise
function bunta_wrx_available() => dword(0x31CE4C)

// $8FF174: Race Data Pointer [32 bit]
//           
//           +0xF40003A4 = Car Data Pointer? [32 bit]
//           .. +0xF4000170 = Current Speed [Float]
//           
//           +0xF40003B0 = Paper Cup Pointer [32 bit]
//           .. +0xF400000C = cup anim left [32 bit], 0xffffffff (-1), 0-2 during splash
//           .. +0xF4000010 = cup anim right [32 bit], 0xffffffff (-1), 0-2 during splash
//           
//           +0xF4000414 = View Mode [32 bit]
//           (actually represents whether own car is rendered)
//           0 = First Person, 1 = Third Person
//           
//           +0xF400041C = Race Info [32 bit]
//           .. +0xF4000004 = add to total race time per frame [32 bit]
//           .. +0xF4000008 = total race time [32 bit]
//           .. +0xF4000044 = add to time remaining per frame [32 bit]
//           .. +0xF4000048 = time remaining [32 bit]
function race_data_ptr() => vptr(0x08FF174)

function car_data_ptr() => vptr(race_data_ptr() + 0x3A4)
function speed() => float(car_data_ptr() + 0x170)

function paper_cup_ptr() => vptr(race_data_ptr() + 0x3B0)
function paper_cup_L() => dword(paper_cup_ptr() + 0x0C)
function paper_cup_R() => dword(paper_cup_ptr() + 0x10)

function view_mode() => dword(race_data_ptr() + 0x414)

function race_info_ptr() => vptr(race_data_ptr() + 0x41C)
function race_time_raw() => dword(race_info_ptr() + 0x08)
function race_time() => race_time_raw() / 6000.0

TIME_REMAINING_ADDR = race_info_ptr() + 0x48
function time_remaining() => dword(TIME_REMAINING_ADDR) / 6000.0
function timer_exceeded() => bit7(TIME_REMAINING_ADDR+3) == 1 || dword(TIME_REMAINING_ADDR) == 0

// $8FF1D4: Race End Metadata Pointer [32 bit]
//          
//          +0xF40000E8 = Finishing Time
//          -1 while racing, final time once complete
function race_end_ptr() => vptr(0x08FF1D4)
function finishing_time_raw() => dword(race_end_ptr() + 0x0E8)
function finishing_time() => finishing_time_raw() / 6000.0

// $8FF36C: Race in Progress [32 bit]
//          1 while racing, 0 elsewhere
function is_racing() => dword(0x8FF36C)

// $8FF3DA: Headlights Disabled [8 bit]
//          0 = Enabled (default), 1 = Disabled
//          
//          Mirrored @ 0x008ff5d2
//          Mirrored @ 0x009008f6
function headlights_disabled() => byte(0x8FF3DA)

// $8FF482: Rival's Headlights Disabled [8 bit]
//          0 = Enabled (default), 1 = Disabled
function rival_headlights_disabled() => byte(0x8FF482)

// $900B1C: Front Tire 1 Not Grounded [32 bit]
// $900B20: Front Tire 2 Not Grounded [32 bit]
// $90102C: Back Tire 1 Not Grounded [32 bit]
// $901030: Back Tire 2 Not Grounded [32 bit]
function front_tire_1_not_grounded() => dword(0x900B1C)
function front_tire_2_not_grounded() => dword(0x900B20)
function back_tire_1_not_grounded() => dword(0x90102C)
function back_tire_2_not_grounded() => dword(0x901030)

// $900D98: Front Tire Info [Float]
// $9012A8: Back Tire Info [Float]
//          Counts down by 0.01 from 0.19 when going over jump
function front_tire_data() => float(0x900D98)
function back_tire_data() => float(0x9012A8)

// $900F00: Car X Position [Float]
// $900F04: Car Y Position [Float] (height)
// $900F08: Car Z Position [Float]
function car_x_pos() => float(0x900F00)
function car_y_pos() => float(0x900F04)
function car_z_pos() => float(0x900F08)

// $900E88: Gear [32 bit]
function gear() => dword(0x900E88)

// $9012E4: Max Speed (km/h) [Float]
function max_speed() => float(0x9012E4)

// $9012F8: Times Entered Ditches [32 bit]
function ditches() => dword(0x9012F8)

// $901650: Rival Advantage [Float] (not manipulable)
//          desynchronized by 2 frames, probably for display
//          positive is ahead, negative is behind
ADVANTAGE_ADDR = 0x901650
function advantage() => float(ADVANTAGE_ADDR)
function advantage_sign() => bit7(ADVANTAGE_ADDR+3)

// $91FB10: Analysis - Accel Percentage (0-1) [Float]
// $91FB14: Analysis - Brake Percentage (0-1) [Float]
// $91FB2C: Analysis - Times Entered Ditches [32 bit]
// $1DDBA9D: Street Racing Analysis Screen [32 bit]
//           1 while Analysis, 0 elsewhere
function analysis_screen() => dword(0x1DDBA9C)
function analysis_accel() => float(0x91FB10)
function analysis_brake() => float(0x91FB14)
function analysis_ditches() => dword(0x91FB2C)

// $91FB50: Analysis - Start Interval [32 bit]
// $91FB54: Analysis - Total Time [32 bit]
// $91FB58: Analysis - Segment 1 Time [32 bit]
// $91FB5C: Analysis - Segment 2 Time [32 bit]
// $91FB60: Analysis - Segment 3 Time [32 bit]
// $91FB64: Analysis - Segment 4 Time [32 bit]
function analysis_start_interval() => dword(0x91FB50)
function analysis_time() => dword(0x91FB54) / 6000.0
function analysis_segment_time(i) => dword(0x91FB58 + i * 4) / 6000.0

// $AA94C4: Wheel Dropped in Ditch [32 bit]
//          1 if using ditch, 0 otherwise
function is_using_ditch() => dword(0xAA94C4)

// $AA975C: Is Contacting Wall [32 bit]
//          1 if touching wall, 0 otherwise
function is_hitting_wall() => dword(0xAA975C)

// $BFF958: End of Race Music [ASCII Text]
//          
//          this address is the end of a filename that is consistently
//          written to this location when a race is ended (use 0x002f4de0 for this)
//          
//          read as [32 bit BE]
//          0x57494e2e = WIN.bin
//          0x4c4f5345 = LOSE.bin
//          0x54494d45 = TIMEUP.bin
function race_outcome_music_loaded() => dword_be(0xBFF94C) == 0x6f756e64
function race_outcome() => dword_be(0xBFF958)

// $1F98CC0: Race Results - Win/Lose [32 bit]
//           0 = Win, 1 = Lose
function results_winner() => dword(0x1F98CC0)

// $1F98CC4: Race Results - Section/Lap Count [32 bit]
function results_segment_count() => dword(0x1F98CC4)

// $1F98CC8: Race Results - Total Time [32 bit]
//           +100 from displayed time
function results_total_comp() => dword(0x1F98CC8) / 6000.0

// $1F98CCC: Race Results - Section/Lap 1 Time [32 bit]
// $1F98CD0: Race Results - Section/Lap 2 Time [32 bit]
// $1F98CD4: Race Results - Section/Lap 3 Time [32 bit]
// $1F98CD8: Race Results - Section/Lap 4 Time [32 bit]
function results_segment_time(i) => dword(0x1F98CCC + i * 4) / 6000.0 - 0.016667
function results_total_time() => sum_of(range(0,3, (i) => dword(0x1F98CCC + i * 4))) / 6000.0

// $1F98CDC: Race Results - Advantage Distance [Float]
function results_advantage() => float(0x1F98CDC)

// $1F98CE4: Race Results - Battle Points [32 bit]
// $1F98CE8: Race Results - Victory Bonus [32 bit]
// $1F98CEC: Race Results - Advantage Bonus [32 bit]
function results_battle_points() => dword(0x1F98CE4)
function results_victory_bonus() => dword(0x1F98CE8)
function results_advantage_bonus() => dword(0x1F98CEC)

// $1F9B92C: Street Racing Analysis - Dialogue Line #1 Pointer [32 bit]
// $1F9B930: Street Racing Analysis - Dialogue Line #2 Pointer [32 bit]
// $1F9B934: Street Racing Analysis - Dialogue Line #3 Pointer [32 bit]
function analysis_dialogue(i) => dword(0x1F9B92C + i * 4)

// $1FB6860: Analysis - Wall Contacts [32 bit]
function analysis_wall_contacts() => dword(0x1FB6860)

// $1FBB100: Race Results Pointer [32 bit]
//           
//           +F4000010 = Tuning Display
//           0=<No Display>
//           1=You now have #### tuning points
//           2=Tuning stage (Step)
//           3=<Installation SFX>
//           6=<Exiting Tuning>
//           7=Option # Customization Complete!!
//           8=Option # Customization Complete!!
RACE_RESULTS_PTR = 0x1FBB100
function race_results_screen() => dword(RACE_RESULTS_PTR) // != 0
function race_results_ptr() => vptr(RACE_RESULTS_PTR)

function tuning_display() => dword(race_results_ptr() + 0x010)

// --- MAIN DATA -------------------------------------------------------------------

STATE_CONQUERED = 3

MODE_STORY = 0
MODE_TIME = 1
MODE_BUNTA = 2

COURSE_MYOGI = 0
COURSE_USUI = 1
COURSE_AKAGI = 2
COURSE_AKINA = 3
COURSE_HAPPOGAHARA = 4
COURSE_IROHAZAKA = 5
COURSE_SHOMARU = 6
COURSE_TSUCHISAKA = 7
COURSE_AKINA_SNOW = 8

COURSES = [
    COURSE_MYOGI,
    COURSE_USUI,
    COURSE_AKAGI,
    COURSE_AKINA,
    COURSE_IROHAZAKA,
    COURSE_AKINA_SNOW,
    COURSE_HAPPOGAHARA,
    COURSE_SHOMARU,
    COURSE_TSUCHISAKA,
]

TIME_DAY = 0
TIME_NIGHT = 1

DIRECTION_ANY = -1
DIRECTION_NORMAL = 0
DIRECTION_ALT = 1

WEATHER_DRY = 0
WEATHER_WET = 1

TRANS_AUTO = 0
TRANS_MANUAL = 1

NAV_ON = 0
NAV_OFF = 1
NAV_CUP = 2

VIEW_FIRST = 0
VIEW_THIRD = 1

ONE_CAR_LENGTH = 4.2 // meters

OUTCOME_WIN = 0x57494e2e
OUTCOME_LOSE = 0x4c4f5345
OUTCOME_TIMEUP = 0x54494d45

RESULT_WIN = 0
RESULT_LOSE = 1

RIVAL_ACHIEVEMENTS = [
    {"id": 0x00, "points": 2, "course": COURSE_MYOGI, "title": "Lonely Driver"},
    {"id": 0x01, "points": 2, "course": COURSE_MYOGI, "title": "Speedy Speed Boy"},
    {"id": 0x02, "points": 3, "course": COURSE_MYOGI, "title": "Downhill Specialist"},
    {"id": 0x03, "points": 3, "course": COURSE_USUI, "title": "The Downhill Kamikaze"},
    {"id": 0x04, "points": 3, "course": COURSE_USUI, "title": "Seven Star Leader"},
    {"id": 0x05, "points": 4, "course": COURSE_USUI, "title": "Stacked Two from Impact Blue"},
    {"id": 0x06, "points": 4, "course": COURSE_AKAGI, "title": "Extreme-Ultra-Super-Late-Braking"},
    {"id": 0x07, "points": 4, "course": COURSE_AKAGI, "title": "Rain Condition Specialist"},
    {"id": 0x08, "points": 5, "course": COURSE_AKAGI, "title": "KANSEI DORIFTU"},
    {"id": 0x09, "points": 4, "course": COURSE_AKINA, "title": "Star of the SpeedStars"},
    {"id": 0x0a, "points": 4, "course": COURSE_AKINA, "title": "Black Lightning"},
    {"id": 0x0b, "points": 4, "course": COURSE_AKINA, "title": "Race Circuit Superiority"},
    {"id": 0x0c, "points": 5, "course": COURSE_AKINA, "title": "The White Comet"},
    {"id": 0x0d, "points": 5, "course": COURSE_AKINA, "title": "The Ghost of Akina"},
    {"id": 0x0e, "points": 5, "course": COURSE_IROHAZAKA, "title": "Hunting the Hawk"},
    {"id": 0x0f, "points": 5, "course": COURSE_IROHAZAKA, "title": "The Emperor of Daiya River"},
    {"id": 0x10, "points": 5, "course": COURSE_IROHAZAKA, "title": "The Go-Kart Prodigy"},
    {"id": 0x11, "points": 10, "course": COURSE_AKINA_SNOW, "title": "Glacial Drift"},
    {"id": 0x12, "points": 5, "course": COURSE_HAPPOGAHARA, "title": "Rolling the Dice"},
    {"id": 0x13, "points": 5, "course": COURSE_HAPPOGAHARA, "title": "Grin and Bear It"},
    {"id": 0x14, "points": 5, "course": COURSE_HAPPOGAHARA, "title": "The Old Boys Club"},
    {"id": 0x15, "points": 5, "course": COURSE_SHOMARU, "title": "Ope! Lemme Just Sneak Right Past Ya Here"},
    {"id": 0x16, "points": 5, "course": COURSE_SHOMARU, "title": "Rally in the Valley"},
    {"id": 0x17, "points": 5, "course": COURSE_SHOMARU, "title": "Thunder in Shomaru Pass"},
    {"id": 0x18, "points": 5, "course": COURSE_TSUCHISAKA, "title": "Lovergirl"},
    {"id": 0x19, "points": 5, "course": COURSE_TSUCHISAKA, "title": "Fastest Racing Theory"},
    {"id": 0x1a, "points": 5, "course": COURSE_TSUCHISAKA, "title": "Dirty Deeds"},
    {"id": 0x1b, "points": 5, "course": COURSE_TSUCHISAKA, "title": "Slicking the Track"},
    {"id": 0x1c, "points": 10, "course": COURSE_TSUCHISAKA, "title": "The Rotary Brothers"},
    {"id": 0x1d, "points": 10, "course": COURSE_TSUCHISAKA, "title": "The Fastest Team in Gunma"},
    {"id": 0x1e, "points": 25, "course": COURSE_AKINA, "title": "Tofu Man Ascendant"},
]

ConqueredRivals = [
    COURSE_MYOGI,
    COURSE_USUI,
    COURSE_AKAGI,
    // COURSE_AKINA,
    COURSE_IROHAZAKA,
    // COURSE_AKINA_SNOW,
    COURSE_HAPPOGAHARA,
    COURSE_SHOMARU,
    COURSE_TSUCHISAKA,
]

// for time trials
function faster_than(min, sec, ms) => {
    "trigger": (finishing_time_raw() <= ((min * 60 + sec) * 1000 + ms) * 6),
    "display": format("{0}'{1}\"{2}", min, zfill(sec, 2), zfill(ms, 3)),
}

// best times -- https://idrankings.com/initiald/v3/rankings
TARGET_TIMES = [
    {"course": COURSE_MYOGI, "d": DIRECTION_ANY, "time": faster_than(2, 59, 500)}, // 2'59
    {"course": COURSE_USUI, "d": DIRECTION_ANY, "time": faster_than(3, 00, 000)}, // 3'00
    {"course": COURSE_AKAGI, "d": DIRECTION_NORMAL, "time": faster_than(2, 35, 000)}, // 2'35
    {"course": COURSE_AKAGI, "d": DIRECTION_ALT, "time": faster_than(2, 40, 000)}, // 2'40
    {"course": COURSE_AKINA, "d": DIRECTION_NORMAL, "time": faster_than(3, 16, 000)}, // 3'16
    {"course": COURSE_AKINA, "d": DIRECTION_ALT, "time": faster_than(3, 25, 000)}, // 3'25
    {"course": COURSE_IROHAZAKA, "d": DIRECTION_NORMAL, "time": faster_than(3, 15, 000)}, // 3'15
    {"course": COURSE_IROHAZAKA, "d": DIRECTION_ALT, "time": faster_than(3, 25, 000)}, // 3'25
    {"course": COURSE_AKINA_SNOW, "d": DIRECTION_NORMAL, "time": faster_than(3, 40, 000)}, // 3'40
    {"course": COURSE_AKINA_SNOW, "d": DIRECTION_ALT, "time": faster_than(3, 50, 000)}, // 3'50
    {"course": COURSE_HAPPOGAHARA, "d": DIRECTION_ANY, "time": faster_than(2, 39, 000)}, // 2'39
    {"course": COURSE_SHOMARU, "d": DIRECTION_ANY, "time": faster_than(3, 22, 000)}, // 3'22
    {"course": COURSE_TSUCHISAKA, "d": DIRECTION_ANY, "time": faster_than(2, 58, 000)}, // 2'58
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// returns true when the race is being setup
function race_setup() => prev(is_racing()) == 0 && is_racing() != 0

// returns true when the player crosses the finish line
function complete_race() => is_racing() != 0 && prev(is_race_complete()) == 0 && is_race_complete() != 0 && !timer_exceeded()

// returns true when the player wins a race
function win_race() => is_racing() != 0 && is_race_complete() != 0 && race_outcome() == OUTCOME_WIN

// returns true when the paper cup display spills water in either direction
function water_spills() => (
    (prev(paper_cup_L()) == 1 && paper_cup_L() == 2) ||
    (prev(paper_cup_R()) == 1 && paper_cup_R() == 2)
)

// returns true when overtaken
function rival_overtaken() => is_racing() != 0 && prev(advantage()) <= 0 && advantage() > 0
function player_overtaken() => is_racing() != 0 && prev(advantage()) >= 0 && advantage() < 0

// returns true if a ditch has been used recently
function used_ditch_recently(n) => once(is_using_ditch() == 1 && never(repeated(n, is_using_ditch() == 0 && never(is_using_ditch() == 1))))

// check how many tires are grounded
function num_tires_grounded() => 4 - (
    front_tire_1_not_grounded() + front_tire_2_not_grounded() + 
    back_tire_1_not_grounded() + back_tire_2_not_grounded()
)

// --- RICH PRESENCE -------------------------------------------------------------------

CarLookup = {
    0x00: "Trueno GT-APEX",
    0x01: "Levin GT-APEX",
    0x02: "Levin SR",
    0x03: "MR2 G-Limited",
    0x04: "MR-S S Edition",
    0x05: "Altezza RS-200",
    0x06: "Celica GT-Four",
    0x07: "Skyline GT-R V-spec II",
    0x08: "Skyline GT-R V-spec II",
    0x09: "Silvia K's",
    0x0a: "Silvia Q's",
    0x0b: "Silvia K's Aero",
    0x0c: "Silvia spec-R",
    0x0d: "180SX Type X",
    0x0e: "Sileighty",
    0x0f: "Civic Type R",
    0x10: "Civic SiR II",
    0x11: "Integra Type R",
    0x12: "S2000",
    0x13: "Lancer GSR Evolution III",
    0x14: "Lancer RS Evolution IV",
    0x15: "Lancer GSR Evolution VII",
    0x16: "RX-7 Type R",
    0x17: "RX-7 Spirit R Type A",
    0x18: "RX-7 ∞ III",
    0x19: "Roadster S Special",
    0x1a: "Roadster RS",
    0x1b: "Impreza WRX STi Version VI",
    0x1c: "Impreza WRX STi",
    0x1d: "Impreza WRX type R STi Version V",
    0x1e: "Cappuccino",
    0x1f: "Skyline 25GT Turbo",
    0x20: "Lancer RS Evolution V",
    0x21: "Lancer GSR Evolution VI T.M.Edition",
    0x22: "RX-8 Type S",
}

CarShortLookup = {
    0x00: "AE86",
    0x01: "AE86",
    0x02: "AE85",
    0x03: "SW20",
    0x04: "ZZW30",
    0x05: "SXE10",
    0x06: "ST205",
    0x07: "BNR32",
    0x08: "BNR34",
    0x09: "S13",
    0x0a: "S14",
    0x0b: "S14",
    0x0c: "S15",
    0x0d: "RPS13",
    0x0e: "RPS13",
    0x0f: "EK9",
    0x10: "EG6",
    0x11: "DC2",
    0x12: "AP1",
    0x13: "CE9A",
    0x14: "CN9A",
    0x15: "CT9A",
    0x16: "FD3S",
    0x17: "FD3S",
    0x18: "FC3S",
    0x19: "NA6CE",
    0x1a: "NB8C",
    0x1b: "GC8",
    0x1c: "GDB",
    0x1d: "GC8V",
    0x1e: "EA11R",
    0x1f: "ER34",
    0x20: "CG9A",
    0x21: "CP9A",
    0x22: "SE3P",
}

MapShortLookup = {
    COURSE_MYOGI: "Myogi",
    COURSE_USUI: "Usui",
    COURSE_AKAGI: "Akagi",
    COURSE_AKINA: "Akina",
    COURSE_HAPPOGAHARA: "Happogahara",
    COURSE_IROHAZAKA: "Irohazaka",
    COURSE_SHOMARU: "Shomaru",
    COURSE_TSUCHISAKA: "Tsuchisaka",
    COURSE_AKINA_SNOW: "Akina",
}

MapLookup = {
    COURSE_MYOGI: "Mt. Myogi",
    COURSE_USUI: "Usui Pass",
    COURSE_AKAGI: "Mt. Akagi",
    COURSE_AKINA: "Mt. Akina",
    COURSE_HAPPOGAHARA: "Happogahara",
    COURSE_IROHAZAKA: "Irohazaka",
    COURSE_SHOMARU: "Shomaru Pass",
    COURSE_TSUCHISAKA: "Tsuchisaka Pass",
    COURSE_AKINA_SNOW: "Mt. Akina",
}

TeamLookup = {
    COURSE_MYOGI: "NightKids",
    COURSE_USUI: "Impact Blue",
    COURSE_AKAGI: "RedSuns",
    COURSE_AKINA: "SpeedStars",
    COURSE_HAPPOGAHARA: "Todoh Racing School",
    COURSE_IROHAZAKA: "Emperor",
    COURSE_SHOMARU: "NW Saitama",
    COURSE_TSUCHISAKA: "Project D",
    COURSE_AKINA_SNOW: "SpeedStars",
}

function dirmap(c, d) => c * 2 + d
DirLookup = {
    dirmap(COURSE_MYOGI, DIRECTION_NORMAL): "↪️",
    dirmap(COURSE_MYOGI, DIRECTION_ALT): "↩️",
    dirmap(COURSE_USUI, DIRECTION_NORMAL): "↪️",
    dirmap(COURSE_USUI, DIRECTION_ALT): "↩️",
    dirmap(COURSE_AKAGI, DIRECTION_NORMAL): "⬇️",
    dirmap(COURSE_AKAGI, DIRECTION_ALT): "⬆️",
    dirmap(COURSE_AKINA, DIRECTION_NORMAL): "⬇️",
    dirmap(COURSE_AKINA, DIRECTION_ALT): "⬆️",
    dirmap(COURSE_HAPPOGAHARA, DIRECTION_NORMAL): "⬅️",
    dirmap(COURSE_HAPPOGAHARA, DIRECTION_ALT): "➡️",
    dirmap(COURSE_IROHAZAKA, DIRECTION_NORMAL): "⬇️",
    dirmap(COURSE_IROHAZAKA, DIRECTION_ALT): "⬆️",
    dirmap(COURSE_SHOMARU, DIRECTION_NORMAL): "⬅️",
    dirmap(COURSE_SHOMARU, DIRECTION_ALT): "➡️",
    dirmap(COURSE_TSUCHISAKA, DIRECTION_NORMAL): "⬅️",
    dirmap(COURSE_TSUCHISAKA, DIRECTION_ALT): "➡️",
    dirmap(COURSE_AKINA_SNOW, DIRECTION_NORMAL): "⬇️",
    dirmap(COURSE_AKINA_SNOW, DIRECTION_ALT): "⬆️",
}

DirName = {
    dirmap(COURSE_MYOGI, DIRECTION_NORMAL): "Counter-Clockwise",
    dirmap(COURSE_MYOGI, DIRECTION_ALT): "Clockwise",
    dirmap(COURSE_USUI, DIRECTION_NORMAL): "Counter-Clockwise",
    dirmap(COURSE_USUI, DIRECTION_ALT): "Clockwise",
    dirmap(COURSE_AKAGI, DIRECTION_NORMAL): "Downhill",
    dirmap(COURSE_AKAGI, DIRECTION_ALT): "Uphill",
    dirmap(COURSE_AKINA, DIRECTION_NORMAL): "Downhill",
    dirmap(COURSE_AKINA, DIRECTION_ALT): "Uphill",
    dirmap(COURSE_HAPPOGAHARA, DIRECTION_NORMAL): "Outbound",
    dirmap(COURSE_HAPPOGAHARA, DIRECTION_ALT): "Inbound",
    dirmap(COURSE_IROHAZAKA, DIRECTION_NORMAL): "Downhill",
    dirmap(COURSE_IROHAZAKA, DIRECTION_ALT): "Reverse",
    dirmap(COURSE_SHOMARU, DIRECTION_NORMAL): "Outbound",
    dirmap(COURSE_SHOMARU, DIRECTION_ALT): "Inbound",
    dirmap(COURSE_TSUCHISAKA, DIRECTION_NORMAL): "Outbound",
    dirmap(COURSE_TSUCHISAKA, DIRECTION_ALT): "Inbound",
    dirmap(COURSE_AKINA_SNOW, DIRECTION_NORMAL): "Downhill",
    dirmap(COURSE_AKINA_SNOW, DIRECTION_ALT): "Uphill",
}

function weathermap(c, w) => c * 2 + w
WeatherLookup = {
    weathermap(COURSE_MYOGI, WEATHER_WET): "💧",
    weathermap(COURSE_USUI, WEATHER_WET): "💧",
    weathermap(COURSE_AKAGI, WEATHER_WET): "💧",
    weathermap(COURSE_AKINA, WEATHER_WET): "💧",
    weathermap(COURSE_HAPPOGAHARA, WEATHER_WET): "💧",
    weathermap(COURSE_IROHAZAKA, WEATHER_WET): "💧",
    weathermap(COURSE_SHOMARU, WEATHER_WET): "💧",
    weathermap(COURSE_TSUCHISAKA, WEATHER_WET): "💧",
    weathermap(COURSE_AKINA_SNOW, WEATHER_WET): "❄️",
}

DayTimeLookup = {
    TIME_DAY: "☀️",
    TIME_NIGHT: "🌙",
}

RivalLookup = {
    0x00: "Iggy",
    0x01: "Kenji",
    0x02: "Shingo",
    0x03: "Toru",
    0x04: "Kawai",
    0x05: "Maya & Simone",
    0x06: "Two Guys from Tokyo",
    0x07: "Danny",
    0x08: "K.T.",
    0x09: "Cole",
    0x0a: "Zack",
    0x0b: "Kyle",
    0x0c: "Ry",
    0x0d: "Takumi",
    0x0e: "Hawk",
    0x0f: "Kyle",
    0x10: "Caine",
    0x11: "Miki",
    0x12: "Dice",
    0x13: "Smiley",
    0x14: "Touch",
    0x15: "Nobu",
    0x16: "Sid",
    0x17: "Aki",
    0x18: "Kylie",
    0x19: "Ry",
    0x1a: "Man in Evo.V",
    0x1b: "Man in Evo.VI",
    0x1c: "K.T.",
    0x1d: "Tak",
    0x1e: "Bunta",
}

SignLookup = {
    0: "+",
    1: "",
}

RacerLevelLookup = {
    0: "",
    1: " ⭐",
    2: " ⭐⭐",
    3: " ⭐⭐⭐",
}

// general lookups
rp_course = rich_presence_lookup("Course", map(), MapShortLookup, fallback="")
rp_dir = rich_presence_lookup("Direction", dirmap(map(), map_dir()), DirLookup, fallback="")
rp_weather = rich_presence_lookup("Weather", weathermap(map(), map_weather()), WeatherLookup, fallback="")
rp_time = rich_presence_lookup("DayTime", map_time(), DayTimeLookup, fallback=DayTimeLookup[TIME_DAY])
rp_player_car = rich_presence_lookup("Car", car(), CarLookup, fallback=CarLookup[0x00])
rp_player_short = rich_presence_lookup("CarShort", car(), CarShortLookup, fallback=CarShortLookup[0x00])
rp_race_time = rich_presence_value("_Centiseconds", (race_time() - 0.033333) * 100, "MILLISECS")
rp_race_complete_time = rich_presence_value("_Centiseconds", finishing_time() * 100, "MILLISECS")
rp_license_pts = rich_presence_value("_Score", total_license_points(), "SCORE")

rp_adv_sign = rich_presence_lookup("Sign", advantage_sign(), SignLookup, fallback="+")
rp_adv = rich_presence_value("_Float1", advantage(), "FLOAT1")

// story mode lookups
rp_chapter = rich_presence_value("_Number", chapter()+1, "VALUE")
rp_rival = rich_presence_lookup("Rival", chapter(), RivalLookup, fallback="Bunta")
rp_rival_car = rich_presence_lookup("Car", rival_car(), CarLookup, fallback=CarLookup[0x00])
rp_rival_short = rich_presence_lookup("CarShort", rival_car(), CarShortLookup, fallback=CarShortLookup[0x00])
rp_story_wins = rich_presence_value("_Number", story_wins(), "VALUE")

rp_racer_level = rich_presence_lookup("RacerLevel", story_loop(), RacerLevelLookup, fallback=" 🌟")
rp_racer_level_num = rich_presence_value("_Number", story_loop(), "VALUE")

// time trials
rp_analysis_time = rich_presence_value("_Centiseconds", analysis_time() * 100, "MILLISECS")

// Bunta's challenge
rp_bunta_stars = rich_presence_value("_Number", bunta_level(map()), "VALUE")
rp_bunta_total = rich_presence_value("_Number", bunta_total(), "VALUE")

rich_presence_conditional_display(is_racing() != 0 && mode() == MODE_STORY,
    "📖 Chapter {8}: vs {9}{10} ({6}{7}m) | 🚩 {0} {1}{2}{3} | 🚗 {4} ({5})",
    rp_course, rp_dir, rp_weather, rp_time,
    rp_player_car, rp_player_short,
    rp_adv_sign, rp_adv,
    rp_chapter, rp_rival, rp_racer_level
)

rich_presence_conditional_display(is_racing() != 0 && mode() == MODE_TIME && is_race_complete() != 0,
    "⏱️ Time Trial ({6}) | 🚩 {0} {1}{2}{3} | 🚗 {4} ({5})",
    rp_course, rp_dir, rp_weather, rp_time,
    rp_player_car, rp_player_short,
    rp_race_complete_time
)

rich_presence_conditional_display(is_racing() != 0 && mode() == MODE_TIME,
    "⏱️ Time Trial ({6}) | 🚩 {0} {1}{2}{3} | 🚗 {4} ({5})",
    rp_course, rp_dir, rp_weather, rp_time,
    rp_player_car, rp_player_short,
    rp_race_time
)

rich_presence_conditional_display(analysis_screen() != 0 && mode() == MODE_TIME,
    "⏱️ Training Analysis ({6}) | 🚩 {0} {1}{2}{3} | 🚗 {4} ({5})",
    rp_course, rp_dir, rp_weather, rp_time,
    rp_player_car, rp_player_short,
    rp_analysis_time
)

rich_presence_conditional_display(is_racing() != 0 && mode() == MODE_BUNTA,
    "⚔️🏆 Challenging Bunta ({8}) ({9}⭐) ({6}{7}m) | 🚩 {0} {1}{2}{3} | 🚗 {4} ({5})",
    rp_course, rp_dir, rp_weather, rp_time,
    rp_player_car, rp_player_short,
    rp_adv_sign, rp_adv,
    rp_rival_short, rp_bunta_stars
)

rich_presence_conditional_display(license_name_length() != 0,
    "Setting up | 🚗 {0} ({1}) | {2} pts | Story 🏆{3}/31{4} | Bunta ✨{5}",
    rp_player_car, rp_player_short,
    rp_license_pts,
    rp_story_wins, rp_racer_level,
    rp_bunta_total
)

rich_presence_display(
    "Setting up for the next race!"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

for r in RIVAL_ACHIEVEMENTS
{
    c = r["course"]
    cname = MapLookup[c]
    if (c == COURSE_AKINA_SNOW)
        cname = cname + " in the snow"

    achievement(
        title=r["title"],
        description=format("Defeat {0} on {1} in Legend of the Street", RivalLookup[r["id"]], cname),
        points=r["points"],
        type=if_else(r["id"] == 0x1e, "", "progression"),
        trigger=(
            // racing in the correct mode
            mode() == MODE_STORY && is_racing() != 0 &&
            
            // win in the correct chapter
            chapter() == r["id"] && win_race()
        )
    )
}

for c in ConqueredRivals
{
    cname = MapShortLookup[c]
    
    course_rivals = []
    for r in RIVAL_ACHIEVEMENTS
        if (r["course"] == c) array_push(course_rivals, r["id"])
    rivals_cleared = sum_of(course_rivals, has_defeated)
    num_rivals = length(course_rivals)

    achievement(
        title=format("{0} Conquered", cname),
        description=format("Defeat all rivals on {0} in Legend of the Street", cname),
        points=10,
        trigger=(
            // correct map
            map() == c &&

            (
                // watching the "X Conquered" screen for the correct amount of time
                repeated(72, game_state() == STATE_CONQUERED && never(game_state() != STATE_CONQUERED)) || 

                // or the "X Conquered" screen has been dismissed
                (prev(game_state()) == STATE_CONQUERED && game_state() != STATE_CONQUERED)
            ) &&

            // all rivals are cleared
            rivals_cleared == num_rivals
        )
    )
}

achievement(
    title="I Wanna Be the Very Best",
    description="Become the greatest racer in Kanto in the Legend of the Street mode",
    points=25,
    type="win_condition",
    trigger=(prev(required_wins()) == 29 && required_wins() == 30)
)

for trial in TARGET_TIMES
{
    cname = MapShortLookup[trial["course"]]
    cdesc = MapLookup[trial["course"]]
    if (trial["course"] == COURSE_AKINA_SNOW)
    {
        cname = cname + " (Snow)"
        cdesc = cdesc + " in the snow"
    }

    dtrigger = always_true()
    dirdesc = ""
    title = format("{0} Dominated - {1}", TeamLookup[trial["course"]], cname)

    if (trial["d"] != DIRECTION_ANY)
    {
        dirname = DirName[dirmap(trial["course"], trial["d"])]
        dtrigger = (map_dir() == trial["d"])
        cdesc = cdesc + " " + dirname
        title = title + " " + dirname
    }

    achievement(
        title=title,
        description=format("Clear {0} on any mode in under {1}", cdesc, trial["time"]["display"]),
        points=10,
        trigger=(
            // check if this is the correct course and direction
            map() == trial["course"] && dtrigger &&

            // check if the race has completed and it is less than the cutoff time
            complete_race() && trial["time"]["trigger"]
        )
    )
}

achievement(
    title="Mr. X Defeated",
    description="Defeat Bunta on any course in Bunta's Challenge",
    points=5,
    trigger=(is_racing() != 0 && bunta_level(map()) - prev(bunta_level(map())) == 1)
)

BUNTA_THRESHOLD = 5
for c in range(0,7)
{
    achievement(
        title=format("Bunta's Challenge - {0} Mastery", MapShortLookup[c]),
        description=format("Reach Bunta level {0} on {1}", BUNTA_THRESHOLD, MapLookup[c]),
        points=10,
        trigger=(
            // racing on the correct map
            is_racing() != 0 && map() == c && 
        
            // reach the correct Bunta level for the course
            prev(bunta_level(c)) == BUNTA_THRESHOLD - 1 && bunta_level(c) == BUNTA_THRESHOLD
        )
    )
}

achievement(
    title="Machine Gun Shifting",
    description="Win a race against any rival with manual transmission",
    points=1,
    trigger=(transmission() == TRANS_MANUAL && win_race())
)

achievement(
    title="The Whole Kit and Caboodle",
    description="Complete any car's customization kit",
    points=10,
    trigger=(
        // showing the correct screen
        is_racing() == 0 && race_results_screen() != 0 &&

        // tuning display is showing "Customization Complete" screen
        prev(tuning_display()) == 7 && tuning_display() == 8
    )
)

achievement(
    title="Stay Hydrated",
    description="Replace the in-game navigation display with a paper cup",
    points=1,
    trigger=(is_racing() != 0 && navigation_display() == NAV_CUP)
)

achievement(
    title="Perfect Tofu Delivery",
    description="Complete Akina downhill without spilling any water",
    points=5,
    trigger=(
        // correct course and direction
        map() == COURSE_AKINA && map_dir() == DIRECTION_NORMAL &&
        
        // using the paper cup
        navigation_display() == NAV_CUP &&

        // checkpoint hit on setting up race
        once(race_setup()) &&

        // trigger when the course is completed
        trigger_when(complete_race()) &&

        // reset if water spills at any point
        never(water_spills()) &&

        // reset if we leave the race
        never(is_racing() == 0)
    )
)

achievement(
    title="The Element of Surprise",
    description="Overtake a racer at night with your headlights disabled",
    points=2,
    trigger=(
        // racing against a rival on a night course
        is_racing() != 0 && mode() != MODE_TIME && map_time() == TIME_NIGHT &&

        // check if lights are disabled
        once(advantage() <= ONE_CAR_LENGTH && headlights_disabled() == 1) &&

        // reset if the lights are turned on
        never(headlights_disabled() == 0) &&

        // overtaking when headlights are off
        trigger_when(advantage() >= ONE_CAR_LENGTH)
    )
)

LARGE_LEAD = 100
achievement(
    title="But a Distant Memory",
    description=format("Defeat a rival by more than {0}m on any course other than Myogi", LARGE_LEAD),
    points=5,
    trigger=(
        // racing against a rival on any course other than Myogi
        is_racing() != 0 && mode() != MODE_TIME && map() != COURSE_MYOGI &&

        // if you win with a large enough lead
        advantage() >= LARGE_LEAD && trigger_when(complete_race())
    )
)

achievement(
    title="Entry Gutter Run",
    description="Overtake a rival by dropping a wheel into a drainage ditch",
    points=4,
    trigger=(
        // racing against a rival
        is_racing() != 0 && mode() != MODE_TIME &&

        // if a rival is overtaken while using a ditch
        used_ditch_recently(60) && rival_overtaken()
    )
)

achievement(
    title="Cutting Corners",
    description="Use Ken Koshigawa's secret technique to jump off the ledges on Irohazaka downhill",
    points=3,
    trigger=(map() == COURSE_IROHAZAKA && map_dir() == DIRECTION_NORMAL && num_tires_grounded() < 2)
)

/*
achievement(
    title="Blind Attack!!",
    description="Watch a rival turn off their headlights in your rear view mirror",
    points=1,
    trigger=(
        // racing against a rival
        is_racing() != 0 && mode() != MODE_TIME &&

        // if you can see your rear view mirror
        view_mode() == VIEW_FIRST &&
        
        // this should only be possible at night
        map_time() == TIME_NIGHT &&

        // rival turned off their headlights
        prev(rival_headlights_disabled()) == 0 && rival_headlights_disabled() == 1
    )
)
*/

achievement(
    title="Take It For a Test Drive",
    description="Unlock and purchase Bunta's Impreza WRX type R STi Version V",
    points=1,
    trigger=(bunta_wrx_available() == 1 && car() == 0x1d)
)

// --- LEADERBOARDS -------------------------------------------------------------------

lb_id = 113795
for c in COURSES
for d in range(0,1)
{
    cname = MapShortLookup[c]
    cdesc = MapLookup[c]
    dname = DirName[dirmap(c, d)]

    if (c == COURSE_AKINA_SNOW)
    {
        cname = cname + " (Snow)"
        cdesc = cdesc + " in the snow"
    }

    leaderboard(id=lb_id,
        title=format("{0} - {1} Specialist", cname, dname),
        description=format("Clear {0} {1} as quickly as possible in any conditions", cdesc, dname),

        start=(map() == c && map_dir() == d && complete_race() && finishing_time() > 0),
        cancel=always_false(),
        submit=always_true(),

        value=finishing_time() * 100,
        format="MILLISECS",
        lower_is_better=true
    )
    lb_id = lb_id + 1
}