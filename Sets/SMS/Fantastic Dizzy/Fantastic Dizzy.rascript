// Fantastic Dizzy
// #ID = 11578

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function array_concat(a, b)
{
	c = []
	for x in a { array_push(c, x) }
	for x in b { array_push(c, x) }
	return c
}

function rich_presence_flag(str, when=always_true(), lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, "")

function _score(x) => (
	byte(x+0) * 100000 +
	byte(x+1) * 10000 +
	byte(x+2) * 1000 +
	byte(x+3) * 100 +
	byte(x+4) * 10 +
	byte(x+5)
)

// --- MEMORY -------------------------------------------------------------------

// $10B3: Bubble Minigame Ending [8 bit]
//        usually 0, counts up to 142 once minigame has ended
//        to determine ending, check for 79->80 for music cue
function bubble_minigame_ending() => byte(0x10B3)

// $10B4: Bubble Minigame On-Ground [8 bit]
//        0 = Not Grounded
//        1 = On Ground (can jump)
function bubble_minigame_onground() => byte(0x10B4)

// $1197: Bubble Minigame Oxygen [8 bit]
//        starts at 0, counts up every 128 frames, death at 48
function bubble_minigame_oxygen() => byte(0x1197)

// $1235: (Tower) Damage [8 bit]
//        starts at 0x2f, die at 0x00
function tower_damage() => byte(0x1235)

// $1238: (Tower) Victory Timer [8 bit]
//        0xC8 when reaching Daisy, counts down to 0 for Win screen
function tower_victory_timer() => byte(0x1238)

// $156C: Archery Progress [8 bit]
//        0 = lose
//        10 = win
function archery_progress() => byte(0x156C)

// $15D6: River Minigame Health [8 bit]
//        starts at 47
//        goblin balloons take 10
//        crocodiles take 1 per frame
function river_minigame_health() => byte(0x15D6)

// $181F: Selected Inventory Slot [8 bit] (0-2)
//        does not reset when leaving inventory
//        resets back to 0 when opening inventory
function selected_inventory_slot() => byte(0x181F)

// $1823: Item Table [240 bytes, 4 bytes per item]
//        +0 | screen id [8 bit] (becomes 0xFF when item in hand)
//        +1 | x position [16 bit]
//        +3 | y position [8 bit]
//        
//        represents any item sitting on the ground
ITEM_TABLE = 0x1823
function item_screen(i) => byte(ITEM_TABLE + 4*i + 0)
function item_not_in_world(i) => bit7(ITEM_TABLE + 4*i + 0)
function item_x(i) => word(ITEM_TABLE + 4*i + 1)
function item_y(i) => byte(ITEM_TABLE + 4*i + 3)

// $195B: Score [6 bytes]
function score() => _score(0x195B)

// $1961: Lives [8 bit]
//        0xFF = game over
//        starts at 2 (3 lives)
function lives() => byte(0x1961)

// $1964: Day Clock [8 bit]
//        0x00 - 0x9F = Day
//        0xA0 - 0xC7 = Dusk
//        0xC8 - 0xFF = Night
//        counts up every 64f
function day_clock() => byte(0x1964)

// $1965: Time of Day [8 bit]
//        0 = day
//        1 = dusk
//        2 = night
function time_of_day() => byte(0x1965)

// $1966: Inventory [3 bytes]
//        0xFF = (Empty)
//        0x00 = A Machine Wrench (from the field)
//        0x01 = A Full Bottle of Medicine (Grand Dizzy's hut)
//        0x02 = An Empty Medicine Bottle (outside Grand Dizzy's hut)
//        0x03 = A Red and White Mushroom (from the field)
//        0x04 = A Magical Star Plant (treehouse)
//        0x05 = A Long Length of Tough Rope (treehouse, above snappy weed)
//        0x06 = A One Ton Weight (treehouse)
//        0x07 = Dizzy's Door Key (dizzy's hut)
//        0x08 = The Key for Dylan's Elevator (treehouse, far right on Grand Dizzy's screen)
//        0x09 = The Key for Denzil's Elevator (treehouse, left of Dizzy's hut)
//        0x0A = The Key for Grand Dizzy's Elevator (diamond mines?)
//        0x0B = The Key for the Ground Elevator (field under treehouse)
//        0x0C = Dozy's Door Key (Daisy's hut)
//        0x0D = Dora's Door Key (far left platform past Denzil's hut)
//        0x0E = Dylan's Door Key (treehouse, after upper rope swing)
//        0x0F = Grand Dizzy's Door Key (in meeting hall)
//        0x10 = Denzil's Door Key (treehouse, lowest platform above wood plank)
//        0x11 = Daisy's Door Key (treehouse, outside)
//        0x12 = A Bridgebuilder's Sharp Axe (diamond mines)
//        0x13 = An Aqua Lung for Under Water (deserted island)
//        0x14 = A Pair of Flippers for Swimming (Denzil's item)
//        0x1B = A Heavy Bag of Gold Coins (from the field)
//        0x1C = A Magic Green Bean (town Shopkeeper)
//        0x1D = A Large Bag of Salt (right beach)
//        0x1E = An Empty Old Tin Bucket (under graveyard)
//        0x1F = A Bucket Full of Water (under graveyard)
//        0x20 = A Tasty Looking Cooked Chicken (field below treehouse)
//        0x21 = A Key with a Skull Motif (graveyard)
//        0x22 = An Empty Treasure Chest (sunken ship)
//        0x23 = Dora Who Has Been Turned Into a Frog (Dora's hut)
//        0x24 = A Crossbow with Lots of Bolts (Prince)
//        0x25 = A Very Strong Crowbar (Keldor street)
//        0x26 = A Thick Persian Rug (Dozy's hut)
//        0x27 = A Portcullis Winch Wheel (ship rigging)
//        0x28 = A Complete D.I.Y. Rope Bridge Kit (troll castle)
//        0x29 = A Gravedigger's Muddy Spade (minecart exit)
//        0x2A = A Protective Old Umbrella (Keldor street)
//        0x2B = A Gymnast's Bouncy Trampet (under graveyard)
//        0x2C = A Heavy Duty Rustproof Pickaxe (beach)
//        0x2D = An Incredibly Small Pigmy Cow (Dylan's hut?)
//        0x2E = A Large Gold Coin (underwater cave)
//        0x2F = A Warm Golden Dragon Egg (Grand Dizzy's hut)
//        0x30 = A Warm Golden Dragon Egg (under the dragon)
//        0x31 = A Small Animal Cage (Daizy's hut)
//        0x32 = A Cage Containing Pogie the Fluffle (*make this*)
//        0x33 = A Dry Match (field near Seamus)
//        0x34 = A Pile of Dry Straw (treehouse, beside Denzil's hut)
//        0x35 = An Old Medicine Recipe (Grand Dizzy's hut)
//        0x36 = A Bottle of Snappy Weed Killer (field under treehouse)
//        0x37 = A Solid Gold Irish Shamrock (under dragon)
//        0x38 = A Pair of Brass Cymbals (water in diamond mine)
//        0x39 = A Large Strong Plank of Wood (treehouse)
//        0x3A = Some Sticks of Dynamite (ship)
//        0x3B = Zaks' Portcullis Winch Handle (ship)
//        0x3C = A Barrel of Pirate's Rum (field, beside waterfall)
function inventory(i) => byte(0x1966 + i)
function is_inventory_empty() => tbyte(0x1966) == 0xFFFFFF

// $1989: Stars Remaining [3 bytes]
function _stars_remaining_raw() => tbyte_be(0x1989)
function stars_remaining() => (
	byte(0x1989) * 100 +
	byte(0x198a) * 10 +
	byte(0x198b)
)

// $1994: Fire in the Fireplace [8 bit] (screen=0x23)
//        0x00 = Fire lit
//        0xFF = Fire extinguished
function fire_in_the_fireplace() => byte(0x1994)

// $1995: Shopkeeper Status [8 bit] (screen=0x1c)
//        0x00 = Initial state
//        0x01 = Trade made, throwing bean
//        0xFF = Bean landed
function shopkeeper_status() => byte(0x1995)

// $1996: Spikes Covered [8 bit] (screen=0x22)
//        0x00 = Spikes dangerous
//        0xFF = Spikes covered with rug
function spikes_covered() => byte(0x1996)

// $1997: Dylan Petsitting [8 bit] (screen=0x01)
//        0x00 = Initial State
//        0x01 = Talked to Dylan
//        0xFF = Delivered Pogie
function dylan_petsitting() => byte(0x1997)

// $1998: Grand Dizzy Healed [8 bit] (screen=0x05)
//        0x00 = In Bed
//        0xFF = Out of Bed
function grand_dizzy_healed() => byte(0x1998)

// $1999: Cauldron Items Placed [8 bit] (screen=0x05)
//        counts up from 0, when it reaches 3, jumps to 0xFF and spits out medicine
//        requires 0x02 (empty bottle), 0x03 (mushroom), 0x04 (plant)
function cauldron_items_placed() => byte(0x1999)

// $199A: Dozy Awake [8 bit] (screen=0x06)
//        0x00 = Asleep
//        0xFF = Dozy Awake
function dozy_awake() => byte(0x199A)

// $199B: Prince Kissed Dora [8 bit] (screen=0x0f)
//        0x00 = Not Kissed
//        0xFF = Kissed
function prince_kissed_dora() => byte(0x199B)

// $199C: Elevator Control Machine Active [8 bit] (screen=0x2b)
//        0x00 = Not Active
//        0xFF = Active
function elevator_control_machine_active() => byte(0x199C)

// $199D: Bridge State [8 bit] (screen=0x10)
//        0x00 = Bridge Intact
//        0x20 = Bridge Destroyed
//        
//        counts up when using the axe. 0x01 immediately, then up once per frame the game is unpaused, representing the rotation of the bridge slats that fall. transition from 1->2 probably best for achievements, or 0x20 when bridge reaches its resting state
function bridge_state() => byte(0x199D)

// $199E: Bridge Under Village Built [8 bit] (screen=0x0f)
//        0x00 = No Bridge
//        0xFF = Bridge Built
function bridge_under_village_built() => byte(0x199E)

// $199F: Chest Placed as Platform [8 bit] (screen=0x11)
//        0x00 = Not placed
//        0xFF = Placed
function chest_placed_as_platform() => byte(0x199F)

// $19A0: Graveyard Bridge Built [8 bit] (screen=0x16)
//        0x00 = No bridge
//        0xFF = Bridge constructed
function graveyard_bridge_built() => byte(0x19A0)

// $19A1: Graveyard Hole Dug [8 bit] (screen=0x16)
//        0x00 = No hole
//        0xFF = Hole dug
function graveyard_hole_dug() => byte(0x19A1)

// $19A2: Ramp Lowered [8 bit] (screen=0x09)
//        0x00 = Ramp Raised
//        0xFF = Ramp Lowered
function ramp_lowered() => byte(0x19A2)

// $19A3: Beanstalk State [8 bit] (screen=0x17)
//        0x00 = Not grown
//        0xFF = Grown
function beanstalk_state() => byte(0x19A3)

// $19A4: Denzil Status [8 bit] (screen=0x07)
//        0x00 = Initial state
//        0x01 = Interacted with ice cube Denzil
//        0x02 = Dry straw added
//        0x03 = Match added
//        counts up per frame to 0xFE while unpaused
//        0xFE = Ice melt text shown
//        0xFF = Denzil unfrozen, prize given
function denzil_status() => byte(0x19A4)

// $19A5: Pogie Captured [8 bit]
//        0x00 = Walking
//        0xFF = Captured
function pogie_captured() => byte(0x19A5)

// $19A6: Log Lifted by Salt [8 bit] (screen=0x17)
//        0x00 = Log at bottom of lake
//        0x01 = Log floating slowly to surface
//        0xFF = Log at surface, safe to walk across
function log_lifted_by_salt() => byte(0x19A6)

// $19A7: Snappy Weed Disabed [8 bit] (screen=0x0e)
//        0x00 = Active
//        0x01 = Disabled
function snappy_weed_disabed() => byte(0x19A7)

// $19A8: Final Star Door Dispelled [8 bit]
//        0x00 = Door electrified
//        0xFF = Door disabled (when 0 stars remaining)
function final_star_door_dispelled() => byte(0x19A8)

// $19AB: Mines Blasting Area [8 bit] (screen=0x2d)
//        0x00 = Initial state
//        0x01 = Dynamite placed
//        when plunger pressed, goes to 2, and counts up to 24, then jumps to 0xFF
//        0xFF = Rocks destroyed/exploded
function mines_blasting_area() => byte(0x19AB)

// $19AC: Archery Game Complete [8 bit]
//        0x00 = Incomplete
//        0xFF = Won
//        changes while still in minigame state
function archery_game_complete() => byte(0x19AC)

// $19AD: Leprechaun Guard [8 bit] (screen=0x17)
//        0x00 = Leprechaun on guard
//        0x01 = Throwing shamrock
//        0x02 = Walking away
//        0xFF = Stopped in the cave
function leprechaun_guard() => byte(0x19AD)

// $19BA: Ground Elevator Active [8 bit] (screen=0x0f)
//        0x00 = Not Active
//        0xFF = Active
function ground_elevator_active() => byte(0x19BA)

// $19BB: Denzil's Elevator Active [8 bit] (screen=0x0c)
//        0x00 = Not Active
//        0xFF = Active
function denzils_elevator_active() => byte(0x19BB)

// $19BC: Grand Dizzy's Elevator Active [8 bit] (screen=0x0a)
//        0x00 = Not Active
//        0xFF = Active
function grand_dizzys_elevator_active() => byte(0x19BC)

// $19BD: Dylan's Elevator Active [8 bit] (screen=0x0a)
//        0x00 = Not Active
//        0xFF = Active
function dylans_elevator_active() => byte(0x19BD)

// $19BE: Zak's Castle Elevator Active [8 bit] (screen=0x23)
//        0x00 = Not Active
//        0xFF = Active
function zaks_castle_elevator_active() => byte(0x19BE)

// $19BF: Mine Elevator #1 Active [8 bit] (screen=0x2b)
//        0x00 = Not Active
//        0xFF = Active
function mine_elevator_1_active() => byte(0x19BF)

// $19C0: Mine Elevator #2 Active [8 bit] (screen=0x2c)
//        0x00 = Not Active
//        0xFF = Active
function mine_elevator_2_active() => byte(0x19C0)

// $19C1: Mine Elevator #3 Active [8 bit] (screen=0x2d, left)
//        0x00 = Not Active
//        0xFF = Active
function mine_elevator_3_active() => byte(0x19C1)

// $19C2: Mine Elevator #4 Active [8 bit] (screen=0x2d, right)
//        0x00 = Not Active
//        0xFF = Active
function mine_elevator_4_active() => byte(0x19C2)

// $19CE: Pirate Guarding Ship [8 bit] (screen=0x1e)
//        0x00 = Pirate on guard
//        0x01 = Pirate walking away
//        0x02 = Pirate gone
function pirate_guarding_ship() => byte(0x19CE)

// $19DA: Dino Fed [8 bit] (screen=0x12)
//        0x00 = Dino running in western field
//        0xFF = Dino fed chicken
function dino_fed() => byte(0x19DA)

// $19E0: Underwater Crowbar Rock Removed [8 bit] (screen=0x15)
//        0x00 = Rock stuck
//        0xFF = Rock removed, bubbles floating
function underwater_crowbar_rock_removed() => byte(0x19E0)

// $19E9: Knight Guard Status [8 bit] (screen=0x2a)
//        0x00 = knight blocking
//        0x01 = throwing coin back
//        0x02 = knight walking away
//        0xFF = knight gone
function knight_guard_status() => byte(0x19E9)

// $19EB: Pogie State [8 bit]
//        0x00 = walking left (Dylan's hut)
//        0x01 = walking uphill right
//        0x02 = walking straight right
//        0x03 = walking downhill right
//        0x05 = walking downhill left
//        0x06 = walking straight left
//        0x07 = walking uphill left
//        0x09 = jumping down?
//        0xFF = walking right (Dylan's hut)
function pogie_state() => byte(0x19EB)

// $19EC: Pogie X Position [16 bit]
function pogie_x_position() => word(0x19EC)

// $19EE: Pogie Y Position [8 bit]
function pogie_y_position() => byte(0x19EE)

// $19EF: Pogie Screen [8 bit]
function pogie_screen() => byte(0x19EF)

// $19F0: Pogie Toss [8 bit]
//        set to 0x1e when tossed, counts down to 0 for toss
function pogie_toss() => byte(0x19F0)

// $19F1: Pogie Rest Timer [8 bit]
//        when pogie stops to rest, this becomes non-zero and counts down
//        walking when this value is zero
function pogie_rest_timer() => byte(0x19F1)

// $19F5: Dizzy's Door Opened [8 bit] (screen=0x00)
//        0x00 = Closed
//        0xFF = Open
function dizzys_door_opened() => byte(0x19F5)

// $19F6: Dozy's Door Opened [8 bit] (screen=0x08)
//        0x00 = Closed
//        0xFF = Open
function dozys_door_opened() => byte(0x19F6)

// $19F7: Dora's Door Opened [8 bit] (screen=0x0a)
//        0x00 = Closed
//        0xFF = Open
function doras_door_opened() => byte(0x19F7)

// $19F8: Dylan's Door Opened [8 bit] (screen=0x0a)
//        0x00 = Closed
//        0xFF = Open
function dylans_door_opened() => byte(0x19F8)

// $19F9: Grand Dizzy's Door Opened [8 bit] (screen=0x0b)
//        0x00 = Closed
//        0xFF = Open
function grand_dizzys_door_opened() => byte(0x19F9)

// $19FA: Denzil's Door Opened [8 bit] (screen=0x0c)
//        0x00 = Closed
//        0xFF = Open
function denzils_door_opened() => byte(0x19FA)

// $19FB: Daisy's Door Opened [8 bit] (screen=0x0c)
//        0x00 = Closed
//        0xFF = Open
function daisys_door_opened() => byte(0x19FB)

// $19FC: Zak's Castle Portcullis Opened [8 bit] (screen=0x1f)
//        0x00 = Closed
//        0xFF = Open
function zaks_castle_portcullis_opened() => byte(0x19FC)

// $19FE: River Minigame Star #01 [8 bit] (0/1)
MINIGAME_STARS_RIVER_ADDR = 0x19FE
MINIGAME_STARS_RIVER_COUNT = 10

// $1A08: Minecart Minigame Star #01 [8 bit] (0/1)
MINIGAME_STARS_MINE_ADDR = 0x1A08
MINIGAME_STARS_MINE_COUNT = 20

// $1A1C: Bubble Minigame Star #01 [8 bit] (0/1)
MINIGAME_STARS_WATER_ADDR = 0x1A1C
MINIGAME_STARS_WATER_COUNT = 10

// $1AE6: Extra Life Cheat Tracker [8 bit]
//        while paused: 2, Left, Left, Left, Left, 2
//        tracks each input 0->5, then 0xFF when awarding extra life
function extra_life_cheat_tracker() => byte(0x1AE6)

// $1AE7: Screen [8 bit]
//        0x00 = Home Sweet Home!
//        0x01 = A peaceful atmosphere engulfs you in Dylan's hut
//        0x02 = Oh woe! You feel so sad standing in Daisy's empty hut
//        0x03 = In the meeting hall. But nobody else is around
//        0x04 = So comfortable in Dora's homely hut
//        0x05 = In Grand Dizzy's hut near a large cast iron cooking cauldron
//        0x06 = Just being here in Dozy's hut makes you feel tired
//        0x07 = In Denzil's party pad with no reason to celebrate
//        0x08 = At the very top of the treehouse village near Dozy's drowsy hut
//        0x09 = High in the trees exploring near Dora's homely hut
//        0x0A = Busy searching high and low for useful things near Dylan's hut
//        0x0B = In the center of the treehouse village near Grand Dizzy's hut
//        0x0C = Wandering around the treehouse paths near Denzil's crucial pad
//        0x0D = Near Daisy's now deserted home in the treehouse
//        0x0E = On some familiar paths through the village near your own hut
//        0x0F = At the base of the Yolkfolk's secret treehouse
//        0x10 = In the countryside near an old wooden bridge over Silver Stream
//        0x11 = At Carber Bay gazing over golden sands and palm trees
//        0x12 = Near the dangerous but glorious crystal falls of Swift River
//        0x13 = In a small eerie cave below the haunted graveyard
//        0x14 = In the crystal clear waters of Carber Bay
//        0x15 = Under the sea near the wreck of an old pirate's galleon
//        0x16 = In a cold and dark graveyard near an old haunted church
//        0x17 = On the grasslands near a broken bridge over a dangerous pond
//        0x18 = High in the rigging of Blackheart the Pirate's ship
//        0x19 = On the upper decks of Blackheart the Pirate's dreaded ship
//        0x1A = Exploring deep into this old ship now owned by Blackheart
//        0x1B = Deep in the hull of the pirate ship, well below sea level
//        0x1C = On Castle Street, where you'll find the shopkeeper
//        0x1D = In the village of Keldor wandering along Bridge St.
//        0x1E = In Dock St. in the troll's village of Keldor
//        0x1F = Your feet are sinking through the soft white clouds
//        0x20 = Near wizard Zaks' magical cloud castle
//        0x21 = Approaching Zaks' tower where Daisy is being held captive
//        0x22 = In the central part of Zaks' awesome castle
//        0x23 = On the lower level of the evil wizard Zaks' castle
//        0x24 = In a dank and dingy tunnel between Dock St. and Castle St.
//        0x25 = In a smelly and dark tunnel linking Castle St. to Bridge St.
//        0x26 = In a dark passage between Castle St. and Bridge St.
//        0x27 = In a long dark tunnel between Dock St. and Castle St.
//        0x28 = In the passageway between Dock St. and Bridge St.
//        0x29 = Walking through a passage that links Castle St. to Dock St.
//        0x2A = In a spooky tunnel between Castle St. and Bridge St.
//        0x2B = In the diamond mines near the elevator control machines
//        0x2C = Underground in the mines near the unused railway track
//        0x2D = In the deepest and least charted tunnels of the diamond mines
//        0x2E = Very bold exploring this far into this deadly castle
//        0x2F = In the reception hall of the trolls' eerie castle
//        0x30 = In a small deep cave below the ocean floor
function screen() => byte(0x1AE7)

// $1AE9: Dizzy X Position [16 bit]
function dizzy_xpos() => word(0x1AE9)

// $1AEB: Dizzy Y Position [8 bit]
function dizzy_ypos() => byte(0x1AEB)

// $1AEE: Camera X Position [16 bit]
function camera_x_position() => word(0x1AEE)

// $1AF5: Inventory Animation Status [8 bit]
//        0x00 = Gameplay
//        0x04 = In inventory menu
//        other values are transition values for Dizzy's animation of bending over
function inventory_anim() => byte(0x1AF5)

// $1AF8: Reversed Controls Timer [8 bit]
//        set to 0xFF when hit by blue butterfly (unless non-zero, where it sets back to 0 immediately). counts back down to 0 every 4f (using 0x1b29), where controls return to normal
function reversed_controls_timer() => byte(0x1AF8)

// $1B12: Damage [8 bit]
//        0x00 = no damage taken
//        0x50 = death
function damage() => byte(0x1B12)

// $1BBA: Language [8 bit]
//        0 = English
//        1 = French
//        2 = German
//        3 = Italian
//        4 = Spanish
function language() => byte(0x1BBA)

// $1BBB: Demo Check [8 bit]
//        0x00 = Playing (also 0 during Codemasters screen and language select)
//        0xFF = Title Screen + Demo
function demo_check() => byte(0x1BBB)

// $1BE3: Game State [8 bit]
//        0 = Loading/Transition
//        1 = Normal Gameplay
//        2 = Menu/Inventory
//        3 = Intro Text/Message
//        4 = Most Minigame Screens + Sliding Puzzles
//        5 = Minecart (screen=0x2c)
//        6 = Dead in Minigame
//        7 = Codemasters Intro
//        
//        Minigames that use mode 4, the screen ids are listed below to identify the minigame:
//        0x19 = bubbles
//        0x1c = archery
//        0x1d = river barrel
//        0x21 = final tower
//        
//        Swap puzzles:
//        location in item table, screen becomes 0xFE when read
//        0x15: screen=0x1e
//        0x16: screen=0x12
//        0x17: screen=0x21
//        0x18: screen=0x17 (right)
//        0x19: screen=0x0e
//        0x1A: screen=0x17 (left)
function game_state() => byte(0x1BE3)

// --- MAIN DATA -------------------------------------------------------------------

STATE_LOADING = 0
STATE_PLAYING = 1
STATE_MENU = 2
STATE_MESSAGE = 3
STATE_MINIGAME = 4
STATE_MINECART = 5
STATE_MINIGAME_DEATH = 6
STATE_CODEMASTERS = 7

ALL_COLLECTABLES = [
	{"addr": 0x1923, "bit": 0, "screen": 0x03, "type": "star"}, // Right of table
	{"addr": 0x1923, "bit": 1, "screen": 0x03, "type": "star"}, // Left of table
	{"addr": 0x1923, "bit": 2, "screen": 0x02, "type": "star"}, // Right of door
	{"addr": 0x1923, "bit": 3, "screen": 0x02, "type": "star"}, // Over bed
	{"addr": 0x1923, "bit": 4, "screen": 0x01, "type": "star"}, // Right of Dylan's table
	{"addr": 0x1923, "bit": 5, "screen": 0x01, "type": "star"}, // Above Dylan's bed
	{"addr": 0x1923, "bit": 6, "screen": 0x00, "type": "star"}, // Dizzy's room right
	{"addr": 0x1923, "bit": 7, "screen": 0x00, "type": "star"}, // Dizzy's room left
	{"addr": 0x1924, "bit": 0, "screen": 0x07, "type": "star"}, // Denzil's room right
	{"addr": 0x1924, "bit": 1, "screen": 0x07, "type": "star"}, // Denzil's room left
	{"addr": 0x1924, "bit": 2, "screen": 0x06, "type": "star"}, // Dozy's right ceiling
	{"addr": 0x1924, "bit": 3, "screen": 0x06, "type": "star"}, // Dozy's left side table
	{"addr": 0x1924, "bit": 4, "screen": 0x05, "type": "star"}, // Table near cauldron
	{"addr": 0x1924, "bit": 5, "screen": 0x05, "type": "star"}, // Left of GD's bed
	{"addr": 0x1924, "bit": 6, "screen": 0x04, "type": "star"}, // Right of bed
	{"addr": 0x1924, "bit": 7, "screen": 0x04, "type": "star"}, // Left of door
	{"addr": 0x1925, "bit": 0, "screen": 0x0a, "type": "star"}, // Right of Dylan's hut
	{"addr": 0x1925, "bit": 1, "screen": 0x0a, "type": "star"}, // Above Dylan's hut, top of elevator
	{"addr": 0x1925, "bit": 2, "screen": 0x0a, "type": "star"}, // Far left, bottom of useless ramp
	{"addr": 0x1925, "bit": 3, "screen": 0x09, "type": "star"}, // Right of hook
	{"addr": 0x1925, "bit": 4, "screen": 0x09, "type": "star"}, // Above hook
	{"addr": 0x1925, "bit": 5, "screen": 0x09, "type": "star"}, // Right of Dora's hut
	{"addr": 0x1925, "bit": 6, "screen": 0x08, "type": "star"}, // Right of Dozy's hut
	{"addr": 0x1925, "bit": 7, "screen": 0x08, "type": "star"}, // Far right, raised platform
	{"addr": 0x1926, "bit": 0, "screen": 0x0b, "type": "star"}, // End of ramp, by key to Dylan's elevator
	{"addr": 0x1926, "bit": 1, "screen": 0x0b, "type": "star"}, // Under ramp
	{"addr": 0x1926, "bit": 2, "screen": 0x0b, "type": "star"}, // Far right of Grand Dizzy's hut
	{"addr": 0x1926, "bit": 3, "screen": 0x0b, "type": "star"}, // Right of Grand Dizzy's hut
	{"addr": 0x1926, "bit": 4, "screen": 0x0b, "type": "star"}, // Upper path above Grand Dizzy's hut
	{"addr": 0x1926, "bit": 5, "screen": 0x0b, "type": "star"}, // Far left above elevator
	{"addr": 0x1926, "bit": 6, "screen": 0x0a, "type": "star"}, // Far right high ant platform
	{"addr": 0x1926, "bit": 7, "screen": 0x0a, "type": "star"}, // Far right down ramp
	{"addr": 0x1927, "bit": 0, "screen": 0x0d, "type": "star"}, // Left of meeting hall
	{"addr": 0x1927, "bit": 1, "screen": 0x0d, "type": "star"}, // Upper walkway, above spider
	{"addr": 0x1927, "bit": 2, "screen": 0x0d, "type": "star"}, // Above Dizzy's hut, left of rope swing
	{"addr": 0x1927, "bit": 3, "screen": 0x0c, "type": "star"}, // Right of Denzil's elevator
	{"addr": 0x1927, "bit": 4, "screen": 0x0c, "type": "star"}, // Between Denzil's hut and elevator
	{"addr": 0x1927, "bit": 5, "screen": 0x0c, "type": "star"}, // On ramp up, right of star plant
	{"addr": 0x1927, "bit": 6, "screen": 0x0c, "type": "star"}, // Left of dry straw
	{"addr": 0x1927, "bit": 7, "screen": 0x0c, "type": "star"}, // Far left, between two spiders
	{"addr": 0x1928, "bit": 0, "screen": 0x0e, "type": "star"}, // Far right, near spider
	{"addr": 0x1928, "bit": 1, "screen": 0x0e, "type": "star"}, // Up dead-end ramp
	{"addr": 0x1928, "bit": 2, "screen": 0x0e, "type": "star"}, // Top of ramp above snappy weed
	{"addr": 0x1928, "bit": 3, "screen": 0x0e, "type": "star"}, // Right of Dizzy's hut
	{"addr": 0x1928, "bit": 4, "screen": 0x0e, "type": "star"}, // In front of Dizzy's hut
	{"addr": 0x1928, "bit": 5, "screen": 0x0e, "type": "star"}, // Left, above key
	{"addr": 0x1928, "bit": 6, "screen": 0x0d, "type": "star"}, // Right of Daisy's hut
	{"addr": 0x1928, "bit": 7, "screen": 0x0d, "type": "star"}, // Ramp up near spider
	{"addr": 0x1929, "bit": 0, "screen": 0x0f, "type": "star"}, // Right of bridge, near spider
	{"addr": 0x1929, "bit": 1, "screen": 0x0f, "type": "star"}, // On upper walkway, right of bridge
	{"addr": 0x1929, "bit": 2, "screen": 0x0f, "type": "star"}, // Right of bridge, near bridge
	{"addr": 0x1929, "bit": 3, "screen": 0x0f, "type": "star"}, // Above bridge over spikes
	{"addr": 0x1929, "bit": 4, "screen": 0x0f, "type": "star"}, // On ramp down to elevator
	{"addr": 0x1929, "bit": 5, "screen": 0x0f, "type": "star"}, // Near ground left of elevator
	{"addr": 0x1929, "bit": 6, "screen": 0x0f, "type": "star"}, // Right of Prince Clumsy
	{"addr": 0x1929, "bit": 7, "screen": 0x0f, "type": "star"}, // Far right near hill down
	{"addr": 0x192a, "bit": 0, "screen": 0x11, "type": "star"}, // Far left, on beach
	{"addr": 0x192a, "bit": 1, "screen": 0x10, "type": "star"}, // Far right, near hill down
	{"addr": 0x192a, "bit": 2, "screen": 0x10, "type": "star"}, // Hill, above wrench
	{"addr": 0x192a, "bit": 3, "screen": 0x10, "type": "star"}, // Right of bridge
	{"addr": 0x192a, "bit": 4, "screen": 0x10, "type": "star"}, // Under left side of destroyed bridge
	{"addr": 0x192a, "bit": 5, "screen": 0x10, "type": "star"}, // Left of volcano
	{"addr": 0x192a, "bit": 6, "screen": 0x10, "type": "star"}, // Passage into mines
	{"addr": 0x192a, "bit": 7, "screen": 0x0f, "type": "star"}, // Far right of bridge
	{"addr": 0x192b, "bit": 0, "screen": 0x11, "type": "star"}, // Above mineshaft door
	{"addr": 0x192b, "bit": 1, "screen": 0x11, "type": "star"}, // Left side of right shore
	{"addr": 0x192b, "bit": 2, "screen": 0x11, "type": "star"}, // Right of right island, in open water
	{"addr": 0x192b, "bit": 3, "screen": 0x11, "type": "star"}, // Right of right island, in water near surface
	{"addr": 0x192b, "bit": 4, "screen": 0x11, "type": "star"}, // Right island, inland slightly
	{"addr": 0x192b, "bit": 5, "screen": 0x11, "type": "star"}, // Right island, in water
	{"addr": 0x192b, "bit": 6, "screen": 0x11, "type": "star"}, // Left island
	{"addr": 0x192b, "bit": 7, "screen": 0x11, "type": "star"}, // Left beach near water
	{"addr": 0x192c, "bit": 0, "screen": 0x13, "type": "star"}, // Right side over water
	{"addr": 0x192c, "bit": 1, "screen": 0x13, "type": "star"}, // Low platform in center
	{"addr": 0x192c, "bit": 2, "screen": 0x13, "type": "star"}, // Left side over water
	{"addr": 0x192c, "bit": 3, "screen": 0x12, "type": "star"}, // Coming down hill
	{"addr": 0x192c, "bit": 4, "screen": 0x12, "type": "star"}, // In dino's patrol
	{"addr": 0x192c, "bit": 5, "screen": 0x12, "type": "star"}, // Right of dino, near spider
	{"addr": 0x192c, "bit": 6, "screen": 0x12, "type": "star"}, // Left of gold coins
	{"addr": 0x192c, "bit": 7, "screen": 0x12, "type": "star"}, // Far left, near hill
	{"addr": 0x192d, "bit": 0, "screen": 0x15, "type": "star"}, // Far left alcove entrance
	{"addr": 0x192d, "bit": 1, "screen": 0x15, "type": "star"}, // Far left alcove in the back
	{"addr": 0x192d, "bit": 2, "screen": 0x14, "type": "star"}, // Under right side of right island
	{"addr": 0x192d, "bit": 3, "screen": 0x14, "type": "star"}, // Right side hill
	{"addr": 0x192d, "bit": 4, "screen": 0x14, "type": "star"}, // Under middle of right island
	{"addr": 0x192d, "bit": 5, "screen": 0x14, "type": "star"}, // Under left side of right island
	{"addr": 0x192d, "bit": 6, "screen": 0x14, "type": "star"}, // Seaweed right side
	{"addr": 0x192d, "bit": 7, "screen": 0x14, "type": "star"}, // Alcove below left island
	{"addr": 0x192e, "bit": 0, "screen": 0x16, "type": "star"}, // Far left, beside tree
	{"addr": 0x192e, "bit": 1, "screen": 0x15, "type": "star"}, // Underwater, far right sea cave
	{"addr": 0x192e, "bit": 2, "screen": 0x15, "type": "star"}, // Underwater ledge above crowbar rock
	{"addr": 0x192e, "bit": 3, "screen": 0x15, "type": "star"}, // Underwater, by crowbar rock
	{"addr": 0x192e, "bit": 4, "screen": 0x15, "type": "star"}, // On sunken ship
	{"addr": 0x192e, "bit": 5, "screen": 0x15, "type": "star"}, // Left of sunken ship
	{"addr": 0x192e, "bit": 6, "screen": 0x15, "type": "star"}, // Paired stars, higher
	{"addr": 0x192e, "bit": 7, "screen": 0x15, "type": "star"}, // Paired stars, lower
	{"addr": 0x192f, "bit": 0, "screen": 0x17, "type": "star"}, // Far left near scroll
	{"addr": 0x192f, "bit": 1, "screen": 0x16, "type": "star"}, // Above right ledge
	{"addr": 0x192f, "bit": 2, "screen": 0x16, "type": "star"}, // Far right bridged platform
	{"addr": 0x192f, "bit": 3, "screen": 0x16, "type": "star"}, // Directly right of newly built bridge
	{"addr": 0x192f, "bit": 4, "screen": 0x16, "type": "star"}, // Right of brick house
	{"addr": 0x192f, "bit": 5, "screen": 0x16, "type": "star"}, // Left of brick house
	{"addr": 0x192f, "bit": 6, "screen": 0x16, "type": "star"}, // At highest ledge, left of brick house
	{"addr": 0x192f, "bit": 7, "screen": 0x16, "type": "star"}, // Beside ledges, left of brick house
	{"addr": 0x1930, "bit": 0, "screen": 0x18, "type": "star"}, // Middle line, middle mast
	{"addr": 0x1930, "bit": 1, "screen": 0x18, "type": "star"}, // Left mast
	{"addr": 0x1930, "bit": 2, "screen": 0x17, "type": "star"}, // Entrance to right cave
	{"addr": 0x1930, "bit": 3, "screen": 0x17, "type": "star"}, // Inside center dead-end cave
	{"addr": 0x1930, "bit": 4, "screen": 0x17, "type": "star"}, // Left of leprechaun
	{"addr": 0x1930, "bit": 5, "screen": 0x17, "type": "star"}, // Above right side of broken bridge
	{"addr": 0x1930, "bit": 6, "screen": 0x17, "type": "star"}, // Above left side of broken bridge
	{"addr": 0x1930, "bit": 7, "screen": 0x17, "type": "star"}, // Further inland from left side
	{"addr": 0x1931, "bit": 0, "screen": 0x19, "type": "star"}, // Above deck, beside middle mast
	{"addr": 0x1931, "bit": 1, "screen": 0x19, "type": "star"}, // Directly beneath middle mast
	{"addr": 0x1931, "bit": 2, "screen": 0x19, "type": "star"}, // Middle floor, between masts
	{"addr": 0x1931, "bit": 3, "screen": 0x19, "type": "star"}, // Bottom, directly beneath left mast
	{"addr": 0x1931, "bit": 4, "screen": 0x19, "type": "star"}, // Left of left mast
	{"addr": 0x1931, "bit": 5, "screen": 0x19, "type": "star"}, // Bottom left in ship
	{"addr": 0x1931, "bit": 6, "screen": 0x19, "type": "star"}, // Ramp up to ship
	{"addr": 0x1931, "bit": 7, "screen": 0x18, "type": "star"}, // Right of rope swing
	{"addr": 0x1932, "bit": 0, "screen": 0x1c, "type": "star"}, // Far left of Castle St, building window
	{"addr": 0x1932, "bit": 1, "screen": 0x1c, "type": "star"}, // Far left of Castle St, near water
	{"addr": 0x1932, "bit": 2, "screen": 0x1b, "type": "star"}, // Bottom floor, far right
	{"addr": 0x1932, "bit": 3, "screen": 0x1b, "type": "star"}, // Bottom floor, beside barrel
	{"addr": 0x1932, "bit": 4, "screen": 0x1a, "type": "star"}, // Far right, top near path up
	{"addr": 0x1932, "bit": 5, "screen": 0x1a, "type": "star"}, // Bottom floor, center beside barre
	{"addr": 0x1932, "bit": 6, "screen": 0x1a, "type": "star"}, // Left side
	{"addr": 0x1932, "bit": 7, "screen": 0x19, "type": "star"}, // Directly above cannon
	{"addr": 0x1933, "bit": 0, "screen": 0x1d, "type": "star"}, // Next to tunnel to Dock St
	{"addr": 0x1933, "bit": 1, "screen": 0x1d, "type": "star"}, // In front of stone wall
	{"addr": 0x1933, "bit": 2, "screen": 0x1d, "type": "star"}, // Right of tunnel to Castle St
	{"addr": 0x1933, "bit": 3, "screen": 0x1d, "type": "star"}, // In shaft left side of Castle St
	{"addr": 0x1933, "bit": 4, "screen": 0x1c, "type": "star"}, // Far right of Castle Street
	{"addr": 0x1933, "bit": 5, "screen": 0x1c, "type": "star"}, // Near tunnel entrance
	{"addr": 0x1933, "bit": 6, "screen": 0x1c, "type": "star"}, // Near portcullis
	{"addr": 0x1933, "bit": 7, "screen": 0x1c, "type": "star"}, // Near tunnel to Dock St
	{"addr": 0x1934, "bit": 0, "screen": 0x1e, "type": "star"}, // Next to brick wall
	{"addr": 0x1934, "bit": 1, "screen": 0x1e, "type": "star"}, // Over Dock St door
	{"addr": 0x1934, "bit": 2, "screen": 0x1e, "type": "star"}, // Left of Dock St building
	{"addr": 0x1934, "bit": 3, "screen": 0x1e, "type": "star"}, // Far left of Dock St
	{"addr": 0x1934, "bit": 4, "screen": 0x1e, "type": "star"}, // Far left of Dock St, near water
	{"addr": 0x1934, "bit": 5, "screen": 0x1d, "type": "star"}, // Far right near Crystal River
	{"addr": 0x1934, "bit": 6, "screen": 0x1d, "type": "star"}, // Beside tunnel to Castle St
	{"addr": 0x1934, "bit": 7, "screen": 0x1d, "type": "star"}, // Left, near bridge
	{"addr": 0x1935, "bit": 0, "screen": 0x20, "type": "star"}, // Lower cloud directly right at start
	{"addr": 0x1935, "bit": 1, "screen": 0x20, "type": "star"}, // Middle cloud, left of start
	{"addr": 0x1935, "bit": 2, "screen": 0x20, "type": "star"}, // Far left cloud
	{"addr": 0x1935, "bit": 3, "screen": 0x1f, "type": "star"}, // Middle right cloud
	{"addr": 0x1935, "bit": 4, "screen": 0x1f, "type": "star"}, // Left from vine
	{"addr": 0x1935, "bit": 5, "screen": 0x1f, "type": "star"}, // Left of Zak's castle
	{"addr": 0x1935, "bit": 6, "screen": 0x1e, "type": "star"}, // On bridge next to pirate
	{"addr": 0x1935, "bit": 7, "screen": 0x1e, "type": "star"}, // Right end of street over door
	{"addr": 0x1936, "bit": 0, "screen": 0x22, "type": "star"}, // On the roof, accessible from left side
	{"addr": 0x1936, "bit": 1, "screen": 0x22, "type": "star"}, // Over table
	{"addr": 0x1936, "bit": 2, "screen": 0x22, "type": "star"}, // Left wall
	{"addr": 0x1936, "bit": 3, "screen": 0x21, "type": "star"}, // Center of fireplace
	{"addr": 0x1936, "bit": 4, "screen": 0x21, "type": "star"}, // Lower platform left of fireplace
	{"addr": 0x1936, "bit": 5, "screen": 0x21, "type": "star"}, // Left end of long hallway
	{"addr": 0x1936, "bit": 6, "screen": 0x21, "type": "star"}, // Leftmost platform
	{"addr": 0x1936, "bit": 7, "screen": 0x20, "type": "star"}, // Upper cloud right of vine
	{"addr": 0x1937, "bit": 0, "screen": 0x23, "type": "star"}, // High platform
	{"addr": 0x1937, "bit": 1, "screen": 0x23, "type": "star"}, // Under stairs
	{"addr": 0x1937, "bit": 2, "screen": 0x23, "type": "star"}, // Immediately at entrance to castle
	{"addr": 0x1937, "bit": 3, "screen": 0x22, "type": "star"}, // Low platform far right
	{"addr": 0x1937, "bit": 4, "screen": 0x22, "type": "star"}, // Right side, big jump past spiders
	{"addr": 0x1937, "bit": 5, "screen": 0x22, "type": "star"}, // Low platform right of fireplace
	{"addr": 0x1937, "bit": 6, "screen": 0x22, "type": "star"}, // High rope swing ledge above fireplace
	{"addr": 0x1937, "bit": 7, "screen": 0x22, "type": "star"}, // Small platform left of fireplace
	{"addr": 0x1938, "bit": 0, "screen": 0x29, "type": "star"}, // Right tunnel
	{"addr": 0x1938, "bit": 1, "screen": 0x28, "type": "star"}, // Center of tunnel
	{"addr": 0x1938, "bit": 2, "screen": 0x27, "type": "star"}, // Center of tunnel
	{"addr": 0x1938, "bit": 3, "screen": 0x26, "type": "star"}, // Center of tunnel
	{"addr": 0x1938, "bit": 4, "screen": 0x25, "type": "star"}, // Center of tunnel
	{"addr": 0x1938, "bit": 5, "screen": 0x24, "type": "star"}, // Left tunnel
	{"addr": 0x1938, "bit": 6, "screen": 0x23, "type": "star"}, // Far right under arch
	{"addr": 0x1938, "bit": 7, "screen": 0x23, "type": "star"}, // Bottom of cutoff stairs
	{"addr": 0x1939, "bit": 0, "screen": 0x2c, "type": "star"}, // Left of top pile
	{"addr": 0x1939, "bit": 1, "screen": 0x2b, "type": "star"}, // Far right underwater alcove, high
	{"addr": 0x1939, "bit": 2, "screen": 0x2b, "type": "star"}, // Underwater, left of cymbals
	{"addr": 0x1939, "bit": 3, "screen": 0x2b, "type": "star"}, // Out of water, high ledge above elevator controls
	{"addr": 0x1939, "bit": 4, "screen": 0x2b, "type": "star"}, // Left of elevator control machine
	{"addr": 0x1939, "bit": 5, "screen": 0x2b, "type": "star"}, // Bottom of elevator
	{"addr": 0x1939, "bit": 6, "screen": 0x2b, "type": "star"}, // In elevator
	{"addr": 0x1939, "bit": 7, "screen": 0x2a, "type": "star"}, // Above knight guard
	{"addr": 0x193a, "bit": 0, "screen": 0x2d, "type": "star"}, // Left of lava geyser
	{"addr": 0x193a, "bit": 1, "screen": 0x2d, "type": "star"}, // Bottom, under Danger sign
	{"addr": 0x193a, "bit": 2, "screen": 0x2c, "type": "star"}, // Under dragon
	{"addr": 0x193a, "bit": 3, "screen": 0x2c, "type": "star"}, // Directly in front of dragon
	{"addr": 0x193a, "bit": 4, "screen": 0x2c, "type": "star"}, // Far right top, near chute
	{"addr": 0x193a, "bit": 5, "screen": 0x2c, "type": "star"}, // Bottom of elevator, right
	{"addr": 0x193a, "bit": 6, "screen": 0x2c, "type": "star"}, // Bottom of elevator, left past box
	{"addr": 0x193a, "bit": 7, "screen": 0x2c, "type": "star"}, // Right of top pile
	{"addr": 0x193b, "bit": 0, "screen": 0x2e, "type": "star"}, // Fireplace
	{"addr": 0x193b, "bit": 1, "screen": 0x2e, "type": "star"}, // Left of spider, left side
	{"addr": 0x193b, "bit": 2, "screen": 0x2e, "type": "star"}, // Far left
	{"addr": 0x193b, "bit": 3, "screen": 0x2d, "type": "star"}, // Farthest right alcove, by right elevator
	{"addr": 0x193b, "bit": 4, "screen": 0x2d, "type": "star"}, // Above left lava geyser bridge
	{"addr": 0x193b, "bit": 5, "screen": 0x2d, "type": "star"}, // Top, beside plunger
	{"addr": 0x193b, "bit": 6, "screen": 0x2d, "type": "star"}, // Bottom of elevator
	{"addr": 0x193b, "bit": 7, "screen": 0x2d, "type": "star"}, // Above right lava geyser bridge
	{"addr": 0x193c, "bit": 0, "screen": 0x30, "type": "star"}, // Left upper alcove
	{"addr": 0x193c, "bit": 1, "screen": 0x2f, "type": "star"}, // Castle entrance
	{"addr": 0x193c, "bit": 2, "screen": 0x2f, "type": "star"}, // Bottom of stairs
	{"addr": 0x193c, "bit": 3, "screen": 0x2f, "type": "star"}, // Top floor, by tables
	{"addr": 0x193c, "bit": 4, "screen": 0x2f, "type": "star"}, // Far left, upper floor
	{"addr": 0x193c, "bit": 5, "screen": 0x2f, "type": "star"}, // Far left, bottom floor
	{"addr": 0x193c, "bit": 6, "screen": 0x2e, "type": "star"}, // Far right, bottom level
	{"addr": 0x193c, "bit": 7, "screen": 0x2e, "type": "star"}, // Bat hallway
	{"addr": 0x193d, "bit": 6, "screen": 0x30, "type": "star"}, // Far right corner
	{"addr": 0x193d, "bit": 7, "screen": 0x30, "type": "star"}, // Bottom left alcove

	{"addr": 0x1943, "bit": 0, "screen": 0x0d, "type": "apple"}, // Ramp up near spider
	{"addr": 0x1943, "bit": 1, "screen": 0x0d, "type": "apple"}, // Above Dizzy's hut, left of rope swing
	{"addr": 0x1943, "bit": 2, "screen": 0x0c, "type": "grapes"}, // Behind tree on ramp
	{"addr": 0x1943, "bit": 3, "screen": 0x0b, "type": "orange"}, // Top of Grand Dizzy's elevator
	{"addr": 0x1943, "bit": 4, "screen": 0x0a, "type": "pear"}, // Far left, top of useless ramp
	{"addr": 0x1943, "bit": 5, "screen": 0x09, "type": "mango"}, // Left of Dylan's hut
	{"addr": 0x1943, "bit": 6, "screen": 0x10, "type": "pear"}, // Right under destroyed bridge
	{"addr": 0x1943, "bit": 7, "screen": 0x10, "type": "pear"}, // Behind tree left of volcano
	{"addr": 0x1944, "bit": 0, "screen": 0x04, "type": "orange"}, // Rafters of Dora's room, unreachable?
	{"addr": 0x1944, "bit": 1, "screen": 0x03, "type": "strawberry"}, // On table
	{"addr": 0x1944, "bit": 2, "screen": 0x02, "type": "pear"}, // On shelf
	{"addr": 0x1944, "bit": 3, "screen": 0x01, "type": "orange"}, // Above Dylan's bed, ceiling
	{"addr": 0x1944, "bit": 4, "screen": 0x00, "type": "apple"}, // Dizzy's room
	{"addr": 0x1944, "bit": 5, "screen": 0x0f, "type": "strawberry"}, // Behind tree left of elevator
	{"addr": 0x1944, "bit": 6, "screen": 0x0e, "type": "mango"}, // Above snappy weed
	{"addr": 0x1944, "bit": 7, "screen": 0x0e, "type": "mango"}, // Left, by spider
	{"addr": 0x1945, "bit": 0, "screen": 0x18, "type": "pear"}, // Top line, above hook
	{"addr": 0x1945, "bit": 1, "screen": 0x17, "type": "strawberry"}, // Under tree right of broken bridge
	{"addr": 0x1945, "bit": 2, "screen": 0x16, "type": "cherry"}, // Behind tree
	{"addr": 0x1945, "bit": 3, "screen": 0x16, "type": "cherry"}, // Behind canopy, far left
	{"addr": 0x1945, "bit": 4, "screen": 0x12, "type": "mango"}, // Below tree, near gold coins
	{"addr": 0x1945, "bit": 5, "screen": 0x11, "type": "grapes"}, // Far left, on beach
	{"addr": 0x1945, "bit": 6, "screen": 0x06, "type": "apple"}, // Dozy's table
	{"addr": 0x1945, "bit": 7, "screen": 0x05, "type": "pear"}, // Cauldron ledge
	{"addr": 0x1946, "bit": 0, "screen": 0x21, "type": "melon"}, // Right end of long hallway
	{"addr": 0x1946, "bit": 1, "screen": 0x21, "type": "melon"}, // Leftmost platform
	{"addr": 0x1946, "bit": 2, "screen": 0x20, "type": "strawberry"}, // Upper cloud right of vine
	{"addr": 0x1946, "bit": 3, "screen": 0x20, "type": "strawberry"}, // Lower cloud on left
	{"addr": 0x1946, "bit": 4, "screen": 0x1d, "type": "mango"}, // Far left in tunnel
	{"addr": 0x1946, "bit": 5, "screen": 0x1b, "type": "orange"}, // Left side
	{"addr": 0x1946, "bit": 6, "screen": 0x1a, "type": "mango"}, // Center, upper ledge
	{"addr": 0x1946, "bit": 7, "screen": 0x19, "type": "mango"}, // Far right, bottom under ledge
	{"addr": 0x1947, "bit": 0, "screen": 0x2e, "type": "cherry"}, // Right side, far left of bat hallway
	{"addr": 0x1947, "bit": 1, "screen": 0x2e, "type": "cherry"}, // Left of fireplace
	{"addr": 0x1947, "bit": 2, "screen": 0x2e, "type": "cherry"}, // Far left, in front of mirror
	{"addr": 0x1947, "bit": 3, "screen": 0x2f, "type": "melon"}, // Left of stairs, bottom
	{"addr": 0x1947, "bit": 4, "screen": 0x2f, "type": "melon"}, // Bottom, far left
	{"addr": 0x1947, "bit": 5, "screen": 0x29, "type": "apple"}, // Near star
	{"addr": 0x1947, "bit": 6, "screen": 0x23, "type": "melon"}, // Far right, behind pillar
	{"addr": 0x1947, "bit": 7, "screen": 0x23, "type": "melon"}, // Under stairs
	{"addr": 0x194b, "bit": 0, "screen": 0x0e, "type": "mango"}, // Jump off right
	{"addr": 0x194b, "bit": 1, "screen": 0x0d, "type": "mango"}, // Right of rope swing
	{"addr": 0x194b, "bit": 2, "screen": 0x0c, "type": "cherry"}, // Near dry straw
	{"addr": 0x194b, "bit": 3, "screen": 0x0b, "type": "strawberry"}, // Right of Grand Dizzy's hut
	{"addr": 0x194b, "bit": 4, "screen": 0x0a, "type": "mango"}, // Right of Dylan's hut
	{"addr": 0x194b, "bit": 5, "screen": 0x09, "type": "grapes"}, // Right of hook
	{"addr": 0x194b, "bit": 6, "screen": 0x08, "type": "cherry"}, // Outside Dozy's hut
	{"addr": 0x194b, "bit": 7, "screen": 0x10, "type": "apple"}, // Right of volcano
	{"addr": 0x194c, "bit": 0, "screen": 0x04, "type": "cherry"}, // Left of bed
	{"addr": 0x194c, "bit": 1, "screen": 0x04, "type": "cherry"}, // Left of table
	{"addr": 0x194c, "bit": 2, "screen": 0x03, "type": "grapes"}, // Top of left shelf
	{"addr": 0x194c, "bit": 3, "screen": 0x01, "type": "melon"}, // Ceiling Dylan's room
	{"addr": 0x194c, "bit": 4, "screen": 0x00, "type": "cherry"}, // Dizzy's room
	{"addr": 0x194c, "bit": 5, "screen": 0x0f, "type": "apple"}, // Right of bridge
	{"addr": 0x194c, "bit": 6, "screen": 0x0e, "type": "apple"}, // Awkward jump under ramp
	{"addr": 0x194c, "bit": 7, "screen": 0x0e, "type": "apple"}, // Right of Dizzy's hut
	{"addr": 0x194d, "bit": 0, "screen": 0x19, "type": "apple"}, // Top left inside ship
	{"addr": 0x194d, "bit": 1, "screen": 0x18, "type": "apple"}, // Far left, beside wheel
	{"addr": 0x194d, "bit": 2, "screen": 0x16, "type": "mango"}, // On bridged platform
	{"addr": 0x194d, "bit": 3, "screen": 0x16, "type": "mango"}, // Far left, hanging from canopy
	{"addr": 0x194d, "bit": 4, "screen": 0x12, "type": "apple"}, // Top of tree right of dino
	{"addr": 0x194d, "bit": 5, "screen": 0x11, "type": "mango"}, // Right island, by rocks
	{"addr": 0x194d, "bit": 6, "screen": 0x07, "type": "strawberry"}, // Denzil's room
	{"addr": 0x194d, "bit": 7, "screen": 0x05, "type": "mango"}, // GD's table chair
	{"addr": 0x194e, "bit": 0, "screen": 0x22, "type": "mango"}, // Between two spiders
	{"addr": 0x194e, "bit": 1, "screen": 0x21, "type": "mango"}, // Right of fireplace
	{"addr": 0x194e, "bit": 2, "screen": 0x20, "type": "apple"}, // Upper cloud left at start
	{"addr": 0x194e, "bit": 3, "screen": 0x20, "type": "apple"}, // Lower cloud directly right at start
	{"addr": 0x194e, "bit": 4, "screen": 0x1d, "type": "grapes"}, // Next to brick wall
	{"addr": 0x194e, "bit": 5, "screen": 0x1b, "type": "melon"}, // Under stairs
	{"addr": 0x194e, "bit": 6, "screen": 0x1a, "type": "strawberry"}, // Center, beside "door"
	{"addr": 0x194e, "bit": 7, "screen": 0x1a, "type": "strawberry"}, // Far left
	{"addr": 0x194f, "bit": 1, "screen": 0x2e, "type": "apple"}, // Right side, top level
	{"addr": 0x194f, "bit": 2, "screen": 0x2e, "type": "apple"}, // Left side, right of spider
	{"addr": 0x194f, "bit": 3, "screen": 0x2f, "type": "mango"}, // Bottom of stairs
	{"addr": 0x194f, "bit": 4, "screen": 0x2f, "type": "mango"}, // Top floor, far left
	{"addr": 0x194f, "bit": 5, "screen": 0x2a, "type": "cherry"}, // Above Bridge St sign
	{"addr": 0x194f, "bit": 6, "screen": 0x28, "type": "cherry"}, // In tunnel
	{"addr": 0x194f, "bit": 7, "screen": 0x22, "type": "mango"}, // Over table, left side

	{"addr": 0x1953, "bit": 0, "screen": 0x2d, "type": "diamond"}, // Bottom of elevator
	{"addr": 0x1953, "bit": 1, "screen": 0x2d, "type": "diamond"}, // Right of right lava geyser bridge
	{"addr": 0x1953, "bit": 2, "screen": 0x2c, "type": "diamond"}, // Bottom of elevator, left past box
	{"addr": 0x1953, "bit": 3, "screen": 0x2c, "type": "diamond"}, // Top, right side
	{"addr": 0x1953, "bit": 4, "screen": 0x2c, "type": "diamond"}, // Bottom of elevator, right
	{"addr": 0x1953, "bit": 5, "screen": 0x2c, "type": "diamond"}, // Bottom of elevator, far right
	{"addr": 0x1953, "bit": 6, "screen": 0x2b, "type": "diamond"}, // Bottom of elevator, right alcove
	{"addr": 0x1953, "bit": 7, "screen": 0x2b, "type": "diamond"}, // Left of elevator
	{"addr": 0x1954, "bit": 7, "screen": 0x2d, "type": "diamond"}, // Top left of right elevator
]

FRUITS = ["apple", "cherry", "mango", "orange", "grapes", "melon", "strawberry", "pear"]

SCREENS_VILLAGE = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, ]
SCREENS_COUNTRYSIDE_MINES = [0x10, 0x12, 0x2B, 0x2C, 0x2D, ]
SCREENS_KELDOR = [0x1C, 0x1D, 0x1E, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2E, 0x2F, ]
SCREENS_SHIP_CARBERBAY = [0x11, 0x14, 0x15, 0x18, 0x19, 0x1A, 0x1B, 0x30, ]
SCREENS_ZAKS = [0x13, 0x16, 0x17, 0x1F, 0x20, 0x21, 0x22, 0x23, ]

ALL_YOLKFOLK_DOORS = [
	dizzys_door_opened(),
	dozys_door_opened(),
	doras_door_opened(),
	dylans_door_opened(),
	grand_dizzys_door_opened(),
	denzils_door_opened(),
	daisys_door_opened(),
]

function _minigame_stars(a, c) => array_map(range(0,c-1), i => bit0(a+i))
RIVER_STARS = _minigame_stars(MINIGAME_STARS_RIVER_ADDR, MINIGAME_STARS_RIVER_COUNT)
MINECART_STARS = _minigame_stars(MINIGAME_STARS_MINE_ADDR, MINIGAME_STARS_MINE_COUNT)
BUBBLE_STARS = _minigame_stars(MINIGAME_STARS_WATER_ADDR, MINIGAME_STARS_WATER_COUNT)

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function make_group(screengroup, filter) => array_map(
	array_filter(
		array_filter(ALL_COLLECTABLES, filter),
		c => array_contains(screengroup, c["screen"])
	),
	x => bit(x["bit"], x["addr"])
)

function all_stars(screengroup) => make_group(screengroup, x => x["type"] == "star")

function collect_some(x, c) => (
	prev(sum_of(x, y => y)) < c &&
	measured(sum_of(x, y => y) >= c, when=game_state() < 4)
)
function collect_all(x) => collect_some(x, length(x))

function on_title_screen() => screen() == 0x00 && game_state() == 0x04
function in_game() => demo_check() == 0x00 && __ornext(!on_title_screen()) && game_state() != STATE_CODEMASTERS

function doors_opened() => sum_of(ALL_YOLKFOLK_DOORS, x => x / 0xFF)
function scrolls_collected() => sum_of(range(0x15, 0x1A), i => item_not_in_world(i))

function screen_transition(fm, to) => (
	game_state() <= 1 &&
	prev(screen()) == fm && screen() == to
)

function collect_item(x, s) => (
	game_state() == STATE_LOADING && screen() == s &&
	any_of(range(0,2), i => prev(inventory(i)) == 0xFF && inventory(i) == x)
)

function flag_update(x, s, fm, to) => (
	// covers flags that update during gameplay, loading, and messages
	game_state() < 4 && screen() == s && prev(x) == fm && x == to
)

function new_game() => (
	screen() == 0x00 &&
	demo_check() == 0x00 &&
	prev(game_state()) == STATE_MESSAGE &&
	game_state() == STATE_LOADING &&
	day_clock() == 0x00 &&
	dizzys_door_opened() == 0x00
)

function win_the_game() => (
	game_state() == STATE_MINIGAME && screen() == 0x21 &&
	tower_damage() > 0 &&
	prev(tower_victory_timer()) == 0x0a &&
	tower_victory_timer() == 0x09
)

// --- RICH PRESENCE -------------------------------------------------------------------

// these will all follow the text "Dizzy is..."
LOCATION_STRINGS = {
	0x00: "home sweet home",
	0x01: "content in Dylan's peaceful hut",
	0x02: "sad in Daisy's empty hut",
	0x03: "lonely in the meeting hall",
	0x04: "comfortable in Dora's homely hut",
	0x05: "in Grand Dizzy's hut",
	0x06: "feeling sleepy in in Dozy's cozy hut",
	0x07: "hanging out in Denzil's party pad",
	0x08: "at the very top of the treehouse village near Dozy's drowsy hut",
	0x09: "high in the trees exploring near Dora's homely hut",
	0x0A: "busy searching high and low for useful things near Dylan's hut",
	0x0B: "in the center of the treehouse village near Grand Dizzy's hut",
	0x0C: "wandering around the treehouse paths near Denzil's crucial pad",
	0x0D: "near Daisy's now-deserted home in the treehouse",
	0x0E: "on some familiar paths through the village near his hut",
	0x0F: "at the base of the Yolkfolk's secret treehouse",
	0x10: "in the countryside near an old wooden bridge over Silver Stream",
	0x11: "at Carber Bay gazing over golden sands and palm trees",
	0x12: "near the dangerous but glorious crystal falls of Swift River",
	0x13: "in a small eerie cave below the haunted graveyard",
	0x14: "in the crystal clear waters of Carber Bay",
	0x15: "under the sea near the wreck of an old pirate's galleon",
	0x16: "in a cold and dark graveyard near an old haunted church",
	0x17: "on the grasslands near a broken bridge over a dangerous pond",
	0x18: "high in the rigging of Blackheart the Pirate's ship",
	0x19: "on the upper decks of Blackheart the Pirate's dreaded ship",
	0x1A: "exploring deep into this old ship now owned by Blackheart",
	0x1B: "deep in the hull of the pirate ship, well below sea level",
	0x1C: "on Castle Street, where you'll find the shopkeeper",
	0x1D: "in the village of Keldor wandering along Bridge St.",
	0x1E: "in Dock St. in the troll's village of Keldor",
	0x1F: "sinking through the soft white clouds in the sky",
	0x20: "near wizard Zaks' magical cloud castle",
	0x21: "approaching Zaks' tower where Daisy is being held captive",
	0x22: "in the central part of Zaks' awesome castle",
	0x23: "on the lower level of the evil wizard Zaks' castle",
	0x24: "in a dank and dingy tunnel between Dock St. and Castle St.",
	0x25: "in a smelly and dark tunnel linking Castle St. to Bridge St.",
	0x26: "in a dark passage between Castle St. and Bridge St.",
	0x27: "in a long dark tunnel between Dock St. and Castle St.",
	0x28: "in the passageway between Dock St. and Bridge St.",
	0x29: "walking through a passage that links Castle St. to Dock St.",
	0x2A: "in a spooky tunnel between Castle St. and Bridge St.",
	0x2B: "in the diamond mines near the elevator control machines",
	0x2C: "underground in the mines near the unused railway track",
	0x2D: "in the deepest and least charted tunnels of the diamond mines",
	0x2E: "exploring deep into the trolls' deadly castle",
	0x2F: "in the reception hall of the trolls' eerie castle",
	0x30: "in a small deep cave below the ocean floor",
}

ITEM_STRINGS = {
	0x00: "a wrench",
	0x01: "medicine",
	0x02: "an empty bottle",
	0x03: "a mushroom",
	0x04: "a star plant",
	0x05: "rope",
	0x06: "a weight",
	0x07: "his door key",
	0x08: "Dylan's elevator key",
	0x09: "Denzil's elevator key",
	0x0A: "Grand Dizzy's elevator key",
	0x0B: "ground elevator key",
	0x0C: "Dozy's door key",
	0x0D: "Dora's door key",
	0x0E: "Dylan's door key",
	0x0F: "Grand Dizzy's door key",
	0x10: "Denzil's door key",
	0x11: "Daisy's door key",
	0x12: "an axe",
	0x13: "an aqua lung",
	0x14: "flippers",
	0x1B: "gold coins",
	0x1C: "a bean",
	0x1D: "salt",
	0x1E: "an empty bucket",
	0x1F: "a water bucket",
	0x20: "a chicken",
	0x21: "a skull key",
	0x22: "an empty chest",
	0x23: "a frog",
	0x24: "a crossbow",
	0x25: "a crowbar",
	0x26: "a rug",
	0x27: "a winch wheel",
	0x28: "a bridge kit",
	0x29: "a shovel",
	0x2A: "an umbrella",
	0x2B: "a trampet",
	0x2C: "a pickaxe",
	0x2D: "a small cow",
	0x2E: "a coin",
	0x2F: "a golden egg",
	0x30: "a golden egg",
	0x31: "an empty cage",
	0x32: "Pogie in a cage",
	0x33: "a match",
	0x34: "dry straw",
	0x35: "a medicine recipe",
	0x36: "weed killer",
	0x37: "a gold shamrock",
	0x38: "cymbals",
	0x39: "a plank of wood",
	0x3A: "dynamite",
	0x3B: "a winch handle",
	0x3C: "pirate rum",
}

rp_location = rich_presence_lookup("LOCATION", screen(), LOCATION_STRINGS, fallback="somewhere in Fantasy Land")
function rp_item(i) => rich_presence_lookup("ITEM", inventory(i), ITEM_STRINGS, fallback="")
rp_score = rich_presence_value("SCORE", score(), "SCORE")
rp_stars = rich_presence_number(250-stars_remaining())

rich_presence_conditional_display(!in_game(),
	"On the Title Screen"
)

rich_presence_conditional_display(is_inventory_empty(),
	"Dizzy is {0}, holding nothing · ⭐ {1}/250 · Score: {2}",
	rp_location, rp_stars, rp_score
)

rich_presence_display(
	"Dizzy is {0}, holding {3}{4}{5}{6}{7} · ⭐ {1}/250 · Score: {2}",
	rp_location, rp_stars, rp_score,
	rp_item(0),
	rich_presence_flag(", ", inventory(0) != 0xFF && inventory(1) != 0xFF, lookupname="COMMA"),
	rp_item(1),
	rich_presence_flag(", ", (inventory(0) != 0xFF || inventory(1) != 0xFF) && inventory(2) != 0xFF, lookupname="COMMA"),
	rp_item(2)
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Howdy Neighbor",
	description="Open all doors in the Yolkfolk Village",
	type="progression",
	points=5,
	trigger=(
		in_game() &&
		prev(doors_opened()) == length(ALL_YOLKFOLK_DOORS) - 1 &&
		measured(doors_opened() == length(ALL_YOLKFOLK_DOORS), when=game_state() < 4)
	)
)

achievement(
	title="Hard Boiled",
	description="Cure Grand Dizzy's illness",
	type="progression",
	points=5,
	trigger=flag_update(grand_dizzy_healed(), s=0x05, fm=0x01, to=0xFF)
)

achievement(
	title="Hatching a Plan",
	description="Help Dora with her froggy affliction",
	type="progression",
	points=3,
	// trigger=flag_update(prince_kissed_dora(), s=0x0F, fm=0x00, to=0xFF)
	trigger=game_state() < 4 && screen() == 0x0F && prev(prince_kissed_dora()) != 0xFF && prince_kissed_dora() == 0xFF
)

achievement(
	title="Frozen Egg Custard",
	description="Break the ice with Denzil",
	type="progression",
	points=5,
	trigger=flag_update(denzil_status(), s=0x07, fm=0xFE, to=0xFF)
)

achievement(
	title="Sunny Side Up",
	description="Wake Dozy from his nap",
	type="progression",
	points=5,
	trigger=flag_update(dozy_awake(), s=0x06, fm=0x01, to=0xFF)
)

achievement(
	title="Spoiled Rotten",
	description="Catch Pogie and bring him to Dylan",
	points=3,
	trigger=flag_update(dylan_petsitting(), s=0x01, fm=0x01, to=0xFF)
)

achievement(
	title="RIP to Whoever Left This Here",
	description="Collect the aqua lung",
	type="progression",
	points=3,
	trigger=collect_item(0x13, s=0x11)
)

achievement(
	title="A Rising Tide",
	description="Fix the bridge between Carber Bay and the graveyard",
	points=3,
	trigger=flag_update(log_lifted_by_salt(), s=0x17, fm=0x01, to=0xFF)
)

achievement(
	title="Putting Your Eggs in One Bucket",
	description="Collect the bucket",
	type="progression",
	points=5,
	trigger=collect_item(0x1E, s=0x13)
)

achievement(
	title="Construction Eggs-pertise",
	description="Collect the bridge building kit",
	type="progression",
	points=5,
	trigger=collect_item(0x28, s=0x2e)
)

achievement(
	title="Anchors Egg-weigh!",
	description="Board Blackheart's ship",
	type="progression",
	points=5,
	trigger=screen_transition(fm=0x1E, to=0x19)
)

achievement(
	title="Storming the Castle",
	description="Enter Zaks' castle",
	type="progression",
	points=5,
	trigger=screen_transition(fm=0x1F, to=0x23)
)

achievement(
	title="Home Is Where the Stars Are",
	description="Collect all of the stars in the Yolkfolk village",
	type="progression",
	points=5,
	trigger=collect_all(all_stars(SCREENS_VILLAGE))
)

achievement(
	title="Worth Its Weight in Stars",
	description="Collect all of the stars in the countryside and the diamond mines",
	type="progression",
	points=5,
	trigger=collect_all(array_concat(all_stars(SCREENS_COUNTRYSIDE_MINES), MINECART_STARS))
)

achievement(
	title="Where the Streets Are Paved With Stars",
	description="Collect all of the stars in Keldor and the troll castle",
	type="progression",
	points=5,
	trigger=collect_all(array_concat(all_stars(SCREENS_KELDOR), RIVER_STARS))
)

achievement(
	title="Of Stars and Sextants",
	description="Collect all of the stars on Blackheart's ship and Carber Bay",
	type="progression",
	points=5,
	trigger=collect_all(array_concat(all_stars(SCREENS_SHIP_CARBERBAY), BUBBLE_STARS))
)

achievement(
	title="Star-Crossed Enemies",
	description="Collect all of the stars in Zaks' castle, the clouds, and the graveyard",
	type="progression",
	points=5,
	trigger=collect_all(all_stars(SCREENS_ZAKS))
)

achievement(
	title="Leave No Star Unturned",
	description="Collect all 250 stars",
	type="progression",
	points=25,
	trigger=game_state() < 4 && prev(_stars_remaining_raw()) == 0x000001 && _stars_remaining_raw() == 0x000000
)

achievement(
	title="Poached Eggs and Fruit Salad",
	description="Collect 75 pieces of fruit",
	points=25,
	trigger=collect_some(make_group(range(0x00, 0x30), x => array_contains(FRUITS, x["type"])), 75)
)

achievement(
	title="Deviled Egg",
	description="Defeat the evil wizard Zaks and save Daisy",
	type="win_condition",
	points=25,
	trigger=win_the_game()
)

achievement(
	title="Tossed Salad and Scrambled Eggs",
	description="Toss Pogie",
	points=1,
	trigger=(
		game_state() == STATE_PLAYING &&
		screen() == pogie_screen() &&
		prev(pogie_toss()) == 0x1e &&
		pogie_toss() == 0x1d
	)
)

achievement(
	title="Djack and the Beans Talk",
	description="Take your cow to the market and trade it",
	type="missable",
	points=2,
	trigger=(
		prev(inventory(selected_inventory_slot())) == 0x2D &&
		inventory(selected_inventory_slot()) == 0xFF &&
		prev(shopkeeper_status()) == 0x00 &&
		shopkeeper_status() == 0x01
	)
)

achievement(
	title="Runaway Yolkomotive",
	description="Complete the minecart minigame after collecting all 20 stars in one attempt",
	type="missable",
	points=10,
	trigger=(
		// measured minecart stars
		measured(
			sum_of(MINECART_STARS, x => x) == MINIGAME_STARS_MINE_COUNT,
			// entering the minecart with 0 stars
			when=once(
				screen() == 0x2C && 
				prev(game_state()) == STATE_LOADING && 
				game_state() == STATE_MINECART &&
				all_of(MINECART_STARS, x => x == 0)
			)
		) &&
		// reset when leaving the minigame
		never(game_state() == STATE_MINIGAME_DEATH) &&
		never(game_state() == STATE_CODEMASTERS) &&
		// complete the minecart at the specific ending with all the stars
		prev(game_state()) == STATE_MINECART &&
		prev(screen()) == 0x2C &&
		screen() == 0x1D
	)
)

achievement(
	title="Eggs-Stream Sports",
	description="Complete the Crystal River minigame after collecting all 10 stars and taking no damage in one attempt",
	type="missable",
	points=5,
	trigger=(
		// measured river stars
		measured(
			sum_of(RIVER_STARS, x => x) == MINIGAME_STARS_RIVER_COUNT,
			// entering the river with 0 stars
			when=once(
				screen() == 0x1D && 
				prev(game_state()) == STATE_LOADING && 
				game_state() == STATE_MINIGAME &&
				all_of(RIVER_STARS, x => x == 0)
			)
		) &&
		// reset when leaving the minigame
		never(game_state() == STATE_MINIGAME_DEATH) &&
		never(game_state() == STATE_CODEMASTERS) &&
		// reset when losing health
		never(river_minigame_health() < prev(river_minigame_health())) &&
		// complete the river minigame
		prev(game_state()) == STATE_MINIGAME &&
		prev(screen()) == 0x1D &&
		screen() == 0x12
	)
)

achievement(
	title="Waiting to Eggs-hale",
	description="Complete the walk-the-plank minigame after collecting all 10 stars in one attempt",
	type="missable",
	points=5,
	trigger=(
		// measured bubble stars
		measured(
			sum_of(BUBBLE_STARS, x => x) == MINIGAME_STARS_WATER_COUNT,
			// entering the bubble with 0 stars
			when=once(
				screen() == 0x19 && 
				prev(game_state()) == STATE_LOADING && 
				game_state() == STATE_MINIGAME &&
				all_of(BUBBLE_STARS, x => x == 0)
			)
		) &&
		// reset when leaving the minigame
		never(game_state() == STATE_MINIGAME_DEATH) &&
		never(game_state() == STATE_CODEMASTERS) &&
		// complete the bubble minigame
		game_state() == STATE_MINIGAME &&
		screen() == 0x19 &&
		prev(bubble_minigame_ending()) == 79 &&
		bubble_minigame_ending() == 80
	)
)

achievement(
	title="Theo's Eggs-tra Life",
	description="Earn an extra life from one of Theo's scrolls",
	type="missable",
	points=3,
	trigger=(
		game_state() == STATE_MINIGAME &&
		// inventory_anim() == 0 &&
		// prior(inventory_anim()) == 4 &&
		lives() > prev(lives())
	)
)

achievement(
	title="A Treasure Beyond Measure",
	description="Find all of Theo's scrolls",
	points=5,
	trigger=(
		in_game() &&
		prev(scrolls_collected()) == 5 &&
		measured(scrolls_collected() == 6)
	)
)

achievement(
	title="Going the Eggs-tra Mile",
	description="Kill the snappy weed in the treehouse without placing the plank under the Yolkfolk treehouse",
	type="missable",
	points=25,
	trigger=(
		flag_update(snappy_weed_disabed(), s=0x0E, fm=0x00, to=0x01) &&
		bridge_under_village_built() != 0xFF
	)
)

achievement(
	title="By the Crack of Dawn",
	description="Deliver the caged Pogie before dusk (20:00) on the first day",
	type="missable",
	points=10,
	trigger=(
		once(new_game()) &&
		never(day_clock() >= 0xA0) &&
		never(!in_game()) &&
		trigger_when(flag_update(dylan_petsitting(), s=0x01, fm=0x01, to=0xFF))
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Fewest Days",
	description="Fewest number of days to save Daisy and complete the game",

	start=new_game(),
	cancel=!in_game(),
	submit=win_the_game(),

	value=measured(tally(0, 
		once(always_true()),
		prev(day_clock()) == 0xFF && day_clock() == 0x00
	)),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="High Score",
	description="Highest score on completing the game",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(score()),
	format="SCORE",
	lower_is_better=false
)

function fake_time() => 5*60 + day_clock()*5.625
leaderboard(
	title="Pogie Delivery Service",
	description="Deliver Pogie as early as possible on the first day",

	start=new_game(),
	cancel=!in_game() || fake_time() > 1440,
	submit=flag_update(dylan_petsitting(), s=0x01, fm=0x01, to=0xFF),

	value=measured(fake_time()),
	format="SECS",
	lower_is_better=true
)