// Quest 64 [Subset - Barbarian]
// #ID = 33718

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function plural(x) => rich_presence_lookup("_Plural", x, {1: ""}, fallback="s")
function ptr(x) => dword(x)
function rich_presence_number(x) => rich_presence_value("_Number", x, "VALUE")

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

function commas(x)
{
	function comma_join(list)
	{
		res = ""
		for i in range(0, length(list)-1)
		{
			if (i == length(list) - 1)
				res = format("{0}", list[i]) + res
			else res = "," + zfill(list[i], 3) + res
		}
		return res
	}

	parts = []
	for i in range(1, 10)
	{
		if (x == 0) return comma_join(parts)
		array_push(parts, x % 1000)
		x = x / 1000
	}
}

// --- MEMORY -------------------------------------------------------------------

// $07B2E4: Game state
//          0x0000 = Normal
//          0x0001 = Item Menu
//          0x0002 = Talking to NPC
//          0x0004 = Spell Menu
//          0x0008 = Spirit Placement
//          0x0012 = Talking to INN
//          0x0080 = Interacting with a Door
//          0x0160 = Title Screen
//          0x01E0 = Load Screen transition
//          0x0480 = Loading Memory Card
//          0x05A0 = Save Menu
//          0x0880 = Dying
function game_state() => word(0x07B2E4)

// $07BA84: Max HP [16 bit]
function max_hp() => word(0x07BA84)

// $07BA86: Current HP [16 bit]
function current_hp() => word(0x07BA86)

// $07BA88: Max MP [16 bit]
//          start game at 15
function max_mp() => word(0x07BA88)

// $07BA8A: Current MP [16 bit]
function current_mp() => word(0x07BA8A)

// $07BA8C: Defense [16 bit]
function defense() => word(0x07BA8C)

// $07BA8E: Agility [16 bit]
function agility() => word(0x07BA8E)

// $07BAA4: Wind Element Level (C Right) [8 bit]
function wind_count() => byte(0x07BAA4)

// $07BAA5: Water Element Level (C Down) [8 bit]
function water_count() => byte(0x07BAA5)

// $07BAA6: Earth Element Level (C Left) [8 bit]
function earth_count() => byte(0x07BAA6)

// $07BAA7: Fire Element Level (C Up) [8 bit]
function fire_count() => byte(0x07BAA7)

// $07BAA8: MP Exp [16 bit]
//          goes up when casting spells
function mp_exp() => word(0x07BAA8)

// $07BAAA: HP Exp [16 bit]
function hp_exp() => word(0x07BAAA)

// $07BAAC: Defense Exp [16 bit]
function defense_exp() => word(0x07BAAC)

// $07BAAE: Agility Exp [16 bit]
function agility_exp() => word(0x07BAAE)

// $07BBD4: Spell Being Cast [16 bit]
//          
//          00XX = Fire
//          01XX = Rock
//          02XX = Water
//          03XX = Wind
function cast_spell() => word(0x07BBD4)

// $07D19F: Boss Flags [8 bit]
//          
//          Bit 0 - Solvaring
//          Bit 1 - Zelse
//          Bit 2 - Nepty
//          Bit 3 - Shilf
//          Bit 4 - Fargo
//          Bit 5 - Guilty
//          Bit 6 - Beigis
//          Bit 7 - Mammon
BOSS_FLAGS = 0x07D19F

// $085368: Map ID [8 bit]
//          
//          Map ID, and Sub Map ID, should be applied to Boss Kill Achievements, with Delta values.
//          Left Value is Map ID, Right Value is Sub Map ID, Credits to "Retroben"
//          
//          00,00=Melrode Town
//          00,01=Outside Monastery
//          00,02=Floating Monastery
//          00,03=Mammon Melrode Town
//          00,04=Mammon Monastery
//          01,00=Dondoran Castle Town
//          02,00=Holy Plain
//          03,00=Dondoran Flats
//          03,01=Dondoran Ship
//          04,00=Larapool
//          04,01=Lower Larapool
//          04,02=Drained Lower Larapool
//          05,00=West Carmagh
//          05,01=Carmagh Ship
//          06,00=Normoon
//          07,00=East Limelin
//          07,01=Limelin Ship
//          08,00=Limelin Castle Town
//          08,01=Limelin Castle Front
//          09,00=Dindom Dries
//          0A,00=Shamwood
//          0B,00=Brannoch Town
//          0B,01=Brannoch Castle Front
//          0B,02=Baragoon Moor
//          0B,03=Brannoch Castle Hallway
//          0B,04=Brannoch Castle Roofs
//          0B,05=Brannoch Castle Ramp
//          0B,06=Brannoch Castle Stairs
//          0B,07=Brannoch Elemental Shrine?
//          0C,00=Isle Of Skye
//          0C,01=Ship Of Skye
//          0C,02=Sailing Skye Ship
//          0D,00=Monastery Entrance/Exit
//          0D,01=Room Six
//          0D,02=Room Five
//          0D,03=Room Three
//          0D,04=Room Two
//          0D,05=Room Four
//          0D,06=Fergus
//          0D,07=Kitchen
//          0D,08=Cerious
//          0D,09=Hallway
//          0D,0A=Garden
//          0D,0B=Storage
//          0D,0C=Bottom Stairs
//          0D,0D=Middle Stairs
//          0D,0E=Top Stairs
//          0D,0F=Library
//          0D,10=Hall After 1st Stairs
//          0D,11=First Room (Grand Abbott)
//          0E,00=Dondoran Castle Entrance/Exit
//          0E,01=King Scottfort
//          0E,02=DonCas Kitchen
//          0E,03=Gibson
//          0E,04=DonCas Storage
//          0E,05=DonCas Red Balcony
//          0E,06=DonCas Green Balcony
//          0E,07=DonCas Second Floor
//          0E,08=DonCas Dining
//          0E,09=DonCas Library
//          0E,0A=DonCas King Bedroom
//          0E,0B=Kate
//          0E,0C=King's Secret Room
//          0E,0D=False Kate Room (Mammon)
//          0E,0E=Princess Flora's Room
//          0E,0F=Secret Room's Secret
//          0F,00=Ralph's House
//          0F,01=Elspet's House
//          0F,02=Holly's House
//          0F,03=House Near Kids
//          0F,04=Katie's House
//          0F,05=Melrode Inn
//          0F,06=Upstairs
//          0F,07=Inn Room Left
//          0F,08=Inn Room Right
//          0F,09=Inn Room Front Left
//          0F,0A=Inn Room Front Right
//          0F,0B=White Wings Shop
//          0F,0C=Farm Shed
//          0F,0D=Epona's House (Mammon)
//          10,00=Dondoran First House
//          10,01=Claire's House
//          10,02=Another House
//          10,03=Annabell's House
//          10,04=Walter's House
//          10,05=Curtis' House
//          10,06=Clay's House
//          10,07=Dondoran Inn
//          10,08=Upstairs
//          10,09=Left Room
//          10,0A=Right Room
//          10,0B=Front Left Room
//          10,0C=Front Right Room
//          10,0D=Dondoran Bar
//          10,0E=Yellow Wings Shop
//          10,0F=Don Flats Inn
//          10,10=Upstairs
//          10,11=Left Room
//          10,12=Right Room
//          10,13=Front Left Room
//          10,14=Front Right Room
//          10,15=Marion's
//          11,00=Larapool Hotel Tavern
//          11,01=Downstairs
//          11,02=Room One
//          11,03=Naltese's Room
//          11,04=Leftward Room
//          11,05=Rightward Room
//          11,06=Leila's Room
//          11,07=Leila's Water Chamber?
//          12,00=Camelia's House
//          12,01=Another House
//          12,02=Rosa and Olden
//          12,03=Glion's House
//          12,04=Blue Wings Shop
//          12,05=Lumberjack Shack
//          12,06=Efna's Place
//          12,07=Dorothy's Place
//          13,00=BETA Windmill (Mammon)
//          13,01=BETA Windmill
//          13,02=Finished Windmill One
//          13,03=Finished windmill Two
//          14,00=Byson and Micah's
//          14,01=Gelus' House
//          14,02=Hector's House
//          14,03=Unused House!
//          14,04=Another Unused!
//          14,05=Normoon Inn
//          14,06=Upstairs
//          14,07=Left Room
//          14,08=Right Room
//          14,09=Front Left Room
//          14,0A=Front Right Room
//          14,0B=Green Wings Shop
//          15,00=Limelin Castle Entrance/Exit
//          15,01=Hallways of Stairs
//          15,02=Storage
//          15,03=Guest Room One?
//          15,04=Guest room Two?
//          15,05=Throne Room AND Secret Entrance
//          15,06=Library
//          15,07=Dining Room
//          15,08=Guest Room Three??
//          15,09=Another Guest Room?!?
//          15,0A=Queen's Bedroom
//          15,0B=William's Room
//          15,0C=Secret Room
//          16,00=Jail Tower?
//          16,01=Jail Room?
//          16,02=Tina's House
//          16,03=Dolgo Upstairs
//          16,04=Talco's House
//          16,05=Upstairs
//          16,06=Amber's House
//          16,07=Upstairs
//          16,08=Elle's House
//          16,09=Elle Upstairs
//          16,0A=Opal's House
//          16,0B=Opal Upstairs
//          16,0C=Another House
//          16,0D=Upstairs
//          16,0E=Limelin Inn
//          16,0F=Upstairs
//          16,10=Left Room
//          16,11=Right Room
//          16,12=Front Left Room
//          16,13=Front Right Room
//          16,14=Limelin Rootbeer Tavern
//          16,15=Red Wings Shop
//          16,16=Sabastian's Place
//          16,17=Mine Cabin?
//          16,18=Creepy House (Mammon)
//          16,19=Upstairs (Mammon)
//          17,00=A Burnt Town's Inn
//          17,01=Upstairs
//          17,02=Left Room
//          17,03=Front Left Room
//          17,04=Front Right Room
//          17,05=Forsaken Town Neglect
//          17,06=Janat's House
//          17,07=Another House
//          17,08=Brannoch Inn
//          17,09=Upstairs
//          17,0A=Left Room
//          17,0B=Right Room
//          17,0C=Front Left Room
//          17,0D=Front Right Room
//          17,0E=Black Wings Shop
//          17,0F=Knights House
//          17,10=Another Knights
//          17,11=Knights Upstairs
//          17,12=Another Upstairs
//          17,13=Desert Tent
//          17,14=Walt's Desert House
//          17,15=Bedroom
//          17,16=Bation's Place
//          17,17=Upstairs
//          17,18=Right Room
//          17,19=Left Room
//          18,00=Lavaar's Treasure Chamber
//          18,01=Shamwood Tomb
//          18,02=Treasure Tomb Jackpot
//          19,00=Skye House
//          19,01=Skye Portal
//          19,02=Inside Skye Ship
//          19,03=Downstairs
//          19,04=Macren's Ship Room
//          19,05=Inside Carmagh Ship
//          19,06=Inside Skye Ship? (Mammon)
//          19,07=Downstairs (Mammon)
//          19,08=Inside Limelin ship
//          19,09=Inside Dondoran Ship
//          1A,00=Blue Cave
//          1A,01=Deep In Blue Cave
//          1A,02=Blue Cave Building Area?
//          1A,03=Epona's Cave House
//          1A,04=Portal Room
//          1B,00=Cull Hazard
//          1C,00=Baragoon Tunnel
//          1D,00=Boil Hole
//          1E,00=Brannoch Castle Stairway
//          1E,01=A Larger Stairway
//          1E,02=A Third Stairway
//          1E,03=Fourth
//          1E,04=Fifth
//          1E,05=Sixth
//          1E,06=Seventh
//          1E,07=Railing
//          1E,08=Secret room?
//          1E,09=Railing and Pedestals
//          1E,0A=Guilty Boss
//          1E,0B=WTF?
//          1E,0C=Column Railing
//          1E,0D=Your Dad,Bart
//          1E,0E=Beigis Boss
//          1E,0F=Prince Leonardo Arrived
//          1F,00=Connor Fortress
//          1F,01=Solvaring 1st Boss
//          1F,02=Fortress Building
//          20,00=Glencoe Forest
//          20,01=Kelly's Cabin
//          20,02=Bedroom
//          21,00=Windward Forest
//          21,01=Cabin
//          21,02=Bedroom
//          22,00=Mammon
//          22,01=Shannon Alone
//          22,02=Pink Bubble
//          22,03=Shannon Far
//          22,04=Mammon's Forest
//          22,05=Mammon,s Beautiful Woods
//          22,06=Mammon's Pathway?
//          22,07=Pink Bubble Ramp
//          22,08=Pink Bubble Woods
//          22,09=Dark Pathway
//          22,0A=Mammon,(the kindest) Final Boss
//          23,00=Nepty Boss
function map_id() => byte(0x085368)

// $08536C: Sub Map ID [8 bit]
function sub_map_id() => byte(0x08536C)

// $0869D8: (Bits) Treasure Chests [12 bytes]
//          
//          Bit 0 = Silver Amulet in Limelin Castle Treasury
//          Bit 1 = Celine's Bell in Limelin Castle Treasury
//          Bit 2 = Healing Potion in Limelin Castle Treasury
//          Bit 3 = Mint Leaves in Limelin house across from INN
//          Bit 4 = Honey Bread in Limelin red house near INN
//          Bit 5 = Dew Drop in Limelin purple house near INN
//          Bit 6 = Giant's Shoes in Dindom Dries House
//          Bit 7 = Spirit Light in Baragoon Moore INN

// $0869D9: (Bits) Treasure Chests
//          
//          Bit 0 = Fresh Bread in Normoon 1st Mill
//          Bit 1 = Fresh Bread in Normoon 1st Mill
//          Bit 2 = Fresh Bread in Normoon 2nd Mill
//          Bit 3 = Heroes Drink in Normoon 2nd Mill
//          Bit 4 = Honey Bread in Limelin Castle Armory
//          Bit 5 = Healing Potion in Limelin Castle Armory
//          Bit 6 = Mint Leaves in Limelin Castle Armory
//          Bit 7 = Healing Potion in Limelin House across from INN

// $0869DA: (Bits) Treasure Chests
//          
//          Bit 0 = Dew Drop in Dondoran Floras Room
//          Bit 1 = Dew Drop in Dondoran Floras Room
//          Bit 2 = Mint Leaves in Dondoran Floras Room
//          Bit 3 = Healing Potion in Dondoran Treasury
//          Bit 4 = Replica in Dondoran Treasury
//          Bit 5 = Heroes Drink in Dondoran Treasury
//          Bit 6 = Fresh Bread in Melrode Hut
//          Bit 7 = Silver Amulet in Larapool Crystal Well

// $0869DB: (Bits) Treasure Chests
//          
//          Bit 0 = Replica in Greenoch
//          Bit 1 = Honey Bread in Monastery Kitch
//          Bit 2 = Dewdrp in Monastery
//          Bit 3 = Dewdrp in Monastery
//          Bit 4 = Dewdrp in Monastery
//          Bit 5 = Fresh Bread in Dondoran Kings Room
//          Bit 6 = Fresh Bread in Dondoran Kings Room
//          Bit 7 = Dew Drop in Dondoran Kings Room

// $0869DC: (Bits) Treasure Chests
//          
//          Bit 0 = Healing Potion in Cull Hazard
//          Bit 1 = Silent Flute in Cull Hazard
//          Bit 2 = Healing Potion in Baragoon Tunnel
//          Bit 3 = Heroes Drink in Baragoon Tunnel
//          Bit 4 = Healing Potion in Baragoon Tunnel
//          Bit 5 = Replica in Baragoon Tunnel
//          Bit 6 = Dew Drop in Baragoon Tunnel
//          Bit 7 = Silver Amulet in Baragoon Tunnel

// $0869DD: (Bits) Treasure Chests
//          
//          Bit 0 = Dew Drop in Blue Cave
//          Bit 1 = Healing Potion in Blue Cave
//          Bit 2 = Heroes Drink in Blue Cave
//          Bit 3 = Healing Potion in Blue Cave
//          Bit 4 = Mint Leaves in Blue Cave
//          Bit 5 = Healing Potion in Cull Hazard
//          Bit 6 = Heroes Drink in Cull Hazard
//          Bit 7 = Honey Bread in Cull Hazard

// $0869DE: (Bits) Treasure Chests
//          
//          Bit 0 = Celine's Bell in Shamwood
//          Bit 1 = Spirit Light in Shamwood
//          Bit 2 = Replica in Shamwood
//          Bit 3 = Healing Potion in Shamwood
//          Bit 4 = Giant's Shoes in Shamwood
//          Bit 5 = Dew Drop in Shamwood
//          Bit 6 = Silver Amulet in Shamwood
//          Bit 7 = Dragon's Potion in Isle of Skye Ship

// $0869DF: (Bits) Treasure Chests
//          
//          Bit 0 = Silver Amulet in Baragoon Moore INN
//          Bit 1 = Giant's Shoes in Baragoon Moore INN
//          Bit 2 = Dragon's Potion in Baragoon Moore INN
//          Bit 3 = Replica in Baragoon Moore INN
//          Bit 4 = Celine's Bell in Baragoon Moore INN
//          Bit 5 = Golden Amulet in Lavaars Room in Shamwood
//          Bit 6 = Silent Flute in Shamwood
//          Bit 7 = Dragons Potion in Shamwood

// $0869E0: (Bits) Treasure Chests [Unused Bits]

// $0869E1: (Bits) Treasure Chests
//          
//          Bit 0 = Healing Potion in Brannoch Castle Leonardos Room
//          Bit 1 = Dew Drop in Connor Forest
//          Bit 2 = Honey Bread in Connor Forest Solverings Room
//          Bit 3 = Mint Leaves in Connor Forest Solverings Room
//          Bit 4 = Giant's Shoes in Connor Forest Hut
//          Bit 5 = Silent Flute in Glencoe Forest Cabin
//          Bit 6 = Healing Potion in Windward Forest
//          Bit 7 = Honey Bread in Windward Forest Cabin

// $0869E2: (Bits) Treasure Chests
//          
//          Bit 0 = Healing Potion in Brannoch Castle
//          Bit 1 = Deroes Drink in Brannoch Castle
//          Bit 2 = Spirit Light in Brannoch Castle Map Room
//          Bit 3 = Golden Amulet in Brannoch Castle Map Room
//          Bit 4 = Dragon's Potion in Brannoch Castle Leonardos Room
//          Bit 5 = Celine's Bell in Brannoch Castle Leonardos Room
//          Bit 6 = Spirit Light in Brannoch Castle Leonardos Room
//          Bit 7 = Silver Amulet in Brannoch Castle Leonardos Room

// $0869E3: (Bits) Treasure Chests
//          
//          Bit 0 = Healing Potion in Baragoon Tunnel
//          Bit 1 = Dragons Potion in Boil Hole
//          Bit 2 = Healing Potion in Boil Hole
//          Bit 3 = Giant's Shoes in Boil Hole
//          Bit 4 = Replica in Boil Hole
//          Bit 5 = Dragons Potion in Boil Hole
//          Bit 6 = Dragon's Potion in Brannoch Castle
//          Bit 7 = Mint Leaves in Brannoch Castle
TREASURE_CHESTS = 0x0869D8

// $086AE8: (Bits) Spirit Flags [16 bytes]
//          
//          Bit 0 = Limelin 4th Spirit
//          Bit 1 = Limelin Castle Courtyard Spirit
//          Bit 2 = Dindom Dries 1st Spirit
//          Bit 3 = Dindom Dries 2nd Spirit
//          Bit 4 = Dindom Dries 3rd Spirit
//          Bit 5 = Dindom Dries 4th Spirit
//          Bit 6 = Dindom Dries 5th Spirit
//          Bit 7 = Dindom Dries 6th Spirit

// $086AE9: (Bits) Spirit Flags
//          
//          Bit 0 = Normoon 3rd Spirit
//          Bit 1 = East Limelin 1st Spirit
//          Bit 2 = East Limelin 2nd Spirit
//          Bit 3 = East Limelin 3rd Spirit
//          Bit 4 = East Limelin 4th Spirit
//          Bit 5 = Limelin 1st Spirit
//          Bit 6 = Limelin 2nd Spirit
//          Bit 7 = Limelin 3rd Spirit

// $086AEA: (Bits) Spirit Flags
//          
//          Bit 0 = Larapool Drained 1st Spirit
//          Bit 1 = Larapool Drained 2nd Spirit
//          Bit 2 = Larapool Drained 3rd Spirit
//          Bit 3 = West Carmagh 1st Spirit
//          Bit 4 = West Carmagh 2nd Spirit
//          Bit 5 = West Carmagh 3rd Spirit
//          Bit 6 = Normoon 1st Spirit
//          Bit 7 = Normoon 2nd Spirit

// $086AEB: (Bits) Spirit Flags
//          
//          Bit 0 = Melrode town Spirit
//          Bit 1 = Monastery Spirit
//          Bit 2 = Dondoran Spirit
//          Bit 3 = Holy Planes 1st Spirit
//          Bit 4 = Holy Planes 2nd Spirit
//          Bit 5 = Dondoran Flats 1st Spirit
//          Bit 6 = Dondoran Flats 2nd Spirit
//          Bit 7 = Dondoran Flats 3rd Spirit

// $086AEC: (Bits) Spirit Flags
//          
//          Bit 0 = Baragoon Tunnel 3rd Spirit
//          Bit 1 = Baragoon Tunnel 4th Spirit
//          Bit 2 = Baragoon Tunnel 5th Spirit
//          Bit 3 = Boil Hole 1st Spirit
//          Bit 4 = Boil Hole 2nd Spirit
//          Bit 5 = Brannoch Castle 1st Spirit
//          Bit 6 = Brannoch Castle 2nd Spirit
//          Bit 7 = Connor Forest 1st Spirit

// $086AED: (Bits) Spirit Flags
//          
//          Bit 0 = Blue Cave 4th Spirit
//          Bit 1 = Blue Cave 5th Spirit
//          Bit 2 = Blue Cave 6th Spirit
//          Bit 3 = Crystal Valley Spirit
//          Bit 4 = Cull Hazard 1st Spirit
//          Bit 5 = Cull Hazard 2nd Spirit
//          Bit 6 = Baragoon Tunnel 1st Spirit
//          Bit 7 = Baragoon Tunnel 2nd Spirit

// $086AEE: (Bits) Spirit Flags
//          
//          Bit 0 = Baragoon Moor 4th Spirit
//          Bit 1 = Isle of Skye 1st Spirit
//          Bit 2 = Isle of Skye 2nd Spirit
//          Bit 3 = Isle of Skye 3rd Spirit
//          Bit 4 = Isle of Skye 4th Spirit
//          Bit 5 = Blue Cave 1st Spirit
//          Bit 6 = Blue Cave 2nd Spirit
//          Bit 7 = Blue Cave 3rd Spirit

// $086AEF: (Bits) Spirit Flags
//          
//          Bit 0 = Shamwood 1st Spirit
//          Bit 1 = Shamwood 2nd Spirit
//          Bit 2 = Shamwood 3rd Spirit
//          Bit 3 = Shamwood 4th Spirit
//          Bit 4 = Brannoch Castle Exterior Spirit
//          Bit 5 = Baragoon Moor 1st Spirit
//          Bit 6 = Baragoon Moor 2nd Spirit
//          Bit 7 = Baragoon Moor 3rd Spirit

// $086AF0: (Bits) Spirit Flags
//          
//          Bit 0 = Baragoon Moor INN Spirit
//          Bit 1 = Shamwood Interior 1st Spirit
//          Bit 2 = Shamwood Interior 2nd Spirit
//          Bit 3 = Shamwood Interior 3rd Spirit
//          Bit 4 = Shamwood Interior 4th Spirit
//          Bit 5 = Shamwood Interior 5th Spirit
//          Bit 6 = Shamdoow Interior 6th Spirit
//          Bit 7 = Isle of Sky Cabbin Spirit

// $086AF1: (Bits) Spirit Flags
//          
//          Bit 0 = Fortune Tellers Hut Spirit
//          Bit 1 = Limelin Castle 1st Spirit
//          Bit 2 = Limelin Castle 2nd Spirit
//          Bit 3 = Limelin Castle 3rd Spirit
//          Bit 4 = Limelin Prison Spirit
//          Bit 5 = Baragoon Tunnel Cabin 1st Spirit
//          Bit 6 = Baragoon Tunnel Cabin 2nd Spirit
//          Bit 7 = Desert Tent Spirit

// $086AF2: (Bits) Spirit Flags
//          
//          Bit 0 = Glencoe Forest 5th Spirit
//          Bit 1 = Glencoe Forest 6th Spirit
//          Bit 2 = Windward Forest 1st Spirit
//          Bit 3 = Windward Forest 2nd Spirit
//          Bit 4 = Windward Forest 3rd Spirit
//          Bit 5 = Windward Forest Cabin Spirit
//          Bit 6 = Dondoran Castle 1st Spirit
//          Bit 7 = Dondoran Castle 2nd Spirit

// $086AF3: (Bits) Spirit Flags
//          
//          Bit 0 = Connor Forest 2nd Spirit
//          Bit 1 = Connor Forest 3rd Spirit
//          Bit 2 = Connor Forest 4th Spirit
//          Bit 3 = Connor Forest Hut Spirit
//          Bit 4 = Glencoe Forest 1st Spirit
//          Bit 5 = Glencoe Forest 2nd Spirit
//          Bit 6 = Glencoe Forest 3rd Spirit
//          Bit 7 = Glencoe Forest 4th Spirit

// $086AF7: (Bits) Spirit Flags
//          
//          Bit 0 = Skye Ship Spirit
//          Bit 1 = Dondoran Ship Spirit
FREE_SPIRITS = 0x086AE8

// --- MAIN DATA -------------------------------------------------------------------

STATE_NORMAL = 0x0000
STATE_ITEM_MENU = 0x0001
STATE_NPC = 0x0002
STATE_SPELL_MENU = 0x0004
STATE_SPIRIT_ALLOC = 0x0008
STATE_INN = 0x0012
STATE_DOOR = 0x0080
STATE_TITLE = 0x0160
STATE_LOAD_SCREEN = 0x01E0
STATE_LOAD = 0x0480
STATE_SAVE_MENU = 0x05A0
STATE_DEATH = 0x0880

BOSS_SOLVARING = 0
BOSS_ZELSE = 1
BOSS_NEPTY = 2
BOSS_SHILF = 3
BOSS_FARGO = 4
BOSS_GUILTY = 5
BOSS_BEIGIS = 6
BOSS_MAMMON = 7

AREAS = {
	0x00: "Melrode",
	0x01: "Dondoran",
	0x02: "Holy Plain",
	0x03: "Dondoran",
	0x04: "Larapool",
	0x05: "Carmagh",
	0x06: "Normoon",
	0x07: "Limelin",
	0x08: "Limelin",
	0x09: "Dindom Dries",
	0x0A: "Shamwood",
	0x0B: "Brannoch",
	0x0C: "Isle of Skye",
	0x0D: "Melrode",
	0x0E: "Dondoran Castle",
	0x0F: "Melrode",
	0x10: "Dondoran",
	0x11: "Larapool",
	0x12: "Larapool",
	0x13: "Normoon",
	0x14: "Normoon",
	0x15: "Limelin Castle",
	0x16: "Limelin",
	0x17: "Brannoch",
	0x18: "Shamwood",
	0x19: "On the Sea",
	0x1A: "Blue Cave",
	0x1B: "Cull Hazard",
	0x1C: "Baragoon Tunnel",
	0x1D: "Boil Hole",
	0x1E: "Brannoch Castle",
	0x1F: "Connor Forest",
	0x20: "Glencoe Forest",
	0x21: "Windward Forest",
	0x22: "Mammon's Realm",
	0x23: "Under the Sea",
}

DESC_FORMAT = "Defeat {0} having never used magic or opened a chest; using Silent Flute, Celine's Bell, Replica, Giant's Shoes, Silver Amulet, or Golden Amulet is considered spell-casting by the game, and are banned"

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function boss_killed(x) => bit(x, BOSS_FLAGS) > prev(bit(x, BOSS_FLAGS))

function no_chests() => all_of(range(0,2), i => dword(TREASURE_CHESTS + i * 4) == 0)

function no_magic() => max_mp() == 15 && mp_exp() == 0

function barbarian_rules() => no_chests() && no_magic()

// --- RICH PRESENCE -------------------------------------------------------------------

function rp_hex(x) => rich_presence_lookup("Hex", x, {
	00: "0", 01: "1", 02: "2", 03: "3", 04: "4", 05: "5", 06: "6", 07: "7",
	08: "8", 09: "9", 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F",
}, fallback="0")

rich_presence_conditional_display(game_state() == STATE_TITLE,
	"💪 Brian the Barbarian is going to save the Kingdom of Celtland with just his fists 💪"
)

rich_presence_conditional_display(!no_magic(),
	"💪 BARBARIANS DON'T USE MAGIC ⚠️ ({0}, {1})",
	rich_presence_number(max_mp()),
	rich_presence_number(mp_exp())
)

rich_presence_conditional_display(!no_chests(),
	"💪 BARBARIANS DON'T OPEN CHESTS ⚠️ ({0}{1} {2}{3} {4}{5} {6}{7} {8}{9} {10}{11} {12}{13} {14}{15} {16}{17} {18}{19} {20}{21} {22}{23})",
	rp_hex(high4(TREASURE_CHESTS + 00)), rp_hex(low4(TREASURE_CHESTS + 00)),
	rp_hex(high4(TREASURE_CHESTS + 01)), rp_hex(low4(TREASURE_CHESTS + 01)),
	rp_hex(high4(TREASURE_CHESTS + 02)), rp_hex(low4(TREASURE_CHESTS + 02)),
	rp_hex(high4(TREASURE_CHESTS + 03)), rp_hex(low4(TREASURE_CHESTS + 03)),
	rp_hex(high4(TREASURE_CHESTS + 04)), rp_hex(low4(TREASURE_CHESTS + 04)),
	rp_hex(high4(TREASURE_CHESTS + 05)), rp_hex(low4(TREASURE_CHESTS + 05)),
	rp_hex(high4(TREASURE_CHESTS + 06)), rp_hex(low4(TREASURE_CHESTS + 06)),
	rp_hex(high4(TREASURE_CHESTS + 07)), rp_hex(low4(TREASURE_CHESTS + 07)),
	rp_hex(high4(TREASURE_CHESTS + 08)), rp_hex(low4(TREASURE_CHESTS + 08)),
	rp_hex(high4(TREASURE_CHESTS + 09)), rp_hex(low4(TREASURE_CHESTS + 09)),
	rp_hex(high4(TREASURE_CHESTS + 10)), rp_hex(low4(TREASURE_CHESTS + 10)),
	rp_hex(high4(TREASURE_CHESTS + 11)), rp_hex(low4(TREASURE_CHESTS + 11))
)

rich_presence_display(
	"💪 Brian the Barbarian | 🗺️ {0} | ❤️ {1} / {2} | 🛡️ {3} 🏃 {4} | 🟥 {5} 🟨 {6} 🟦 {7} 🟩 {8}",
	rich_presence_lookup("Area", map_id(), AREAS, fallback="Celtland"),

	rich_presence_number(current_hp()), rich_presence_number(max_hp()),
	rich_presence_number(defense()), rich_presence_number(agility()),
	
	rich_presence_number(fire_count()),
	rich_presence_number(earth_count()),
	rich_presence_number(water_count()),
	rich_presence_number(wind_count())
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Mirror Match",
	description=format(DESC_FORMAT, "Solvaring"),
	points=10,
	trigger=(
		map_id() == 0x1f && sub_map_id() == 0x01 &&
		boss_killed(BOSS_SOLVARING) && barbarian_rules()
	)
)

achievement(
	title="Blowhard Beatdown",
	description=format(DESC_FORMAT, "Zelse"),
	points=10,
	trigger=(
		map_id() == 0x21 && sub_map_id() == 0x00 &&
		boss_killed(BOSS_ZELSE) && barbarian_rules()
	)
)

achievement(
	title="Washed-Up Wizard",
	description=format(DESC_FORMAT, "Nepty"),
	points=10,
	trigger=(
		map_id() == 0x23 && sub_map_id() == 0x00 &&
		boss_killed(BOSS_NEPTY) && barbarian_rules()
	)
)

achievement(
	title="The Fight at the End of the Tunnel",
	description=format(DESC_FORMAT, "Shilf"),
	points=10,
	trigger=(
		map_id() == 0x1c && sub_map_id() == 0x00 &&
		boss_killed(BOSS_SHILF) && barbarian_rules()
	)
)

achievement(
	title="Fiery Temper",
	description=format(DESC_FORMAT, "Fargo"),
	points=10,
	trigger=(
		map_id() == 0x1d && sub_map_id() == 0x00 &&
		boss_killed(BOSS_FARGO) && barbarian_rules()
	)
)

achievement(
	title="Guilty of Skipping Leg Day",
	description=format(DESC_FORMAT, "Guilty"),
	points=25,
	trigger=(
		map_id() == 0x1e && sub_map_id() == 0x0a &&
		boss_killed(BOSS_GUILTY) && barbarian_rules()
	)
)

achievement(
	title="Royal Rumble",
	description=format(DESC_FORMAT, "Beigis"),
	points=25,
	trigger=(
		map_id() == 0x1e && sub_map_id() == 0x0e &&
		boss_killed(BOSS_BEIGIS) && barbarian_rules()
	)
)

achievement(
	title="BarbarBrian",
	description=format(DESC_FORMAT, "Mammon"),
	points=50,
	trigger=(
		game_state() != STATE_TITLE &&
		trigger_when(map_id() == 0x22 && boss_killed(BOSS_MAMMON)) && 
		barbarian_rules()
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------
