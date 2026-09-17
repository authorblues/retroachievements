// ~Homebrew~ Kero Kero Cowboy
// #ID = 34054
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $C0BB: [8-bit] Player Tile X
function player_tile_x() => byte(0xC0BB)

// $C0BD: [8-bit] Player Tile Y
function player_tile_y() => byte(0xC0BD)

// $C0BE: [8-bit] Player Direction
function player_direction() => byte(0xC0BE)

// $C526: [24-bit] _current_scene
//        _current_scene is (in the engine) a struct defined as far_ptr_t which the first byte is the bank and the 2 next bytes is the pointer
//        When loading a scene the bank and pointer of the scene in ROM is stored in that.
function current_scene() => tbyte(0xC526)

// $CB99: [16-bit] VAR_GUN_IS_EQUIPPED
function gun_equipped() => word(0xCB99)

// $CB9B: [16-bit] VAR_PLAYER_MOUTH_IS_FULL
function mouth_full() => word(0xCB9B)

// $CB9D: [16-bit] VAR_TONGUE_ATTACK_COOLDOWN
function tongue_cooldown() => word(0xCB9D)

// $CB9F: [16-bit] VAR_PLAYER_HP
function health() => word(0xCB9F)

// $CBA1: [16-bit] VAR_PLAYER_AMMO
function ammo() => word(0xCBA1)

// $CBA3: [16-bit] VAR_PLAYER_LIVES
function lives() => word(0xCBA3)

// $CBA5: [16-bit] VAR_PLAYER_COIN_COUNT
function coins() => word(0xCBA5)

// $CBA7: [16-bit] VAR_GUN_ATTACK_COOLDOWN
function gun_cooldown() => word(0xCBA7)

// $CBA9: [16-bit] VAR_CURRENT_LEVEL_BIG_COIN_
function _current_level_big_coin() => word(0xCBA9)

// $CBAB: [16-bit] VAR_INFINITE_AMMO
function infinite_ammo() => word(0xCBAB)

// $CBAD: [16-bit] VAR_WEAPON_SWAP_DISABLED
function swap_disabled() => word(0xCBAD)

// $CBAF: [16-bit] VAR_BOOT_MODE
function boot_mode() => word(0xCBAF)

// $CBB1: [16-bit] VAR_LEVEL_START_X_POSITION
function level_start_x() => word(0xCBB1)

// $CBB3: [16-bit] VAR_LEVEL_START_Y_POSITION
function level_start_y() => word(0xCBB3)

// $CBB5: [16-bit] VAR_CHECKPOINT_X_POSITION
function checkpoint_x() => word(0xCBB5)

// $CBB7: [16-bit] VAR_CHECKPOINT_Y_POSITION
function checkpoint_y() => word(0xCBB7)

// $CBB9: [16-bit] VAR_CHECKPOINT_ACTIVATED
function checkpoint_activated() => word(0xCBB9)

// $CBBB: [16-bit] VAR_PLAYER_IS_INVINCIBLE_TO
function invincible_to() => word(0xCBBB)

// $CBBD: [16-bit] VAR_PLAYER_IS_ON_SPIKES
function on_spikes() => word(0xCBBD)

// $CBBF: [16-bit] VAR_JALAPENO_MODE
function jalapeno_mode() => word(0xCBBF)

// $CBD9: [16-bit] VAR_W1_BONUS_LEVEL_UNLOCKED
function w1_bonus_level_unlocked() => word(0xCBD9)

// $CBDB: [16-bit] VAR_BOSS_HP
function boss_health() => word(0xCBDB)

// $CBDD: [16-bit] VAR_BOSS_INVINCIBILITY
function boss_invincibility() => word(0xCBDD)

// $CBF9: [16-bit] VAR_BGANIM1
function bganim1() => word(0xCBF9)

// $CBFB: [16-bit] VAR_BGANIM2
function bganim2() => word(0xCBFB)

// $CBFD: [16-bit] VAR_BGANIM3
function bganim3() => word(0xCBFD)

// $CBFF: [16-bit] VAR_BGANIM4
function bganim4() => word(0xCBFF)

// $CC01: [16-bit] VAR_VARIABLE_FOR_MENUS
function menu_var() => word(0xCC01)

// $CC03: [16-bit] VAR_VARIABLE_FOR_PLATFORM_P
function platform_var() => word(0xCC03)

// $CC05: [16-bit] VAR_TRIGGER_PICKUP_1_COLLEC
function trigger_pickup_1_collect() => word(0xCC05)

// $CC07: [16-bit] VAR_PLAYER_SPAWN_IN_BOOT
function spawn_in_boot() => word(0xCC07)

// $CC09: [16-bit] VAR_TRIGGER_PICKUP_2_COLLEC
function trigger_pickup_2_collect() => word(0xCC09)

// $CC0B: [16-bit] VAR_TRIGGER_PICKUP_3_COLLEC
function trigger_pickup_3_collect() => word(0xCC0B)

// $CC0D: [16-bit] VAR_TRIGGER_PICKUP_4_COLLEC
function trigger_pickup_4_collect() => word(0xCC0D)

// $CC0F: [16-bit] VAR_TRIGGER_PICKUP_5_COLLEC
function trigger_pickup_5_collect() => word(0xCC0F)

// $CC11: [16-bit] VAR_BALLOON_1_POPPED
function balloon_1_popped() => word(0xCC11)

// $CC13: [16-bit] VAR_BALLOON_2_POPPED
function balloon_2_popped() => word(0xCC13)

// $CC15: [16-bit] VAR_BALLOON_3_POPPED
function balloon_3_popped() => word(0xCC15)

// $CC17: [16-bit] VAR_DEMOMODE
function demo_mode() => word(0xCC17)

// $CC19: [16-bit] VAR_ENEMYDROPS
function enemydrops() => word(0xCC19)

// $CC1B: [16-bit] VAR_HP_PICKUP_ON_SCREEN
function hp_pickup_on_screen() => word(0xCC1B)

// $CC1D: [16-bit] VAR_AMMO_PICKUP_ON_SCREEN
function ammo_pickup_on_screen() => word(0xCC1D)

// $CC1F: [16-bit] VAR_TONGUEATTACKHIT
function tongue_attack_hit() => word(0xCC1F)

// $CC21: [16-bit] VAR_HP_PICKUP_X_POS
function hp_pickup_x_pos() => word(0xCC21)

// $CC23: [16-bit] VAR_HP_PICKUP_Y_POS
function hp_pickup_y_pos() => word(0xCC23)

// $CC25: [16-bit] VAR_AMMO_PICKUP_X_POS
function ammo_pickup_x_pos() => word(0xCC25)

// $CC27: [16-bit] VAR_AMMO_PICKUP_Y_POS
function ammo_pickup_y_pos() => word(0xCC27)

// $CC29: [16-bit] VAR_BOSSATTACKPATTERN
function boss_attack_pattern() => word(0xCC29)

// $CC2B: [16-bit] VAR_BOSSMOVING
function boss_moving() => word(0xCC2B)

// $CC2D: [16-bit] VAR_PLAYER_IS_INVINCIBLE_TO_0
function player_is_invincible_to_0() => word(0xCC2D)

// $CC2F: [16-bit] VAR_LEVEL_BOTTOM_OF_PIT_VAL
function level_bottom_of_pit_val() => word(0xCC2F)

// $CC31: [16-bit] VAR_CART_MODE
function cart_mode() => word(0xCC31)

// $CC33: [16-bit] VAR_CART_BOOST
function cart_boost() => word(0xCC33)

// $CC55: [16-bit] VAR_W2_BONUS_LEVEL_UNLOCKED
function w2_bonus_level_unlocked() => word(0xCC55)

// $CC69: [16-bit] VAR_TEST_MODE
function test_mode() => word(0xCC69)

// $CC6B: [16-bit] VAR_CURRENT_PLAYER_REGION
function current_player_region() => word(0xCC6B)

// $CC8D: [16-bit] VAR_PLAYER_IS_IN_WATER
function in_water() => word(0xCC8D)

// $CC8F: [16-bit] VAR_BUBBLE_ATTACK_COOLDOWN
function bubble_attack_cooldown() => word(0xCC8F)

// $CCB9: [16-bit] VAR_W3_BONUS_LEVEL_UNLOCKED
function w3_bonus_level_unlocked() => word(0xCCB9)

// $CCCD: [16-bit] VAR_PLAYER_X_POS
function player_x_pos() => word(0xCCCD)

// $CCCF: [16-bit] VAR_PLAYER_Y_POS
function player_y_pos() => word(0xCCCF)

// $CCE1: [16-bit] VAR_ENABLE_FAKE_PROJECTILE_
function enable_fake_projectile() => word(0xCCE1)

// $CCE3: [16-bit] VAR_PLAYER_X_VELOCITY_VARIA
function player_x_velocity() => word(0xCCE3)

// $CCE5: [16-bit] VAR_PLAYER_IS_ON_ICE
function on_ice() => word(0xCCE5)

// $CCFF: [16-bit] VAR_W4_BONUS_LEVEL_UNLOCKED
function w4_bonus_level_unlocked() => word(0xCCFF)

// $CD1B: [16-bit] VAR_ICE_CHANGE_DIRECTION_SL
function ice_change_direction() => word(0xCD1B)

// $CD39: [16-bit] VAR_W5_BONUS_LEVEL_UNLOCKED
function w5_bonus_level_unlocked() => word(0xCD39)

// $CD55: [16-bit] VAR_BOOT_X_POS
function boot_x_pos() => word(0xCD55)

// $CD57: [16-bit] VAR_BOOT_Y_POS
function boot_y_pos() => word(0xCD57)

// $CD5D: [16-bit] VAR_ALL_STAR_COIN_CONGRATS_
function all_star_coin_congrats() => word(0xCD5D)

// $CD63: [16-bit] VAR_CURRENT_SALOON_SCORE
function current_saloon_score() => word(0xCD63)

// $CD65: [16-bit] VAR_TOP_SALOON_SCORE
function top_saloon_score() => word(0xCD65)

// $CD67: [16-bit] VAR_BOSS_LEFT_POSITION
function boss_left_position() => word(0xCD67)

// $CD69: [16-bit] VAR_BOSS_RIGHT_POSITION
function boss_right_position() => word(0xCD69)

// $CD6B: [16-bit] VAR_BOSS_CUTSCENE_VIEWED
function boss_cutscene_viewed() => word(0xCD6B)

// $CD6D: [16-bit] VAR_BOSS_CUTSCENE_2_VIEWED
function boss_cutscene_2_viewed() => word(0xCD6D)

// $CD6F: [16-bit] VAR_DPAD_ACTOR_UP_VISIBLE
function dpad_actor_up_visible() => word(0xCD6F)

// $CD71: [16-bit] VAR_CURRENT_SAVE_FILE
function current_save_file() => word(0xCD71)

// $CD73: [16-bit] VAR_FILEPROGRESSIONVARIABLE
function file_progression() => word(0xCD73)

// $CD75: [16-bit] VAR_MUSIC_TRACK_SELECTOR
function music_track_selector() => word(0xCD75)

// $CD77: [16-bit] VAR_PLAYER_IS_FACING_RIGHT
function player_is_facing_right() => word(0xCD77)

// $CD79: [16-bit] VAR_PLAYER_TAKE_DAMAGE
function player_take_damage() => word(0xCD79)

// $CD7B: [16-bit] VAR_PLAYTILES
function playtiles() => word(0xCD7B)

// $CD7D: [16-bit] VAR_PLAYER_IN_CHECKPOINT_CU
function player_in_checkpoint_cutscene() => word(0xCD7D)

// $CD7F: [16-bit] VAR_ENEMY_PROJECTILE_BEHAVI
function enemy_projectile_behavior() => word(0xCD7F)

// --- MAIN DATA -------------------------------------------------------------------

class LevelData
{
	world = -1
	stage = -1
	clear = -1
	scenes = []
	coins = []
	allcoins = -1

	function in_level() => any_of(this.scenes, s => current_scene() == s)
	function cleared() => prev(word(this.clear)) == 0 && word(this.clear) == 1
	function all_coins() => sum_of(this.coins, addr => word(addr))
	function all_coins_award() => word(this.allcoins)
}

LEVELS = [
	[ // WORLD 1 - Dusty Desert
		LevelData(world=1, stage=1, clear=0xCBC7, 
			scenes=[0x73C892, 0x740392, 0x641C92], 
			coins=[0xCBC1, 0xCBC3, 0xCBC5], allcoins=0xCBE9),
		LevelData(world=1, stage=2, clear=0xCBCF, 
			scenes=[0x743E92, 0x747992, 0x74EF92, 0x74B492], 
			coins=[0xCBC9, 0xCBCB, 0xCBCD], allcoins=0xCBEB),
		LevelData(world=1, stage=3, clear=0xCBD7, 
			scenes=[0x615892, 0x624492, 0x627F92], 
			coins=[0xCBD1, 0xCBD3, 0xCBD5], allcoins=0xCBED),
		LevelData(world=1, stage=4, clear=0xCBE7, 
			scenes=[0x619392, 0x636B92, 0x63A692, 0x6B0692, 0x633092], 
			coins=[0xCBE1, 0xCBE3, 0xCBE5], allcoins=0xCBEF),
		LevelData(world=1, stage=5, clear=0xCBF7, 
			scenes=[0x61CE92, 0x62BA92, 0x62F592], 
			coins=[0xCBF1, 0xCBF3, 0xCBF5]),
		LevelData(world=1, stage=6, clear=0xCBDF, 
			scenes=[0x5CF792, 0x5A6E92]),
	],

	[ // WORLD 2 - Mole Mines
		LevelData(world=2, stage=1, clear=0xCC3B, 
			scenes=[0x645792, 0x64CD92, 0x654392, 0x657E92, 0x65B992], 
			coins=[0xCC35, 0xCC37, 0xCC39], allcoins=0xCC57),
		LevelData(world=2, stage=2, clear=0xCC43, 
			scenes=[0x662F92, 0x666A92, 0x66E092, 0x64CD92, 0x671B92], 
			coins=[0xCC3D, 0xCC3F, 0xCC41], allcoins=0xCC59),
		LevelData(world=2, stage=3, clear=0xCC4B, 
			scenes=[0x679192, 0x67CC92, 0x680792, 0x650892], 
			coins=[0xCC45, 0xCC47, 0xCC49], allcoins=0xCC5B),
		LevelData(world=2, stage=4, clear=0xCC53, 
			scenes=[0x687D92, 0x68B892, 0x68F392, 0x692E92], 
			coins=[0xCC4D, 0xCC4F, 0xCC51], allcoins=0xCC5D),
		LevelData(world=2, stage=5, clear=0xCC65, 
			scenes=[0x69DF92, 0x6A1A92, 0x6A5592], 
			coins=[0xCC5F, 0xCC61, 0xCC63]),
		LevelData(world=2, stage=6, clear=0xCC67, 
			scenes=[0x6A9092, 0x6ACB92]),
	],

	[ // WORLD 3 - Choo Choo Railway
		LevelData(world=3, stage=1, clear=0xCC9F, 
			scenes=[0x6BB792, 0x6BF292, 0x6C2D92, 0x6C6892], 
			coins=[0xCC99, 0xCC9B, 0xCC9D], allcoins=0xCCBB),
		LevelData(world=3, stage=2, clear=0xCCA7, 
			scenes=[0x6CA392, 0x6CDE92, 0x6D1992, 0x6D5492], 
			coins=[0xCCA1, 0xCCA3, 0xCCA5], allcoins=0xCCBD),
		LevelData(world=3, stage=3, clear=0xCCAF, 
			scenes=[0x6D8F92, 0x6DCA92, 0x6E0592, 0x6E4092, 0x6E7B92], 
			coins=[0xCCA9, 0xCCAB, 0xCCAD], allcoins=0xCCBF),
		LevelData(world=3, stage=4, clear=0xCCB7, 
			scenes=[0x6EB692, 0x6EF192, 0x6F2C92, 0x6F6792], 
			coins=[0xCCB1, 0xCCB3, 0xCCB5], allcoins=0xCCC1),
		LevelData(world=3, stage=5, clear=0xCCC9, 
			scenes=[0x6FA292, 0x6FDD92, 0x701892], 
			coins=[0xCCC3, 0xCCC5, 0xCCC7]),
		LevelData(world=3, stage=6, clear=0xCCCB, 
			scenes=[0x705392, 0x708E92]),
	],

	[ // WORLD 4 - Musty Mountain
		LevelData(world=4, stage=1, clear=0xCCED, 
			scenes=[0x71F092, 0x722B92, 0x72A192, 0x72DC92, 0x4AFD92], 
			coins=[0xCCE7, 0xCCE9, 0xCCEB], allcoins=0xCD0B),
		LevelData(world=4, stage=2, clear=0xCCF5, 
			scenes=[0x735292, 0x4A4C92, 0x4A8792, 0x4AC292], 
			coins=[0xCCEF, 0xCCEF1, 0xCCF3], allcoins=0xCD0D),
		LevelData(world=4, stage=3, clear=0xCCFD, 
			scenes=[0x4B3892, 0x4BAE92, 0x4BE992, 0x4C2492], 
			coins=[0xCCF7, 0xCCF9, 0xCCFB], allcoins=0xCD0F),
		LevelData(world=4, stage=4, clear=0xCD09, 
			scenes=[0x4C9A92, 0x4CD592, 0x4D1092, 0x4D4B92], 
			coins=[0xCD03, 0xCD05, 0xCD07], allcoins=0xCD11),
		LevelData(world=4, stage=5, clear=0xCD19, 
			scenes=[0x4DFC92, 0x4E3792, 0x4E7292], 
			coins=[0xCD13, 0xCD15, 0xCD17]),
		LevelData(world=4, stage=6, clear=0xCD01, 
			scenes=[0x4EAD92, 0x4EE892, 0x4F2392, 0x4F5E92]),
	],

	[ // WORLD 5 - Ghost Town
		LevelData(world=5, stage=1, clear=0xCD27, 
			scenes=[0x4FD492, 0x50FB92, 0x513692, 0x517192, 0x51AC92, 0x51E792, 0x522292], 
			coins=[0xCD21, 0xCD23, 0xCD25], allcoins=0xCD45),
		LevelData(world=5, stage=2, clear=0xCD2F, 
			scenes=[0x525D92, 0x529892, 0x52D392, 0x530E92, 0x534992, 0x538492, 0x53BF92], 
			coins=[0xCD29, 0xCD2B, 0xCD2D], allcoins=0xCD47),
		LevelData(world=5, stage=3, clear=0xCD37, 
			scenes=[0x53FA92, 0x543592, 0x547092, 0x54AB92, 0x54E692], 
			coins=[0xCD31, 0xCD33, 0xCD35], allcoins=0xCD49),
		LevelData(world=5, stage=4, clear=0xCD43, 
			scenes=[0x559792, 0x573492, 0x576F92, 0x57E592], 
			coins=[0xCD3D, 0xCD3F, 0xCD41], allcoins=0xCD4B),
		LevelData(world=5, stage=5, clear=0xCD53, 
			scenes=[0x56F992, 0x582092, 0x585B92, 0x589692, 0x58D192, 0x590C92, 0x594792, 0x598292, 0x59BD92, 0x59F892, 0x5A3392, 0x5AA992, 0x5AE492, 0x5B1F92, 0x5B5A92, 0x5B9592, 0x5BD092, 0x5C0B92, 0x5C4692, 0x5C8192, 0x5CBC92, 0x5D3292, 0x5D6D92], 
			coins=[0xCD4D, 0xCD4F, 0xCD51]),
		LevelData(world=5, stage=6, clear=0xCD3B, 
			scenes=[0x504A92, 0x508592, 0x50C092]),
	],
]

SCENE_REGION_SELECT = [
	0x765192,
	0x649292,
	0x6b4192,
	0x726692,
	0x4f9992,
]

SCENE_LEVEL_SELECT = [
//   1         2         3         4         boss      boss + ☆
	[0x752a92, 0x756592, 0x75a092, 0x75db92, 0x761692, 0x5f8092, ],
	[0x49d692, 0x65f492, 0x675692, 0x684292, 0x696992, 0x69a492, ],
	[0x6b7c92, 0x70c992, 0x4a1192, 0x710492, 0x713f92, 0x717a92, ],
	[0x71b592, 0x731792, 0x4b7392, 0x4c5f92, 0x4d8692, 0x4dc192, ],
	[0x500f92, 0x55d292, 0x560d92, 0x564892, 0x568392, 0x56be92, ],
]

SCENE_TITLE = 0x76c792
SCENE_FILE_SELECT = 0x606c92
SCENE_MUSIC_PLAYER = 0x603192
SCENE_CREDITS = 0x5fbb92

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function Level(w, s) => LEVELS[w-1][s-1]

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------