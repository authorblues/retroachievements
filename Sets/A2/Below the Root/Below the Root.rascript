// Below the Root
// #ID = 14317
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0019: X Position [8 bit] (0-39)
function xpos() => byte(0x0019)

// $001A: Y Position [8 bit] (0-19)
function ypos() => byte(0x001A)

// $001B: Current Screen [16 bit]
function screen() => word(0x001B)

// $0020: Character [8 bit]
//        0 = Neric (Kindar M, 20 stamina, 5 spirit)
//        1 = Genaa (Kindar F, 20 stamina, 0 spirit)
//        2 = Herd (Erdling M, 20 stamina, 5 spirit)
//        3 = Pomma (Kindar F child, 10 stamina, 10 spirit)
//        4 = Charn (Erdling M child, 15 stamina, 5 spirit)
function character() => byte(0x0020)

// $0021: Time of Day [8 bit]
//        0 = Early Morning
//        1 = Late Morning
//        2 = Early Afternoon
//        3 = Late Afternoon
//        4 = Early Evening
//        5 = Late Evening
//        6 = Midnight
//        7 = Late Night
function time_of_day() => byte(0x0021)

// $0022: Day [8 bit]
//        game ends when ticking over 50->51
//        
//        ranking at the end is dependent on days taken
//        01-14 = Master Quester
//        15-29 = Highly Gifted Quester
//        30-50 = Gifted Quester
function day() => byte(0x0022)

// $0023: Spirit Level [8 bit]
function spirit_level() => byte(0x0023)

// $0024: Food Level [8 bit]
function food_level() => byte(0x0024)

// $0025: Rest Level [8 bit]
function rest_level() => byte(0x0025)

// $0026: Stamina [8 bit]
function stamina() => byte(0x0026)

// $0027: Spirit Limit [8 bit]
function spirit_limit() => byte(0x0027)

// $0037: Permission to Take [8 bit] (0/1)
function permission_to_take() => byte(0x0037)

// $0067: Indoors [8 bit]
//        0 = outdoors
//        1 = indoors
//        
//        since some screens are tiled close together, this value says whether indoor areas should be blank screens or actual indoors
function indoors() => byte(0x0067)

// $0070: Carry Weight [8 bit]
//        token weighs 1
//        everything else weighs 5?
function carry_weight() => byte(0x0070)

// $0071: Menu Selection X [8 bit]
//        
//        As 16-bit:
//        0x0000 = Pause
//        0x0001 = Take
//        0x0002 = Drop
//        0x0003 = Examine
//        0x0004 = Status
//        0x0100 = Speak
//        0x0101 = Buy
//        0x0102 = Sell
//        0x0103 = Inventory
//        0x0104 = Renew
//        0x0200 = Pense
//        0x0201 = Use
//        0x0202 = Heal
//        0x0203 = Grunspreke
//        0x0204 = Menu
//        0x0300 = Offer
//        0x0301 = Eat
//        0x0302 = Rest
//        0x0303 = Kiniport
//        0x0304 = Sound
function menu_selection() => word(0x0071)

// $0077: Item Tracking [8 bit]
//        goes to 0 when opening menu
//        
//        Take: tracks last object collected
//        0x00 = Spirit Bell
//        0x02 = Honeylamp
//        0x05 = Pan Bread
//        0x06 = Fruit & Nuts
//        0x07 = Shuba
//        0x08 = Token
//        0x0B = Vine Rope
//        0x0E = Strange Elixer
//        
//        Offer/Eat/Drop/other: tracks item selected
//        value is actual index into object tables
//        0xFF = (Nothing)
function item_tracking() => byte(0x0077)

// $0085: Left/Right Input [8 bit]
//        0x00 = none
//        0x01 = Right
//        0xFF = Left
function left_right_input() => byte(0x0085)

// $0086: Up/Down Input [8 bit]
//        0x00 = none
//        0x01 = Down
//        0xFF = Up
function up_down_input() => byte(0x0086)

// $00C4: Script Indicator [8 bit]
//        bit0 | currently executing a script
//        flickers quickly so might be worth summing Mem and Delta
function script_indicator() => bit0(0x00C4)

// $B2B3: Spirit Leader - D'ol Neshom [8 bit]
//        bit7 | Received spirit increase
function spirit_leader_dol_neshom() => bit7(0xB2B3)

// $B2BC: Spirit Leader - Wise Child [8 bit]
//        bit7 | Received spirit increase
function spirit_leader_wise_child() => bit7(0xB2BC)

// $B2BF: Spirit Leader - The Hermit [8 bit]
//        bit7 | Received spirit increase
function spirit_leader_the_hermit() => bit7(0xB2BF)

// $B2C8: Spirit Leader - Hearba [8 bit]
//        bit7 | Received spirit increase
function spirit_leader_hearba() => bit7(0xB2C8)

// $B2CA: Spirit Leader - Vatar? [8 bit]
//        bit7 | Received spirit increase
function spirit_leader_vatar() => bit7(0xB2CA)

// $B2D8: Animal - Lapan [8 bit] (screen=0x00c0)
//        bit7 | pensed and received +1 spirit
function lapan1() => bit7(0xB2D8)

// $B2DB: Animal - Sima [8 bit] (screen=0x0062)
//        bit7 | pensed and received +1 spirit
function sima1() => bit7(0xB2DB)

// $B2DE: Animal - Lapan [8 bit] (screen=0x0043)
//        bit7 | pensed and received +1 spirit
function lapan2() => bit7(0xB2DE)

// $B2E3: Animal - Sima [8 bit] (screen=0x0086)
//        bit7 | pensed and received +1 spirit
function sima2() => bit7(0xB2E3)

// $B2E4: Animal - Lapan [8 bit] (screen=0x0128)
//        bit7 | pensed and received +1 spirit
function lapan3() => bit7(0xB2E4)

// $B2E7: Animal - Sima [8 bit] (screen=0x00d5)
//        bit7 | pensed and received +1 spirit
function sima3() => bit7(0xB2E7)

// $B2E9: Animal - Sima [8 bit] (screen=0x013c)
//        bit7 | pensed and received +1 spirit
function sima4() => bit7(0xB2E9)

// $B2F6: Animal - Lapan [8 bit] (screen=0x01f0)
//        bit7 | pensed and received +1 spirit
function lapan4() => bit7(0xB2F6)

// $B300: Object Screen Table [256 bytes]
//        indexed by object id from 0x0077
//        which screen an object can be found on. when an object is collected, this is not changed, but updated when item is dropped
function item_screen(i) => byte(0xB300+i)

// $B400: Object X Position Table [256 bytes]
//        indexed by object id from 0x0077
function item_xpos(i) => byte(0xB400+i)

// $B500: Object Meta Table [256 bytes]
//        indexed by object id from 0x0077
//        bits0-4 | Y Position
//        bit5 | Held by Player
function item_ypos(i) => 16*bit4(0xB500+i) + low4(0xB500+i)
function item_held(i) => bit5(0xB500+i)

// --- MAIN DATA -------------------------------------------------------------------

ITEM_SPIRIT_BELL = range(0x00, 0x00)
ITEM_SPIRIT_LAMP = range(0x01, 0x01)
ITEM_HONEY_LAMP = range(0x02, 0x1A)
ITEM_WAND_OF_BEFAL = range(0x1B, 0x1B)
ITEM_ROAST_LAPAN = range(0x1C, 0x25)
ITEM_PAN_BREAD = range(0x26, 0x3E)
ITEM_FRUIT_NUTS = range(0x3F, 0x57)
ITEM_SHUBA = range(0x58, 0x6B)
ITEM_TOKEN = range(0x6C, 0xB6)
ITEM_TRENCHER_BEAK = range(0xB7, 0xCF)
ITEM_WISSENBERRIES = range(0xD0, 0xD9)
ITEM_VINE_ROPE = range(0xDA, 0xF7)
ITEM_TEMPLE_KEY = range(0xF8, 0xF8)
ITEM_DOL_FALLAS_KEY = range(0xF9, 0xF9)
ITEM_STRANGE_EXILER = range(0xFA, 0xFE)

CHARNAME = {
	0: "Neric",
	1: "Genaa",
	2: "Herd",
	3: "Pomma",
	4: "Charn",
}

TIMEOFDAY = {
	0: "Early Morning",
	1: "Late Morning",
	2: "Early Afternoon",
	3: "Late Afternoon",
	4: "Early Evening",
	5: "Late Evening",
	6: "Midnight",
	7: "Late Night",
}

function _(r, c, indoor=0 ) => indoor*0x200 + (r-1)*0x20 + (c-1)
SCREENS = {
	_(1, 1, indoor=1): "Underground Path",
	_(1, 5, indoor=1): "A Nid-home in Sky Grund",
	_(1, 6, indoor=1): "Pomma's Nid-home",
	_(1, 7, indoor=1): "A Nid-home in Sky Grund",
	_(1, 8, indoor=1): "A Nid-home in Sky Grund",
	_(1, 9, indoor=1): "A Nid-home in Sky Grund",
	_(1, 10, indoor=1): "The Sky-nid",
	_(1, 11, indoor=1): "A Nid-home on the ground",
	_(1, 12, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 13, indoor=1): "The Garden",
	_(1, 14, indoor=1): "The Garden",
	_(1, 15, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 18, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 19, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 20, indoor=1): "The Wise Child",
	_(1, 21, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 22, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 23, indoor=1): "A Nid-home in the Garden Grunds",
	_(1, 24, indoor=1): "A Nid-home on the ground",
	_(1, 25, indoor=1): "A Nid-home on the ground",
	_(1, 26, indoor=1): "A Nid-home on the ground",
	_(1, 27, indoor=1): "The Lapan House",
	_(1, 28, indoor=1): "A Nid-home on the ground",
	_(1, 29, indoor=1): "Jail",
	_(1, 30, indoor=1): "A Nid-home in the Broad Grund",
	_(1, 31, indoor=1): "A Nid-home in the Broad Grund",
	_(1, 32, indoor=1): "Herd's Nid-home",

	_(2, 1, indoor=1): "Underground Path",
	_(2, 5, indoor=1): "A Nid-home in the Broad Grund",
	_(2, 6, indoor=1): "Broad Grund Fruit & Nuts Shop",
	_(2, 7, indoor=1): "Broad Grund Trencher Beak Shop",
	_(2, 8, indoor=1): "Broad Grund Honeylamp Shop",
	_(2, 9, indoor=1): "A Nid-home on the ground",
	_(2, 10, indoor=1): "The Hermit",
	_(2, 11, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 12, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 13, indoor=1): "Genaa's Nid-home",
	_(2, 14, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 15, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 18, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 19, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 20, indoor=1): "A Nid-home in the Grand Grund",
	_(2, 21, indoor=1): "A Nid-home on the ground",
	_(2, 22, indoor=1): "Charn's Nid-home",
	_(2, 23, indoor=1): "A Nid-home in the Silk Grund",
	_(2, 24, indoor=1): "A Nid-home in the Silk Grund",
	_(2, 25, indoor=1): "A Nid-home in the Silk Grund",
	_(2, 26, indoor=1): "Silk Weavers' Cottage",
	_(2, 27, indoor=1): "Silk Weavers' Cottage",
	_(2, 28, indoor=1): "Nekom Jail",
	_(2, 29, indoor=1): "A Nid-home in the Star Grund",
	_(2, 30, indoor=1): "Neric's Nid-home",
	_(2, 31, indoor=1): "A Nid-home in the Star Grund",
	_(2, 32, indoor=1): "A Nid-home in the Star Grund",

	_(3, 1, indoor=1): "Star Grund Shuba Shop",
	_(3, 5, indoor=1): "Star Grund Vine Rope Shop",
	_(3, 6, indoor=1): "Star Grund Pan Bread Shop",
	_(3, 7, indoor=1): "Temple Grunds",
	_(3, 8, indoor=1): "Vine Palace",
	_(3, 9, indoor=1): "Vine Palace",
	_(3, 10, indoor=1): "Vine Palace",
	_(3, 11, indoor=1): "Gates to the Chamber",
	_(3, 12, indoor=1): "The Chamber of the Forgotten",
	_(3, 13, indoor=1): "A Nid-home in the Temple Grunds",
	_(3, 14, indoor=1): "A Nid-home in the Temple Grunds",
	_(3, 18, indoor=1): "Temple Grunds",
	_(3, 19, indoor=1): "A Nid-home in the Broad Grund",
	_(3, 28, indoor=1): "Grand Hall",
	_(3, 29, indoor=1): "Grand Hall",
	_(3, 30, indoor=1): "Grand Hall",
	_(3, 31, indoor=1): "Grand Hall",
	_(3, 32, indoor=1): "Grand Hall",

	_(4, 19, indoor=1): "The Temple",
	_(4, 20, indoor=1): "The Temple",
	_(4, 21, indoor=1): "The Temple",
	_(4, 22, indoor=1): "The Temple",
	_(5, 19, indoor=1): "The Temple",
	_(5, 20, indoor=1): "The Temple",
	_(5, 21, indoor=1): "The Temple",
	_(5, 22, indoor=1): "The Temple",

	_(6, 31, indoor=1): "D'ol Neshom's Dream",
	_(6, 32, indoor=1): "D'ol Neshom's Dream",
}

// big grund blocks
for c in range(1,5) for r in range(1,11) SCREENS[_(r, c)] = "Sky Grund"
for c in range(6,10) for r in range(1,11) SCREENS[_(r, c)] = "Garden Grunds"
for c in range(11,13) for r in range(1,11) SCREENS[_(r, c)] = "Broad Grund"
for c in range(14,18) for r in range(1,11) SCREENS[_(r, c)] = "Grand Grund"
for c in range(19,21) for r in range(1,11) SCREENS[_(r, c)] = "Silk Grund"
for c in range(22,25) for r in range(1,11) SCREENS[_(r, c)] = "Star Grund"
for c in range(26,32) for r in range(1,11) SCREENS[_(r, c)] = "Temple Grunds"

// small branch corrections
SCREENS[_(6, 5)] = "Garden Grunds"
SCREENS[_(10, 6)] = "Broad Grund"
SCREENS[_(10, 7)] = "Broad Grund"
SCREENS[_(9, 9)] = "Broad Grund"
SCREENS[_(10, 9)] = "Broad Grund"
SCREENS[_(9, 14)] = "Broad Grund"
SCREENS[_(10, 13)] = "Grand Grund"
SCREENS[_(6, 25)] = "Temple Grunds"

// ground and underground
for c in range(1,32)
	SCREENS[_(12, c)] = "Ground"
for r in range(13,16) for c in range(1,32)
	SCREENS[_(r, c, indoor=1)] = "Below the Root"

TITLE_SCREENS = [0x007d, 0x007e, 0x009d, 0x009e]

ANIMALS = [
	{ "addr": 0xB2D8, "screen": 0x00c0, }, // lapan
	{ "addr": 0xB2DE, "screen": 0x0043, }, // lapan
	{ "addr": 0xB2E4, "screen": 0x0128, }, // lapan
	{ "addr": 0xB2F6, "screen": 0x01f0, }, // lapan
	{ "addr": 0xB2DB, "screen": 0x0062, }, // sima
	{ "addr": 0xB2E3, "screen": 0x0086, }, // sima
	{ "addr": 0xB2E7, "screen": 0x00d5, }, // sima
	{ "addr": 0xB2E9, "screen": 0x013c, }, // sima
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function is_scripted() => script_indicator() + prev(script_indicator()) != 0

function on_title() => any_of(TITLE_SCREENS, x => screen() == x)
function watching_sample_quest() => is_scripted() && !on_title()

function item_is(x, g) => x >= g[0] && x <= g[length(g)-1]

function location() => indoors()*0x200 + screen()

// usually this data lives in the page starting at 0x0800, but during screen transitions, moves to 0x0000
// this could be useful for detecting those page swaps and not letting it trigger achievements erroneously
function stable() => dword_be(0x0020) != 0x00280018

function flicker_guard() => disable_when(!stable())

// --- RICH PRESENCE -------------------------------------------------------------------

rich_presence_conditional_display(on_title(),
	"Title Screen"
)

rich_presence_conditional_display(watching_sample_quest(),
	"Watching the sample quest..."
)

rich_presence_display(
	"{0} · {1} Day {2} · {3} [✨ Spirit: {4}/{5}] [🏃 Stamina: {6}/{7}] [🥗 Food: {8}/{9}]",
	rich_presence_lookup("CHAR", character(), CHARNAME, fallback="????"),
	rich_presence_lookup("TIME", time_of_day(), TIMEOFDAY, fallback="????"),
	rich_presence_number(day()),
	rich_presence_lookup("LOCATION", location(), SCREENS, fallback="Green-Sky"),
	rich_presence_number(spirit_level()),
	rich_presence_number(spirit_limit()),
	rich_presence_number(rest_level()),
	rich_presence_number(stamina()/2),
	rich_presence_number(food_level()),
	rich_presence_number(stamina()/2)
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------
