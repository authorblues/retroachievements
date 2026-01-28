// Higemaru Makaijima: Nanatsu no Shima Daibouken
// #ID = 4333

// $005C: Title Screen Cursor [8 bit]
//        0 = New Game
//        1 = Password
function loaded_game() => byte(0x00005C)

// $0070: Player Status [8 bit]
//        bit0 = taking damage
//        bit3 = teleporting out of the map
//        bit6 = carrying item (@ 0x0300)
PLAYER_STATUS = 0x000070
function player_status() => byte(PLAYER_STATUS)
function player_is_carrying() => bit6(PLAYER_STATUS)
function player_throw() => prev(player_is_carrying()) == 1 && player_is_carrying() == 0

// $0087: Currently Screen Scrolling [8 bit]
//        bit0 = left/right scroll
//        bit1 = up/down scroll
//        bit7 = negative direction (left/up)
function screen_scrolling() => byte(0x000087)

// $0088: Current Screen ID [8 bit]
function screen_id() => byte(0x000088)

ROOM_KEY_CAPTAIN = 0x04
ROOM_BOUSO = 0x11
ROOM_DEVIL = 0x08

// $008B: Facing Direction [8 bit]
//        1 = right
//        2 = left
//        4 = down
//        8 = up
function facing_direction() => byte(0x00008B)

DIR_RT = 1
DIR_LT = 2
DIR_DN = 4
DIR_UP = 8

// $0092: Ocean Map [8 bit]
//        0=Yes, 1=No
function on_land() => byte(0x000092)

// $0097: Jump Animation Timer [8 bit]
//        0 = grounded
function jump_animation_timer() => byte(0x000097)

// $00B2: Camera X Position [16 bit] (in px)
function camera_x_position_in_px() => word(0x0000B2)
function screen_x() => byte(0x0000B3)

// $00B5: Camera Y Position [16 bit] (in px)
function camera_y_position_in_px() => word(0x0000B5)
function screen_y() => byte(0x0000B6)

// $00DB: Current Island [8 bit]
//        0x00 = Cook
//        0x01 = Curse
//        0x02 = Mermaid
//        0x03 = Hebi
//        0x04 = Dokuro
//        0x05 = Ookami
//        0x06 = J.Knife
//        0x07 = Key Ships
//        0x08 = Finale
//        0x09 = Ghost Ship
function map_id() => byte(0x0000DB)

ISLAND_COOK = 0x00
ISLAND_CURSE = 0x01
ISLAND_MERMAID = 0x02
ISLAND_HEBI = 0x03
ISLAND_DOKURO = 0x04
ISLAND_OOKAMI = 0x05
ISLAND_JKNIFE = 0x06
SHIP_KEY = 0x07
FINALE = 0x08
SHIP_GHOST = 0x09

// $00F9: Pirate Ship - Pirates Left [8 bit] (BCD)
function pirates_remaining() => high4(0x0000F9) * 10 + low4(0x0000F9)

// $01D7: Combo Counter [8 bit]
//        sets to 0 on throw
//        if thrown object immediately makes contact, does not show 0
function combo() => byte(0x0001D7)

// $0200: Interactable Objects [8 x 32 byte table]
//        .. +0 = object flags
//        .... bit7 = active
//        .... bit4 = respawning
//        .... bit0 = "defeated"
//        .. +2 = object identifier [16 bit]
//        .. +4 = freeze timer (frames)
//        .. +5 = script action
//        .. +6 = script timer (frames)
//        .. +8 = X position
//        .. +11 = Y position
//        .. +16 = animation frame
//        .. +28 = hit count
//        
//        hit counters:
//        yashichi -> 4
//        ship bosses -> 8
//        moribito -> 10
//        glacier -> 8
//        bouso -> ?
//        red arremer -> 12
OBJ_INTERACTABLE = 0x000200
function actor_exists(i) => bit7(OBJ_INTERACTABLE + i * 32)
function actor_type(i) => word(OBJ_INTERACTABLE + i * 32 + 2)
function actor_hits(i) => byte(OBJ_INTERACTABLE + i * 32 + 28)
function actor_xpos(i) => byte(OBJ_INTERACTABLE + i * 32 + 8)
function actor_ypos(i) => byte(OBJ_INTERACTABLE + i * 32 + 11)

ACTOR_ROCKET = 0x96F1
ACTOR_PIRATE = 0xF664

function boss_active() => actor_exists(0)
function boss_hits() => actor_hits(0)
function boss_died() => prev(boss_active()) == 1 && boss_active() == 0

// $0300: Carried/Thrown Items [8 x 32 byte table]
//        .. +0 = object flags
//        .... bit7 = active
//        .... bit4 = stopped, hit landed
//        .... bit0 = thrown
//        .. +8 = X position
//        .. +11 = Y position
//        .. +14 = direction (0=up, 4=down, 8=left, C=right)
OBJ_CARRIED = 0x000300
function obj_flags(i) => byte(OBJ_CARRIED + i * 32)
function obj_exists(i) => bit7(OBJ_CARRIED + i * 32)
function obj_stopped(i) => bit4(OBJ_CARRIED + i * 32)
function obj_moving(i) => bit0(OBJ_CARRIED + i * 32)

// $047C: Out of Game Indicator [16 bit]
//        0x0000 = not in game
function in_game() => word(0x00047C)

// $0481: Health - X0000
// $0482: Health - 0X000
// $0483: Health - 00X00
// $0484: Health - 000X0
// $0485: Health - 0000X
function health() => (
    low4(0x000481) * 10000 +
    low4(0x000482) * 1000 +
    low4(0x000483) * 100 +
    low4(0x000484) * 10 +
    low4(0x000485)
)

FLAGS1 = 0x00048C
FLAGS2 = 0x00048D
FLAGS3 = 0x00048E

// $048C: Progression Flags [8 bit]
//        bit7 = reached final door
//        bit6 = Bouso dead
//        bit5 = Ookami ship -> bridge built
//        bit4 = Cook candles lit

function seen_treasure_door() => bit7(FLAGS1)
function bouso_dead() => bit6(FLAGS1)
function ookami_ship_secret() => bit5(FLAGS1)
function cook_candles_lit() => bit4(FLAGS1)

// $048D: Collectables [8 bit]
//        bit0 = J.Knife extended
//        bit3 = Yashichi @ Cook
//        bit4 = Fake Lamp
//        bit5 = O Crystal
//        bit6 = M Crystal
//        bit7 = C Crystal

function jknife_extended() => bit0(FLAGS2)
function yashichi_collected() => bit3(FLAGS2)
function lamp_fake() => bit4(FLAGS2)
function item_crystal_O() => bit5(FLAGS2)
function item_crystal_M() => bit6(FLAGS2)
function item_crystal_C() => bit7(FLAGS2)

// $048E: Collectables [8 bit]
//        bit0 = Baido's Tear
//        bit1 = Ocean Map
//        bit2 = Translation Chart
//        bit3 = Satan Sword
//        bit4 = Lamp
//        bit5 = Triangle Tablet
//        bit6 = Circle Tablet
//        bit7 = Square Tablet

function item_baidos_tear() => bit0(FLAGS3)
function item_ocean_map() => bit1(FLAGS3)
function item_trans_chart() => bit2(FLAGS3)
function item_satan_sword() => bit3(FLAGS3)
function item_lamp() => bit4(FLAGS3)
function item_tablet_triangle() => bit5(FLAGS3)
function item_tablet_circle() => bit6(FLAGS3)
function item_tablet_square() => bit7(FLAGS3)

function tablet_count() => item_tablet_triangle() + item_tablet_circle() + item_tablet_square()

// $048F: Island Keys [8 bit]
//        bit7 = Cook
//        bit6 = Curse
//        bit5 = Mermaid
//        bit4 = Hebi
//        bit3 = Dokuro
//        bit2 = Ookami
//        bit1 = J.Knife
//        bit0 =
function num_keys() => bitcount(0x00048F)
function have_key(i) => bit(7-i, 0x00048F)

// $0490: Boss Defeated [8 bit]
//        bit7 = Cook - Moribito
//        bit6 = Curse - Archbishop
//        bit5 = Mermaid - Kraken
//        bit4 = Hebi - Cyclops
//        bit3 = Dokuro - Giant Zombie
//        bit2 = Ookami - Fire Kong
//        bit1 = J.Knife - unnamed glacier monster
//        bit0 =
function num_bosses() => bitcount(0x000490)
function boss_defeated(i) => bit(7-i, 0x000490)

// $0491: Current Task [8 bit]
//        increments on ship key
function task() => byte(0x000491)

ISLANDS = [
    {"i": ISLAND_COOK, "name": "Cook Island", "boss": "Moribito", "achievement": "A Downpour of Axes"},
    {"i": ISLAND_CURSE, "name": "Curse Island", "boss": "the Archbishop", "achievement": "Creepy Cultists"},
    {"i": ISLAND_MERMAID, "name": "Mermaid Island", "boss": "the Kraken", "achievement": "Decease the Kraken"},
    {"i": ISLAND_HEBI, "name": "Hebi Island", "boss": "the Cyclops", "achievement": "Arthur the Knight Avenged"},
    {"i": ISLAND_DOKURO, "name": "Dokuro Island", "boss": "the Giant Zombie", "achievement": "Rest in Peace... Again"},
    {"i": ISLAND_OOKAMI, "name": "Ookami Island", "boss": "Fire Kong", "achievement": "Whatever Happened to Fay Wray?"},
    {"i": ISLAND_JKNIFE, "name": "J.Knife Island", "boss": "the ice golem", "achievement": "They Put Something in the Water"},
]

ISLAND_LOOKUP = {
    SHIP_KEY: "a pirate ship",
    FINALE: "the vault of Baido's treasure",
    SHIP_GHOST: "the mysterious ghost ship",
}
for island in ISLANDS { ISLAND_LOOKUP[island["i"]] = island["name"] }

rich_presence_health = rich_presence_value("Score", health(), "SCORE")
rich_presence_keys = rich_presence_value("Number", num_keys())
rich_presence_island = rich_presence_lookup("Island", map_id(), ISLAND_LOOKUP, fallback="the seven islands")
rich_presence_target = rich_presence_lookup("Island", num_bosses(), ISLAND_LOOKUP, fallback="the seven islands")

rich_presence_conditional_display(in_game() == 0x0000,
    "🦜 Gettin' a crew together for an adventure in the seven islands"
)

rich_presence_conditional_display(on_land() == 0 && num_keys() == num_bosses() && num_bosses() < 7,
    "⛵🌊 Sailin' the high seas | Lookin' for the key to {2} | 💰{0} 🗝️{1}",
    rich_presence_health, rich_presence_keys, rich_presence_target
)

rich_presence_conditional_display(on_land() == 0 && num_bosses() < 7,
    "⛵🌊 Sailin' the high seas | Headin' to port at {2} | 💰{0} 🗝️{1}",
    rich_presence_health, rich_presence_keys, rich_presence_target
)

rich_presence_conditional_display(on_land() == 0,
    "⛵🌊 Sailin' the high seas | Solvin' the mystery of Baido's treasure | 💰{0} 🗝️{1}",
    rich_presence_health, rich_presence_keys
)

rich_presence_conditional_display(on_land() == 1 && map_id() == SHIP_KEY,
    "🏴‍☠️⚔️ Raidin' a Higemaru ship (☠️{3}) | Lookin' for the key to {2} | 💰{0} 🗝️{1}",
    rich_presence_health, rich_presence_keys, rich_presence_target,
    rich_presence_value("Number", pirates_remaining())
)

rich_presence_display(
    "🏴‍☠️🗺️ Yarr! Lootin' and pillagin' {2} | 💰{0} 🗝️{1}",
    rich_presence_health, rich_presence_keys, rich_presence_island
)

function check_flag(flag, island) => (
    on_land() == 1 && map_id() == island && prev(flag) == 0 && flag == 1
)

// (x=2, y=0) Curse boss (Archbishop)
// (x=1, y=0) heart of Dokuro
// (x=4, y=3) bridge to Baido's tomb
// (x=8, y=2) Bouso fight
// (x=4, y=1) final boss room
// (x=4, y=0) final treasure door
// (x=5, y=1) Baido's treasure cutscene
function location(island, x, y) => on_land() == 1 && map_id() == island && screen_x() == x && screen_y() == y && screen_scrolling() == 0
function win_game() => (
    // on land
    on_land() == 1 &&

    // on the finale map
    map_id() == FINALE &&

    // new screen is the finale
    screen_x() == 5 && screen_y() == 1 &&

    // previous screen was the door
    prev(screen_x()) == 4 && prev(screen_y()) == 0 &&

    // player has baido's tear
    item_baidos_tear() == 1
)

for island in ISLANDS
{
    achievement(
        title=format("En Route to {0}", island["name"]),
        description=format("Collect the key for {0}", island["name"]),
        points=5,
        type="progression",
        trigger=check_flag(have_key(island["i"]), SHIP_KEY)
    )

    achievement(
        title=island["achievement"],
        description=format("Defeat {1} on {0}", island["name"], island["boss"]),
        points=10,
        type="progression",
        trigger=check_flag(boss_defeated(island["i"]), island["i"])
    )
}

achievement(
    title="The Bionic Buccaneer",
    description="Defeat Bouso and collect Baido's Tear",
    points=10,
    type="progression",
    trigger=check_flag(item_baidos_tear(), ISLAND_OOKAMI)
)

achievement(
    title="The Greatest Treasure",
    description="Defeat the Red Arremer and plunder Baido's treasure",
    points=25,
    type="win_condition",
    trigger=win_game()
)

achievement(
    title="The Cultists' Sacred Relic",
    description="Obtain the C Crystal from Curse Island",
    points=5,
    trigger=check_flag(item_crystal_C(), ISLAND_CURSE)
)

achievement(
    title="The Mermaid's Gift",
    description="Obtain the M Crystal from Mermaid Island",
    points=5,
    trigger=check_flag(item_crystal_M(), ISLAND_MERMAID)
)

achievement(
    title="The Secret of the Lone Cactus",
    description="Obtain the O Crystal from Ookami Island",
    points=5,
    trigger=check_flag(item_crystal_O(), ISLAND_OOKAMI)
)

achievement(
    title="Some Farcical Aquatic Ceremony",
    description="Obtain the Satan Sword",
    points=10,
    trigger=check_flag(item_satan_sword(), ISLAND_CURSE)
)

achievement(
    title="Lan-turn Around, Bright Eyes",
    description="Obtain the lamp?",
    points=1,
    trigger=check_flag(lamp_fake(), ISLAND_HEBI)
)

achievement(
    title="A Light in the Darkness",
    description="Obtain the lamp",
    points=5,
    trigger=check_flag(item_lamp(), ISLAND_HEBI)
)

achievement(
    title="A Yankee Candle in Blackbeard's Port",
    description="Light the candles on Cook Island",
    points=5,
    trigger=check_flag(cook_candles_lit(), ISLAND_COOK)
)

achievement(
    title="Of Stars and Sextants",
    description="Obtain the ocean map",
    points=5,
    trigger=check_flag(item_ocean_map(), ISLAND_OOKAMI)
)

achievement(
    title="BESURETODRINKYOURGROG",
    description="Obtain the translation chart",
    points=5,
    trigger=check_flag(item_trans_chart(), ISLAND_DOKURO)
)

achievement(
    title="Welcome to the Shapes Museum",
    description="Obtain the three tablets",
    points=10,
    trigger=(on_land() == 1 && prev(tablet_count()) == 2 && measured(tablet_count() == 3))
)

achievement(
    title="X Marks the Spot",
    description="Collect the Yashichi",
    points=2,
    trigger=check_flag(yashichi_collected(), ISLAND_COOK)
)

achievement(
    title="Polly Bridge",
    description="Restore the bridge to Baido's tomb on Ookami Island",
    points=5,
    trigger=(location(ISLAND_OOKAMI, 4, 3) && ookami_ship_secret() == 1)
)

achievement(
    title="Fifteen Men on a Dead Man's Chest",
    description="Defeat Bouso without taking damage",
    points=10,
    trigger=(
        // player is in Bouso's room
        location(ISLAND_OOKAMI, 8, 2) &&

        // challenge indicator for fighting Bouso
        prev(bouso_dead()) == 0 && trigger_when(bouso_dead() == 1) &&

        // pause lock if player takes damage
        disable_when(health() < prev(health()), until=screen_scrolling() != 0)
    )
)

achievement(
    title="Drink and the Devil Had Done the Rest",
    description="Defeat the Red Arremer without the Satan Sword",
    points=10,
    trigger=(
        // correct room
        location(FINALE, 4, 1) &&

        // don't have Satan Sword and killed boss
        item_satan_sword() == 0 && boss_died()
    )
)

achievement(
    title="Bowling a Perfect Game",
    description="Defeat the Archbishop without missing any throws",
    points=10,
    trigger=(
        // entered Archbishop boss room
        location(ISLAND_CURSE, 2, 0) &&
        
        // achievement triggers when the Archbishop is dead
        prev(boss_defeated(ISLAND_CURSE)) == 0 && trigger_when(boss_defeated(ISLAND_CURSE) == 1) &&

        // boulders go from 0x81 -> 0x00 when they miss, but 0x81 -> 0x11 -> 0x00 when they hit (on bosses)
        all_of(range(0,3), (i) => disable_when(prev(obj_flags(i)) == 0x81 && obj_flags(i) == 0x00,
            until=screen_scrolling() != 0))
    )
)

TARGET_COMBO = 4
achievement(
    title="Strike!",
    description=format("Combo kill {0} or more enemies in one throw", TARGET_COMBO),
    points=5,
    trigger=(on_land() == 1 && prev(combo()) < TARGET_COMBO && combo() >= TARGET_COMBO)
)

achievement(
    title="The Missle Knows Where It Is",
    description="Pretty advanced rocket technology for a bunch of smelly pirates",
    points=1,
    trigger=(
        on_land() == 1 &&

        any_of(range(0,7), (i) => (
            prev(actor_type(i)) == ACTOR_ROCKET && actor_exists(i) == 1 && actor_hits(i) > 0
        ))
    )
)

TARGET_POINTS = 19830
achievement(
    title="Drink Up, Me Hearties!",
    description=format("Earn {0} points", TARGET_POINTS),
    points=10,
    trigger=(on_land() == 1 && prev(health()) < TARGET_POINTS && health() >= TARGET_POINTS)
)

achievement(
    title="The Greatest Treasure Hunter",
    description="Complete the game and earn the best ending",
    points=25,
    trigger=win_game() && item_crystal_C() == 1 && item_crystal_M() == 1 && item_crystal_O() == 1
)

achievement(
    title="With the Wind in Our Sails",
    description="In one session, beat the game from the start without using passwords",
    points=50,
    trigger=(
        // checkpoint hit on being in-game on a new game
        in_game() != 0 && loaded_game() == 0 &&

        // challenge icon for winning the game
        trigger_when(win_game())
    )
)

achievement(
    title="You Fight Like a Dairy Farmer",
    description="Collect a Pow for 2000 points",
    points=2,
    trigger=(on_land() == 1 && health() - prev(health()) == 2000)
)