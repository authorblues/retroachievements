// The Chessmaster
// #ID = 32601

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function rich_presence_flag(str, when=always_true(), fallback="", lookupname="_F") => 
	rich_presence_lookup(lookupname, max_of(measured(1, when=when), measured(0)), {1: str}, fallback)

function rich_presence_condition_table(lookupname, list)
{ // highest priority needs to be listed first in the pairs list
	dict = {}
	expr = max_of(array_map(range(1, length(list)), i => measured(length(list)-i, when=list[i-1][0])))
	for i in range(1, length(list)) dict[length(list)-i] = list[i-1][1]
	return rich_presence_lookup(lookupname, expr, dict, "")
}

// --- MEMORY -------------------------------------------------------------------

// $00A0: Actual Board State (true state) [64 bytes]
//        0x00 = none
//        
//        0x01 = black king
//        0x02 = black queen
//        0x03 = black rook
//        0x04 = black bishop
//        0x05 = black knight (facing right)
//        0x06 = black pawn
//        0x07 = black knight (facing left)
//        
//        0x09 = white king
//        0x0a = white queen
//        0x0b = white rook
//        0x0c = white bishop
//        0x0d = white knight (facing right)
//        0x0e = white pawn
//        0x0f = white knight (facing left)
function board(i) => 0x00A0 + i
function board_state(r, c) => byte(board(r*8 + c))

// $0200: Game History - Piece Moved [256 bytes]
//        0x01 = black king
//        0x02 = black queen
//        0x03 = black rook
//        0x04 = black bishop
//        0x05 = black knight (facing right)
//        0x06 = black pawn
//        0x07 = black knight (facing left)
//        
//        0x09 = white king
//        0x0a = white queen
//        0x0b = white rook
//        0x0c = white bishop
//        0x0d = white knight (facing right)
//        0x0e = white pawn
//        0x0f = white knight (facing left)
//        
//        0xFF = no entry
function history_moved(i) => byte(0x0200 + i)

// $0300: Game History - Piece Captured [256 bytes]
//        (this table is used to construct the capture list in the pause menu)
//        0x00 = none
//        
//        0x01 = black king
//        0x02 = black queen
//        0x03 = black rook
//        0x04 = black bishop
//        0x05 = black knight (facing right)
//        0x06 = black pawn
//        0x07 = black knight (facing left)
//        
//        0x09 = white king
//        0x0a = white queen
//        0x0b = white rook
//        0x0c = white bishop
//        0x0d = white knight (facing right)
//        0x0e = white pawn
//        0x0f = white knight (facing left)
//        
//        0x80 = castle (to=0x3e for 0-0, to=0x3a for 0-0-0)
//        0x86/0x8e = en passant (lower4 is which pawn was captured)
//        0xc# = promotion to piece (# from list above)
//        0xFF = no entry
function history_captured(i) => byte(0x0300 + i)
function history_move_type(i) => high4(0x0300 + i)

// $0400: Game History - Moved From [256 bytes]
//        counted from top left, assuming black on top
function history_from(i) => byte(0x0400 + i)

// $0500: Game History - Moved To [256 bytes]
//        counted from top left, assuming black on top
function history_to(i) => byte(0x0500 + i)

// $0600: Screen Buffer [360 bytes]
function screen_buffer() => byte(0x0600)

// $07AD: Color To Move [8 bit]
//        0 = White
//        1 = Black
function color_to_move() => byte(0x07AD)

// $07AF: Screen ID [8 bit]
//        0 = Sega / Title Screen
//        1 = Chess Board (and set up)
//        3 = Game Log / Actions
//        4 = Settings
//        5 = Setup Menu
//        6 = Load Game (enter password)
//        7 = Save Game (shows password)
//        8 = Title Press Start
function screen_id() => byte(0x07AF)

// $07B4: Piece in Hand [8 bit] (0/1)
function piece_in_hand() => byte(0x07B4)

// $07B5: Held Piece [8 bit]
//        updates when grabbing piece
//        
//        0x01 = black king
//        0x02 = black queen
//        0x03 = black rook
//        0x04 = black bishop
//        0x05 = black knight (facing right)
//        0x06 = black pawn
//        0x07 = black knight (facing left)
//        
//        0x09 = white king
//        0x0a = white queen
//        0x0b = white rook
//        0x0c = white bishop
//        0x0d = white knight (facing right)
//        0x0e = white pawn
//        0x0f = white knight (facing left)
function held_piece() => byte(0x07B5)

// $07B7: Input [8 bit]
//        bit0 = up
//        bit1 = down
//        bit2 = left
//        bit3 = right
//        bit4 = button 1
//        bit5 = button 2
//        bit7 = start
function button_up() => bit0(0x07B7)
function button_dn() => bit1(0x07B7)
function button_lt() => bit2(0x07B7)
function button_rt() => bit3(0x07B7)
function button_b1() => bit4(0x07B7)
function button_b2() => bit5(0x07B7)
function button_start() => bit7(0x07B7)

// $07BE: Actions/Settings Selected Row [8 bit]
//        
//        Actions [0x03]
//        0x00 = Log Screen
//        0x05 = Human Players
//        0x06 = Change Sides
//        0x07 = Force Move
//        0x08 = Takeback/Replay
//        0x09 = Set Up Board
//        0x0a = Solve For Mate
//        0x0b = Offer Draw
//        0x0c = Load Game
//        0x0d = Save Game
//        0x0e = Begin New Game
//        
//        Settings [0x04]
//        0x05 = Mate in N moves
//        0x06 = Chessmaster Level
//        0x07 = Deep Thinking On/Off
//        0x08 = Opening Book On/Off
//        0x09 = Teaching Mode On/Off
//        0x0a = Coordinates On/Off
//        0x0b = Chess Clock On/Off
//        0x0c = Touching rule On/Off
//        0x0d = White Visible/Hidden
//        0x0e = Black Visible/Hidden
//        0x0f = White On Bottom/Left/Top/Right
function menu_row() => byte(0x07BE)

// $07CA: In Setup Mode [8 bit] (0/1)
function in_setup_mode() => byte(0x07CA)

// $07CB: Setup Mode - In Board View [8 bit] (0/1)
function setup_mode_board_view() => byte(0x07CB)

// $07D1: Turns Taken [8 bit]
function turns_taken() => byte(0x07D1)

// $07D9: Paused [8 bit] (0/1)
//        used to stop the game clock
function paused() => byte(0x07D9)

// $07DE: Player in Check [8 bit] (0/1)
function player_in_check() => byte(0x07DE)

// $07DF: Game Ended [8 bit] (0/1)
//        if game ended but no check, stalemate
//        check 0x07ad on game end for losing player (checkmate and stalemate)
function game_ended() => byte(0x07DF)

// $07E0: Draw Offered [8 bit]
//        0 = no draw offered
//        2 = draw offered
function draw_offered() => byte(0x07E0)

// $07E1: Forced Draw [8 bit]
//        0 = no draw
//        1 = 50 move rule / 3 fold repetition
function forced_draw() => byte(0x07E1)

// $07E9: Black Clock (Frames) [8 bit]
// $07EA: Black Clock (00:00:0X) [8 bit]
// $07EB: Black Clock (00:00:X0) [8 bit]
// $07EC: Black Clock (00:0X:00) [8 bit]
// $07ED: Black Clock (00:X0:00) [8 bit]
// $07EE: Black Clock (0X:00:00) [8 bit]
// $07EF: Black Clock (X0:00:00) [8 bit]

// $07F0: White Clock (Frames) [8 bit]
function clock_frames(c)   => byte(0x07F0 - 7*c)
function clock_00_00_0x(c) => byte(0x07F1 - 7*c)
function clock_00_00_x0(c) => byte(0x07F2 - 7*c)
function clock_00_0x_00(c) => byte(0x07F3 - 7*c)
function clock_00_x0_00(c) => byte(0x07F4 - 7*c)
function clock_0x_00_00(c) => byte(0x07F5 - 7*c)
function clock_x0_00_00(c) => byte(0x07F6 - 7*c)

// $07FE: Chessmaster Forced Mate Moves [8 bit]
//        0 = 1 move
//        1 = 2 moves
//        2 = 3 moves
//        3 = 4 moves
//        4 = 5 moves
function forced_mate_moves() => byte(0x07FE)

// $07FF: CPU Difficulty [8 bit]
//        0x00 = Newcomer 1
//        0x01 = Newcomer 2
//        0x02 = Level 1: 60/5
//        0x03 = Level 2: 40/5
//        0x04 = Level 3: 60/10
//        0x05 = Level 4: 60/30
//        0x06 = Level 5: 60/45
//        0x07 = Level 6: 60/60
//        0x08 = Level 7: 30/45
//        0x09 = Level 8: 30/60
//        0x0A = Level 9: 40/90
//        0x0B = Level 10: 40/100
//        0x0C = Level 11: 40/120
//        0x0D = Level 12: 40/150
//        0x0E = Level 13: 40/180
//        0x0F = Infinite
function cpu_difficulty() => byte(0x07FF)
function chessmaster_level() => cpu_difficulty() - 1

// $0800: Deep Thinking On [8 bit] (0/1)
function deep_thinking_on() => byte(0x0800)

// $0801: Teaching Mode On [8 bit] (0/1)
function teaching_mode_on() => byte(0x0801)

// $0802: Coordinates On [8 bit] (0/1)
function coordinates_on() => byte(0x0802)

// $0803: Chess Clock On [8 bit] (0/1)
function chess_clock_on() => byte(0x0803)

// $0804: Touching Rule On [8 bit] (0/1)
function touching_rule_on() => byte(0x0804)

// $0805: White Hidden [8 bit] (0/1)
function white_hidden() => byte(0x0805)

// $0806: Black Hidden [8 bit] (0/1)
function black_hidden() => byte(0x0806)

// $0807: Board Orientation [8 bit]
//        0 = White on Bottom
//        1 = White on Left
//        2 = White on Top
//        3 = White on Right
function board_orientation() => byte(0x0807)

// $0808: Human Color [8 bit]
//        0 = White
//        1 = Black
function human_color() => byte(0x0808)

// $1003: Last Move From [8 bit]
//        0xAB = row A, col B (assuming black on top)
function last_move_from() => byte(0x1003)

// $1004: Last Move To [8 bit]
//        0xAB = row A, col B (assuming black on top)
function last_move_to() => byte(0x1004)

// $10C0: White Piece Positions [16 bytes]
//        0xAB for A row, B col - 0xFF no piece
function white_piece_positions() => byte(0x10C0)

// $10D0: Black Piece Positions [16 bytes]
//        0xAB for A row, B col - 0xFF no piece
function black_piece_positions() => byte(0x10D0)

// $10E0: White Piece Types [16 bytes]
//        0 = pawn
//        1 = king
//        2 = knight
//        3 = rook
//        4 = bishop
//        5 = queen
function white_piece_types() => byte(0x10E0)

// $10F0: Black Piece Types [16 bytes]
//        0 = pawn
//        1 = king
//        2 = knight
//        3 = rook
//        4 = bishop
//        5 = queen
function black_piece_types() => byte(0x10F0)

// $1100: Engine Board State [0x80 bytes]
//        index 0xAB corresponds to the piece in row A, column B
//        (row 0 is black's back row, column 0 is A file)
//        
//        upper 4 is color (0 = empty, 1 = white, 2 = black)
//        lower 4 is piece
//        0 = pawn
//        1 = king
//        2 = knight
//        3 = rook
//        4 = bishop
//        5 = queen
function engine_board_state() => byte(0x1100)

// $1BAA: Settings [8 bit]
//        bit1 = Opening Book (0 = on, 1 = off)
function settings() => byte(0x1BAA)

// $1F03: Human Player Count [8 bit] (0-2)
function human_player_count() => byte(0x1F03)

// --- MAIN DATA -------------------------------------------------------------------

WHITE = 0
BLACK = 1

XX_ = 0x00

BK_ = 0x01
BQ_ = 0x02
BR_ = 0x03
BB_ = 0x04
BN1 = 0x05
BP_ = 0x06
BN2 = 0x07

WK_ = 0x09
WQ_ = 0x0a
WR_ = 0x0b
WB_ = 0x0c
WN1 = 0x0d
WP_ = 0x0e
WN2 = 0x0f

SCREEN_TITLE = 0
SCREEN_BOARD = 1
SCREEN_LOG_ACTIONS = 3
SCREEN_SETTINGS = 4
SCREEN_SETUP = 5
SCREEN_LOAD_GAME = 6
SCREEN_SAVE_GAME = 7
SCREEN_PRESS_START = 8

function chess960(r)
{
	B = [
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
		BP_, BP_, BP_, BP_, BP_, BP_, BP_, BP_, 
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
		WP_, WP_, WP_, WP_, WP_, WP_, WP_, WP_, 
		XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	]

	for i in range(0,7)
	{
		B[i] = r[i]
		B[56 + i] = r[i] + 8
	}
	return B
}

BOARD_NORMAL = [
	BR_, BN1, BB_, BQ_, BK_, BB_, BN2, BR_, 
	BP_, BP_, BP_, BP_, BP_, BP_, BP_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, WP_, WP_, WP_, WP_, WP_, WP_, WP_, 
	WR_, WN1, WB_, WQ_, WK_, WB_, WN2, WR_,
]

BOARD_CHECKERS = [
	XX_, BP_, XX_, BK_, XX_, BP_, XX_, BP_, 
	BP_, XX_, BP_, XX_, BP_, XX_, BP_, XX_, 
	XX_, BP_, XX_, BP_, XX_, BP_, XX_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, XX_, WP_, XX_, WP_, XX_, WP_, XX_, 
	XX_, WP_, XX_, WP_, XX_, WP_, XX_, WP_, 
	WP_, XX_, WP_, XX_, WK_, XX_, WP_, XX_, 
]

/*
BOARD_DIAGONAL = [ // HXw0108wc3bJg9jKk#G%v$Cl
	BK_, BB_, BR_, BP_, XX_, XX_, XX_, XX_, 
	BQ_, BN1, BP_, XX_, XX_, XX_, XX_, XX_, 
	BB_, BP_, XX_, XX_, XX_, XX_, XX_, XX_, 
	BP_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, WP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, WP_, WB_, 
	XX_, XX_, XX_, XX_, XX_, WP_, WN2, WQ_, 
	XX_, XX_, XX_, XX_, WP_, WR_, WB_, WK_, 
]
*/

BOARD_DIAGONAL = [ // b*w136D/wgbN-ShS6T:St#q%r%B%W>9
	BK_, BN1, BN2, BR_, BP_, XX_, XX_, XX_, 
	BB_, BQ_, BP_, BP_, XX_, XX_, XX_, XX_, 
	BB_, BP_, BP_, XX_, XX_, XX_, XX_, XX_, 
	BR_, BP_, XX_, XX_, XX_, XX_, XX_, WP_, 
	BP_, XX_, XX_, XX_, XX_, XX_, WP_, WR_, 
	XX_, XX_, XX_, XX_, XX_, WP_, WP_, WB_, 
	XX_, XX_, XX_, XX_, WP_, WP_, WQ_, WB_, 
	XX_, XX_, XX_, WP_, WR_, WN1, WN2, WK_, 
]

BOARD_SHOGI = [
	XX_, BN1, BQ_, XX_, BK_, BQ_, BN2, XX_, 
	XX_, BR_, XX_, XX_, XX_, XX_, BB_, XX_, 
	BP_, BP_, BP_, BP_, BP_, BP_, BP_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, WP_, WP_, WP_, WP_, WP_, WP_, WP_, 
	XX_, WB_, XX_, XX_, XX_, XX_, WR_, XX_, 
	XX_, WN1, WQ_, WK_, XX_, WQ_, WN2, XX_, 
]

// https://www.chess.com/news/view/vachier-lagrave-comments-while-playing-komodo
BOARD_KNIGHTMARE = [
	BR_, XX_, BB_, BQ_, BK_, BB_, XX_, BR_, 
	BP_, BP_, BP_, BP_, BP_, BP_, BP_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, WP_, WP_, WP_, WP_, WP_, WP_, WP_, 
	WN2, WN2, WN2, WN2, WK_, WN2, WN2, WN2,
]

BOARD_PAWN_ODDS = [
	BR_, BN1, BB_, BQ_, BK_, BB_, BN2, BR_, 
	BP_, BP_, BP_, BP_, BP_, BP_, BP_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, WP_, XX_, WP_, WP_, XX_, WP_, WP_, 
	WR_, WN1, WB_, WQ_, WK_, WB_, WN2, WR_,
]

// https://www.reddit.com/r/chess/comments/io3m6z
MATE4_DISTRACTION = [
	BR_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, WP_, 
	XX_, XX_, BP_, XX_, WR_, XX_, BP_, XX_, 
	BP_, BP_, BK_, XX_, BP_, XX_, XX_, XX_, 
	XX_, XX_, XX_, BP_, WB_, XX_, XX_, BQ_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	WP_, WP_, WP_, XX_, XX_, XX_, WP_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, WK_, XX_, 
]

// https://www.sparkchess.com/chess-puzzles/mikhail-botvinnik-vs-victor-goglidze.html
MATE4_GORDIAN_KNOT = [
	XX_, XX_, BB_, BK_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, BB_, XX_, 
	XX_, XX_, BP_, WN2, BP_, XX_, XX_, XX_, 
	BR_, XX_, WP_, BP_, WP_, XX_, WP_, XX_, 
	WP_, XX_, BP_, WP_, XX_, WQ_, XX_, XX_, 
	XX_, XX_, BR_, BQ_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, WR_, 
	XX_, XX_, XX_, XX_, XX_, XX_, WR_, WK_, 
]

// https://thechessworld.com/articles/problems/3-hardest-mate-in-4-ever/
MATE4_DIE_WELT = [
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, BP_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, WR_, 
	XX_, BP_, XX_, XX_, BK_, BP_, XX_, XX_, 
	XX_, WR_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, WK_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
	XX_, XX_, XX_, XX_, XX_, XX_, XX_, XX_, 
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// check board state
function board_is(b)
{
	trigger = always_true()
	for i in range(0, 63, 4)
	{
		x = 0
		for j in range(0, 3) x = x * 0x100 + b[i + j]
		trigger = trigger && x == dword_be(board(i))
	}
	return trigger
}

function board_changed() => any_of(range(0, 63, 4), i => prev(dword_be(board(i))) != dword_be(board(i)))

function on_human_turn(f) => (
	// there is exactly one human player
	human_player_count() == 1 &&
	// a turn has been taken
	prev(color_to_move()) != color_to_move() &&
	// the turn was taken by the human player
	prev(color_to_move()) == human_color() &&
	// check predicate, pass prev turn number for an index into the logs
	f(turns_taken() - 1)
)

// compute the time of the human player
function human_seconds() => (
	clock_00_00_0x(human_color()) +
	clock_00_00_x0(human_color())*10 +
	clock_00_0x_00(human_color())*60 +
	clock_00_x0_00(human_color())*600 +
	clock_0x_00_00(human_color())*3600 +
	clock_x0_00_00(human_color())*36000
)

// move types
function is_castle(i) => history_captured(i) == 0x80
function is_en_passant(i, c) => history_captured(i) == (0x86 + c*8)
function is_promotion(i) => history_move_type(i) == 0xC

// game results
function checkmate()          => game_ended() == 1 && draw_offered() == 0 && forced_draw() == 0 && player_in_check() == 1
function stalemate()          => game_ended() == 1 && draw_offered() == 0 && forced_draw() == 0 && player_in_check() != 1
function agreed_draw_result() => game_ended() == 1 && draw_offered() != 0
function forced_draw_result() => game_ended() == 1 && forced_draw() == 1

// game states
function new_game() => prev(screen_id()) == SCREEN_PRESS_START && screen_id() == SCREEN_BOARD && turns_taken() == 0
function loaded_game(b) => prior(screen_id()) == SCREEN_LOAD_GAME && screen_id() == SCREEN_BOARD && turns_taken() == 0 && board_is(b)
function valid_difficulty() => chessmaster_level() >= 1 && chessmaster_level() <= 13

// illegal actions
function illegal_change_difficulty() => turns_taken() > 0 && cpu_difficulty() != prev(cpu_difficulty())
function illegal_change_sides() => turns_taken() > 0 && human_color() != prev(human_color())
function illegal_computer_count() => turns_taken() > 0 && screen_id() == SCREEN_BOARD && human_player_count() != 1
function illegal_force_move() => screen_id() == SCREEN_LOG_ACTIONS && menu_row() == 0x07 && is_set(button_b1())
function illegal_solve_for_mate() => screen_id() == SCREEN_LOG_ACTIONS && menu_row() == 0x0a && is_set(button_b1())
function illegal_rewind() => turns_taken() > 0 && turns_taken() < prev(turns_taken())
function illegal_setup_board() => in_setup_mode() == 1
function illegal_load_game() => screen_id() == SCREEN_LOAD_GAME

function any_illegal() => (
	illegal_change_difficulty()
	|| illegal_change_sides()
	|| illegal_computer_count()
	|| illegal_force_move()
	|| illegal_solve_for_mate()
	|| illegal_rewind()
	|| illegal_setup_board()
	|| illegal_load_game()
)

ILLEGAL_RULES = "You may not force the Chessmaster to move, solve for mate, rewind, or load a game, or change sides or difficulty after the first move."
LOADED_GAME_PREAMBLE = "Playing as White against The Chessmaster at level 3 or higher, enter the following password in the load game menu and win a standard fair game -- "
function loaded_game_achievement(b, n) => once(loaded_game(b)) && chessmaster_level() >= n && human_color() == WHITE && trigger_when(win()) && never(any_illegal())
function mate_in(n) => format("Playing as White against The Chessmaster at level 12 or higher, enter the following password in the load game menu and mate in {0} move{1} (rewind allowed) -- ", n, if_else(n==1, "", "s"))

function mate_in_achievement(b, n) => (
	once(loaded_game(b)) && 
	chessmaster_level() >= 12 && 
	human_color() == WHITE &&
	trigger_when(win()) && 
	never(illegal_change_difficulty()) &&
	never(illegal_change_sides()) &&
	never(illegal_computer_count()) &&
	never(illegal_force_move()) &&
	never(illegal_solve_for_mate()) &&
	never(illegal_setup_board()) &&
	never(illegal_load_game()) &&
	turns_taken() < n*2
)

// sets a flag when *any* valid game is being played (for RP)
function any_valid() => (
	once(turns_taken() == 0 && screen_id() == SCREEN_BOARD)
	&& valid_difficulty()
	&& never(any_illegal())
)

function valid_game() => once(new_game()) && valid_difficulty() && never(any_illegal())
function win() => checkmate() && color_to_move() != human_color()

// --- RICH PRESENCE -------------------------------------------------------------------

rp_white_player = rich_presence_flag("🧠", fallback="🤖", lookupname="WhitePlayer", 
	when=human_player_count() == 2 || (human_player_count() == 1 && human_color() == WHITE))
rp_black_player = rich_presence_flag("🧠", fallback="🤖", lookupname="BlackPlayer", 
	when=human_player_count() == 2 || (human_player_count() == 1 && human_color() == BLACK))

rp_game_state = rich_presence_condition_table("GameResult", [
	[checkmate() && color_to_move() == BLACK, "Black is Checkmated · "],
	[checkmate() && color_to_move() == WHITE, "White is Checkmated · "],
	[stalemate() && color_to_move() == BLACK, "Black Stalemate · "],
	[stalemate() && color_to_move() == WHITE, "White Stalemate · "],
	[forced_draw_result(), "Forced Draw · "],
	[agreed_draw_result(), "Draw · "],
	[always_true(), ""],
])

rp_chessmaster_level = rich_presence_lookup("CPULevel", cpu_difficulty(), {
	0x00: "Newcomer 1",
	0x01: "Newcomer 2",
	0x02: "Chessmaster 1",
	0x03: "Chessmaster 2",
	0x04: "Chessmaster 3",
	0x05: "Chessmaster 4",
	0x06: "Chessmaster 5",
	0x07: "Chessmaster 6",
	0x08: "Chessmaster 7",
	0x09: "Chessmaster 8",
	0x0A: "Chessmaster 9",
	0x0B: "Chessmaster 10",
	0x0C: "Chessmaster 11",
	0x0D: "Chessmaster 12",
	0x0E: "Chessmaster 13",
	0x0F: "Infinite",
}, fallback="???")

rich_presence_conditional_display(screen_id() == SCREEN_TITLE || screen_id() == SCREEN_PRESS_START,
	"[Title Screen]"
)
rich_presence_display(
	"{0}{1}⬜{2} {3}{4}:{5}{6}:{7}{8} vs ⬛{9} {10}{11}:{12}{13}:{14}{15} · 🤖={16}",
	/*  0 */ "", // rich_presence_flag("", when=any_valid(), fallback="⚠️ ", lookupname="WarningFlag"),
	/*  1 */ rp_game_state,
	/*  2 */ rp_white_player,
	/*  3 */ rich_presence_number(clock_x0_00_00(WHITE)),
	/*  4 */ rich_presence_number(clock_0x_00_00(WHITE)),
	/*  5 */ rich_presence_number(clock_00_x0_00(WHITE)),
	/*  6 */ rich_presence_number(clock_00_0x_00(WHITE)),
	/*  7 */ rich_presence_number(clock_00_00_x0(WHITE)),
	/*  8 */ rich_presence_number(clock_00_00_0x(WHITE)),
	/*  9 */ rp_black_player,
	/* 10 */ rich_presence_number(clock_x0_00_00(BLACK)),
	/* 11 */ rich_presence_number(clock_0x_00_00(BLACK)),
	/* 12 */ rich_presence_number(clock_00_x0_00(BLACK)),
	/* 13 */ rich_presence_number(clock_00_0x_00(BLACK)),
	/* 14 */ rich_presence_number(clock_00_00_x0(BLACK)),
	/* 15 */ rich_presence_number(clock_00_00_0x(BLACK)),
	/* 16 */ rp_chessmaster_level
)


// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="You Are Ready to Face the Chessmaster",
	description="All achievements require playing a standard fair game against The Chessmaster at CPU levels 1-13. " + ILLEGAL_RULES,
	points=0,
	trigger=(
		new_game()
	)
)

// ######################################
// ####    Standard Game Winning    #####
// ######################################

achievement(
	title="You Can Only Get Good at Chess If You Love the Game",
	description="Win a standard fair game against The Chessmaster at level 3 or higher.",
	type="win_condition",
	points=5,
	trigger=(
		valid_game() &&
		chessmaster_level() >= 3 &&
		trigger_when(win()) &&
		never(screen_id() == SCREEN_TITLE)
	)
)

achievement(
	title="I Hate Chess. I Hate Chess. I Hate Chess.",
	description="Win a standard fair game against The Chessmaster at level 11, 12, or 13.",
	points=10,
	trigger=(
		valid_game() &&
		chessmaster_level() >= 11 &&
		win() &&
		never(screen_id() == SCREEN_TITLE)
	)
)

BULLET_SECONDS = 5
achievement(
	title="Taking a Bullet",
	description=format("Win a standard fair game against The Chessmaster at level 3 or higher with fewer than {0} minutes on your game clock.", BULLET_SECONDS),
	points=5,
	trigger=(
		valid_game() &&
		chessmaster_level() >= 3 &&
		human_seconds() < BULLET_SECONDS*60 &&
		win() &&
		never(screen_id() == SCREEN_TITLE)
	)
)

// ######################################
// ####        Common Moves         #####
// ######################################

achievement(
	title="Gee, Why Does Your Chessmaster Let You Move TWO Pieces?",
	description="Castle kingside or queenside during a standard fair game against The Chessmaster.",
	points=1,
	trigger=(
		once(new_game()) && never(any_illegal()) &&
		on_human_turn(i => history_captured(i) == 0x80)
	)
)

achievement(
	title="Google \"En Passant\"",
	description="Capture The Chessmaster's pawn via en passant during a standard fair game.",
	points=3,
	trigger=(
		once(new_game()) && never(any_illegal()) &&
		on_human_turn(i => (
			(human_color() == WHITE && history_captured(i) == 0x86) || 
			(human_color() == BLACK && history_captured(i) == 0x8e)
		))
	)
)

// ######################################
// ####   Unique Initial Configs    #####
// ######################################

achievement(
	title="You're Playing Checkers; I'm Playing Chess",
	description=LOADED_GAME_PREAMBLE + "pQjp00JPpQj5kTkTkTk%t%t%tlG",
	points=5,
	trigger=loaded_game_achievement(BOARD_CHECKERS, 3)
)

achievement(
	title="Let the Wookie Win",
	description=LOADED_GAME_PREAMBLE + "b*w136D/wgbN-ShS6T:St#q%r%B%W>9",
	points=5,
	trigger=loaded_game_achievement(BOARD_DIAGONAL, 3)
)

achievement(
	title="Shogi Master",
	description=LOADED_GAME_PREAMBLE + ":9.>00w>2#Q9dX3TkTkTk%t%t%*:VpH",
	points=5,
	trigger=loaded_game_achievement(BOARD_SHOGI, 3)
)

// ######################################
// ####     Challenge Positions     #####
// ######################################

achievement(
	title="Knightmare",
	description=LOADED_GAME_PREAMBLE + "<=H00000>>>JLJgTkTkTt%t%t>>>#>H",
	points=10,
	trigger=loaded_game_achievement(BOARD_KNIGHTMARE, 3)
)

achievement(
	title="Pawn Odds",
	description=LOADED_GAME_PREAMBLE + ">>H00000W>>Nh4.FkTkTk#t%tvFq9>C",
	points=5,
	trigger=loaded_game_achievement(BOARD_PAWN_ODDS, 3)
)

// chess960 stats: https://github.com/welyab/chess960-win-by-position-setup
achievement(
	title="Chess960 Theocracy",
	description=LOADED_GAME_PREAMBLE + ">>H00000W>>>43KLYkTkTk#t%t%=kCzV> (Chess960 castling rules do not apply)",
	points=10,
	trigger=loaded_game_achievement(chess960([BR_, BK_, BR_, BB_, BB_, BQ_, BN1, BN2]), 3) // RKRBBQNN: -126
)

// ######################################
// #####     Mate in N puzzles      #####
// ######################################

achievement(
	title="Distraction: Mate in 4",
	description=mate_in(4) + "108PRc9071./:Vk5kxf%tl",
	points=2,
	trigger=mate_in_achievement(MATE4_DISTRACTION, 4)
)

achievement(
	title="The Gordian Knot: Mate in 4",
	description=mate_in(4) + "D047Y,2302D5h<:/k%t#$8%k",
	points=2,
	trigger=mate_in_achievement(MATE4_GORDIAN_KNOT, 4)
)

achievement(
	title="Die Welt: Mate in 4",
	description=mate_in(4) + "008cy80200csQSW2",
	points=2,
	trigger=mate_in_achievement(MATE4_DIE_WELT, 4)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Bullet Chess",
	description="Complete a standard fair game against The Chessmaster at level 3 or above as fast as possible.",

	start=valid_game() && chessmaster_level() >= 3 && win(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(human_seconds()),
	format="SECS",
	lower_is_better=true
)
