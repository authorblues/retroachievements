ADDR_CAM_X = 0x0702
ADDR_CAM_Y = 0x070a
ADDR_PLAYER_X = 0x41c1
ADDR_PLAYER_Y = 0x41c4
ADDR_VISIBILITY = 0x41e3
ADDR_STAGE = 0x0750
ADDR_HEALTH = 0x0754
ADDR_CHAR_STATE = 0x4185

X_OFFSET = 0x60
Y_OFFSET = 0xa1

INVISIBLE = 0x58

stage = mainmemory.read_u8(ADDR_STAGE)
STAGE_W = {0x1700, 0x1500, 0x1600, 0x0F00, 0x0D00}
STAGE_H = {0x0500, 0x0430, 0x0330, 0x0330, 0x0400}

w = STAGE_W[stage+1]
h = STAGE_H[stage+1]

target_x = 0
target_y = 0

--snes.setlayer_bg_2(false)
snes.setlayer_bg_3(false)

last_cam_x = mainmemory.read_u16_le(ADDR_CAM_X)
last_cam_y = mainmemory.read_u16_le(ADDR_CAM_Y)
no_move = 0

more = true
while more do
	mainmemory.write_u8(ADDR_CHAR_STATE, 0x03)
	mainmemory.write_u8(ADDR_HEALTH, 20)
	mainmemory.write_u8(ADDR_VISIBILITY, INVISIBLE)

	char_x = target_x + X_OFFSET
	if target_x == 0 then char_x = 0 end

	char_y = target_y + Y_OFFSET
	if target_y == 0 then char_y = 0 end

	mainmemory.write_u16_le(ADDR_PLAYER_X, char_x)
	mainmemory.write_u16_le(ADDR_PLAYER_Y, char_y)

	curr_cam_x = mainmemory.read_u16_le(ADDR_CAM_X)
	curr_cam_y = mainmemory.read_u16_le(ADDR_CAM_Y)

	no_move = no_move + 1
	if curr_cam_x ~= last_cam_x or curr_cam_y ~= last_cam_y then no_move = 0 end

	if no_move == 30 and curr_cam_y == 0 then
		--mainmemory.write_u16_le(ADDR_PLAYER_X, mainmemory.read_u16_le(ADDR_PLAYER_X) + target_x - curr_cam_x)
		--mainmemory.write_u16_le(ADDR_CAM_X, target_x)
		--mainmemory.write_u16_le(ADDR_CAM_Y, target_y)
	end

	if (curr_cam_x == target_x and curr_cam_y == target_y) or no_move > 30 then
		filename = string.format("maps/stage%d/%04d-%04d.png", stage, curr_cam_x, curr_cam_y)
		print("screenshotting " .. filename)
		client.screenshot(filename)
		
		-- shift down one screen
		target_y = target_y + 0xD0

		-- if the camera cannot go down further
		if no_move > 30 then
			-- reset to the top
			target_y = 0

			-- shift right one screen
			target_x = target_x + 0x100

			-- if this exceeds the width, done
			if target_x > w then
				more = false
			end
		end

		no_move = 0
	end

	last_cam_x = curr_cam_x
	last_cam_y = curr_cam_y

	emu.frameadvance()
end

mainmemory.write_u16_le(ADDR_PLAYER_X, 0)
mainmemory.write_u16_le(ADDR_PLAYER_Y, 0)

snes.setlayer_bg_3(true)
snes.setlayer_bg_3(true)