// La-Mulana
// #ID = 144

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $003180: [32-bit BE, ASCII] Title ID
//          Title ID as provided by Wii operating system when game is loaded
//          Gets copied to 0x364190 for North American or European versions, 0x3b0208 for Japanese version
//          "WLME" = North American version
//          "WLMJ" = Japanese version
//          "WLMP" = European version
function _32_bit_be_ascii_title_id() => dword_be(0x003180)

// $363ABC: [32-bit BE] Music ID
//          0x00 = Earth Wind
//          0x01 = LA-MULANA
//          0x02 = Mr. Explorer
//          0x03 = Xelpud
//          0x04 = BONGA WANGA
//          0x05 = Fearless Challenger (long version)
//          0x06 = Fearless Challenger
//          0x07 = Requiem
//          0x08 = King Konda
//          0x09 = Fanfare
//          0x0a = Grand History
//          0x0b = G-U-I-L-D
//          0x0c = Giant's Rage
//          0x0d = Sacred Tomb
//          0x0e = Dodge
//          0x0f = Mulbruk
//          0x10 = High-Speed Beast
//          0x11 = Curse of Ocean
//          0x12 = Wise Men
//          0x13 = Dangerous Raid
//          0x14 = Inferno
//          0x15 = M.U.
//          0x16 = Grand Ritual
//          0x17 = Primitive Dance
//          0x18 = Legendary Small Beauty
//          0x19 = Moon Light Dance
//          0x1a = Giant's Cry
//          0x1b = Eden
//          0x1c = Wonder of the Wonder
//          0x1d = GIGA-MAGMA
//          0x1e = In the bottom
//          0x1f = Mother will be awakened
//          0x20 = Sky Tower
//          0x21 = Song of Curry
//          0x22 = Ancient Machine
//          0x23 = Wise men who halts
//          0x24 = Sabbat
//          0x25 = Death Game
//          0x26 = Interstice of the Dimension
//          0x27 = Awakening
//          0x28 = Last Battle?
//          0x29 = Good Night Mom
//          0x2a = Escape!!!
//          0x2b = Run toward the sun
//          0x2c = GAME OVER
//          0x2d = Dead (SE)
//          0x2e = Fairy (SE)
//          0x2f =  Mr. Explorer (SSCC)
//          0x30 = Fearless Challenger (SSCC)
//          0x31 = Grand History (SSCC)
//          0x32 = Wonder of the Wonder (No scream)
function music_id() => dword_be(0x363ABC)

// $363B8C: [32-bit BE] In-game time (milliseconds)
function ingame_time() => dword_be(0x363B8C)

// $363BD8: [32-bit BE] Health bar length
//          0x01 when no orbs collected, increments by 1 with each Sacred Orb
function health_bar_length() => dword_be(0x363BD8)

// $363BDC: [32-bit] EXP
function exp() => dword(0x363BDC)

// $363BEC: [32-bit BE] Counter that tracks number of times weapon or subweapon used during a session
function counter_that_tracks_number_of_times_weapon_or_subweapon_used_during_a_session() => dword_be(0x363BEC)

// $363BF0: [32-bit BE] Pointer to inventory
//          
//          Mostly boolean flags to indicate possession of an item. Where noted, some values are quantities or flags that take values other than 0/1.
//          
//          This is the canonical source of inventory data that is stored in save files, other inventory data such as that displayed in the MSX inventory window is reconstructed based on this block of data when loading a saved game.
//          
//          +0x00: [16-bit BE] (unused - would be for Leather Whip)
//          +0x02: [16-bit BE] Chain Whip
//          +0x04: [16-bit BE] Flail Whip
//          +0x06: [16-bit BE] Knife
//          +0x08: [16-bit BE] Key Sword
//          +0x0a: [16-bit BE] Axe
//          +0x0c: [16-bit BE] Katana
//          +0x0e: [16-bit BE] Key Sword (empowered)
//          +0x10: [16-bit BE] Shuriken
//          +0x12: [16-bit BE] Rolling Shuriken
//          +0x14: [16-bit BE] Earth Spear
//          +0x16: [16-bit BE] Flare Gun
//          +0x18: [16-bit BE] Bomb
//          +0x1a: [16-bit BE] Chakram
//          +0x1c: [16-bit BE] Caltrops
//          +0x1e: [16-bit BE] Pistol
//          +0x20: [16-bit BE] Buckler
//          +0x22: [16-bit BE] Silver Shield
//          +0x24: [16-bit BE] Angel Shield
//          +0x26: [16-bit BE] Ankh Jewels (quantity)
//          +0x28: [16-bit BE] Hand Scanner
//          +0x2a: [16-bit BE] Djed Pilar
//          +0x2c: [16-bit BE] Mini Doll
//          +0x2e: [16-bit BE] Magatama Jewel
//          +0x30: [16-bit BE] Cog of the Soul
//          +0x32: [16-bit BE] Lamp of Time
//          +0x34: [16-bit BE] Pochette Key
//          +0x36: [16-bit BE] Dragon Bone (0x9d)
//          +0x38: [16-bit BE] Crystal Skull
//          +0x3a: [16-bit BE] Vessel
//          +0x3c: [16-bit BE] Pepper
//          +0x3e: [16-bit BE] Woman Statue
//          +0x40: [16-bit BE] Key of Eternity
//          +0x42: [16-bit BE] Serpent Staff
//          +0x44: [16-bit BE] Talisman
//          +0x46: [16-bit BE] (unused - would be for Mobile Super X)
//          +0x48: [16-bit BE] Waterproof Case
//          +0x4a: [16-bit BE] Heatproof Case
//          +0x4c: [16-bit BE] Shell Horn
//          +0x4e: [16-bit BE] Glove
//          +0x50: [16-bit BE] Holy Grail
//          +0x52: [16-bit BE] Isis' Pendant
//          +0x54: [16-bit BE] Crucifix
//          +0x56: [16-bit BE] Helmet
//          +0x58: [16-bit BE] Grapple Claw
//          +0x5a: [16-bit BE] Bronze Mirror
//          +0x5c: [16-bit BE] Eye of Truth
//          +0x5e: [16-bit BE] Ring
//          +0x60: [16-bit BE] Scalesphere
//          +0x62: [16-bit BE] Gauntlet
//          +0x64: [16-bit BE] Anchor
//          +0x66: [16-bit BE] Plane Model
//          +0x68: [16-bit BE] Philosopher's Ocarina
//          +0x6a: [16-bit BE] Feather
//          +0x6c: [16-bit BE] Book of the Dead
//          +0x6e: [16-bit BE] Fairy Clothes
//          +0x70: [16-bit BE] Scriptures
//          +0x72: [16-bit BE] Hermes' Boots
//          +0x74: [16-bit BE] Fruit of Eden
//          +0x76: [16-bit BE] Twin Statue
//          +0x78: [16-bit BE] Bracelet
//          +0x7a: [16-bit BE] Perfume
//          +0x7c: [16-bit BE] Spaulder
//          +0x7e: [16-bit BE] Dimensional Key
//          +0x80: [16-bit BE] Ice Cape
//          +0x82: [16-bit BE] Origin Seal
//          +0x84: [16-bit BE] Birth Seal
//          +0x86: [16-bit BE] Life Seal
//          +0x88: [16-bit BE] Death Seal
//          +0x8a: [16-bit BE] (unused - would be for Sacred Orb)
//          +0x8c: [16-bit BE] Maps (quantity)
//          +0x8e: [16-bit BE] Treasures
//          +0x90: [16-bit BE] Diary
//          +0x92: [16-bit BE] Mulana Talisman
//          +0x94: [16-bit BE] Provocative Bathing Suit
//          +0x96: [16-bit BE] Silver Shield (fake)
//          +0x98: [16-bit BE] Mobile Super X2
//          +0x9a: [16-bit BE] Medicine of the Mind (yellow)
//          +0x9c: [16-bit BE] Medicine of the Mind (green)
//          +0x9e: [16-bit BE] Medicine of the Mind (red)
//          +0xa0: [16-bit BE] Lamp of Time (uncharged)
//          +0xa2: [16-bit BE] Maternity Statue
//          +0xa4: [16-bit BE] Holy Grail (broken)
//          +0xa6: [16-bit BE] Holy Grail (empowered)
//          +0xa8: [16-bit BE] Secret Treasure of Life
//          +0xaa: [16-bit BE] Glyph Reader
//          +0xac: [16-bit BE] Xelpud Mailer
//          +0xae: [16-bit BE] Yagoo Map Reader
//          +0xb0: [16-bit BE] Yagoo Map Street
//          +0xb2: [16-bit BE] TextTrax
//          +0xb4: [16-bit BE] Additional Text Memory
//          +0xb6: [16-bit BE] Snapshots
//          +0xb8: [16-bit BE] Guild
//          +0xba: [16-bit BE] Mantra
//          +0xbc: [16-bit BE] Enga Musica
//          +0xbe: [16-bit BE] Beo La-Mulana
//          +0xc0: [16-bit BE] Death Village
//          +0xc2: [16-bit BE] Rose and Camellia
//          +0xc4: [16-bit BE] Space Capster II
//          +0xc6: [16-bit BE] Lonely House Moving
//          +0xc8: [16-bit BE] Mekuri Master
//          +0xca: [16-bit BE] Bounce Shot
//          +0xcc: [16-bit BE] Miracle Witch
//          +0xce: [16-bit BE] Future Development Company
//          +0xd0: [16-bit BE] La-Mulana
//          -- Quantities --
//          +0xd2: [16-bit BE] Weights
//          +0xd4: [16-bit BE] Coins
//          +0xd6: [16-bit BE] Subweapon ammo - Shuriken
//          +0xd8: [16-bit BE] Subweapon ammo - Rolling Shuriken
//          +0xda: [16-bit BE] Subweapon ammo - Earth Spear
//          +0xdc: [16-bit BE] Subweapon ammo - Flare Gun
//          +0xde: [16-bit BE] Subweapon ammo - Bomb
//          +0xe0: [16-bit BE] Subweapon ammo - Chakram
//          +0xe2: [16-bit BE] Subweapon ammo - Caltrops
//          +0xe4: [16-bit BE] Subweapon ammo - Pistol (clips)
//          +0xe8: [16-bit BE] Subweapon ammo - Pistol (rounds)
function inventory(i) => word_be((dword_be(0x363BF0) & 0x1FFFFFFF) + i*2)

// $363C14: [32-bit BE] RAM usage of current software loadout
function ram_usage_of_current_software_loadout() => dword_be(0x363C14)

// $363C20: [32-bit BE] Pointer to  Xelpud email timestamps
//          +0x00: [180 bytes, 32-bit BE values] Array of timestamps (in milliseconds), ordered from bottom of inbox to top
function pointer_to_xelpud_email_timestamps() => dword_be(0x363C20)

// $363C24: [32-bit BE] Pointer to Xelpud email sort order
//          +0x00: [180 bytes, 32-bit BE values] Array of email numbers (0-44), from bottom of inbox to top. 0xffff for slots for which no email has been received yet.
function pointer_to_xelpud_email_sort_order() => dword_be(0x363C24)

// $363C95: [8-bit] Map flags
//          Bit0 = Chamber of Birth
//          Bit1 = Dimensional Corridor
function map_flags() => byte(0x363C95)

// $363C96: [8-bit] Map flags
//          Bit0 = Endless Corridor
//          Bit1 = Shrine of the Mother
//          Bit2 = Gate of Illusion
//          Bit3 = Graveyard of the Giants
//          Bit4 = Temple of Moonlight
//          Bit5 = Tower of the Goddess
//          Bit6 = Tower of Ruin
//          Bit7 = (unused)
function map_flags_2() => byte(0x363C96)

// $363C97: [8-bit] Map flags
//          Bit0 = Gate of Guidance
//          Bit1 = Surface
//          Bit2 = Mausoleum of the Giants
//          Bit3 = Temple of the Sun
//          Bit4 = Spring in the Sky
//          Bit5 = Inferno Cavern
//          Bit6 = Chamber of Extinction
//          Bit7 = Twin Labyrinths
function map_flags_3() => byte(0x363C97)

// $363CC4: [32-bit BE] Pointer to inventory data (MSX)
//          
//          This block of data controls which items are displayed/selectable on the inventory screen of the MSX, as well as which weapons and held items Lemeza currently has equipped.
//          
//          +0x00: [8-bit] Whip
//          | .... 0x00 = Leather Whip
//          | .... 0x01 = Chain Whip
//          | .... 0x02 = Flail Whip
//          +0x01: [8-bit] Knife
//          | .... 0x03 = Knife
//          | .... 0x0ff = Empty
//          +0x02: [8-bit]  Key Sword
//          | .... 0x04 = Key Sword
//          | .... 0xff = Empty
//          +0x03: [8-bit]  Axe
//          | .... 0x05 = Axe
//          | .... 0xff = Empty
//          +0x04: [8-bit]  Katana
//          | .... 0x06 = Katana
//          | .... 0xff = Empty
//          +0x05: [8-bit] Selected weapon - item ID
//          | .... 0x00 = Whip
//          | .... 0x01 = Chain Whip
//          | .... 0x02 = Flail Whip
//          | .... 0x03 = Knife
//          | .... 0x04 = Key Sword
//          | .... 0x05 = Axe
//          | .... 0x06 = Katana
//          +0x06: [8-bit] Selected weapon - index
//          | .... 0x00 = Whip
//          | .... 0x01 = Knife
//          | .... 0x02 = Key Sword
//          | .... 0x03 = Axe
//          | .... 0x04 = Katana
//          +0x07: [8-bit] Shuriken
//          | .... 0x08 = Shuriken
//          | .... 0xff = Empty
//          +0x08: [8-bit] Rolling Shuriken
//          | .... 0x09 = Rolling Shuriken
//          | .... 0xff = Empty
//          +0x09: [8-bit] Earth Spear
//          | .... 0x0a = Earth Spear
//          | .... 0xff = Empty
//          +0x0a: [8-bit] Flare Gun
//          | .... 0x0b = Flare Gun
//          | .... 0xff = Empty
//          +0x0b: [8-bit] Bomb
//          | .... 0x0c = Bomb
//          | .... 0xff = Empty
//          +0x0c: [8-bit] Chakram
//          | .... 0x0d = Chakram
//          | .... 0xff = Empty
//          +0x0d: [8-bit] Caltrops
//          | .... 0x0e = Caltrops
//          | .... 0xff = Empty
//          +0x0e: [8-bit] Pistol
//          | .... 0x0f = Pistol
//          | .... 0xff = Empty
//          +0x0f: [8-bit] Shield
//          | .... 0x10 = Buckler
//          | .... 0x11 = Silver Shield
//          | .... 0x12 = Angel Shield
//          | .... 0x4b = Silver Sield (fake)
//          | .... 0xff = Empty
//          +0x10: [8-bit] Ankh Jewel
//          | .... 0x13 = Ankh Jewel
//          | .... 0xff = Empty
//          +0x1b: [8-bit] Selected subweapon - item ID
//          | .... 0x08 = Shuriken
//          | .... 0x09 = Rolling Shuriken
//          | .... 0x0a = Earth Spear
//          | .... 0x0b = Flare Gun
//          | .... 0x0c = Bomb
//          | .... 0x0d = Chakram
//          | .... 0x0e = Caltrops
//          | .... 0x0f = Pistol
//          | .... 0x10 = Buckler
//          | .... 0x11 = Silver Shield
//          | .... 0x12 = Angel Shield
//          | .... 0x13 = Ankh Jewel
//          | .... 0x4b = Silver Shield (fake)
//          +0x1c: [8-bit] Selected subweapon - index
//          | .... 0x00 = Shuriken
//          | .... 0x01 = Rolling Shuriken
//          | .... 0x02 = Earth Spear
//          | .... 0x03 = Flare Gun
//          | .... 0x04 = Bomb
//          | .... 0x05 = Chakram
//          | .... 0x06 = Caltrops
//          | .... 0x07 = Pistol
//          | .... 0x08 = Shield
//          | .... 0x09 = Ankh Jewel
//          +0x1d: [8-bit] Hand Scanner
//          | .... 0x14 = Hand Scanner
//          | .... 0xff = Empty
//          +0x1e: [8-bit] Djed Pilar
//          | .... 0x15 = Djed Pilar
//          | .... 0xff = Empty
//          +0x1f: [8-bit] Mini Doll
//          | .... 0x15 = Mini Doll
//          | .... 0xff = Empty
//          +0x20: [8-bit] Magatama Jewel
//          | .... 0x17 = Magatama Jewel
//          | .... 0xff = Empty
//          +0x21: [8-bit] Cog of the Soul
//          | .... 0x18 = Cog of the Soul
//          | .... 0xff = Empty
//          +0x22: [8-bit] Lamp of Time
//          | .... 0x19 = Lamp of Time (charged)
//          | .... 0x50 = Lamp of Time (empty)
//          | .... 0xff = Empty
//          +0x23: [8-bit] Pochette Key
//          | .... 0x1a = Pochette Key
//          | .... 0xff = Empty
//          +0x24: [8-bit] Dragon Bone
//          | .... 0x1b = Dragon Bone
//          | .... 0xff = Empty
//          +0x25: [8-bit] Crystal Skull
//          | .... 0x1c = Crystal Skull
//          | .... 0xff = Empty
//          +0x26: [8-bit] Vessel
//          | .... 0x1d = Vessel (empty)
//          | .... 0x4d = Medicine of the Mind (yellow)
//          | .... 0x4e = Medicine of the Mind (green)
//          | .... 0x4f = Medicine of the Mind (red)
//          | .... 0xff = Empty
//          +0x27: [8-bit] Pepper
//          | .... 0x1e = Pepper
//          | .... 0xff = Empty
//          +0x28: [8-bit] Woman Statue
//          | .... 0x1f = Woman Statue
//          | .... 0x51 = Maternity Statue
//          | .... 0xff = Empty
//          +0x29: [8-bit] Key of Eternity
//          | .... 0x20 = Key of Eternity
//          | .... 0xff = Empty
//          +0x2a: [8-bit] Serpent Staff
//          | .... 0x21 = Serpent Staff
//          | .... 0xff = Empty
//          +0x2b: [8-bit] Talisman
//          | .... 0x22 = Talisman
//          | .... 0x48 = Diary
//          | .... 0x49 = Mulana Talisman
//          | .... 0xff = Empty
//          +0x2c: [8-bit] Selected hold item - item ID
//          | .... 0x14 = Hand Scanner
//          | .... 0x15 = Djed Pilar
//          | .... 0x16 = Mini Doll
//          | .... 0x17 = Magatama Jewel
//          | .... 0x18 = Cog of the Soul
//          | .... 0x19 = Lamp of Time (charged)
//          | .... 0x1a = Pochette Key
//          | .... 0x1b = Dragon Bone
//          | .... 0x1c = Crystal Skull
//          | .... 0x1d = Vessel (empty)
//          | .... 0x1e = Pepper
//          | .... 0x1f = Woman Statue
//          | .... 0x20 = Key of Eternity
//          | .... 0x21 = Serpent Staff
//          | .... 0x22 = Talisman
//          | .... 0x48 = Diary
//          | .... 0x49 = Mulana Talisman
//          | .... 0x4d = Vessel (yellow)
//          | .... 0x4e = Vessel (green)
//          | .... 0x4f = Vessel (red)
//          | .... 0x50 = Lamp of Time (empty)
//          | .... 0x51 = Maternity Statue
//          +0x2d: [8-bit] Selected hold item - index
//          +0x2f: [8-bit] Laptop
//          | .... 0x23 = Mobile Super X
//          | .... 0x4c = Mobile Super X2
//          | .... 0xff = Empty
//          +0x30: [8-bit] Waterproof Case
//          | .... 0x24 = Waterproof Case
//          | .... 0xff = Empty
//          +0x31: [8-bit] Heatproof Case
//          | .... 0x25 = Heatproof Case
//          | .... 0xff = Empty
//          +0x32: [8-bit] Shell Horn
//          | .... 0x26 = Shell Horn
//          | .... 0xff = Empty
//          +0x33: [8-bit] Glove
//          | .... 0x27 = Glove
//          | .... 0xff = Empty
//          +0x34: [8-bit] Grail
//          | .... 0x28 = Holy Grail
//          | .... 0x52 = Holy Grail (broken)
//          | .... 0x53 = Holy Grail (empowered)
//          | .... 0xff = Empty
//          +0x35: [8-bit] Pendant
//          | .... 0x29 = Isis' Pendant
//          | .... 0xff = Empty
//          +0x36: [8-bit] Crucifix
//          | .... 0x2a = Crucifix
//          | .... 0xff = Empty
//          +0x37: [8-bit] Helmet
//          | .... 0x2b = Helmet
//          | .... 0xff = Empty
//          +0x38: [8-bit] Grapple Claw
//          | .... 0x2c = Grapple Claw
//          | .... 0xff = Empty
//          +0x39: [8-bit] Bronze Mirror
//          | .... 0x2d = Bronze Mirror
//          | .... 0xff = Empty
//          +0x3a: [8-bit] Eye of Truth
//          | .... 0x2e = Eye of Truth
//          | .... 0xff = Empty
//          +0x3b: [8-bit] Ring
//          | .... 0x2f = Ring
//          | .... 0xff = Empty
//          +0x3c: [8-bit] Scalesphere
//          | .... 0x30 = Scalesphere
//          | .... 0xff = Empty
//          +0x3d: [8-bit] Gauntlet
//          | .... 0x31 = Gauntlet
//          | .... 0xff = Empty
//          +0x3e: [8-bit] Mr. Slushfund's Goodies
//          | .... 0x32 = Anchor
//          | .... 0x47 = Treasures
//          | .... 0xff = Empty
//          +0x3f: [8-bit] Plane Model
//          | .... 0x33 = Plane Model
//          | .... 0xff = Empty
//          +0x40: [8-bit] Ocarina
//          | .... 0x34= Philosopher's Ocarina
//          | .... 0xff = Empty
//          +0x41: [8-bit] Feather
//          | .... 0x35 = Feather
//          | .... 0xff = Empty
//          +0x42: [8-bit] Book of the Dead
//          | .... 0x36 = Book of the Dead
//          | .... 0xff = Empty
//          +0x43: [8-bit] Fairy Clothes
//          | .... 0x37 = Fairy Clothes
//          | .... 0xff = Empty
//          +0x44: [8-bit] Scriptures
//          | .... 0x38 = Scriptures
//          | .... 0xff = Empty
//          +0x45: [8-bit] Boots
//          | .... 0x39 = Hermes' Boots
//          | .... 0xff = Empty
//          +0x46: [8-bit] Fruit
//          | .... 0x3a = Fruit of Eden
//          | .... 0xff = Empty
//          +0x47: [8-bit] Twin Statue
//          | .... 0x3b = Twin Statue
//          | .... 0xff = Empty
//          +0x48: [8-bit] Bracelet
//          | .... 0x3c = Bracelet
//          | .... 0xff = Empty
//          +0x49: [8-bit] Perfume
//          | .... 0x3d = Perfume
//          | .... 0xff = Empty
//          +0x4a: [8-bit] Spaulder
//          | .... 0x3e = Spaulder
//          | .... 0xff = Empty
//          +0x4b: [8-bit] Dimensional Key
//          | .... 0x3f = Dimensional Key
//          | .... 0xff = Empty
//          +0x4c: [8-bit] Ice Cape
//          | .... 0x40 = Ice Cape
//          | .... 0xff = Empty
//          +0x4d: [8-bit] Origin Seal
//          | .... 0x41 = Origin Seal
//          | .... 0xff = Empty
//          +0x4e: [8-bit] Birth Seal
//          | .... 0x42 = Birth Seal
//          | .... 0xff = Empty
//          +0x4f: [8-bit] Life Seal
//          | .... 0x43 = Life Seal
//          | .... 0xff = Empty
//          +0x50: [8-bit] Death Seal
//          | .... 0x44 = Death Seal
//          | .... 0xff = Empty
//          +0x51: [8-bit] Secret Treasure of Life
//          | .... 0x54 = Secret Treasure of Life
//          | .... 0xff = Empty
function pointer_to_inventory_data() => dword_be(0x363CC4)

// $363E88: [16-bit BE] Used when allocating object data
//          Newly created object is placed at *0xe363e7c + this_value * 0x33c
function used_when_allocating_object_data() => word_be(0x363E88)

// $363E8A: [16-bit BE] Number of sprites(?) or objects(?) on screen
//          Cannot exceed 0x7f, as seen by spamming caltrops before a Viy beam
function number_of_spritesor_objectson_screen() => word_be(0x363E8A)

// $363EE0: [8-bit] Index (not-actually-a pointer) for controller input ring buffer
//          Increments every frame, counts 0-7
//          +0x3c3db0: [32-bit BE] Controller input
//          | .... Bit2 = Left
//          | .... Bit3 = Right
function index_notactuallya_pointer_for_controller_input_ring_buffer() => byte(0x363EE0)

// $363F60: [32-bit BE] Pointer to Lemeza data
//          +0x01c: [32-bit BE] Movement state
//          | ..... 0x00 = Falling
//          | ..... 0x01 = Grounded
//          | ..... 0x02 = Climbing ladder
//          | ..... 0x03 = Dismounting ladder
//          | ..... 0x04 = Mounting ladder
//          | ..... 0x05 = Starting jump
//          | ..... 0x06 = Jumping
//          | ..... 0x08 = Turned sideways on ladder
//          | ..... 0x09 = In knockback
//          | ..... 0x0a = Grapple (facing left)
//          | ..... 0x0b = Grapple (facing right)
//          | ..... 0x0f = Flying plane
//          | ..... 0x10 = Plane knockback
//          | ..... 0xe8 = Dying
//          +0x034: [32-bit BE] Double jump state
//          | ..... Goes to 0x00 when jump starts, 0x01 when double jump used (value persists upon landing until next jump)
//          +0x044: [32-bit BE] Swim state
//          | ..... 0x00 = On land
//          | ..... 0x01 = Swimming
//          +0x048: [32-bit BE] Fluid medium that Lemeza currently inhabits
//          | ..... 0x00 = Air
//          | ..... 0x01 = Water
//          | ..... 0x02 = Lava
//          +0x06c: [32-bit BE] Screen transition flag
//          +0x070: [32-bit BE] Gaunlet effect flag
//          +0x074: [32-bit BE] Weapon ID for last swing (when spaulder is in inventory)
//          +0x07c: [32-bit BE] Weapon swing counter
//          +0x160: [Float BE] y-velocity (falling)
//          +0x164: [Float BE] y-velocity (jumping)
//          +0x184: [Float BE] x-velocity
//          +0x1e0: [Float BE] x-coordinate
//          +0x1e4: [Float BE] y-coordinate
//          +0x204: [32-bit BE] Health
//          +0x2ec: [32-bit BE] Pointer to weapon object data (null when no weapon being swung)
//          ++0x00: [32-bit BE] Function pointer - damage calculation function
function pointer_to_lemeza_data() => dword_be(0x363F60)
function health() => dword_be((pointer_to_lemeza_data() & 0x1FFFFFFF) + 0x000204)

// $363FB9: [8-bit] Weapon being used
//          Takes on a nonzero value for a few frames during Lemeza's weapon swing animation
//          0x00 = (nothing)
//          0x01 = Leather whip
//          0x02 = Chain whip
//          0x03 = Flail whip
//          0x04 = Knife
//          0x05 = Key Sword
//          0x06 = Axe
//          0x07 = Katana
function weapon_being_used() => byte(0x363FB9)

// $363FBB: [8-bit] Subweapon being used
//          Takes on a nonzero value for a few frames during Lemeza's throwing/shooting animation
//          0x00 = (nothing)
//          0x08 = Shuriken
//          0x09 = Rolling shuriken
//          0x0a = Earth spear
//          0x0b = Flare gun
//          0x0c = Bomb
//          0x0d = Chakram
//          0x0e = Caltrops
//          0x0f = Pistol
//          0x10 = Buckler
//          0x11 = Silver shield
//          0x12 = Angel shield
//          0x13 = Ankh jewel
//          0x4b = Silver shield (fake)
function subweapon_being_used() => byte(0x363FBB)

// $363FD0: [8-bit] Field ID
//          0x00 = Gate of Guidance
//          0x01 = Surface
//          0x02 = Mausoleum of the Giants
//          0x03 = Temple of the Sun
//          0x04 = Spring in the Sky
//          0x05 = Inferno Cavern
//          0x06 = Chamber of Extinction
//          0x07 = Twin Labyrinths
//          0x08 = Endless Corridor
//          0x09 = Shrine of the Mother
//          0x0a = Gate of Illusion
//          0x0b = Graveyard of the Giants
//          0x0c = Temple of Moonlight
//          0x0d = Tower of the Goddess
//          0x0e = Tower of Ruin
//          0x0f = Chamber of Birth (upper)
//          0x10 = Chamber of Birth (lower)
//          0x11 = Dimensional Corridor
//          0x12 = True Shrine of the Mother
//          0x13 = Gate of Time - Mausoleum
//          0x14 = Gate of Time - Guidance
//          0x15 = Gate of Time - Surface
//          0xff = Title screen / Game over
function field_id() => byte(0x363FD0)

// $363FD1: [8-bit] Room ID
//          Should be paired with screen ID since some some rooms use different names for different screens.
//          List of combined room/screen IDs:
//          
//          -- 0x00: Gate of Guidance --
//          0x0000 = Pillars Gate
//          0x0001 = Pillars Gate
//          0x0100 = Heavenly Temple of the Cross
//          0x0101 = Heavenly Temple of the Cross
//          0x0200 = Room of Courage
//          0x0201 = Room of Courage
//          0x0300 = Heavenly Corridor
//          0x0301 = Heavenly Corridor
//          0x0400 = Pit of the Holy Grail
//          0x0401 = Pit of the Holy Grail
//          0x0402 = Pit of the Holy Grail
//          0x0500 = Door to Eden
//          0x0600 = Gate of Giant Faces
//          0x0601 = Room of the Strong
//          0x0700 = Monument of Oannes
//          0x0701 = Cliff of Radiance
//          0x0800 = Snake's Sanctuary
//          0x0801 = Snake's Sanctuary
//          0x0900 = Monument of Time
//          0x0901 = Monument of Time
//          
//          -- 0x01: Surface --
//          0x0000 = Altar Hill
//          0x0001 = Altar Hill
//          0x0002 = Altar Hill
//          0x0100 = Cliff in front of the Altar
//          0x0101 = Cliff in front of the Altar
//          0x0200 = Village of Departure
//          0x0201 = Village of Departure
//          0x0300 = Gate of Departure
//          0x0400 = Sound Canyon
//          0x0401 = Sound Canyon
//          0x0402 = Sound Canyon
//          0x0500 = Gazing Hill
//          0x0501 = Gazing Hill
//          0x0502 = Underground Passage
//          0x0600 = Bahrun's Waterfall
//          0x0601 = Bahrun's Waterfall
//          0x0700 = Bahrun's Waterfall
//          0x0701 = Bahrun's Waterfall
//          0x0800 = Waterfall of the Goddess
//          0x0801 = Waterfall of the Goddess
//          0x0900 = Outskirts of the village
//          0x0901 = Outskirts of the village
//          0x0a00 = Foothill
//          0x0a01 = Foothill
//          0x0a02 = Foothill
//          0x0a03 = Gate of Departure
//          0x0b00 = Mother's Split Gate
//          0x0b01 = Entrance to La-Mulana Ruins
//          
//          -- 0x02: Mausoleum of the Giants --
//          0x0000 = Last Shrine
//          0x0001 = Last Shrine
//          0x0100 = Approach of the Giants
//          0x0101 = Approach of the Giants
//          0x0200 = Room of Redemption
//          0x0201 = Room of Redemption
//          0x0300 = Shrine of the Giants
//          0x0400 = Zebu's Room
//          0x0500 = Shaft to the Heavens
//          0x0501 = Shaft to the Heavens
//          0x0502 = Shaft to the Heavens
//          0x0600 = Monument to Hermes
//          0x0601 = Dolphin's Room
//          0x0700 = Star Palace of the Giants
//          0x0701 = Star Palace of the Giants
//          0x0702 = Star Palace of the Giants
//          0x0800 = Moon Palace of the Giants
//          0x0801 = Moon Palace of the Giants
//          0x0802 = Moon Palace of the Giants
//          0x0900 = Nebra Sky Disk
//          
//          -- 0x03: Temple of the Sun --
//          0x0000 = Watchtower
//          0x0001 = Watchtower
//          0x0100 = Hathor's Room
//          0x0101 = Altar of War
//          0x0102 = Altar of War
//          0x0200 = Isis' Room
//          0x0201 = Isis' Antechamber
//          0x0300 = Thoth's Room
//          0x0400 = Great Colonnade, Left-side room
//          0x0401 = Sun Pyramid
//          0x0402 = Great Colonnade, Right-side room
//          0x0403 = Great Colonnade, Left-side room
//          0x0404 = Sun Pyramid: Burial Chamber
//          0x0405 = Great Colonnade, Right-side room
//          0x0500 = Altar of Mirrors
//          0x0600 = Sanctuary
//          0x0601 = Sanctuary
//          0x0700 = Horus' Room of Pillars
//          0x0701 = Horus' Room of Pillars
//          0x0800 = Aten's Room
//          
//          -- 0x04: Spring in the Sky --
//          0x0000 = Mural of Oannes
//          0x0001 = Mural of Oannes
//          0x0002 = Mural of Oannes
//          0x0100 = Goddess' Water Jug
//          0x0200 = Sacred Lake
//          0x0201 = Goddess' Water Jug
//          0x0300 = Waterfall Approach
//          0x0301 = Waterfall Approach
//          0x0302 = Waterfall Approach
//          0x0303 = Waterfall Approach
//          0x0304 = Waterfall Approach
//          0x0400 = Sanctuary
//          0x0500 = Room of Origin
//          0x0501 = Room of Origin
//          0x0600 = Mirror Waterfall
//          0x0601 = Mirror Waterfall
//          0x0700 = Oannes' Waterfall
//          0x0701 = Oannes' Waterfall
//          0x0800 = Anunnaki's Stone Basin
//          0x0801 = Anunnaki's Stone Basin
//          
//          -- 0x05: Inferno Cavern --
//          0x0000 = Statue of the Giant
//          0x0001 = Statue of the Giant
//          0x0100 = Twin's Footstool
//          0x0101 = Twin's Footstool
//          0x0200 = Pit of Fire
//          0x0201 = Pit of Fire
//          0x0202 = Pit of Fire
//          0x0300 = Pylon of Power
//          0x0301 = Pazuzu's Room
//          0x0302 = Pazuzu's Room
//          0x0400 = Serdab of Light
//          0x0500 = Antechamber
//          0x0501 = Antechamber
//          0x0600 = Hall of Worship
//          0x0700 = Treasury of Ice
//          0x0701 = Treasury of Ice
//          0x0800 = Darkness Sanctuary
//          0x0801 = Darkness Sanctuary
//          0x0900 = Echidna's Chamber
//          0x0901 = Echidna's Chamber
//          
//          -- 0x06: Chamber of Extinction --
//          0x0000 = Approach to the Sanctuary
//          0x0001 = Approach to the Sanctuary
//          0x0100 = Gate of Ox-Head and Horse-Face
//          0x0101 = Gate of Ox-Head and Horse-Face
//          0x0200 = Mural of Invocation
//          0x0201 = Mural of Invocation
//          0x0300 = Darkness Approach
//          0x0301 = Darkness Approach
//          0x0400 = Mural Depicting the Power of Words
//          0x0401 = Mural Depicting the Power of Words
//          0x0500 = Side path
//          0x0501 = Side path
//          0x0600 = Mural of Light
//          0x0601 = Mural of Light
//          0x0700 = Path of Life
//          0x0701 = Lake of Life
//          0x0800 = Shiva's Crucifix
//          0x0801 = Shiva's Crucifix
//          0x0900 = Antechamber
//          0x0901 = Palenque's Coffin
//          
//          -- 0x07: Twin Labyrinths --
//          0x0000 = Hero's Approach
//          0x0001 = Hero's Approach
//          0x0100 = Sanctuary
//          0x0101 = Sanctuary
//          0x0200 = Zodiac
//          0x0201 = Zodiac
//          0x0202 = Zodiac
//          0x0300 = Twin's Surrounding Wall
//          0x0301 = Twin's Surrounding Wall
//          0x0302 = Twin's Surrounding Wall
//          0x0400 = Demon Altar
//          0x0401 = Demon Altar
//          0x0500 = Zu's Room
//          0x0501 = Zu's Room
//          0x0600 = Treasury
//          0x0601 = Treasury
//          0x0700 = Idigna's Room
//          0x0701 = Idigna's Room
//          0x0800 = Hero's Surrounding Wall
//          0x0801 = Hero's Surrounding Wall
//          0x0900 = Hero's Approach
//          0x0901 = Hero's Approach
//          0x0a00 = Sanctuary
//          0x0a01 = Sanctuary
//          0x0b00 = Zodiac
//          0x0b01 = Zodiac
//          0x0b02 = Zodiac
//          0x0c00 = Twin's Surrounding Wall
//          0x0c01 = Twin's Surrounding Wall
//          0x0c02 = Twin's Surrounding Wall
//          0x0d00 = Demon Altar
//          0x0d01 = Demon Altar
//          0x0e00 = Treasury
//          0x0e01 = Treasury
//          0x0f00 = Hero's Surrounding Wall
//          0x0f01 = Hero's Surrounding Wall
//          0x0f02 = Buranun's Room
//          0x1000 = Peryton's Room
//          0x1001 = Poseidon's Room
//          0x1002 = Poseidon's Room
//          
//          -- 0x08: Endless Corridor --
//          0x0000 = First Endless Corridor
//          0x0001 = First Endless Corridor
//          0x0100 = First Endless Corridor
//          0x0101 = First Endless Corridor
//          0x0200 = Second Endless Corridor
//          0x0201 = Second Endless Corridor
//          0x0202 = Second Endless Corridor
//          0x0203 = Second Endless Corridor
//          0x0300 = Third Endless Corridor
//          0x0301 = Third Endless Corridor
//          0x0302 = Third Endless Corridor
//          0x0303 = Third Endless Corridor
//          0x0400 = Fourth Endless Corridor
//          0x0401 = Fourth Endless Corridor
//          0x0402 = Fourth Endless Corridor
//          0x0403 = Fourth Endless Corridor
//          0x0500 = Fifth Endless Corridor
//          0x0501 = Fifth Endless Corridor
//          0x0502 = Fifth Endless Corridor
//          0x0503 = Fifth Endless Corridor
//          
//          -- 0x09: Shrine of the Mother --
//          0x0000 = Amphisbaena's Room
//          0x0001 = Amphisbaena's Room
//          0x0100 = Sakit's Room
//          0x0101 = Sakit's Room
//          0x0200 = Ellmac's Room
//          0x0201 = Ellmac's Room
//          0x0300 = Home of the Mother
//          0x0301 = Tiamat's Room
//          0x0400 = Baphomet's Room
//          0x0401 = Baphomet's Room
//          0x0500 = Palenque's Room
//          0x0501 = Palenque's Room
//          0x0600 = Viy's Room
//          0x0601 = Viy's Room
//          0x0700 = Beelzebub's Room
//          0x0701 = Beelzebub's Room
//          0x0800 = Bahamut's Room
//          0x0801 = Bahamut's Room
//          0x0900 = Treasury
//          0x0901 = Treasury
//          
//          -- 0x0a: Gate of Illusion --
//          0x0000 = Bird's Room
//          0x0001 = Cog of Life
//          0x0100 = Children's Room
//          0x0101 = Children's Room
//          0x0200 = Sacrificial Abyss
//          0x0201 = Sacrificial Abyss
//          0x0202 = Chi You's Room
//          0x0300 = Doorway to Guidance
//          0x0400 = Chapel
//          0x0401 = Chapel
//          0x0500 = Lizard's Room
//          0x0501 = Lizard's Room
//          0x0600 = Mausoleum of Fairies
//          0x0700 = Fool's Confusion Corridor
//          0x0701 = Fool's Confusion Corridor
//          0x0702 = Fool's Confusion Corridor
//          0x0800 = Sacred Lake of the Sky
//          0x0801 = Sacred Lake of the Sky
//          0x0900 = Entrance of Illusion
//          0x0901 = Entrance of Illusion
//          
//          -- 0x0b: Graveyard of the Giants --
//          0x0000 = First Tomb
//          0x0001 = First Tomb
//          0x0002 = First Tomb
//          0x0100 = White Silver Altar
//          0x0101 = White Silver Altar
//          0x0200 = Second Tomb
//          0x0201 = Second Tomb
//          0x0300 = Abuto's Tomb
//          0x0400 = Path to the Graveyard
//          0x0401 = Path to the Graveyard
//          0x0402 = Path to the Graveyard
//          0x0403 = Path to the Graveyard
//          0x0500 = Third Tomb
//          0x0501 = Third Tomb
//          0x0600 = Altar of Power
//          0x0700 = Antechamber
//          0x0701 = Antechamber
//          0x0800 = Spirit of Language Altar
//          0x0900 = Altar of Knowledge
//          0x0901 = Altar of Knowledge
//          
//          -- 0x0c: Temple of Moonlight --
//          0x0000 = Boneyard
//          0x0001 = Boneyard
//          0x0100 = Stairway of Eden
//          0x0101 = Stairway of Eden
//          0x0200 = Neptune's Feet
//          0x0201 = Neptune's Feet
//          0x0300 = Serdab of Power
//          0x0400 = Moon-Gazing Pit
//          0x0401 = Moon-Gazing Pit
//          0x0402 = Moon-Gazing Pit
//          0x0403 = Moon-Gazing Pit
//          0x0500 = Moon Pyramid: Burial Chamber
//          0x0501 = Moon Pyramid
//          0x0600 = Moon Watchtower
//          0x0601 = Moon Watchtower
//          0x0700 = Serdab of Treasure
//          0x0800 = Sealed Approach
//          0x0900 = Path to the Underworld
//          0x0901 = Path to the Underworld
//          0x0a00 = Underworld Palace
//          
//          -- 0x0d: Tower of the Goddess --
//          0x0000 = Urtharbrunnr
//          0x0001 = Urtharbrunnr
//          0x0100 = Antechamber
//          0x0101 = Antechamber
//          0x0200 = Urd's Tower
//          0x0201 = Urd's Tower
//          0x0202 = Urd's Tower
//          0x0300 = Verdandi's Tower
//          0x0301 = Verdandi's Tower
//          0x0400 = Verdandi's Tower
//          0x0401 = Verdandi's Tower
//          0x0500 = Scales of the Heart
//          0x0501 = Scales of the Heart
//          0x0600 = Skuld's Tower
//          0x0601 = Skuld's Tower
//          0x0602 = Skuld's Tower
//          0x0603 = Skuld's Tower
//          0x0700 = Path to Life
//          0x0701 = Skuld's Tower
//          0x0702 = Path to Power
//          0x0800 = Urd's Tower
//          
//          -- 0x0e: Tower of Ruin --
//          0x0000 = Fountain of Heat
//          0x0001 = Fountain of Heat
//          0x0002 = Fountain of Heat
//          0x0100 = Monument of Name
//          0x0101 = Monument of Name
//          0x0200 = Tower of Babel
//          0x0201 = Tower of Babel
//          0x0300 = Serdab of Time
//          0x0301 = Tower of Babilu
//          0x0400 = One Who Reads Tablets
//          0x0401 = Concubine
//          0x0500 = Approach of the Philosophers
//          0x0501 = Approach of the Philosophers
//          0x0600 = Approach of Life
//          0x0601 = Approach of Life
//          0x0700 = Burial Chamber of Life
//          0x0701 = Burial Chamber of Life
//          0x0800 = Nüwa's Pyramid
//          0x0801 = Nüwa's Pyramid
//          0x0802 = Nüwa's Pyramid
//          
//          -- 0x0f: Chamber of Birth --
//          0x0000 = Saraswati's Room
//          0x0001 = Saraswati's Room
//          0x0100 = Surrounding Wall of Spikes
//          0x0101 = Surrounding Wall of Spikes
//          0x0200 = Shiva's Room
//          0x0201 = Shiva's Room
//          0x0300 = Vishnu's Room
//          0x0301 = Vishnu's Room
//          0x0400 = Parvati's Room
//          
//          -- 0x10: Chamber of Birth --
//          0x0000 = Deva's Room
//          0x0001 = Deva's Room
//          0x0100 = Brahma's Room
//          0x0101 = Brahma's Room
//          0x0200 = Asura's Room
//          0x0201 = Asura's Room
//          0x0300 = Skanda's Room
//          0x0301 = Skanda's Room
//          0x0400 = Hanuman's Room
//          0x0401 = Ganesha's Room
//          0x0402 = Lakshmi's Room
//          
//          -- 0x11: Dimensional Corridor --
//          0x0000 = Anshar's Room
//          0x0001 = Kishar's Room
//          0x0100 = Ea's Room
//          0x0101 = Kulullu's Room
//          0x0200 = Kuusarikku's Room
//          0x0201 = Girtablilu's Room
//          0x0300 = Ushum's Room
//          0x0400 = Lahmu's Room
//          0x0401 = Lahamu's Room
//          0x0500 = Ugallu's Room
//          0x0501 = Abzu's Room
//          0x0600 = Mushussu's Room
//          0x0700 = Enlil's Room
//          0x0701 = Urmahlullu's Room
//          0x0800 = Marduk's Room
//          0x0801 = Mushnahhu's Room
//          0x0900 = Tiamat's Room
//          0x0901 = Umu Dabrutu's Room
//          0x0a00 = Anu's Room
//          0x0a01 = Ushumgallu's Room
//          
//          -- 0x12: True Shrine of the Mother --
//          0x0000 = Amphisbaena's Room
//          0x0001 = Amphisbaena's Room
//          0x0100 = Sakit's Room
//          0x0101 = Sakit's Room
//          0x0200 = Ellmac's Room
//          0x0201 = Ellmac's Room
//          0x0300 = Home of the Mother
//          0x0301 = Tiamat's Room
//          0x0400 = Baphomet's Room
//          0x0401 = Baphomet's Room
//          0x0500 = Palenque's Room
//          0x0501 = Palenque's Room
//          0x0600 = Viy's Room
//          0x0601 = Viy's Room
//          0x0700 = Beelzebub's Room
//          0x0701 = Beelzebub's Room
//          0x0800 = Bahamut's Room
//          0x0801 = Bahamut's Room
//          0x0900 = Treasury
//          0x0901 = Treasury
//          
//          -- 0x13: Gate of Time --
//          0x0000 = Mausoleum of the Giants
//          0x0001 = Mausoleum of the Giants
//          0x0100 = Mausoleum of the Giants
//          0x0101 = Mausoleum of the Giants
//          0x0102 = Mausoleum of the Giants
//          0x0200 = Mausoleum of the Giants
//          0x0201 = Mausoleum of the Giants
//          0x0300 = Mausoleum of the Giants
//          0x0301 = Mausoleum of the Giants
//          0x0400 = Mausoleum of the Giants
//          0x0401 = Mausoleum of the Giants
//          
//          -- 0x14: Gate of Time --
//          0x0000 = Gate of Guidance
//          0x0001 = Gate of Guidance
//          0x0100 = Gate of Guidance
//          0x0101 = Gate of Guidance
//          0x0102 = Gate of Guidance
//          0x0200 = Gate of Guidance
//          0x0201 = Gate of Guidance
//          0x0300 = Gate of Guidance
//          0x0301 = Gate of Guidance
//          0x0400 = Gate of Guidance
//          0x0401 = Gate of Guidance
//          
//          -- 0x15: Gate of Time --
//          0x0000 = Surface
//          0x0001 = Surface
function room_id() => byte(0x363FD1)

// $363FD2: [8-bit] Screen ID
function screen_id() => byte(0x363FD2)

// $363FD3: [8-bit] Indicates which field objects list pointer is current
//          0x00 = 0x00363ff8
//          0x01 = 0x00363ffc
//          
//          Current list changes with every field transition
function indicates_which_field_objects_list_pointer_is_current() => byte(0x363FD3)

// $363FD4: [8-bit] Indicates which room objects list pointer is current
//          0x00 = 0x00364008
//          0x01 = 0x0036400c
//          
//          Current list changes with every room transition
function indicates_which_room_objects_list_pointer_is_current() => byte(0x363FD4)

// $363FD5: [8-bit] Indicates which screen objects list pointer is current
//          0x00 = 0x00364018
//          0x01 = 0x0036401c
//          
//          Current list changes with every screen transition
function indicates_which_screen_objects_list_pointer_is_current() => byte(0x363FD5)

// $363FE8: [32-bit BE] Play time for current session (frames)
//          Resets on death or exiting to main menu
function play_time_for_current_session() => dword_be(0x363FE8)

// $363FF8: [32-bit BE] Pointer to field objects meta-list #1
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_field_objects_metalist_1() => dword_be(0x363FF8)

// $363FFC: [32-bit BE] Pointer to field objects meta-list #2
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_field_objects_metalist_2() => dword_be(0x363FFC)

// $364008: [32-bit BE] Pointer to room objects meta-list #1
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_room_objects_metalist_1() => dword_be(0x364008)

// $36400C: [32-bit BE] Pointer to room objects meta-list #2
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_room_objects_metalist_2() => dword_be(0x36400C)

// $364018: [32-bit BE] Pointer to screen objects meta-list #1
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_screen_objects_metalist_1() => dword_be(0x364018)

// $36401C: [32-bit BE] Pointer to screen objects meta-list #2
//          
//          A doubly-linked list that keeps track of entries in the field objects list. Each node is 28 bytes in size. This list is updated whenever nodes are added or removed to the actual objects list, but nodes other than the head are not used when the game accesses object data; rather, the head of this list is used to locate the head of the actual objects list, which the game then iterates over.
//          
//          +0x00: [32-bit BE] Pointer to previous node
//          +0x04: [32-bit BE] Pointer to next node
//          +0x08: [32-bit BE] Pointer to head of field objects list
//          ++0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          ++0x2fa: [32-bit BE] Pointer to next object in list
function pointer_to_screen_objects_metalist_2() => dword_be(0x36401C)

// $3640F8: [32-bit BE] Index of script card used for last shop/NPC room visited
function index_of_script_card_used_for_last_shop_npc_room_visited() => dword_be(0x3640F8)

// $364110: [32-bit BE] Pointer to global object data
//          A singly-linked list where each node is at least 762 bytes.
//          +0x00: [32-bit BE] First of several pointers that can be used to discriminate object type
//          | 0x8022a350 = Escape timer
//          + 0xf0: [32-bit BE] Escape timer: minutes
//          + 0xf4: [32-bit BE] Escape timer: seconds
//          + 0xf8: [32-bit BE] Escape timer: 1/100 seconds
//          + 0x2f4: [32-bit BE] Pointer to next node
function pointer_to_global_object_data() => dword_be(0x364110)

// $364190: [4 bytes, ASCII] Title ID
//          "WLME" -> North American version
//          "WLMP" -> European version
function _4_bytes_ascii_title_id() => dword(0x364190)

// $365490: [Float BE] Walk speed scale factor - denominator
//          In the WiiWare version of La-Mulana, walk speed (and only walk speed) is scaled by a factor of 9999/10000 after being calculated, breaking integer alignment for movement.
//          
//          Changing this value from 0x461c4000 (10000.0) to 0x4c1c3c00 (9999.0) fixes movement speed scaling and allows Lemeza to once again perform alignment-related glitches.
function walk_speed_scale_factor_denominator() => float_be(0x365490)

// $374B88: [50 bytes, 8-bit values] Flags 0-49 (screen flags)
function _50_bytes_8_bit_values_flags_0_49() => byte(0x374B88)

// $374BBA: [50 bytes, 8-bit values] Flags 50-99 (room flags)
function _50_bytes_8_bit_values_flags_50_99() => byte(0x374BBA)

// $374BEC: [18 bytes, 8-bit values] Flags 100-117 - grail point scans
//          [0] = Gate of Guidance
//          [1] = Mausoleum of the Giants
//          [2] = Temple of the Sun
//          [3] = Spring in the Sky
//          [4] = Inferno Cavern
//          [5] = Chamber of Extinction
//          [6] = Twin Labyrinths (front)
//          [7] = Endless Corridor
//          [8] = Shrine of the Mother
//          [9] = Gate of Illusion
//          [10] = Graveyard of the Giants
//          [11] = Temple of Moonlight
//          [12] = Tower of the Goddess
//          [13] = Tower of Ruin
//          [14] = Chamber of Birth
//          [15] = Twin Labyrinths (back)
//          [16] = Dimensional Corridor
//          [17] = True Shrine of the Mother
function _18_bytes_8_bit_values_flags_100_117_grail_point_scans() => byte(0x374BEC)

// $374BFE: [8-bit] Flag 118 - (unused)
function flag_118() => byte(0x374BFE)

// $374BFF: [8-bit] Flag 119 - Number of coin chests opened
//          (28 chests in total)
function flag_119_number_of_coin_chests_opened() => byte(0x374BFF)

// $374C00: [8-bit] Flag 120 - Giltoriyo
//          (Values >= 0x01) = Woke Giltoriyo
function flag_120_giltoriyo() => byte(0x374C00)

// $374C01: [8-bit] Flag 121 - Waking Mulbruk
//          0x01 = Origin Seal broken
//          0x02 = Had initial waking / Wedjet conversation
//          0x04 = Had "Mulbruk finally starting to wake up" conversation
function flag_121_waking_mulbruk() => byte(0x374C01)

// $374C02: [8-bit] Flag 122 - Alsedana
//          (Values >= 0x01) = Woke Alsedana
function flag_122_alsedana() => byte(0x374C02)

// $374C03: [8-bit] Flag 123 - Hidden point system score
//          Used for Xelpud/Mulbruk dialogue availability
function flag_123_hidden_point_system_score() => byte(0x374C03)

// $374C04: [8-bit] Flag 124 - Surface - Xelpud conversation state
//          0x01 = Had conversation with Xelpud ("Welcome! You that Professor Lemeza, am I right?")
//          0x02 = Had conversation with Xelpud ("What are you still doing here?")
//          0x03 = Returned to surface and have received email #18
//          0x04 = Had conversation with Xelpud ("You made it! Actually, I called you back for no good reason." or "Hey! I told you in my e-mail to hurry back!")
//          0x05 = Have returned to surface, and have not received email #19, and flag 227?
//          0x06 = Returned to surface and have received email #23
//          0x07 = Had conversation with Xelpud ("This here's a story that's been passed down in the village.")
//          0x08 = Returned to surface and have woken Mulbruk
//          0x09 = Had conversation with Xelpud ("Well, I'll be. You found the sleeping one.")
//          0x0a = Returned to surface and have received email #43
//          0x0b = Had conversation with Xelpud ("So you made it. Now, hurry up and go buy that newfangled laptop!")
//          0x0c = Had conversation with Xelpud ("Now then, it looks like you found your father's Diary.")
//          0x0d = Had conversation with Xelpud ("Our race has continued to protect the ruins, following the teachings of the Four Philosophers")
function flag_124_surface_xelpud_conversation_state() => byte(0x374C04)

// $374C05: [14 bytes, 8-bit values] Flags 125-138 - Weapons collected
//          [0] = Chain whip
//          [1] = Flail whip
//          [2] = Knife
//          [3] = Key sword
//          [4] = Axe
//          [5] = Katana
//          [6] = Shuriken
//          [7] = Rolling shuriken
//          [8] = Earth spear
//          [9] = Flare Gun
//          [10] = Bomb
//          [11] = Chakram
//          [12] = Caltrops
//          [13] = Pistol (0x02)
function _14_bytes_8_bit_values_flags_125_138_weapons_collected() => byte(0x374C05)

// $374C13: [8-bit] Flag 139 - Samaranta
//          (Values >= 0x01) = Woke Samaranta
function flag_139_samaranta() => byte(0x374C13)

// $374C14: [2 bytes, 8-bit values] Flags 140-141 - Shields collected
//          [0] = Silver shield
//          [1] = Angel shield
function _2_bytes_8_bit_values_flags_140_141_shields_collected() => word(0x374C14)

// $374C16: [8 bytes, 8-bit values] Flags 142-149 - Ankh jewel chests
//          0x01 = chest opened, 0x02 = ankh jewel collected
//          [0] = Gate of Guidance
//          [1] = Mausoleum of the Giants
//          [2] = Temple of the Sun
//          [3] = Spring in the Sky
//          [4] = Tower of Ruin
//          [5] = Chamber of Birth
//          [6] = Twin Labyrinths
//          [7] = Dimensional Corridor
function _8_bytes_8_bit_values_flags_142_149_ankh_jewel_chests() => byte(0x374C16)

// $374C1E: [15 bytes, 8-bit values] Flags 150-164 - Use item chests
//          0x01 = Chest opened / item puchased/received from NPC
//          0x02 = Item collected / left shop/NPC room
//          [0] = Hand Scanner
//          [1] = Djed Pilar
//          [2] = Mini Doll
//          [3] = Magatama Jewel
//          [4] = Cog of the Soul
//          [5] = Lamp of Time
//          [6] = Pochette Key
//          [7] = Dragon Bone
//          [8] = Crystal Skull
//          [9] =  Vessel
//          [10] = Pepper
//          [11] = Woman Statue
//          [12] = Key of Eternity
//          [13] = Serpent Staff
//          [14] = Talisman
function _15_bytes_8_bit_values_flags_150_164_use_item_chests() => byte(0x374C1E)

// $374C2D: [29 bytes, 8-bit values] Flags 165-193 - Equip item chests
//          0x01 = Chest opened / item puchased/received from NPC
//          0x02 = Item collected / left shop/NPC room
//          [0] = Waterproof Case
//          [1] = Heatproof Case
//          [2] = Shell Horn
//          [3] = Glove
//          [4] = Holy Grail
//          [5] = Isis' Pendant
//          [6] = Crucifix
//          [7] = Helmet
//          [8] = Grapple Claw
//          [9] = Bronze Mirror
//          [10] = Eye of Truth
//          [11] = Ring (* flag stays at 0x01)
//          [12] = Scalesphere
//          [13] = Gauntlet
//          [14] = (unused)
//          [15] = Plane Model
//          [16] = Philosopher's Ocarina
//          [17] = Feather
//          [18] = (unused)
//          [19] = Fairy Clothes
//          [20] = Scriptures
//          [21] = Hermes' Boots
//          [22] = Fruit of Eden
//          [23] = Twin Statue
//          [24] = Bracelet
//          [25] = Perfume
//          [26] = Spaulder
//          [27] = Dimensional Key
//          [28] = Ice cape
function _29_bytes_8_bit_values_flags_165_193_equip_item_chests() => byte(0x374C2D)

// $374C4A: [4 bytes, 8-bit values] - Flags 194-197 - Seal chests
//          0x01 = chest opened, 0x02 = seal collected
//          [0] = Origin seal
//          [1] = Birth seal
//          [2] = Life seal
//          [3] = Death seal
function _4_bytes_8_bit_values_flags_194_197_seal_chests() => dword(0x374C4A)

// $374C4E: [8-bit] Flag 198 - Surface - Village of Departure
//          Visiting Village of Departure while this flag is 0x02 will prime flag 822 to allow the Mulbruk conversation about laptops / ancient software to occur.
//          But it is unclear how this flag is ever changed from its initial value.
function flag_198_surface_village_of_departure() => byte(0x374C4E)

// $374C4F: [10 bytes, 8-bit values] Flags 199-208 - Sacred Orb chests
//          0x01 = chest opened, 0x02 = orb collected
//          [0] = Gate of Guidance
//          [1] = Surface
//          [2] = Mausoleum of the Giants
//          [3] = Temple of the Sun
//          [4] = Spring in the Sky
//          [5] = Chamber of Extinction
//          [6] = Twin Labyrinths
//          [7] = Shrine of the Mother
//          [8] = Tower of Ruin
//          [9] = Dimensional Corridor
function _10_bytes_8_bit_values_flags_199_208_sacred_orb_chests() => byte(0x374C4F)

// $374C59: [17 bytes, 8-bit values] Flags 209-225 - Map chests
//          0x01 = chest opened, 0x02 = map collected
//          [0] = Surface*
//          [1] = Gate of Guidance
//          [2] = Mausoleum of the Giants
//          [3] = Temple of the Sun
//          [4] = Spring in the Sky
//          [5] = Inferno Cavern
//          [6] = Chamber of Extinction
//          [7] = Twin Labyrinths
//          [8] = Endless Corridor
//          [9] = Shrine of the Mother
//          [10] = Gate of Illusion
//          [11] = Graveyard of the Giants
//          [12] = Temple of Moonlight
//          [13] = Tower of the Goddess
//          [14] = Tower of Ruin
//          [15] = Chamber of Birth
//          [16] = Dimensional Corridor
//          * On surface, reading skeleton and closing scan window function as chest open/map collected
function _17_bytes_8_bit_values_flags_209_225_map_chests() => byte(0x374C59)

// $374C6A: [20 bytes, 8-bit values] Flags 226-245 - Software chests
//          Entries marked with (0x01) take on a final value of 0x01, entries marked 0x02 take on a final value of 0x02
//          [0] = (0x02) Glyph Reader
//          [1] = (0x01) Xelpud Mailer
//          [2] = (0x02) Yagoo Map Reader
//          [3] = (0x02) Yagoo Map Street
//          [4] = (0x02) TextTrax
//          [5] = (0x01) Additional Text Memory
//          [6] = (0x01) Snapshots
//          [7] = (0x01) Guild
//          [8] = (0x01) Mantra
//          [9] = (0x01) Enga Musica
//          [10] = (0x01) Beo La-Mulana
//          [11] = (unused)
//          [12] = (0x02) Rose and Camellia
//          [13] = (0x02) Space Capster II
//          [14] = (0x02) Lonely House Moving
//          [15] = (0x02) Mekuri Master
//          [16] = (0x02) Bounce Shot
//          [17] = (0x01) Miracle Witch
//          [18] = (0x02) Future Development Company
//          [19] = (0x02) La-Mulana
function _20_bytes_8_bit_values_flags_226_245_software_chests() => byte(0x374C6A)

// $374C7E: [9 bytes, 8-bit values] Flags 246-254 - Boss ankh states
//          0x00 = ankh hidden, 0x01 = ankh exposed, 0x02 = fighting boss, 0x03 = boss defeated
//          [0] = Amphisbaena
//          [1] = Sakit
//          [2] = Ellmac
//          [3] = Bahamut
//          [4] = Viy
//          [5] = Palenque
//          [6] = Baphomet
//          [7] = Tiamat
//          [8] = Mother (*uses separate flag for ankh exposure, but takes on 0x02/0x03 values when fighting/defeated)
function _9_bytes_8_bit_values_flags_246_254_boss_ankh_states() => byte(0x374C7E)

// $374C87: [8-bit] Flag 255 - Item pots:
//          Bit0 = Gate of Guidance D1 - Coins x 10
//          Bit1 = Gate of Guidance D2 - Coins x 10
//          Bit2 = Gate of Guidance E2 - Weight
//          Bit3 = Gate of Guidance E2 - Shuriken Ammo x 10
//          Bit4 = Gate of Guidance F2 - Coins x 10
//          Bit5 = Gate of Guidance G2 - Coins x 10
//          Bit6 = Gate of Guidance D3 - Coins x 10
//          Bit7 = Gate of Guidance C3 - Coins x 10
function flag_255_item_pots() => byte(0x374C87)

// $374C88: [8-bit] Flag 256 - Item pots:
//          Bit0 = Gate of Guidance A3 - Shuriken Ammo x 10
//          Bit1 = Gate of Guidance B4 - Coins x 10
//          Bit2 = Gate of Guidance B5 - Coins x 10
//          Bit3 = Gate of Guidance B5 - Coins x 10
//          Bit4 = Gate of Guidance B6 - Coins x 10
//          Bit5 = Surface E4 - Weight
function flag_256_item_pots() => byte(0x374C88)

// $374C89: [8-bit] Flag 257 - Item pots:
//          Bit0 = Surface D4 - Coins x 10
//          Bit1 = Surface F4 - Coins x 10
//          Bit2 = Surface I3 - Coins x 10
//          Bit3 = Surface K1 - Coins x 10
//          Bit4 = Surface H4 - Weight
//          Bit7 = Surface G4 - Coins x 10
function flag_257_item_pots() => byte(0x374C89)

// $374C8A: [8-bit] Flag 258 - Number of guardians obliterated
//          Tracks number of guardians defeated, takes on value of 0x09 when all 8 defeated
function flag_258_number_of_guardians_obliterated() => byte(0x374C8A)

// $374C8B: [8-bit] Flag 259 - Treasures
//          0x01 = Chest opened
//          0x02 = Treasures collected
function flag_259_treasures() => byte(0x374C8B)

// $374C8C: [8-bit] Flag 260 - Diary
//          0x01 = Chest opened
//          0x02 = Diary collected
function flag_260_diary() => byte(0x374C8C)

// $374C8D: [8-bit] Flag 261 - Mulana Talisman
//          0x01 = Received Mulana Talisman from Xelpud
//          0x02 = Left Xelpud's tent
function flag_261_mulana_talisman() => byte(0x374C8D)

// $374C8E: [8-bit] Flag 262 - Provocative Bathing Suit
//          0x02 = Bathing suit collected
function flag_262_provocative_bathing_suit() => byte(0x374C8E)

// $374C8F: [8-bit] Flag 263 - (unused)
function flag_263() => byte(0x374C8F)

// $374C90: [8-bit] Flag 264 - Tower of Ruin - Fountain
//          0x02 = Collected Medicine of the Mind (yellow)
function flag_264_tower_of_ruin_fountain() => byte(0x374C90)

// $374C91: [8-bit] Flag 265 - Tower of Ruin - Fountain
//          0x02 = Collected Medicine of the Mind (green)
function flag_265_tower_of_ruin_fountain() => byte(0x374C91)

// $374C92: [8-bit] Flag 266 - Tower of Ruin - Fountain
//          0x02 = Collected Medicine of the Mind (red)
function flag_266_tower_of_ruin_fountain() => byte(0x374C92)

// $374C93: [8-bit] Flag 267 - Maternity Statue
//          (Value >= 1) = Maternity Statue collected
function flag_267_maternity_statue() => byte(0x374C93)

// $374C94: [8-bit] Flag 268 - (unused)
function flag_268() => byte(0x374C94)

// $374C95: [8-bit] Flag 269 - Fobos
//          (Values >= 0x01) = Woke Fobos
function flag_269_fobos() => byte(0x374C95)

// $374C96: [8-bit] Flag 270 - Item pots:
//          Bit0 = Mausoleum of the Giants B1 - Coins x 10
//          Bit1 = Mausoleum of the Giants C1 - Rolling Shuriken Ammo x 10
//          Bit2 = Mausoleum of the Giants D1 - Coins x 10
//          Bit3 = Mausoleum of the Giants D1 - Weight
//          Bit4 = Mausoleum of the Giants F4 - Empty
//          Bit5 = Mausoleum of the Giants G4 - Coins x 10
//          Bit6 = Mausoleum of the Giants F3 - Empty
//          Bit7 = Mausoleum of the Giants E3 - Coins x 10
function flag_270_item_pots() => byte(0x374C96)

// $374C97: [8-bit] Flag 271 - Item pots:
//          Bit0 = Mausoleum of the Giants D2 - Coins x 10
//          Bit1 = Mausoleum of the Giants C5 - Coins x 10
//          Bit2 = Mausoleum of the Giants B5 - Coins x 10
function flag_271_item_pots() => byte(0x374C97)

// $374C98: [8-bit] Flag 272 - Item pots:
//          Bit0 = Temple of the Sun B1 - Empty
//          Bit1 = Temple of the Sun B1 - Coins x 10
//          Bit2 = Temple of the Sun C2 - Empty
//          Bit3 = Temple of the Sun D2 - Coins x 10
//          Bit4 = Temple of the Sun C3 - Shuriken Ammo x 10
//          Bit5 = Temple of the Sun F3 - Coins x 10
//          Bit6 = Temple of the Sun F3 - Coins x 10
//          Bit7 = Temple of the Sun D4 - Coins x 10
function flag_272_item_pots() => byte(0x374C98)

// $374C99: [8-bit] Flag 273 - Item pots:
//          Bit0 = Temple of the Sun F4 - Flare Gun Ammo x 10
//          Bit1 = Temple of the Sun C5 - Coins x 10
//          Bit2 = Temple of the Sun D5 - Coins x 10
//          Bit3 = Temple of the Sun E5 - Coins x 10
function flag_273_item_pots() => byte(0x374C99)

// $374C9A: [8-bit] Flag 274 - Item pots:
//          Bit0 = Spring in the Sky A5 - Coins x 10
//          Bit1 = Spring in the Sky A6 - Coins x 10
//          Bit2 = Spring in the Sky C5 - Coins x 10
//          Bit3 = Spring in the Sky E2 - Coins x 10
function flag_274_item_pots() => byte(0x374C9A)

// $374C9B: [8-bit] Flag 275 - Item pots:
//          Bit0 = Inferno Cavern E1 - Coins x 10
//          Bit1 = Inferno Cavern E1 - Empty
//          Bit2 = Inferno Cavern E2 - Earth Spear Ammo x 10
//          Bit3 = Inferno Cavern D4 - Coins x 10
//          Bit4 = Inferno Cavern C3 - Coins x 10
//          Bit5 = Inferno Cavern B3 - Empty
//          Bit6 = Inferno Cavern E4 - Rolling Shuriken Ammo x 10
//          Bit7 = Inferno Cavern E5 - Coins x 10
function flag_275_item_pots() => byte(0x374C9B)

// $374C9C: [8-bit] Flag 276 - Item pots:
//          Bit0 = Chamber of Extinction B3 - Coins x 10
//          Bit1 = Chamber of Extinction E4 - Coins x 10
//          Bit2 = Chamber of Extinction E4 - Flare Gun Ammo x 10
//          Bit3 = Chamber of Extinction E4 - Coins x 10
//          Bit4 = Chamber of Extinction H5 - Coins x 10
//          Bit5 = Chamber of Extinction I5 - Coins x 10
//          Bit6 = Chamber of Extinction I5 - Empty
//          Bit7 = Chamber of Extinction H2 - Caltrop Ammo x 10
function flag_276_item_pots() => byte(0x374C9C)

// $374C9D: [8-bit] Flag 277 - Item pots:
//          Bit0 = Chamber of Extinction H3 - Coins x 10
//          Bit1 = Chamber of Extinction H3 - Coins x 10
//          Bit2 = Twin Labyrinths I5 - Coins x 10
//          Bit3 = Twin Labyrinths F5 - Earth Spear Ammo x 10
function flag_277_item_pots() => byte(0x374C9D)

// $374C9E: [8-bit] Flag 278 - Item pots:
//          Bit0 = Twin Labyrinths C1 - Coins x 10
//          Bit1 = Twin Labyrinths D1 - Shuriken Ammo x 10
//          Bit2 = Twin Labyrinths C2 - Coins x 10
//          Bit3 = Twin Labyrinths D2 - Coins x 10
//          Bit4 = Twin Labyrinths A3 - Coins x 20
//          Bit5 = Twin Labyrinths B4 - Coins x 10
//          Bit6 = Twin Labyrinths B5 - Coins x 10
//          Bit7 = Twin Labyrinths F1 - Coins x 10
function flag_278_item_pots() => byte(0x374C9E)

// $374C9F: [8-bit] Flag 279 - Item pots:
//          Bit0 = Twin Labyrinths G1 - Coins x 10
//          Bit1 = Twin Labyrinths H1 - Weight
//          Bit2 = Twin Labyrinths H2 - Coins x 10
//          Bit3 = Twin Labyrinths J2 - Coins x 10
//          Bit4 = Twin Labyrinths J3 - Coins x 10
//          Bit6 = Twin Labyrinths I4 - Weight
//          Bit7 = Twin Labyrinths J4 - Coins x 10
function flag_279_item_pots() => byte(0x374C9F)

// $374CA0: [8-bit] Flag 280 - Fairy points enabled
function flag_280_fairy_points_enabled() => byte(0x374CA0)

// $374CA1: [8-bit] Flag 281 - Item pots:
//          Bit0 = Endless Corridor D1 - Coins x 10
//          Bit1 = Endless Corridor C1 - Coins x 10
//          Bit2 = Endless Corridor A1 - Coins x 10
//          Bit3 = Endless Corridor B2 - Coins x 10
//          Bit4 = Endless Corridor D2 - Weight
//          Bit5 = Endless Corridor D3 - Caltrop Ammo x 10
//          Bit6 = Endless Corridor D3 - Coins x 10
//          Bit7 = Endless Corridor C3 - Weight
function flag_281_item_pots() => byte(0x374CA1)

// $374CA2: [8-bit] Flag 282 - Item pots:
//          Bit0 = Endless Corridor C3 - Chakram Ammo x 2
//          Bit1 = Endless Corridor A3 - Earth Spear Ammo x 10
//          Bit2 = Endless Corridor D5 - Coins x 10
//          Bit3 = Endless Corridor A5 - Coins x 100
//          Bit4 = Endless Corridor B5 - Coins x 10
function flag_282_item_pots() => byte(0x374CA2)

// $374CA3: [8-bit] Flag 283 - Item pots:
//          Bit0 = Shrine of the Mother B2 - Coins x 10
//          Bit1 = Shrine of the Mother D3 - Coins x 10
//          Bit2 = Shrine of the Mother C4 - Coins x 10
//          Bit3 = Shrine of the Mother C4 - Coins x 10
//          Bit4 = Shrine of the Mother D4 - Coins x 10
//          Bit5 = Shrine of the Mother B6 - Coins x 10
function flag_283_item_pots() => byte(0x374CA3)

// $374CA4: [8-bit] Flag 284 - Item pots:
//          Bit0 = Gate of Illusion F5 - Coins x 10
//          Bit1 = Gate of Illusion F4 - Weight
//          Bit3 = Gate of Illusion C3 - Coins x 10
//          Bit5 = Gate of Illusion C2 - Empty
//          Bit6 = Gate of Illusion D2 - Coins x 10
//          Bit7 = Gate of Illusion D3 - Coins x 10
function flag_284_item_pots() => byte(0x374CA4)

// $374CA5: [8-bit] Flag 285 - Item pots:
//          Bit0 = Graveyard of the Giants A2 - Coins x 10
//          Bit1 = Graveyard of the Giants B5 - Coins x 10
//          Bit2 = Graveyard of the Giants D5 - Coins x 10
//          Bit3 = Graveyard of the Giants B2 - Empty
//          Bit4 = Graveyard of the Giants F4 - Coins x 10
//          Bit5 = Graveyard of the Giants D2 - Coins x 20
//          Bit6 = Graveyard of the Giants E5 - Coins x 10
//          Bit7 = Graveyard of the Giants F4 - Coins x 10
function flag_285_item_pots() => byte(0x374CA5)

// $374CA6: [8-bit] Flag 286 - Item pots:
//          Bit0 = Temple of Moonlight A1 - Coins x 10
//          Bit1 = Temple of Moonlight C2 - Coins x 10
//          Bit2 = Temple of Moonlight C3 - Coins x 50
//          Bit2 = Temple of Moonlight D5 - Empty
//          Bit3 = Temple of Moonlight E3 - Coins x 10
//          Bit4 = Temple of Moonlight F4 - Empty
//          Bit5 = Temple of Moonlight D2 - Weight
//          Bit6 = Temple of Moonlight D6 - Weight
function flag_286_item_pots() => byte(0x374CA6)

// $374CA7: [8-bit] Flag 287 - Item pots:
//          Bit0 = Tower of the Goddess B8 - Empty
//          Bit1 = Tower of the Goddess B8 - Coins x 10
//          Bit2 = Tower of the Goddess C7 - Empty
//          Bit3 = Tower of the Goddess B7 - Coins x 10
//          Bit5 = Tower of the Goddess B5 - Empty
//          Bit6 = Tower of the Goddess A5 - Weight
//          Bit7 = Tower of the Goddess A4 - Bomb Ammo x 5
function flag_287_item_pots() => byte(0x374CA7)

// $374CA8: [8-bit] Flag 288 - Item pots:
//          Bit0 = Tower of Ruin G5 - Coins x 10
//          Bit1 = Tower of Ruin E5 - Coins x 10
//          Bit2 = Tower of Ruin D5 - Coins x 10
//          Bit3 = Tower of Ruin D4 - Weight
//          Bit4 = Tower of Ruin A3 - Empty
//          Bit5 = Tower of Ruin B3 - Coins x 10
//          Bit6 = Tower of Ruin D3 - Earth Spear Ammo x 10
//          Bit7 = Tower of Ruin F2 - Coins x 10
function flag_288_item_pots() => byte(0x374CA8)

// $374CA9: [8-bit] Flag 289 - Item pots:
//          Bit0 = Chamber of Birth D2 - Coins x 10
//          Bit1 = Chamber of Birth E2 - Coins x 10
//          Bit2 = Chamber of Birth F2 - Weight
//          Bit3 = Chamber of Birth H4 - Coins x 10
//          Bit4 = Chamber of Birth B3 - Coins x 10
//          Bit5 = Chamber of Birth C5 - Coins x 10
//          Bit6 = Chamber of Birth G6 - Coins x 10
//          Bit7 = Chamber of Birth E6 - Empty
function flag_289_item_pots() => byte(0x374CA9)

// $374CAA: [8-bit] Flag 290 - Item pots:
//          Bit0 = Dimensional Corridor B7 - Coins x 10
//          Bit1 = Dimensional Corridor B5 - Empty
//          Bit1 = Dimensional Corridor B6 - Empty
//          Bit2 = Dimensional Corridor A6 - Coins x 10
//          Bit4 = Dimensional Corridor D6 - Coins x 10
//          Bit5 = Dimensional Corridor B4 - Coins x 10
//          Bit6 = Dimensional Corridor B3 - Coins x 10
//          Bit7 = Dimensional Corridor C2 - Weight
function flag_290_item_pots() => byte(0x374CAA)

// $374CAB: [8-bit] Flag 291 - Item pots:
//          Bit0 = Tower of the Goddess A2 - Coins x 10
//          Bit1 = Tower of the Goddess A2 - Empty
//          Bit2 = Tower of the Goddess C5 - Coins x 10
//          Bit4 = Tower of the Goddess E1 - Weight
//          Bit5 = Tower of the Goddess D5 - Flare Gun Ammo x 10
//          Bit6 = Tower of the Goddess B5 - Coins x 10
function flag_291_item_pots() => byte(0x374CAB)

// $374CAC: [8-bit] Flag 292 - Wedge #1
//          0x01 = LAMULANA tablet primed to appear
//          0x02 = LAMULANA tablet appeared
//          0x03 = Read LAMULANA tablet
//          0x04 = Drove wedge into Gate of Illusion
function flag_292_wedge_1() => byte(0x374CAC)

// $374CAD: [8-bit] Flag 293 - Wedge #2
//          0x01 = ABUTO tablet primed to appear
//          0x02 = ABUTO tablet appeared
//          0x03 = Read ABUTO tablet
//          0x04 = Drove wedge into Graveyard of the Giants
function flag_293_wedge_2() => byte(0x374CAD)

// $374CAE: [8-bit] Flag 294 - Wedge #3
//          0x01 = WEDJET tablet primed to appear
//          0x02 = WEDJET tablet appeared
//          0x03 = Read WEDJET tablet
//          0x04 = Drove wedge into Temple of Moonlight
function flag_294_wedge_3() => byte(0x374CAE)

// $374CAF: [8-bit] Flag 295 - Wedge #4
//          0x01 = BAHRUN tablet primed to appear
//          0x02 = BAHRUN tablet appeared
//          0x03 = Read BAHRUN tablet
//          0x04 = Drove wedge into Tower of the Goddess
function flag_295_wedge_4() => byte(0x374CAF)

// $374CB0: [8-bit] Flag 296 - Wedge #5
//          0x01 = VIY tablet primed to appear
//          0x02 = VIY tablet appeared
//          0x03 = Read VIY tablet
//          0x04 = Drove wedge into Tower of Ruin
function flag_296_wedge_5() => byte(0x374CB0)

// $374CB1: [8-bit] Flag 297 - Wedge #6
//          0x01 = MU tablet primed to appear
//          0x02 = MU tablet appeared
//          0x03 = Read MU tablet
//          0x04 = Drove wedge into Chamber of Birth
function flag_297_wedge_6() => byte(0x374CB1)

// $374CB2: [8-bit] Flag 298 - Wedge #7
//          0x01 = SABBAT tablet primed to appear
//          0x02 = SABBAT tablet appeared
//          0x03 = Read SABBAT tablet
//          0x04 = Drove wedge into Twin Labyrinths
function flag_298_wedge_7() => byte(0x374CB2)

// $374CB3: [8-bit] Flag 299 - Wedge #8
//          0x01 = MARDUK tablet primed to appear
//          0x02 = MARDUK tablet appeared
//          0x03 = Read MARDUK tablet
//          0x04 = Drove wedge into Endless Corridor
function flag_299_wedge_8() => byte(0x374CB3)

// $374CB4: [8-bit] Flag 300 - Gate of Guidance - Orb chest unlocked
function flag_300_gate_of_guidance_orb_chest_unlocked() => byte(0x374CB4)

// $374CB5: [8-bit] Flag 301 - Gate of Guidance - Crucifix puzzle
//          0x01 = Life Seal broken
//          0x03 = Chest unlocked
function flag_301_gate_of_guidance_crucifix_puzzle() => byte(0x374CB5)

// $374CB6: [8-bit] Flag 302 - Gate of Guidance - Map chest unlocked
function flag_302_gate_of_guidance_map_chest_unlocked() => byte(0x374CB6)

// $374CB7: [8-bit] Flag 303 - Gate of Guidance - Yagoo Map Street chest unlocked
function flag_303_gate_of_guidance_yagoo_map_street_chest_unlocked() => byte(0x374CB7)

// $374CB8: [8-bit] Flag 304 - Gate of Guidance - Red skeletons defeated
//          0x01 = Skeletons defeated
//          0x02 = Push block puzzle solved
//          0x03 = Placed weight to open ladder to Amphisbaena's chamber
function flag_304_gate_of_guidance_red_skeletons_defeated() => byte(0x374CB8)

// $374CB9: [8-bit] Flag 305 - Gate of Guidance - Pit of Courage
//          0x01 = Leapt into pit
//          0x02 = Dais appeared
//          0x03 = Dais pressed
//          0x04 = Weapon cover removed
function flag_305_gate_of_guidance_pit_of_courage() => byte(0x374CB9)

// $374CBA: [8-bit] Flag 306 - Gate of Guidance - Pressed dais to expose coin chest
function flag_306_gate_of_guidance_pressed_dais_to_expose_coin_chest() => byte(0x374CBA)

// $374CBB: [8-bit] Flag 307 - Gate of Guidance - Ankh exposure puzzle
//          0x01 = Pushed block in Pit of the Holy Grail, exposed first dais
//          0x02 = Placed weight on first dais
//          0x03 = Exposed second dais in Heavenly Corridor
//          0x04 = (unused?)
//          0x05 = Placed weight on second dais, ankh exposed
//          0x06 = Amphisbaena defeated
function flag_307_gate_of_guidance_ankh_exposure_puzzle() => byte(0x374CBB)

// $374CBC: [8-bit] Flag 308 - Gate of Guidance - Grail pit elevator puzzle
//          0x01 = Hitbox broken on block
//          0x02 = Olmec head has swallowed the block
//          0x03 = Olmec head spitting out the elevator
//          0x04 = Elevator active
function flag_308_gate_of_guidance_grail_pit_elevator_puzzle() => byte(0x374CBC)

// $374CBD: [8-bit] Flag 309 - Gate of Guidance - Push block puzzle to unlock Grail chest
function flag_309_gate_of_guidance_push_block_puzzle_to_unlock_grail_chest() => byte(0x374CBD)

// $374CBE: [8-bit] Flag 310 - Gate of Guidance - Unlocking ankh jewel chest
//          0x01 = Destroyed apocalypse tablets in correct order
//          0x02 = Pressed dais at Monument of Time
//          0x03 = Pressed dais at Cliff of Radiance
function flag_310_gate_of_guidance_unlocking_ankh_jewel_chest() => byte(0x374CBE)

// $374CBF: [8-bit] Flag 311 - Gate of Guidance - Used pepper
//          0x01 = Chest dropping
//          0x02 = Chest landed
function flag_311_gate_of_guidance_used_pepper() => byte(0x374CBF)

// $374CC0: [8-bit] Flag 312 - Gate of Guidance - Coin chest (Room of Courage - upper)
function flag_312_gate_of_guidance_coin_chest() => byte(0x374CC0)

// $374CC1: [8-bit] Flag 313 - Gate of Guidance - Stepped on pressure plate by door to Illusion
function flag_313_gate_of_guidance_stepped_on_pressure_plate_by_door_to_illusion() => byte(0x374CC1)

// $374CC2: [8-bit] Flag 314 - Gate of Guidance - Ladder to Illusion door
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_314_gate_of_guidance_ladder_to_illusion_door() => byte(0x374CC2)

// $374CC3: [8-bit] Flag 315 - Gate of Guidance - Coin chest (Room of Courage - lower)
function flag_315_gate_of_guidance_coin_chest() => byte(0x374CC3)

// $374CC4: [8-bit] Flag 316 - Gate of Guidance - Coin chest (Gate of Giant Faces)
function flag_316_gate_of_guidance_coin_chest() => byte(0x374CC4)

// $374CC5: [8-bit] Flag 317 - Gate of Guidance - Ladder in the Pit of Courage
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_317_gate_of_guidance_ladder_in_the_pit_of_courage() => byte(0x374CC5)

// $374CC6: [8-bit] Flag 318 - Gate of Guidance - Cover over ankh jewel chest
//          0x01 = Cover retracting
//          0x02 = Cover fully retracted
function flag_318_gate_of_guidance_cover_over_ankh_jewel_chest() => byte(0x374CC6)

// $374CC7: [8-bit] Flag 319 - Gate of Guidance - Monument of Time ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_319_gate_of_guidance_monument_of_time_ladder() => byte(0x374CC7)

// $374CC8: [8-bit] Flag 320 - Gate of Guidance - Room of the Strong - Crusher trap triggered
function flag_320_gate_of_guidance_room_of_the_strong_crusher_trap_triggered() => byte(0x374CC8)

// $374CC9: [8-bit] Flag 321 - Gate of Guidance - Entered ruins for the first time / long intro to Fearless Challenger played
function flag_321_gate_of_guidance_entered_ruins_for_the_first_time_long_intro_to_fearless_challenger_played() => byte(0x374CC9)

// $374CCA: [8-bit] Flag 322 - Gate of Guidance - Pressed dais to drop Olmec face trap
//          "...can't believe I fell for... such an obvious trap..."
function flag_322_gate_of_guidance_pressed_dais_to_drop_olmec_face_trap() => byte(0x374CCA)

// $374CCB: [8-bit] Flag 323 - Gate of Guidance - Pressed dais to unlock coin chests (Room of Courage)
function flag_323_gate_of_guidance_pressed_dais_to_unlock_coin_chests() => byte(0x374CCB)

// $374CCC: [8-bit] Flag 324 - (unused)
function flag_324() => byte(0x374CCC)

// $374CCD: [8-bit] Flag 325 - Surface - Had initial conversation with Xelpud to unlock village tents and ruins entrance
function flag_325_surface_had_initial_conversation_with_xelpud_to_unlock_village_tents_and_ruins_entrance() => byte(0x374CCD)

// $374CCE: [8-bit] Flag 326 - Surface - Gazing Hill - Bombable wall
//          (Values >= 0x01) = Wall bombed open
function flag_326_surface_gazing_hill_bombable_wall() => byte(0x374CCE)

// $374CCF: [8-bit] Flag 327 - Surface - Gate of Departure - Broke open shortcut wall
function flag_327_surface_gate_of_departure_broke_open_shortcut_wall() => byte(0x374CCF)

// $374CD0: [8-bit] Flag 328 - Surface - Argus defeated
function flag_328_surface_argus_defeated() => byte(0x374CD0)

// $374CD1: [8-bit] Flag 329 - Surface - Unlocked Shell Horn chest
function flag_329_surface_unlocked_shell_horn_chest() => byte(0x374CD1)

// $374CD2: [8-bit] Flag 330 - Surface - Origin seal broken
function flag_330_surface_origin_seal_broken() => byte(0x374CD2)

// $374CD3: [8-bit] Flag 331 - Surface - Broke wall for orb chest
function flag_331_surface_broke_wall_for_orb_chest() => byte(0x374CD3)

// $374CD4: [8-bit] Flag 332 - Surface - Determines whether tunnel area is visible
function flag_332_surface_determines_whether_tunnel_area_is_visible() => byte(0x374CD4)

// $374CD5: [8-bit] Flag 333 - Surface - Coin chest (Cliff in front of the Altar)
//          0x01 = Seal broken
//          0x02 = Chest opened
function flag_333_surface_coin_chest() => byte(0x374CD5)

// $374CD6: [8-bit] Flag 334 - Surface - Broke open wall to expose coin chest (Bahrun's Waterfall)
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_334_surface_broke_open_wall_to_expose_coin_chest() => byte(0x374CD6)

// $374CD7: [8-bit] Flag 335 - Surface - Death Village
//          0x01 = Rocks behind Xelpud's statue broken
//          0x02 = Death Village collected
function flag_335_surface_death_village() => byte(0x374CD7)

// $374CD8: [8-bit] Flag 336 - Surface - Broke wall covering Mekuri Master tent
function flag_336_surface_broke_wall_covering_mekuri_master_tent() => byte(0x374CD8)

// $374CD9: [8-bit] Flag 337 - Surface - Waterfall of the Goddess - Broke open wall full of bats
//          0x01 = Wall broken
//          0x02 = Bats spawned
function flag_337_surface_waterfall_of_the_goddess_broke_open_wall_full_of_bats() => byte(0x374CD9)

// $374CDA: [8-bit] Flag 338 - 5 Door uncovered
function flag_338_5_door_uncovered() => byte(0x374CDA)

// $374CDB: [8-bit] Flag 339 - 5 Door opened
function flag_339_5_door_opened() => byte(0x374CDB)

// $374CDC: [8-bit] Flag 340 - Surface - Pressed dais to unlock ruins entrance
//          (Values >= 0x01) = Unlocked
function flag_340_surface_pressed_dais_to_unlock_ruins_entrance() => byte(0x374CDC)

// $374CDD: [8-bit] Flag 341 - Surface - Coin chest (Gazing Hill)
function flag_341_surface_coin_chest() => byte(0x374CDD)

// $374CDE: [8-bit] Flag 342 - Surface - Coin chest (Bahrun's Waterfall)
function flag_342_surface_coin_chest() => byte(0x374CDE)

// $374CDF: [8-bit] Flag 343 - Surface - Controls particle effects when falling down to ruins entrance for the first time
//          0x01 = Lemeza detector triggered
//          0x02 = Particle effect played
function flag_343_surface_controls_particle_effects_when_falling_down_to_ruins_entrance_for_the_first_time() => byte(0x374CDF)

// $374CE0: [8-bit] Flag 344 - Mausoleum of the Giants - Proved thou art small
function flag_344_mausoleum_of_the_giants_proved_thou_art_small() => byte(0x374CE0)

// $374CE1: [8-bit] Flag 345 - Number of bats killed (related to Xelpud email #06)
function flag_345_number_of_bats_killed() => byte(0x374CE1)

// $374CE2: [8-bit] Flag 346 - Gate of Guidance - Pit of the Holy Grail - Pressed dais to remove laser wall
function flag_346_gate_of_guidance_pit_of_the_holy_grail_pressed_dais_to_remove_laser_wall() => byte(0x374CE2)

// $374CE3: [8-bit] Flag 347 - Gate of Guidance - Pressed dais to unock shop
function flag_347_gate_of_guidance_pressed_dais_to_unock_shop() => byte(0x374CE3)

// $374CE4: [8-bit] Flag 348 - 1 Door uncovered
function flag_348_1_door_uncovered() => byte(0x374CE4)

// $374CE5: [8-bit] Flag 349 - 1 Door opened
function flag_349_1_door_opened() => byte(0x374CE5)

// $374CE6: [8-bit] Flag 350 - Mausoleum of the Giants - Map chest puzzle
//          0x02 = Chest unlocked
function flag_350_mausoleum_of_the_giants_map_chest_puzzle() => byte(0x374CE6)

// $374CE7: [8-bit] Flag 351 - Mausoleum of the Giants - Nebra Sky Disk
//          0x00 = Between positions
//          0x01 = Star
//          0x02 = Moon
//          0x03 = Sun
function flag_351_mausoleum_of_the_giants_nebra_sky_disk() => byte(0x374CE7)

// $374CE8: [8-bit] Flag 352 - Mausoleum of the Giants - Broke wall covering coin chest
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_352_mausoleum_of_the_giants_broke_wall_covering_coin_chest() => byte(0x374CE8)

// $374CE9: [8-bit] Flag 353 - Mausoleum of the Giants - Broke floor above entrance to Ghost Lord's room
function flag_353_mausoleum_of_the_giants_broke_floor_above_entrance_to_ghost_lords_room() => byte(0x374CE9)

// $374CEA: [8-bit] Flag 354 - Mausoleum of the Giants - Ghost Lord defeated
function flag_354_mausoleum_of_the_giants_ghost_lord_defeated() => byte(0x374CEA)

// $374CEB: [8-bit] Flag 355 - Mausoleum of the Giants - Unlocked ankh jewel chest
function flag_355_mausoleum_of_the_giants_unlocked_ankh_jewel_chest() => byte(0x374CEB)

// $374CEC: [8-bit] Flag 356 - Mausoleum of the Giants - Ankh exposure puzzle
//          0x01 = Pressed dais on statue of Ledo
//          0x02 = Sakit defeated
function flag_356_mausoleum_of_the_giants_ankh_exposure_puzzle() => byte(0x374CEC)

// $374CED: [8-bit] Flag 357 - Mausoleum of the Giants - Unlocked orb chest
//          "Strength lies at the foot of Futo But which one is Futo...?"
function flag_357_mausoleum_of_the_giants_unlocked_orb_chest() => byte(0x374CED)

// $374CEE: [8-bit] Flag 358 - Mausoleum of the Giants - Coin chest
function flag_358_mausoleum_of_the_giants_coin_chest() => byte(0x374CEE)

// $374CEF: [8-bit] Flag 359 - Mausoleum of the Giants - Ankh jewel chest laser wall
//          0x01 = Laser wall primed
//          0x02 = Laser wal acttivated
//          0x04 = Face destroyed, laser wall deactivated
function flag_359_mausoleum_of_the_giants_ankh_jewel_chest_laser_wall() => byte(0x374CEF)

// $374CF0: [8-bit] Flag 360 - Mausoleum of the Giants - Bado statue collapsed
//          Resets when Nebra Sky Disk is not set to star
function flag_360_mausoleum_of_the_giants_bado_statue_collapsed() => byte(0x374CF0)

// $374CF1: [8-bit] Flag 361 - Mausoleum of the Giants - Bado statue collapsed
//          Resets when Nebra Sky Disk is not set to star
//          There is a buffed Lizard Man in Gate of Illusion - Mausoleum of Fairies that spawns when this flag is set rather than when the hard mode flag is set
function flag_361_mausoleum_of_the_giants_bado_statue_collapsed() => byte(0x374CF1)

// $374CF2: [8-bit] Flag 362 - Mausoleum of the Giants - Hard Mode
//          0x00 = Tablet unread
//          0x01 = Read tablet once
//          0x02 = Hard mode activated
function flag_362_mausoleum_of_the_giants_hard_mode() => byte(0x374CF2)

// $374CF3: [8-bit] Flag 363 - Mausoleum of the Giants - Broke floor above Zebu's room
function flag_363_mausoleum_of_the_giants_broke_floor_above_zebus_room() => byte(0x374CF3)

// $374CF4: [8-bit] Flag 364 - Mausoleum of the Giants - Broke pot covering shop entrance
function flag_364_mausoleum_of_the_giants_broke_pot_covering_shop_entrance() => byte(0x374CF4)

// $374CF5: [8-bit] Flag 365 - 2 Door uncovered
function flag_365_2_door_uncovered() => byte(0x374CF5)

// $374CF6: [8-bit] Flag 366 - 2 Door opened
function flag_366_2_door_opened() => byte(0x374CF6)

// $374CF7: [8-bit] Flag 367 - Temple of the Sun - Sanctuary - Broke pot covering shop door
function flag_367_temple_of_the_sun_sanctuary_broke_pot_covering_shop_door() => byte(0x374CF7)

// $374CF8: [8-bit] Flag 368 - Temple of the Sun - Altar of War - Broke pot covering shop door
function flag_368_temple_of_the_sun_altar_of_war_broke_pot_covering_shop_door() => byte(0x374CF8)

// $374CF9: [8-bit] Flag 369 - Temple of the Sun - Ladder to Isis' Room
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_369_temple_of_the_sun_ladder_to_isis_room() => byte(0x374CF9)

// $374CFA: [8-bit] Flag 370 - Temple of the Sun - Watchtower - Broke block in wall to unlock exit
function flag_370_temple_of_the_sun_watchtower_broke_block_in_wall_to_unlock_exit() => byte(0x374CFA)

// $374CFB: [8-bit] Flag 371 - Temple of the Sun & Spring in the Sky - State variable related to Shawn Kosugi
function flag_371_temple_of_the_sun_spring_in_the_sky_state_variable_related_to_shawn_kosugi() => byte(0x374CFB)

// $374CFC: [8-bit] Flag 372 - Temple of the Sun - Altar of Mirrors - State of water column under origin seal
function flag_372_temple_of_the_sun_altar_of_mirrors_state_of_water_column_under_origin_seal() => byte(0x374CFC)

// $374CFD: [8-bit] Flag 373 - 3 Door uncovered
function flag_373_3_door_uncovered() => byte(0x374CFD)

// $374CFE: [8-bit] Flag 374 - 3 Door opened
function flag_374_3_door_opened() => byte(0x374CFE)

// $374CFF: [8-bit] Flag 375 - Temple of the Sun - Map chest unlocked
function flag_375_temple_of_the_sun_map_chest_unlocked() => byte(0x374CFF)

// $374D00: [8-bit] Flag 376 - Temple of the Sun - Minecart puzzle
//          0x01 = Pressed dais to drop minecart
//          0x02 = Pushed minecart to Altar of War
//          0x03 = Pushed minecart to Thoth's Room
//          0x04 = Pushed minecart to Sanctuary
//          0x05 = Pushed minecart to Aten's Room
//          0x06 = Ellmac defeated
function flag_376_temple_of_the_sun_minecart_puzzle() => byte(0x374D00)

// $374D01: [8-bit] Flag 377 - Temple of the Sun - Turning on platforms connecting Hathor's Room to Isis' Antechamber
//          0x01 = Wedge broken
//          0x02 = Ball dropped
//          0x03 = Light turned on / platforms active
function flag_377_temple_of_the_sun_turning_on_platforms_connecting_hathors_room_to_isis_antechamber() => byte(0x374D01)

// $374D02: [8-bit] Flag 378 - Temple of the Sun - Buer defeated
function flag_378_temple_of_the_sun_buer_defeated() => byte(0x374D02)

// $374D03: [8-bit] Flag 379 - Temple of the Sun - Isis' Pendant puzzle
//          0x01 = Broke ceiling in Isis' Antechamber
//          0x02 = Raised dais to open pendant chest
//          0x03 = Pressed dais to open pendant chest
function flag_379_temple_of_the_sun_isis_pendant_puzzle() => byte(0x374D03)

// $374D04: [8-bit] Flag 380 - Temple of the Sun - Removed weapon cover on knife
//          0x01 = Stepped on pressure plate
//          0x02 = Weapon cover removed
function flag_380_temple_of_the_sun_removed_weapon_cover_on_knife() => byte(0x374D04)

// $374D05: [8-bit] Flag 381 - Temple of the Sun - Related to sphinx statue
function flag_381_temple_of_the_sun_related_to_sphinx_statue() => byte(0x374D05)

// $374D06: [8-bit] Flag 382 - Temple of the Sun - Pyramid sun
//          0x00 = Initial state
//          0x01 = After taking enough hits to shift position
//          0x02 = Sun has fallen off screen
function flag_382_temple_of_the_sun_pyramid_sun() => byte(0x374D06)

// $374D07: [8-bit] Flag 383 - Temple of the Sun - Pyramid exit unlock
//          0x01 = Pressure plate active
//          0x02 = Pressure plate pressed
//          0x03 = Exit opening
//          0x04 = Exit opening
//          0x05 = Exit opened
function flag_383_temple_of_the_sun_pyramid_exit_unlock() => byte(0x374D07)

// $374D08: [8-bit] Flag 384 - Temple of the Sun & Spring in the Sky - State variable related to Shawn Kosugi
function flag_384_temple_of_the_sun_spring_in_the_sky_state_variable_related_to_shawn_kosugi() => byte(0x374D08)

// $374D09: [8-bit] Flag 385 - Temple of the Sun - Bronze Mirror chest
//          0x01 = Broke wall in Chamber of Extinction
//          0x02 = Pressed dais in Altar of Mirrors
//          0x03 = Chest unlocked
function flag_385_temple_of_the_sun_bronze_mirror_chest() => byte(0x374D09)

// $374D0A: [8-bit] Flag 386 - (unused)
function flag_386() => byte(0x374D0A)

// $374D0B: [8-bit] Flag 387 - Temple of the Sun - Triggered disappearance of ladder under grail point
function flag_387_temple_of_the_sun_triggered_disappearance_of_ladder_under_grail_point() => byte(0x374D0B)

// $374D0C: [8-bit] Flag 388 - Temple of the Sun - Aim and shoot
//          0x02 = Aimed and shot
function flag_388_temple_of_the_sun_aim_and_shoot() => byte(0x374D0C)

// $374D0D: [8-bit] Flag 389 - Temple of the Sun - Poverty chest unlock
//          0x01 = Wall bombed out
//          0x02 = Chest unlocked
function flag_389_temple_of_the_sun_poverty_chest_unlock() => byte(0x374D0D)

// $374D0E: [8-bit] Flag 390 - Temple of the Sun - Spawned wall blocking Watchtower exit
function flag_390_temple_of_the_sun_spawned_wall_blocking_watchtower_exit() => byte(0x374D0E)

// $374D0F: [8-bit] Flag 391 - Temple of the Sun - Altar of Mirrors - Origin seal broken
function flag_391_temple_of_the_sun_altar_of_mirrors_origin_seal_broken() => byte(0x374D0F)

// $374D10: [8-bit] Flag 392 - Temple of the Sun - Ladder underneath grail point
//          0x00 = Ladder retracted
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_392_temple_of_the_sun_ladder_underneath_grail_point() => byte(0x374D10)

// $374D11: [8-bit] Flag 393 - Temple of the Sun - Aim and shoot pot column removed
function flag_393_temple_of_the_sun_aim_and_shoot_pot_column_removed() => byte(0x374D11)

// $374D12: [8-bit] Flag 394 - Temple of the Sun - Aim and shoot wall removed
function flag_394_temple_of_the_sun_aim_and_shoot_wall_removed() => byte(0x374D12)

// $374D13: [8-bit] Flag 395 - Temple of the Sun - Coin chest
function flag_395_temple_of_the_sun_coin_chest() => byte(0x374D13)

// $374D14: [8-bit] Flag 396 - Temple of the Sun - Those that fly must be cast down
function flag_396_temple_of_the_sun_those_that_fly_must_be_cast_down() => byte(0x374D14)

// $374D15: [8-bit] Flag 397 - Temple of the Sun - Death seal broken
function flag_397_temple_of_the_sun_death_seal_broken() => byte(0x374D15)

// $374D16: [8-bit] Flag 398 - Temple of the Sun - Thoth's Room - Origin seal
//          0x01 = Origin seal exposed
//          0x02 = Origin seal broken
//          0x03 = Shine effect on Mulbruk's door complete
function flag_398_temple_of_the_sun_thoths_room_origin_seal() => byte(0x374D16)

// $374D17: [8-bit] Flag 399 - Temple of the Sun - Meditated under Wedjet
function flag_399_temple_of_the_sun_meditated_under_wedjet() => byte(0x374D17)

// $374D18: [8-bit] Flag 400 - Spring in the Sky - Birth seal broken
function flag_400_spring_in_the_sky_birth_seal_broken() => byte(0x374D18)

// $374D19: [8-bit] Flag 401 - Spring in the Sky - Nuckelavee defeated
function flag_401_spring_in_the_sky_nuckelavee_defeated() => byte(0x374D19)

// $374D1A: [8-bit] Flag 402 - Spring in the Sky - Removed weapon cover on Caltrops
//          0x01 = Pressed dais
//          0x02 = Weapon cover removed
function flag_402_spring_in_the_sky_removed_weapon_cover_on_caltrops() => byte(0x374D1A)

// $374D1B: [8-bit] Flag 403 - Spring in the Sky - Ankh exposure sequence - enables dais in Oannes' Waterfall
//          Sets after flag 1008 goes to 3
function flag_403_spring_in_the_sky_ankh_exposure_sequence_enables_dais_in_oannes_waterfall() => byte(0x374D1B)

// $374D1C: [8-bit] Flag 404 - Spring in the Sky - Broke Verdandi's hatch
function flag_404_spring_in_the_sky_broke_verdandis_hatch() => byte(0x374D1C)

// $374D1D: [8-bit] Flag 405 - Spring in the Sky - Broke Skuld's hatch
function flag_405_spring_in_the_sky_broke_skulds_hatch() => byte(0x374D1D)

// $374D1E: [8-bit] Flag 406 - Spring in the Sky - Map chest unlocked
function flag_406_spring_in_the_sky_map_chest_unlocked() => byte(0x374D1E)

// $374D1F: [8-bit] Flag 407 - Spring in the Sky - Fishman Shop unlock sequence
//          0x01 = Beat up Gyonin in fish tank
//          0x02 = Origin seal broken
//          0x03 = Key Fairy unlocked new shop items
function flag_407_spring_in_the_sky_fishman_shop_unlock_sequence() => byte(0x374D1F)

// $374D20: [8-bit] Flag 408 - Spring in the Sky - Scalesphere chest unlocked
function flag_408_spring_in_the_sky_scalesphere_chest_unlocked() => byte(0x374D20)

// $374D21: [8-bit] Flag 409 - Spring in the Sky - Broke waterwheel to flood Sanctuary
function flag_409_spring_in_the_sky_broke_waterwheel_to_flood_sanctuary() => byte(0x374D21)

// $374D22: [8-bit] Flag 410 - Spring in the Sky - Pointless flag
//          If its value is 2, entering Waterfall Approach D2 will set it to 3.
//          Yet, no other objects or script cards reference this flag, so it will always remain 0.
function flag_410_spring_in_the_sky_pointless_flag() => byte(0x374D22)

// $374D23: [8-bit] Flag 411 - Spring in the Sky - Sanctuary
//          0x01 = Origin seal broken
//          0x02 = Walls retracted
function flag_411_spring_in_the_sky_sanctuary() => byte(0x374D23)

// $374D24: [8-bit] Flag 412 - Spring in the Sky - Broke wall covering hidden NPC room
function flag_412_spring_in_the_sky_broke_wall_covering_hidden_npc_room() => byte(0x374D24)

// $374D25: [8-bit] Flag 413 - Spring in the Sky - Chest above fish tank unlocked
function flag_413_spring_in_the_sky_chest_above_fish_tank_unlocked() => byte(0x374D25)

// $374D26: [8-bit] Flag 414 - Spring in the Sky - Related to Shawn appearing near drainplug
function flag_414_spring_in_the_sky_related_to_shawn_appearing_near_drainplug() => byte(0x374D26)

// $374D27: [8-bit] Flag 415 - Spring in the Sky - Ankh exposure puzzle
//          0x01 = Pressed dais in Oannes' Waterfall
//          0x02 = Bahamut defeated
//          Exposing the ankh also relies flag 409
function flag_415_spring_in_the_sky_ankh_exposure_puzzle() => byte(0x374D27)

// $374D28: [8-bit] Flag 416 - Spring in the Sky - Raising drain plug in Annunaki's Stone Basin
//          0x01 = Broke wall covering chain
//          0x02 = Broke pulley
//          0x03 = Drainplug raised
function flag_416_spring_in_the_sky_raising_drain_plug_in_annunakis_stone_basin() => byte(0x374D28)

// $374D29: [8-bit] Flag 417 - Spring in the sky - Broke wall covering coin chest
function flag_417_spring_in_the_sky_broke_wall_covering_coin_chest() => byte(0x374D29)

// $374D2A: [8-bit] Flag 418 - Spring in the Sky - Coin chest
function flag_418_spring_in_the_sky_coin_chest() => byte(0x374D2A)

// $374D2B: [8-bit] Flag 419 - Spring in the Sky - Broke floor next to entrance of Nuckelavee's room
function flag_419_spring_in_the_sky_broke_floor_next_to_entrance_of_nuckelavees_room() => byte(0x374D2B)

// $374D2C: [8-bit] Flag 420 - Spring in the Sky - Ladder in Nuckelavee's room
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_420_spring_in_the_sky_ladder_in_nuckelavees_room() => byte(0x374D2C)

// $374D2D: [8-bit] Flag 421 - Spring in the Sky - Breakable floors in Room of Origin
//          Bits0-2 = Individual floor segments broken
function flag_421_spring_in_the_sky_breakable_floors_in_room_of_origin() => byte(0x374D2D)

// $374D2E: [8-bit] Flag 422 - Spring in the Sky - Turned off laser wall in Oannes' Waterfall
function flag_422_spring_in_the_sky_turned_off_laser_wall_in_oannes_waterfall() => byte(0x374D2E)

// $374D2F: [8-bit] Flag 423 - Mausoleum of the Giants - Ji's statue is kneeling
//          Resets when nebra sky disk is not set to moon
function flag_423_mausoleum_of_the_giants_jis_statue_is_kneeling() => byte(0x374D2F)

// $374D30: [8-bit] Flag 424 - Mausoleum of the Giants - Used in Ji statue kneeling animation
function flag_424_mausoleum_of_the_giants_used_in_ji_statue_kneeling_animation() => byte(0x374D30)

// $374D31: [8-bit] Flag 425 - Inferno Cavern - Statue of the Giant
//          0x01 = Destroyed snake statue
//          0x02 = Placed weight on exposed dais
//          0x03 = Statue of the Giant destroyed
function flag_425_inferno_cavern_statue_of_the_giant() => byte(0x374D31)

// $374D32: [8-bit] Flag 426 - Inferno Cavern - Broke wall in laval pit covering coin chest
function flag_426_inferno_cavern_broke_wall_in_laval_pit_covering_coin_chest() => byte(0x374D32)

// $374D33: [8-bit] Flag 427 - Inferno Cavern - Coin chest (Twin's Footstool)
function flag_427_inferno_cavern_coin_chest() => byte(0x374D33)

// $374D34: [8-bit] Flag 428 - Inferno Cavern - Fake Sacred Orb 'collected'
function flag_428_inferno_cavern_fake_sacred_orb_collected() => byte(0x374D34)

// $374D35: [8-bit] Flag 429 - Inferno Cavern - Map chest unlocked
function flag_429_inferno_cavern_map_chest_unlocked() => byte(0x374D35)

// $374D36: [8-bit] Flag 430 - Inferno Cavern - Turned off laser wall blocking tablet
function flag_430_inferno_cavern_turned_off_laser_wall_blocking_tablet() => byte(0x374D36)

// $374D37: [8-bit] Flag 431 - Inferno Cavern - Pazuzu defeated
//          0x01 = Wall seal broken
//          0x02 = Passageway exposed
//          0x03 = Pazuzu defeated
function flag_431_inferno_cavern_pazuzu_defeated() => byte(0x374D37)

// $374D38: [8-bit] Flag 432 - Inferno Cavern - Chain whip puzzle solution
//          0x01 = Dais pressed
//          0x02 = Weapon cover removed
function flag_432_inferno_cavern_chain_whip_puzzle_solution() => byte(0x374D38)

// $374D39: [8-bit] Flag 433 - Inferno Cavern - Chain whip puzzle: left column raised
function flag_433_inferno_cavern_chain_whip_puzzle_left_column_raised() => byte(0x374D39)

// $374D3A: [8-bit] Flag 434 - Inferno Cavern - Chain whip puzzle: right column raised
function flag_434_inferno_cavern_chain_whip_puzzle_right_column_raised() => byte(0x374D3A)

// $374D3B: [8-bit] Flag 435 - Inferno Cavern - Serdab of Light state
//          0x01 = Wall broken open
//          0x02 = Push block puzzle solved
//          0x03 = Weapon cover removed
function flag_435_inferno_cavern_serdab_of_light_state() => byte(0x374D3B)

// $374D3C: [8-bit] Flag 436 - Inferno Cavern - Ankh exposure puzzle
//          0x01 = Dais being raised
//          0x02 = Dais raised
//          0x03 = Dais exposed in lava well
//          0x04 = Ankh exposed
//          0x05 = Viy defeated
function flag_436_inferno_cavern_ankh_exposure_puzzle() => byte(0x374D3C)

// $374D3D: [8-bit] Flag 437 - Inferno Cavern - Broke open Additional Text Memory wall
function flag_437_inferno_cavern_broke_open_additional_text_memory_wall() => byte(0x374D3D)

// $374D3E: [8-bit] Flag 438 - Inferno Cavern - Entrance to Darkness Sanctuary opened
function flag_438_inferno_cavern_entrance_to_darkness_sanctuary_opened() => byte(0x374D3E)

// $374D3F: [8-bit] Flag 439 - Inferno Cavern - Ice cape puzzle
//          0x02 = Chest unlocked
function flag_439_inferno_cavern_ice_cape_puzzle() => byte(0x374D3F)

// $374D40: [8-bit] Flag 440 - (unused)
function flag_440() => byte(0x374D40)

// $374D41: [8-bit] Flag 441 - Inferno Cavern - Unlocked Echidna's Chamber coin chest
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_441_inferno_cavern_unlocked_echidnas_chamber_coin_chest() => byte(0x374D41)

// $374D42: [8-bit] Flag 442 - Inferno Cavern - Coin chest (Echidna's Chamber)
function flag_442_inferno_cavern_coin_chest() => byte(0x374D42)

// $374D43: [8-bit] Flag 443 - Inferno Cavern - Statue of the Giant: right-hand breakable floor
function flag_443_inferno_cavern_statue_of_the_giant_righthand_breakable_floor() => byte(0x374D43)

// $374D44: [8-bit] Flag 444 - Inferno Cavern - Statue of the Giant: left-hand breakable floor
function flag_444_inferno_cavern_statue_of_the_giant_lefthand_breakable_floor() => byte(0x374D44)

// $374D45: [8-bit] Flag 445 - 4 Door uncovered
function flag_445_4_door_uncovered() => byte(0x374D45)

// $374D46: [8-bit] Flag 446 - 4 Door opened
function flag_446_4_door_opened() => byte(0x374D46)

// $374D47: [8-bit] Flag 447 - Inferno Cavern - Opened wall blocking jump to shop
function flag_447_inferno_cavern_opened_wall_blocking_jump_to_shop() => byte(0x374D47)

// $374D48: [8-bit] Flag 448 - 7 Door opened
function flag_448_7_door_opened() => byte(0x374D48)

// $374D49: [8-bit] Flag 449 - Spring in the Sky - Birth seal ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_449_spring_in_the_sky_birth_seal_ladder() => byte(0x374D49)

// $374D4A: [8-bit] Flag 450 - Chamber of Birth / Chamber of Extinction - State of permanent lighting
//          0x01 = Vishnu's Room - Destroyed life seal
//          0x02 = Mural of Light - Destroyed life seal
//          0x03 = Lit Mural of Light
function flag_450_chamber_of_birth_chamber_of_extinction_state_of_permanent_lighting() => byte(0x374D4A)

// $374D4B: [8-bit] Flag 451 - Chamber of Extinction - Ankh exposure puzzle
//          0x01 = Weight placed
//          0x02 = Mural of Invocation lowered
//          0x03 = Mural of Invocation shown the Pochette Key
//          0x04 = Palenque defeated
function flag_451_chamber_of_extinction_ankh_exposure_puzzle() => byte(0x374D4B)

// $374D4C: [8-bit] Flag 452 - Chamber of Extinction - Map chest unlocked
function flag_452_chamber_of_extinction_map_chest_unlocked() => byte(0x374D4C)

// $374D4D: [8-bit] Flag 453 - Chamber of Extinction - Sacred orb chest unlocked
function flag_453_chamber_of_extinction_sacred_orb_chest_unlocked() => byte(0x374D4D)

// $374D4E: [8-bit] Flag 454 - Chamber of Extinction - Hekatonkheires defeated
//          0x01 = Hekatonkheires defeated
//          0x02 = Weapon cover removed
function flag_454_chamber_of_extinction_hekatonkheires_defeated() => byte(0x374D4E)

// $374D4F: [8-bit] Flag 455 - Chamber of Extinction - State of Mural Depicting the Power of Words
//          0x01 = Magatama Jewel used
//          0x02 = Mural Depicting the Power of Words lit up
function flag_455_chamber_of_extinction_state_of_mural_depicting_the_power_of_words() => byte(0x374D4F)

// $374D50: [8-bit] Flag 456 - Chamber of Extinction - Birth seal broken
function flag_456_chamber_of_extinction_birth_seal_broken() => byte(0x374D50)

// $374D51: [8-bit] Flag 457 - Chamber of Extinction - Door to Gate of Time opened
function flag_457_chamber_of_extinction_door_to_gate_of_time_opened() => byte(0x374D51)

// $374D52: [8-bit] Flag 458 - Chamber of Extinction - Palenque's room state
//          0x01 = Weight placed
//          0x02 = Platforms dropped
//          0x03 = Mural exposed
function flag_458_chamber_of_extinction_palenques_room_state() => byte(0x374D52)

// $374D53: [8-bit] Flag 459 - Chamber of Extinction - Gozu and Mezu defeated
function flag_459_chamber_of_extinction_gozu_and_mezu_defeated() => byte(0x374D53)

// $374D54: [8-bit] Flag 460 - Chamber of Extinction - Magatama Chamber fake ankh triggered
function flag_460_chamber_of_extinction_magatama_chamber_fake_ankh_triggered() => byte(0x374D54)

// $374D55: [8-bit] Flag 461 - Chamber of Extinction - Temporary lighting active
function flag_461_chamber_of_extinction_temporary_lighting_active() => byte(0x374D55)

// $374D56: [8-bit] Flag 462 - Chamber of Extinction - Pather of Life - Laser wall
//          0x01 = Stepped on pressue plate / laser wall dispelled
function flag_462_chamber_of_extinction_pather_of_life_laser_wall() => byte(0x374D56)

// $374D57: [8-bit] Flag 463 - Chamber of Extinction - Approach to the Sanctuary
//          0x02 = Enables crushers after fake ankh triggered
function flag_463_chamber_of_extinction_approach_to_the_sanctuary() => byte(0x374D57)

// $374D58: [8-bit] Flag 464 - Chamber of Birth - 6 Door unlocked
function flag_464_chamber_of_birth_6_door_unlocked() => byte(0x374D58)

// $374D59: [8-bit] Flag 465 - Chamber of Extinction - Lake of Life - Broke open entrance to wall maze
function flag_465_chamber_of_extinction_lake_of_life_broke_open_entrance_to_wall_maze() => byte(0x374D59)

// $374D5A: [8-bit] Flag 466 - Chamber of Extinction - Shiva's Cruxifix -  Broke open entrance to shop
function flag_466_chamber_of_extinction_shivas_cruxifix_broke_open_entrance_to_shop() => byte(0x374D5A)

// $374D5B: [8-bit] Flag 467 - Chamber of Extinction - Mural of Light - Broke pot covering NPC room
function flag_467_chamber_of_extinction_mural_of_light_broke_pot_covering_npc_room() => byte(0x374D5B)

// $374D5C: [8-bit] Flag 468 - Temple of the Sun - Altar of Mirrors - Broke pot covering dais
function flag_468_temple_of_the_sun_altar_of_mirrors_broke_pot_covering_dais() => byte(0x374D5C)

// $374D5D: [8-bit] Flag 469 - Mausoleum of the Giants - Map puzzle - Stepped on pressure plate to rotate wall symbol
function flag_469_mausoleum_of_the_giants_map_puzzle_stepped_on_pressure_plate_to_rotate_wall_symbol() => byte(0x374D5D)

// $374D5E: [8-bit] Flag 470 - Mausoleum of the Giants - Used to remove objects from room while Sakit fight is active
function flag_470_mausoleum_of_the_giants_used_to_remove_objects_from_room_while_sakit_fight_is_active() => byte(0x374D5E)

// $374D5F: [8-bit] Flag 471 - Twin Labyrinths - Control for poison timer
function flag_471_twin_labyrinths_control_for_poison_timer() => byte(0x374D5F)

// $374D60: [8-bit] Flag 472 - Twin Labyrinths - Peryton defeated
function flag_472_twin_labyrinths_peryton_defeated() => byte(0x374D60)

// $374D61: [8-bit] Flag 473 - Twin Labyrinths - Poseidon's Room - Collapsing floor
function flag_473_twin_labyrinths_poseidons_room_collapsing_floor() => byte(0x374D61)

// $374D62: [8-bit] Flag 474 - Twin Labyrinths - Collapsing floor in lower section of Katana room
function flag_474_twin_labyrinths_collapsing_floor_in_lower_section_of_katana_room() => byte(0x374D62)

// $374D63: [8-bit] Flag 475 - Twin Labyrinths - Grail point elevator
//          0x01 = Pressed dais
//          0x02 = Elevator appeared
function flag_475_twin_labyrinths_grail_point_elevator() => byte(0x374D63)

// $374D64: [8-bit] Flag 476 - Twin Labyrinths - Dispelling the sadness of the Twins
//          0x01 = First weight placed
//          0x02 = Second weight placed
function flag_476_twin_labyrinths_dispelling_the_sadness_of_the_twins() => byte(0x374D64)

// $374D65: [8-bit] Flag 477 - Twin Labyrinths - Map chest unlocked
//          Also used by the 'Crystal Skull' chest in True Shrine of the Mother, which would award a Hand Scanner were it not already open.
function flag_477_twin_labyrinths_map_chest_unlocked() => byte(0x374D65)

// $374D66: [8-bit] Flag 478 - Twin Labyrinths - Statue of Buranun
//          0x01 = Eyes lit up
function flag_478_twin_labyrinths_statue_of_buranun() => byte(0x374D66)

// $374D67: [8-bit] Flag 479 - Twin Labyrinths - Black Witch summoned
function flag_479_twin_labyrinths_black_witch_summoned() => byte(0x374D67)

// $374D68: [8-bit] Flag 480 - Twin Labyrinths - Ankh exposure puzzle
//          0x01 = White witch summoned
//          0x02 = White witch defeated
//          0x03 = Baphomet defeated
function flag_480_twin_labyrinths_ankh_exposure_puzzle() => byte(0x374D68)

// $374D69: [8-bit] Flag 481 - Twin Labyrinths - Ring unlock
//          0x01 = Stepped on pressure plate
//          0x02 = Crusher retracted
function flag_481_twin_labyrinths_ring_unlock() => byte(0x374D69)

// $374D6A: [8-bit] Flag 482 - Twin Labyrinths - Zu defeated
function flag_482_twin_labyrinths_zu_defeated() => byte(0x374D6A)

// $374D6B: [8-bit] Flag 483 - Tiwn Labyrinths - Sacred orb chest unlocked
function flag_483_tiwn_labyrinths_sacred_orb_chest_unlocked() => byte(0x374D6B)

// $374D6C: [8-bit] Flag 484 - Twin Labyrinths - Lamp shop unlocked
function flag_484_twin_labyrinths_lamp_shop_unlocked() => byte(0x374D6C)

// $374D6D: [8-bit] Flag 485 - Twin Labyrinths - Statue of Idigna
//          0x01 = Eyes lit up
//          0x02 = Weight placed
function flag_485_twin_labyrinths_statue_of_idigna() => byte(0x374D6D)

// $374D6E: [8-bit] Flag 486 - Twin Labyrinths - Breakable wall to the left of ankh jewel chest
function flag_486_twin_labyrinths_breakable_wall_to_the_left_of_ankh_jewel_chest() => byte(0x374D6E)

// $374D6F: [8-bit] Flag 487 - Twin Labyrinths - Katana weapon cover removed
//          0x01 = Stepped on pressure plate
//          0x02 = Cover removed
function flag_487_twin_labyrinths_katana_weapon_cover_removed() => byte(0x374D6F)

// $374D70: [8-bit] Flag 488 - Twin Labyrinths - Poseidon's Room elevator
//          0x02 = Elevator active
function flag_488_twin_labyrinths_poseidons_room_elevator() => byte(0x374D70)

// $374D71: [8-bit] Flag 489 - Twin Labyrinths - Stepped on first pressure plate for Katana puzzle
function flag_489_twin_labyrinths_stepped_on_first_pressure_plate_for_katana_puzzle() => byte(0x374D71)

// $374D72: [8-bit] Flag 490 - Twin Labyrinths - Number of items purchased at little brother's shop
function flag_490_twin_labyrinths_number_of_items_purchased_at_little_brothers_shop() => byte(0x374D72)

// $374D73: [8-bit] Flag 491 - Twin Labyrinths - Zu's Room coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_491_twin_labyrinths_zus_room_coin_chest_unlocked() => byte(0x374D73)

// $374D74: [8-bit] Flag 492 - Twin Labyrinths - Coin chest (Zu's Room)
function flag_492_twin_labyrinths_coin_chest() => byte(0x374D74)

// $374D75: [8-bit] Flag 493 - Twin Labyrinths - Demon Altar coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_493_twin_labyrinths_demon_altar_coin_chest_unlocked() => byte(0x374D75)

// $374D76: [8-bit] Flag 494 - Twin Labyrinths - Coin chest (Demon Altar)
function flag_494_twin_labyrinths_coin_chest() => byte(0x374D76)

// $374D77: [8-bit] Flag 495 - Twin Labyrinths - Bombed out wall for lamp shop puzzle
function flag_495_twin_labyrinths_bombed_out_wall_for_lamp_shop_puzzle() => byte(0x374D77)

// $374D78: [8-bit] Flag 496 - Twin Labyrinths - Big Brother's shop unlocked
//          0x01 = Met purchase requirements
//          0x02 = Shop exposed
function flag_496_twin_labyrinths_big_brothers_shop_unlocked() => byte(0x374D78)

// $374D79: [8-bit] Flag 497 - Twin Labyrinths - 6 Ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_497_twin_labyrinths_6_ladder() => byte(0x374D79)

// $374D7A: [8-bit] Flag 498 - Twin Labyrinths - Skull ladder opened
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_498_twin_labyrinths_skull_ladder_opened() => byte(0x374D7A)

// $374D7B: [8-bit] Flag 499 - Twin Labyrinths - Zodiac - Breakable wall covering bottom of ladder
function flag_499_twin_labyrinths_zodiac_breakable_wall_covering_bottom_of_ladder() => byte(0x374D7B)

// $374D7C: [8-bit] Flag 500 - Endless Corridor - Tai Sui defeated
function flag_500_endless_corridor_tai_sui_defeated() => byte(0x374D7C)

// $374D7D: [8-bit] Flag 501 - Endless Corridor - Freyja state
//          0x01 = Given quest to retrieve Isis' Pendant
//          0x02 = Handed in Isis' Pendant
function flag_501_endless_corridor_freyja_state() => byte(0x374D7D)

// $374D7E: [8-bit] Flag 802 - Endless Corridor - Map chest unlocked
//          0x01 = Went through endless gate
//          0x02 = Chest unlocked
function flag_802_endless_corridor_map_chest_unlocked() => byte(0x374D7E)

// $374D7F: [8-bit] Flag 503  - Endless Corridor - Key sword weapon cover
//          0x01 = Removal animation
//          0x02 = Weapon cover removed
function flag_503_endless_corridor_key_sword_weapon_cover() => byte(0x374D7F)

// $374D80: [8-bit] Flag 504 - Endless Corridor - First Endless Corridor - Keyhole puzzle
//          0x01 = Unlocked
function flag_504_endless_corridor_first_endless_corridor_keyhole_puzzle() => byte(0x374D80)

// $374D81: [8-bit] Flag 505 - Endless Corridor - Second Endless Corridor - Keyhole
//          0x01 = Doors puzzle solved / keyhole exposed
//          0x02 = Unlocked
function flag_505_endless_corridor_second_endless_corridor_keyhole() => byte(0x374D81)

// $374D82: [8-bit] Flag 506 - Endless Corridor - Third Endless Corridor - Keyhole
//          0x01 = Beat timer / keyhole exposed
//          0x02 = Unlocked
function flag_506_endless_corridor_third_endless_corridor_keyhole() => byte(0x374D82)

// $374D83: [8-bit] Flag 507 - Endless Corridor - Fourth Endless Corridor - Keyhole
//          0x01 = Activated dais / keyhole exposed
//          0x02 = Unlocked
function flag_507_endless_corridor_fourth_endless_corridor_keyhole() => byte(0x374D83)

// $374D84: [8-bit] Flag 508 - Endless Corridor - Fifth Endless Corridor - Down ladder
//          0x01 = Unlocked
function flag_508_endless_corridor_fifth_endless_corridor_down_ladder() => byte(0x374D84)

// $374D85: [8-bit] Flag 509 - (unused)
function flag_509() => byte(0x374D85)

// $374D86: [8-bit] Flag 510 - (unused)
function flag_510() => byte(0x374D86)

// $374D87: [8-bit] Flag 511 - Endless Corridor - Fifth Endless Corridor - Shortcut wall destroyed
function flag_511_endless_corridor_fifth_endless_corridor_shortcut_wall_destroyed() => byte(0x374D87)

// $374D88: [8-bit] Flag 512 - Endless Corridor - Origin seal broken
function flag_512_endless_corridor_origin_seal_broken() => byte(0x374D88)

// $374D89: [8-bit] Flag 513 - Endless Corridor - Giltoiyo's ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_513_endless_corridor_giltoiyos_ladder() => byte(0x374D89)

// $374D8A: [8-bit] Flag 514 - Endless Corridor - Coin chest unlocked
//          0x01 = Broke wall
//          0x02 = Chest unlocked
function flag_514_endless_corridor_coin_chest_unlocked() => byte(0x374D8A)

// $374D8B: [8-bit] Flag 515 - Endless Corridor - Coin chest
function flag_515_endless_corridor_coin_chest() => byte(0x374D8B)

// $374D8C: [8-bit] Flag 516 - Endless Corridor - Controls First Endless Corridor unlock animation
function flag_516_endless_corridor_controls_first_endless_corridor_unlock_animation() => byte(0x374D8C)

// $374D8D: [8-bit] Flag 517 - Endless Corridor - Controls Second Endless Corridor unlock animation
function flag_517_endless_corridor_controls_second_endless_corridor_unlock_animation() => byte(0x374D8D)

// $374D8E: [8-bit] Flag 518 - Endless Corridor - Controls Third Endless Corridor unlock animation
function flag_518_endless_corridor_controls_third_endless_corridor_unlock_animation() => byte(0x374D8E)

// $374D8F: [8-bit] Flag 519 - Endless Corridor - Controls Fourth Endless Corridor unlock animation
function flag_519_endless_corridor_controls_fourth_endless_corridor_unlock_animation() => byte(0x374D8F)

// $374D90: [8-bit] Flag 520 - (unused)
function flag_520() => byte(0x374D90)

// $374D91: [8-bit] Flag 521 - Gate of Illusion - Shop screen ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_521_gate_of_illusion_shop_screen_ladder() => byte(0x374D91)

// $374D92: [8-bit] Flag 522 - Gate of Illusion - Explosion chest
//          0x01 = Chest unlocked
//          0x02 = Chest opened / explosion spawn trigger
//          0x03 = Explosion complete
function flag_522_gate_of_illusion_explosion_chest() => byte(0x374D92)

// $374D93: [8-bit] Flag 523 - Gate of Illusion - Fairy Clothes chest unlocked
function flag_523_gate_of_illusion_fairy_clothes_chest_unlocked() => byte(0x374D93)

// $374D94: [8-bit] Flag 524 - Gate of Illusion - Broke pot to enable teleporter
//          There's a pot in the middle room of the Fool's Confusion Corridor that must be broken in order to enable one of the teleporters?!
function flag_524_gate_of_illusion_broke_pot_to_enable_teleporter() => byte(0x374D94)

// $374D95: [8-bit] Flag 525 - Shrine of the Mother - Sacred Orb chest unlocked
function flag_525_shrine_of_the_mother_sacred_orb_chest_unlocked() => byte(0x374D95)

// $374D96: [8-bit] Flag 526 - Shrine of the Mother - Map chest unlocked
function flag_526_shrine_of_the_mother_map_chest_unlocked() => byte(0x374D96)

// $374D97: [8-bit] Flag 527 - Shrine of the Mother - Death seal chest unlocked
function flag_527_shrine_of_the_mother_death_seal_chest_unlocked() => byte(0x374D97)

// $374D98: [8-bit] Flag 528 - Shrine of the Mother - Shawn's laptop
//          0x01 = Death seal broken
//          0x02 = Laptop read
function flag_528_shrine_of_the_mother_shawns_laptop() => byte(0x374D98)

// $374D99: [8-bit] Flag 529 - Shrine of the Mother - Life seal broken (Crystal Skull chest)
function flag_529_shrine_of_the_mother_life_seal_broken() => byte(0x374D99)

// $374D9A: [8-bit] Flag 530 - Shrine of the Mother - Diary chest pillar
//          0x01 = Pillar successfully raised
//          0x02 = Diary collected
//          0x03 = Showed Xelpud the Diary
function flag_530_shrine_of_the_mother_diary_chest_pillar() => byte(0x374D9A)

// $374D9B: [8-bit] Flag 531 - Shrine of the Mother - Dragon statue
//          0x01 = Statue appearing
//          0x02 = Statue appeared
function flag_531_shrine_of_the_mother_dragon_statue() => byte(0x374D9B)

// $374D9C: [8-bit] Flag 532 - Gate of Illusion - Ladder leading from Fool's Confusion Corridor to elevator room
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_532_gate_of_illusion_ladder_leading_from_fools_confusion_corridor_to_elevator_room() => byte(0x374D9C)

// $374D9D: [8-bit] Flag 533 - Shrine of the Mother - Coin chest unlocked
//          0x01 = Broke open wall with katana
//          0x02 = Chest unlocked
function flag_533_shrine_of_the_mother_coin_chest_unlocked() => byte(0x374D9D)

// $374D9E: [8-bit] Flag 534 - Shrine of the Mother - Coin chest
function flag_534_shrine_of_the_mother_coin_chest() => byte(0x374D9E)

// $374D9F: [8-bit] Flag 535 - Shrine of the Mother - Broke floor to connect to 6 ladder
function flag_535_shrine_of_the_mother_broke_floor_to_connect_to_6_ladder() => byte(0x374D9F)

// $374DA0: [8-bit] Flag 536 - Shrine of the Mother - Placed the Dragon Bone
function flag_536_shrine_of_the_mother_placed_the_dragon_bone() => byte(0x374DA0)

// $374DA1: [8-bit] Flag 537 - Shrine of the Mother - Priming for Xelpud to raise diary chest column
//          0x01 = Saw Diary chest
//          0x02 = Had conversation with Xelpud
//          0x03 = Collected Diary
function flag_537_shrine_of_the_mother_priming_for_xelpud_to_raise_diary_chest_column() => byte(0x374DA1)

// $374DA2: [8-bit] Flag 538 - Shrine of the Mother - Philosopher's ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_538_shrine_of_the_mother_philosophers_ladder() => byte(0x374DA2)

// $374DA3: [8-bit] Flag 539 - Shrine of the Mother - Shawn Kosugi related
function flag_539_shrine_of_the_mother_shawn_kosugi_related() => byte(0x374DA3)

// $374DA4: [8-bit] Flag 540 - Surface - Xelpud's tent is open
function flag_540_surface_xelpuds_tent_is_open() => byte(0x374DA4)

// $374DA5: [8-bit] Flag 541 - Four boss check state
//          Used to control sending of Xelpud email #43 and availablitiy of MSX2 in shop
//          0x01 = Four guardians defeated
//          0x02 = Purchased Mobile Super X2
function flag_541_four_boss_check_state() => byte(0x374DA5)

// $374DA6: [8-bit] Flag 542 - Chamber of Extinction - Tracks whether Mural of Light has been raised out of the grail point room
function flag_542_chamber_of_extinction_tracks_whether_mural_of_light_has_been_raised_out_of_the_grail_point_room() => byte(0x374DA6)

// $374DA7: [8-bit] Flag 543 - Gate of Illusion - Breakable wall covering Duplex's room
function flag_543_gate_of_illusion_breakable_wall_covering_duplexs_room() => byte(0x374DA7)

// $374DA8: [8-bit] Flag 544 - (unused)
function flag_544() => byte(0x374DA8)

// $374DA9: [8-bit] Flag 545 - Shrine of the Mother - Bounce Shot chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_545_shrine_of_the_mother_bounce_shot_chest_unlocked() => byte(0x374DA9)

// $374DAA: [8-bit] Flag 546 - Gate of Illusion - Explosion chest / map chest puzzle
//          Bits0-3 = Tracking for walking in front of individual chests
//          Bit4 = Walked in front of all chests
function flag_546_gate_of_illusion_explosion_chest_map_chest_puzzle() => byte(0x374DAA)

// $374DAB: [8-bit] Flag 547 - Gate of Illusion - Removed covering wall below 'Search on bended knee' spot
function flag_547_gate_of_illusion_removed_covering_wall_below_search_on_bended_knee_spot() => byte(0x374DAB)

// $374DAC: [8-bit] Flag 548 - Gate of Illusion - State variablle for tracking flow of sacrificial maidens through various rooms
function flag_548_gate_of_illusion_state_variablle_for_tracking_flow_of_sacrificial_maidens_through_various_rooms() => byte(0x374DAC)

// $374DAD: [8-bit] Flage 549 - Gate of Illusion - Breakable wall between Ba's room and cog room
function flage_549_gate_of_illusion_breakable_wall_between_bas_room_and_cog_room() => byte(0x374DAD)

// $374DAE: [8-bit] Flag 550 - Gate of Illusion - Placed Fruit of Eden
function flag_550_gate_of_illusion_placed_fruit_of_eden() => byte(0x374DAE)

// $374DAF: [8-bit] Flag 551 - Gate of Illusion - Upper floors unlock
//          0x01 = Skeleton dais / laser wall removed
//          0x02 = 6 dais puzzle solved
//          0x03 = Push block puzzle solved in elevator room
function flag_551_gate_of_illusion_upper_floors_unlock() => byte(0x374DAF)

// $374DB0: [8-bit] Flag 552 - Gate of Illusion - Mr. Slushfund state
//          0x01 = Sent on Treasures hunt
//          0x02 = Handed in Treasures
function flag_552_gate_of_illusion_mr_slushfund_state() => byte(0x374DB0)

// $374DB1: [8-bit] Flag 553 - Gate of Illusion - Sacred Lake of the Sky - Unlocked mini doll NPC room
//          0x01 = Pressed dais
//          0x02 = Room unlocked
function flag_553_gate_of_illusion_sacred_lake_of_the_sky_unlocked_mini_doll_npc_room() => byte(0x374DB1)

// $374DB2: [8-bit] Flag 554 - Gate of Illusion - Proving thou art small
//          0x01 = Visited Sacrificial Abyss above Chi You's room
//          0x02 = Talked to NPC that gives mini doll
//          0x03 = Showed giants the mini doll
//          0x04 = Read tablet
//          0x05 = Block over ladder to Chi You dispelled
function flag_554_gate_of_illusion_proving_thou_art_small() => byte(0x374DB2)

// $374DB3: [8-bit] Flag 555 - Gate of Illusion - Coin chest unlocked
//          0x01 = Wall broken
//          0x02= Chest unlocked
function flag_555_gate_of_illusion_coin_chest_unlocked() => byte(0x374DB3)

// $374DB4: [8-bit] Flag 556 - Gate of Illusion - Coin chest (Entrance of Illusion)
function flag_556_gate_of_illusion_coin_chest() => byte(0x374DB4)

// $374DB5: [8-bit] Flag 557 - Gate of Illusion - Unlocked explosion and map chests
function flag_557_gate_of_illusion_unlocked_explosion_and_map_chests() => byte(0x374DB5)

// $374DB6: [8-bit] Flag 558 - Gate of Illusion - Broke open entrance to Mausoleum of Fairies
function flag_558_gate_of_illusion_broke_open_entrance_to_mausoleum_of_fairies() => byte(0x374DB6)

// $374DB7: [8-bit] Flag 559 - Gate of Illusion - Ladder connecting uppermost and second-uppermost levels of Fool's Confusion Corridor
//          0x01 = Pressed dais / ladder deploying
//          0x02 = Ladder deployed
function flag_559_gate_of_illusion_ladder_connecting_uppermost_and_seconduppermost_levels_of_fools_confusion_corridor() => byte(0x374DB7)

// $374DB8: [8-bit] Flag 560 - Gate of Illusion - Birth seal ladder
//          0x01 = Birth seal broken / ladder deploying
//          0x02 = Ladder deployed
function flag_560_gate_of_illusion_birth_seal_ladder() => byte(0x374DB8)

// $374DB9: [8-bit[ Flag 561 - Gate of Illusion - Spawning  key fairy chest
//          0x01 = Broke fairy wall under grail point
//          0x02 = Pressed dais
function _8_bit_flag_561_gate_of_illusion_spawning_key_fairy_chest() => byte(0x374DB9)

// $374DBA: [8-bit] Flag 562 - Gate of Illusion - Broke open bombs chest
//          0x01 = Broke wall with katana
//          0x02 = Chest unlocked
function flag_562_gate_of_illusion_broke_open_bombs_chest() => byte(0x374DBA)

// $374DBB: [8-bit] Flag 563 - Gate of Illusion - Coin/bomb chest (Mausoleum of Fairies)
function flag_563_gate_of_illusion_coin_bomb_chest() => byte(0x374DBB)

// $374DBC: [8-bit] Flag 564 - Gate of Illusiion - Broke wall covering tablet
//          "11 children guard Tiamat's room..."
function flag_564_gate_of_illusiion_broke_wall_covering_tablet() => byte(0x374DBC)

// $374DBD: [8-bit] Flag 565 - Gate of Illusiion - Sacrificial Abyss - Pressed dais to remove spikes/spawn platform
function flag_565_gate_of_illusiion_sacrificial_abyss_pressed_dais_to_remove_spikes_spawn_platform() => byte(0x374DBD)

// $374DBE: [8-bit] Flag 566 - Gate of Illusion - Broke hand in Bird's Room
function flag_566_gate_of_illusion_broke_hand_in_birds_room() => byte(0x374DBE)

// $374DBF: [8-bit] Flag 567 - Gate of Illusion - Chi You defeated
//          0x01 = Chi You defeated
//          0x02 = Chest unlocked
function flag_567_gate_of_illusion_chi_you_defeated() => byte(0x374DBF)

// $374DC0: [8-bit] Flag 568 - Gate of Illusion - Push block puzzle to open way to grail point
//          0x01 = Pushed block that breaks when it falls
//          0x02 = Pressed dais
function flag_568_gate_of_illusion_push_block_puzzle_to_open_way_to_grail_point() => byte(0x374DC0)

// $374DC1: [8--bit] Flag 569 - Gate of Illusion - Turned off flow of sacrificial maidens to Chi You's room
function flag_569_gate_of_illusion_turned_off_flow_of_sacrificial_maidens_to_chi_yous_room() => byte(0x374DC1)

// $374DC2: [8-bit] Flag 570 - Gate of Illusion - Trials of the Cog
//          0x01 = Had first conversation with fairy
//          0x02 = Removed all three sets of laser walls
//          0x03 = Had second conversation with fairy / unlocked chest
//          0x04 = Mudmen activated
function flag_570_gate_of_illusion_trials_of_the_cog() => byte(0x374DC2)

// $374DC3: [8-bit] Flag 571 - Gate of Illusion - Trials of the Cog - Ba
//          0x01 = Read tablet
//          0x02 = Defeated Ba
//          0x03 = Removed laser wall
function flag_571_gate_of_illusion_trials_of_the_cog_ba() => byte(0x374DC3)

// $374DC4: [8-bit] Flag 572 - Gate of Illusion - Trials of the Cog - Lizard Man
//          0x01 = Read tablet
//          0x02 = Broke hole in wall
//          0x03 = Lizard man zapped
//          0x04 = Removed laser wall
function flag_572_gate_of_illusion_trials_of_the_cog_lizard_man() => byte(0x374DC4)

// $374DC5: [8-bit] Flag 573 - Gate of Illusion - Trials of the Cog - Child Statue
//          0x01 = Read tablet
//          0x02 = Broke pots
//          0x03 = Removed laser wall
function flag_573_gate_of_illusion_trials_of_the_cog_child_statue() => byte(0x374DC5)

// $374DC6: [8-bit] Flag 574 - (unused)
function flag_574() => byte(0x374DC6)

// $374DC7: [8-bit] Flag 575 - Graveyard of the Giants - Entrance to Illusion
//          0x01 = Broke wedge holding ice block in place
//          0x02 = Ice block dropping
//          0x03 = Ice block dropped
function flag_575_graveyard_of_the_giants_entrance_to_illusion() => byte(0x374DC7)

// $374DC8: [8-bit] Flag 576 - Graveyard of the Giants - Entrance to Illusion
//          0x01 = Push block solved / ladder deploying
//          0x02 = Ladder deployed
function flag_576_graveyard_of_the_giants_entrance_to_illusion() => byte(0x374DC8)

// $374DC9: [8-bit] Flag 577 - Graveyard of the Giants - Coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_577_graveyard_of_the_giants_coin_chest_unlocked() => byte(0x374DC9)

// $374DCA: [8-bit] Flag 578 - Graveyard of the Giants - Coin chest
function flag_578_graveyard_of_the_giants_coin_chest() => byte(0x374DCA)

// $374DCB: [8-bit] Flag 579 - Graveyard of the Giants - Coin chest / grail point access blocks
//          (Value >= 1) = Upper block dropped
function flag_579_graveyard_of_the_giants_coin_chest_grail_point_access_blocks() => byte(0x374DCB)

// $374DCC: [8-bit] Flag 580 - Graveyard of the Giants - Coin chest / grail point access blocks
//          (Value >= 1) = Lower block dropped
function flag_580_graveyard_of_the_giants_coin_chest_grail_point_access_blocks() => byte(0x374DCC)

// $374DCD: [8-bit] Flag 581 - Graveyard of the Giants - Silver shield weapon cover
//          0x01 = Broke floor
//          0x02 = Entered White Silver Altar screen
//          0x03 = Weapon cover removed
function flag_581_graveyard_of_the_giants_silver_shield_weapon_cover() => byte(0x374DCD)

// $374DCE: [8-bit] Flag 582 - Graveyard of the Giants - Map chest unlocked
function flag_582_graveyard_of_the_giants_map_chest_unlocked() => byte(0x374DCE)

// $374DCF: [8-bit] Flag 583 - Graveyard of the Giants - Dropped ice block from grail point room to map chest room
//          0x01 = Pressed dais
//          0x02 = Block falling
//          0x03 = Block dropped
function flag_583_graveyard_of_the_giants_dropped_ice_block_from_grail_point_room_to_map_chest_room() => byte(0x374DCF)

// $374DD0: [8-bit] Flag 584 - Graveyard of the Giants - Life seal broken
function flag_584_graveyard_of_the_giants_life_seal_broken() => byte(0x374DD0)

// $374DD1: [8-bit] Flag 585 - Graveyard of the Giants - Hollowed out the statue's eyes
function flag_585_graveyard_of_the_giants_hollowed_out_the_statues_eyes() => byte(0x374DD1)

// $374DD2: [8-bit] Flag 586 - Graveyard of the Giants - Pressed dais for Gauntlet puzzle
function flag_586_graveyard_of_the_giants_pressed_dais_for_gauntlet_puzzle() => byte(0x374DD2)

// $374DD3: [8-bit] Flag 587 - Graveyard of the Giants - Kamaitachi ladder unlock (part 1)
//          0x01 = Spirit of Language Altar - placed first weight
//          0x02 = Spirit of Language Altar - placed second weight
//          0x03 = Antechamber - placed third weight
function flag_587_graveyard_of_the_giants_kamaitachi_ladder_unlock() => byte(0x374DD3)

// $374DD4: [8-bit] Flag 588 - Graveyard of the Giants - Kamaitachi unlock (laser walls)
//          0x01 = Dispelled first laser wall
//          0x02 = Dispelled second laser wall
function flag_588_graveyard_of_the_giants_kamaitachi_unlock() => byte(0x374DD4)

// $374DD5: [8-bit] Flag 589 - Graveyard of the Giants - Kamaitachi ladder unlock (part 2)
//          0x01 = Antechamber - placed fourth weight
//          0x02 = Antechamber - dispelled third beam
function flag_589_graveyard_of_the_giants_kamaitachi_ladder_unlock() => byte(0x374DD5)

// $374DD6: [8-bit] Flag 590 - Graveyard of the Giants - Kamaitachi ladder unlock (part 3)
//          0x01 = First ladder deploying
//          0x02 = First ladder deploying
function flag_590_graveyard_of_the_giants_kamaitachi_ladder_unlock() => byte(0x374DD6)

// $374DD7: [8-bit] Flag 591 - Graveyard of the Giants - Bombed wall covering snapshots mural
function flag_591_graveyard_of_the_giants_bombed_wall_covering_snapshots_mural() => byte(0x374DD7)

// $374DD8: [8-bit] Flag 592 - Graveyard of the Giants - Kamaitachi ladder unlock (part 4)
//          0x01 = Block pushed / ladder deploying
//          0x02 = Second ladder deployed
function flag_592_graveyard_of_the_giants_kamaitachi_ladder_unlock() => byte(0x374DD8)

// $374DD9: [8-bit] Flag 593 - Item pots:
//          Bit0 = Graveyard of the Giants C3 - Coins x 10
//          Bit1 = Graveyard of the Giants C3 - Coins x 10
//          Bit2 = Graveyard of the Giants C3 - Coins x 10
//          Bit3 = Graveyard of the Giants C3 - Coins x 10
function flag_593_item_pots() => byte(0x374DD9)

// $374DDA: [8-bit] Flag 594 - Graveyard of the Giants - Future Development Company chest unlocked
function flag_594_graveyard_of_the_giants_future_development_company_chest_unlocked() => byte(0x374DDA)

// $374DDB: [8-bit] Flag 595 - Graveyard of the Giants - Bombed out the ice raindrop wall
function flag_595_graveyard_of_the_giants_bombed_out_the_ice_raindrop_wall() => byte(0x374DDB)

// $374DDC: [8-bit] Flag 596 - Graveyard of the Giants - Kamaitachi defated
//          0x01 = Kamaitachi defeated
//          0x02 = Weapon cover removed
function flag_596_graveyard_of_the_giants_kamaitachi_defated() => byte(0x374DDC)

// $374DDD: [8-bit] Flag 597 - Temple of Moonlight - Determines which image of the dancing man is displayed
function flag_597_temple_of_moonlight_determines_which_image_of_the_dancing_man_is_displayed() => byte(0x374DDD)

// $374DDE: [8-bit] Flag 598 - Temple of Moonlight - Serdab of Power - Broke floor covering developer room
function flag_598_temple_of_moonlight_serdab_of_power_broke_floor_covering_developer_room() => byte(0x374DDE)

// $374DDF: [8-bit] Flag 599 - Temple of Moonlight - Collapsible floor in lower right of pyramid
//          0x01 = Floor collapsing
//          0x02 = Floor collapsed
function flag_599_temple_of_moonlight_collapsible_floor_in_lower_right_of_pyramid() => byte(0x374DDF)

// $374DE0: [8-bit] Flag 600 - Temple of Moonlight - Grapple Claw chest unlocked
function flag_600_temple_of_moonlight_grapple_claw_chest_unlocked() => byte(0x374DE0)

// $374DE1: [8-bit] Flag 601 - Temple of Moonlight - Coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_601_temple_of_moonlight_coin_chest_unlocked() => byte(0x374DE1)

// $374DE2: [8-bit] Flag 602 - Temple of Moonlight - Coin chest
function flag_602_temple_of_moonlight_coin_chest() => byte(0x374DE2)

// $374DE3: [8-bit] Flag 603 - Temple of Moonlight - Map chest unlocked
function flag_603_temple_of_moonlight_map_chest_unlocked() => byte(0x374DE3)

// $374DE4: [8-bit] Flag 604 - Temple of Moonlight - Serdab of Power - Axe weapon cover
//          0x01 = Broke skull holding boulder in place
//          0x02 - 0x04 = Boulder rolling event
//          0x05 = Weapon cover removed
function flag_604_temple_of_moonlight_serdab_of_power_axe_weapon_cover() => byte(0x374DE4)

// $374DE5: [8-bit] Flag 605 - Temple of Moonlight - Fruit of Eden puzzle - opened chests in correct order
function flag_605_temple_of_moonlight_fruit_of_eden_puzzle_opened_chests_in_correct_order() => byte(0x374DE5)

// $374DE6: [8-bit] Flag 606 - Temple of Moonlight - Broke shortcut to Twin Labyrinths
function flag_606_temple_of_moonlight_broke_shortcut_to_twin_labyrinths() => byte(0x374DE6)

// $374DE7: [8-bit] Flag 607 - Temple of Moonlight - Dropped platform for shortcut to Twin Labyrinths
//          0x01 = Platform falling
//          0x02 = Platform dropped
function flag_607_temple_of_moonlight_dropped_platform_for_shortcut_to_twin_labyrinths() => byte(0x374DE7)

// $374DE8: [8-bit] Flag 608 - Temple of Moonlight - Slept within the woman
function flag_608_temple_of_moonlight_slept_within_the_woman() => byte(0x374DE8)

// $374DE9: [8-bit] Flag 609 - Temple of Moonlight - Broke wall to expose entrance of Serdab of Treasure
function flag_609_temple_of_moonlight_broke_wall_to_expose_entrance_of_serdab_of_treasure() => byte(0x374DE9)

// $374DEA: [8-bit] Flag 610 - Temple of Moonlight - Opened connection between uppwer and lower Moonlight
function flag_610_temple_of_moonlight_opened_connection_between_uppwer_and_lower_moonlight() => byte(0x374DEA)

// $374DEB: [8-bit] Flag 611 - Temple of Moonlight - Connection between Graveyard and Moonlight
//          Bit0 = Broke lower right-hand wall
//          Bit1 = Broke middle right-hand wall
//          Bit2 = Broke upper right-hand wall
//          Bit3 = Removed top wall section
//          Bit4 = Removed middle wall section
//          Bit5 = Removed lower wall section
//          Bit6 = Removed bottom wall section
//          Bit7 = Removed left-middle wall section
function flag_611_temple_of_moonlight_connection_between_graveyard_and_moonlight() => byte(0x374DEB)

// $374DEC: [8-bit] Flag 612 - (unused)
function flag_612() => byte(0x374DEC)

// $374DED: [8-bit] Flag 613 - Tower of Ruin - Philosopher's Ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_613_tower_of_ruin_philosophers_ladder() => byte(0x374DED)

// $374DEE: [8-bit] Flag 614 - Temple of Moonlight - Dropping pyramid tip
//          0x01 = Broke wall block to expose dais
//          0x02 = Dropped tip (success, underworld access granted)
//          0x03 = Dropped tip (failure, did not remove blocking floor beforehand)
function flag_614_temple_of_moonlight_dropping_pyramid_tip() => byte(0x374DEE)

// $374DEF: [8-bit] Flag 615 - Temple of Moonlight - Pyramid tip elevator related
function flag_615_temple_of_moonlight_pyramid_tip_elevator_related() => byte(0x374DEF)

// $374DF0: [8-bit] Flag 616 - Temple of Moonlight - Broke wall to Serdab of Treasure
function flag_616_temple_of_moonlight_broke_wall_to_serdab_of_treasure() => byte(0x374DF0)

// $374DF1: [8-bit] Flag 617 - Temple of Moonlight - Watchtower access
//          0x01 = Birth seal broken
//          0x02 = Walll full of bats broken
//          0x03 = Bats spawned
function flag_617_temple_of_moonlight_watchtower_access() => byte(0x374DF1)

// $374DF2: [8-bit] Flag 618 - Temple of Moonlight - Activated pyramid tip moving platform
//          0x01 = Block pushed
//          0x02 = Platform activated
function flag_618_temple_of_moonlight_activated_pyramid_tip_moving_platform() => byte(0x374DF2)

// $374DF3: [8-bit] Flag 619 - Temple of Moonlight - Opened floor that blocks falling pyramid tip
function flag_619_temple_of_moonlight_opened_floor_that_blocks_falling_pyramid_tip() => byte(0x374DF3)

// $374DF4: [8-bit] Flag 620 - Temple of Moonlight - Anubis defeated
function flag_620_temple_of_moonlight_anubis_defeated() => byte(0x374DF4)

// $374DF5: [8-bit] Flag 621 - Temple of Moonlight - Unlocked shop
function flag_621_temple_of_moonlight_unlocked_shop() => byte(0x374DF5)

// $374DF6: [8-bit] Flag 622 - (unused)
function flag_622() => byte(0x374DF6)

// $374DF7: [8-bit] Flag 623 - Tower of Ruin - Nüwa's pyramid
//          Takes a value of 0x01 after the death seal is broken, primes the philospher's ladder to deploy, and controls opening the crushers covering the ladder inside the pyramid
function flag_623_tower_of_ruin_nüwas_pyramid() => byte(0x374DF7)

// $374DF8: [8-bit] Flag 624 - Temple of Moonlight - Scanned the dancing man
function flag_624_temple_of_moonlight_scanned_the_dancing_man() => byte(0x374DF8)

// $374DF9: [8-bit] Flag 625 - Tower of the Goddess - Lights
//          0x00 = Lights off
//          0x01 = Transition sequence
//          0x02 = Transition sequence
//          0x03 = Lights on
function flag_625_tower_of_the_goddess_lights() => byte(0x374DF9)

// $374DFA: [8-bit] Flag 626 - Tower of the Goddess - Map chest unlocked
//          0x01 = Wall broken
//          0x02 = Dais pressed / chest unlocked
function flag_626_tower_of_the_goddess_map_chest_unlocked() => byte(0x374DFA)

// $374DFB: [8-bit] Flag 627 - Tower of the Goddess - flood tablet
//          0x00 = Tablet unread
//          0x01 = Tablet read
//          0x02 = Dais appeared
function flag_627_tower_of_the_goddess_flood_tablet() => byte(0x374DFB)

// $374DFC: [8-bit] Flag 628 - Tower of the Goddess - Bombed open snapshots wall
function flag_628_tower_of_the_goddess_bombed_open_snapshots_wall() => byte(0x374DFC)

// $374DFD: [8-bit] Flag 629 - Tower of the Goddess - Eye of Truth puzzle
//          0x01 = Placed first weight
//          0x02 = Placed second weight
function flag_629_tower_of_the_goddess_eye_of_truth_puzzle() => byte(0x374DFD)

// $374DFE: [8-bit] Flag 630 - Tower of the Goddess - Unlocked shop
function flag_630_tower_of_the_goddess_unlocked_shop() => byte(0x374DFE)

// $374DFF: [8-bit] Flag 631 - Tower of the Goddess - Unlocked entrance to Samaranta's room
function flag_631_tower_of_the_goddess_unlocked_entrance_to_samarantas_room() => byte(0x374DFF)

// $374E00: [8-bit] Flag 632 - Tower of the Goddess - Dispelled statue covering 5 gate
function flag_632_tower_of_the_goddess_dispelled_statue_covering_5_gate() => byte(0x374E00)

// $374E01: [8-bit] Flag 633 - Tower of the Goddess - Dispelled statue covering 6 ladder
function flag_633_tower_of_the_goddess_dispelled_statue_covering_6_ladder() => byte(0x374E01)

// $374E02: [8-bit] Flag 634 - Tower of the Goddess- Dispelled statue covering 1 gate
//          0x01= Removal animation
//          0x02 = Statue removed
function flag_634_tower_of_the_goddess_dispelled_statue_covering_1_gate() => byte(0x374E02)

// $374E03: [8-bit] Flag 635 - Tower of the Goddess - Scales of the Heart
//          0x01 = Read tablet
//          0x02 = Balanced scales
//          0x03 = Weapon cover removed
function flag_635_tower_of_the_goddess_scales_of_the_heart() => byte(0x374E03)

// $374E04: [8-bit] Flag 636 - Tower of the Goddess - Samaranta's ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_636_tower_of_the_goddess_samarantas_ladder() => byte(0x374E04)

// $374E05: [8-bit] Flag 637 - Tower of the Goddess - Pressure plate to open coin chest (Urd's Tower)
function flag_637_tower_of_the_goddess_pressure_plate_to_open_coin_chest() => byte(0x374E05)

// $374E06: [8-bit] Flag 638 - Tower of the Goddess - Coin chest (Urd's Tower)
function flag_638_tower_of_the_goddess_coin_chest() => byte(0x374E06)

// $374E07: [8-bit] Flag 639 - Tower of the Goddess - Vimana defeated / plane model puzzle
//          0x01 = Vimana defeated (left side)
//          0x02 = Path to Life counterweight elevator depressed to position 1
//          0x03 = Path to Life counterweight elevator depressed to position 2
//          0x04 = Path to Life counterweight elevator depressed to position 3
function flag_639_tower_of_the_goddess_vimana_defeated_plane_model_puzzle() => byte(0x374E07)

// $374E08: [8-bit] Flag 640 - Tower of the Goddess - Vimana defeated / plane model puzzle
//          0x01 = Vimana defeated (right side)
//          0x02 = Path to Power counterweight elevator depressed to position 1
//          0x03 = Path to Power counterweight elevator depressed to position 2
//          0x04 = Path to Power counterweight elevator depressed to position 3
function flag_640_tower_of_the_goddess_vimana_defeated_plane_model_puzzle() => byte(0x374E08)

// $374E09: [8-bit] Flag 641 - Tower of the Goddess - Plane Model chest unlocked
function flag_641_tower_of_the_goddess_plane_model_chest_unlocked() => byte(0x374E09)

// $374E0A: [8-bit] Flag 642 - Tower of the Goddess - Wall opened to expose Spaulder chest
function flag_642_tower_of_the_goddess_wall_opened_to_expose_spaulder_chest() => byte(0x374E0A)

// $374E0B: [8-bit] Flag 643 - Tower of the Goddess - Removed wall covering Spaulder chest
function flag_643_tower_of_the_goddess_removed_wall_covering_spaulder_chest() => byte(0x374E0B)

// $374E0C: [8-bit] Flag 644 - Tower of the Goddess - Dispelled statue covering 2 ladder
//          0x01 = Start of animation
//          0x02 = Shield throw / statue removed
//          0x03 = Exited room
function flag_644_tower_of_the_goddess_dispelled_statue_covering_2_ladder() => byte(0x374E0C)

// $374E0D: [8-bit] Flag 645 - Tower of the Goddess - Wall covering Path to Power coin chest
//          0x01 = Wall destroyed
//          0x02 = Shell horn tooted
function flag_645_tower_of_the_goddess_wall_covering_path_to_power_coin_chest() => byte(0x374E0D)

// $374E0E: [8-bit] Flag 646 - Tower of the Goddess - Coin chest (Path to Power)
function flag_646_tower_of_the_goddess_coin_chest() => byte(0x374E0E)

// $374E0F: [8-bit] Flag 647 - Towerr of the Goddess - Broke left-hand glass floor
function flag_647_towerr_of_the_goddess_broke_lefthand_glass_floor() => byte(0x374E0F)

// $374E10: [8-bit] Flag 648 - Towerr of the Goddess - Broke right-hand glass floor
function flag_648_towerr_of_the_goddess_broke_righthand_glass_floor() => byte(0x374E10)

// $374E11: [8-bit] Flag 649 - Tower of the Goddess - Shawn Kosugi related
function flag_649_tower_of_the_goddess_shawn_kosugi_related() => byte(0x374E11)

// $374E12: [8-bit] Flag 650 - Tower of Ruin - Sacred orb chest unlocked
function flag_650_tower_of_ruin_sacred_orb_chest_unlocked() => byte(0x374E12)

// $374E13: [8-bit] Flag 651 - Tower of Ruin - Earth spear weapon cover removed
//          0x01 = Pressed dais
//          0x02 = On screen for 30 frames
//          0x03 = Weapon cover removed
function flag_651_tower_of_ruin_earth_spear_weapon_cover_removed() => byte(0x374E13)

// $374E14: [8-bit] Flag 652 - Tower of Ruin - Name of the nameless
//          0x01 = Broke 'M' block
//          0x02 = Broke 'U' block
//          Screen flags 0-5 used to track failure states while solving
function flag_652_tower_of_ruin_name_of_the_nameless() => byte(0x374E14)

// $374E15: [8-bit] Flag 653 - Tower of Ruin - Gargoyle puzzle
//          0x01 = Broke gargoyle
//          0x02 = Pushed column to expose ladder
function flag_653_tower_of_ruin_gargoyle_puzzle() => byte(0x374E15)

// $374E16: [8-bit] Flag 654 - Tower of Ruin - Thunderbird defeated
function flag_654_tower_of_ruin_thunderbird_defeated() => byte(0x374E16)

// $374E17: [8-bit] Flag 655 - Tower of Ruin - Serdab of Time
//          0x01 = Killed silverfish
//          0x02 = Placed weight
function flag_655_tower_of_ruin_serdab_of_time() => byte(0x374E17)

// $374E18: [8-bit] Flag 656 - Tower of Ruin - Shawn Kosugi related
function flag_656_tower_of_ruin_shawn_kosugi_related() => byte(0x374E18)

// $374E19: [8-bit] Flag 657 - Tower of Ruin - Medicine puzzle
//          0x01 = Used BIRTH on Rusalii
//          0x02 = Used DEATH on Rusalii
function flag_657_tower_of_ruin_medicine_puzzle() => byte(0x374E19)

// $374E1A: [8-bit] Flag 658 - Tower of Ruin - Medicine puzzle
//          0x01 = Used BIRTH on Yaksi
//          0x02 = Used DEATH on Yaksi
function flag_658_tower_of_ruin_medicine_puzzle() => byte(0x374E1A)

// $374E1B: [8-bit] Flag 659 - Tower of Ruin - Medicine puzzle
//          0x01 = Used BIRTH on Dakini
//          0x02 = Used DEATH on Dakini
function flag_659_tower_of_ruin_medicine_puzzle() => byte(0x374E1B)

// $374E1C: [8-bit] Flag 660 - Tower of Ruin - Map chest unlocked
//          0x01 = Broke open wall
//          0x02 = Pressed dais / chest unlocked
function flag_660_tower_of_ruin_map_chest_unlocked() => byte(0x374E1C)

// $374E1D: [8-bit] Flag 661 - Tower of Ruin - Cover removed to expose shop
function flag_661_tower_of_ruin_cover_removed_to_expose_shop() => byte(0x374E1D)

// $374E1E: [8-bit] Flag 662 - Tower of Ruin - Approach of the Philosophers - Pressed dais to activate crusher
function flag_662_tower_of_ruin_approach_of_the_philosophers_pressed_dais_to_activate_crusher() => byte(0x374E1E)

// $374E1F: [8-bit] Flag 663 - Tower of Ruin - Approach of the Philosophers - Unlocking path into Ruin
//          0x01 = Broke bottom segment of column
//          0x02 = Dais raised on top of column
//          0x03 = Pressed dais
//          0x04 = Puzzle complete
function flag_663_tower_of_ruin_approach_of_the_philosophers_unlocking_path_into_ruin() => byte(0x374E1F)

// $374E20: [8-bit] Flag 664 - Tower of Ruin - Nüwa's Pyramid state variable
//          0x01 = Nüwa's Pyramid - Death Seal broken
//          0x02 = Burial Chamber of Life - pressed dais to deploy ladder
//          0x03 = Nüwa's Pyramid - Defeated Nüwa
function flag_664_tower_of_ruin_nüwas_pyramid_state_variable() => byte(0x374E20)

// $374E21: [8-bit] Flag 665 - Tower of Ruin - Nüwa defeated
function flag_665_tower_of_ruin_nüwa_defeated() => byte(0x374E21)

// $374E22: [8-bit] Flag 666 - Tower of Ruin - Wall between fountain and Dakini's room opened up
function flag_666_tower_of_ruin_wall_between_fountain_and_dakinis_room_opened_up() => byte(0x374E22)

// $374E23: [8-bit] Flag 667 - Tower of Ruin - Fountain uncovered
function flag_667_tower_of_ruin_fountain_uncovered() => byte(0x374E23)

// $374E24: [8-bit] Flag 668 - Temple of Moonlight - Scanned within the four hands
function flag_668_temple_of_moonlight_scanned_within_the_four_hands() => byte(0x374E24)

// $374E25: [8-bit] Flag 669 - Temple of Moonlight - Scanned the source of a phenomenal trap
function flag_669_temple_of_moonlight_scanned_the_source_of_a_phenomenal_trap() => byte(0x374E25)

// $374E26: [8-bit] Flag 670 - Temple of Moonlight - Scanned a face of the highest rank
function flag_670_temple_of_moonlight_scanned_a_face_of_the_highest_rank() => byte(0x374E26)

// $374E27: [8-bit] Flag 671 - Temple of Moonlight - Ladder to womb
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_671_temple_of_moonlight_ladder_to_womb() => byte(0x374E27)

// $374E28: [8-bit] Flag 672 - (unused)
function flag_672() => byte(0x374E28)

// $374E29: [8-bit] Flag 673 - Tower of Ruin - Shop unlock puzzle
//          0x01 = Broke floor
//          0x02 = Placed weight
function flag_673_tower_of_ruin_shop_unlock_puzzle() => byte(0x374E29)

// $374E2A: [8-bit] Flag 674 - Tower of Ruin - Coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_674_tower_of_ruin_coin_chest_unlocked() => byte(0x374E2A)

// $374E2B: [8-bit] Flag 675 - Chamber of Extinction - Used Woman Statue to unlock map chest
function flag_675_chamber_of_extinction_used_woman_statue_to_unlock_map_chest() => byte(0x374E2B)

// $374E2C: [8-bit] Flag 676 - Chamber of Birth - Pit of Eternity - Used Key of Eternity
function flag_676_chamber_of_birth_pit_of_eternity_used_key_of_eternity() => byte(0x374E2C)

// $374E2D: [8-bit] Flag 677 - Chamber of Birth - Pit of Eternity - Broke wall covering chest
function flag_677_chamber_of_birth_pit_of_eternity_broke_wall_covering_chest() => byte(0x374E2D)

// $374E2E: [8-bit] Flag 678 - Chamber of Birth - Skanda defeated
//          0x01 = Dance of Life performed
//          0x02 = Skanda defeated
function flag_678_chamber_of_birth_skanda_defeated() => byte(0x374E2E)

// $374E2F: [8-bit] Flag 679 - Chamber of Birth - Destroyed laser statue guarding Vessel
function flag_679_chamber_of_birth_destroyed_laser_statue_guarding_vessel() => byte(0x374E2F)

// $374E30: [8-bit] Flag 680 - Chamber of Birth - Vishnu's Room - Destroyed wall covering Life Seal
function flag_680_chamber_of_birth_vishnus_room_destroyed_wall_covering_life_seal() => byte(0x374E30)

// $374E31: [8-bit] Flag 681 - Chamber of Birth - Killed assassin to expose coin chest
function flag_681_chamber_of_birth_killed_assassin_to_expose_coin_chest() => byte(0x374E31)

// $374E32: [8-bit] Flag 682 - Chamber of Birth - Coin chest (Surrounding Wall of Spikes)
function flag_682_chamber_of_birth_coin_chest() => byte(0x374E32)

// $374E33: [8-bit] Flag 683 - Chamber of Birth - Perfume puzzle pressure plate activated
function flag_683_chamber_of_birth_perfume_puzzle_pressure_plate_activated() => byte(0x374E33)

// $374E34: [8-bit] Flag 684 - Chamber of Extinction / Chamber of Birth - Shiva's Crucifix
//          0x01 = Wall in Shiva's Room broken to expose teleporter
//          0x02 = Interior of Shiva's Crucifix exposed
function flag_684_chamber_of_extinction_chamber_of_birth_shivas_crucifix() => byte(0x374E34)

// $374E35: [8-bit] Flag 685 - Chamber of Birth - Crusher puzzle for Woman Statue
//          0x01 = Weight placed to start crusher
//          0x02 = Exited room (puzzle solved)
function flag_685_chamber_of_birth_crusher_puzzle_for_woman_statue() => byte(0x374E35)

// $374E36: [8-bit] Flag 686 - Chamber of Birth - Knocked over column to break open entrance to Parvati's Room/Kali's Room
function flag_686_chamber_of_birth_knocked_over_column_to_break_open_entrance_to_parvatis_room_kalis_room() => byte(0x374E36)

// $374E37: [8-bit] Flag 687 - Chamber of Birth
//          Controls timing and particle effects for toppling the leaning column to break open the entrance to Parvati's Room.
function flag_687_chamber_of_birth() => byte(0x374E37)

// $374E38: [8-bit] Flag 688 - Chamber of Birth - Vishnu's Room coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_688_chamber_of_birth_vishnus_room_coin_chest_unlocked() => byte(0x374E38)

// $374E39: [8-bit] Flag 689 - Chamber of Birth - Coin chest (Vishnu's Room)
function flag_689_chamber_of_birth_coin_chest() => byte(0x374E39)

// $374E3A: [8-bit] Flag 690 - Chamber of Birth - Hanuman's Room coin chest unlocked
//          0x01 = Column broken
//          0x02 = Chest unlocked
function flag_690_chamber_of_birth_hanumans_room_coin_chest_unlocked() => byte(0x374E3A)

// $374E3B: [8-bit] Flag 691 - Chamber of Birth - Coin chest (Hanuman's Room)
function flag_691_chamber_of_birth_coin_chest() => byte(0x374E3B)

// $374E3C: [8-bit] Flag 692 - Temple of Moonlight - Connection to Graveyard
//          Pressed dais next to 2 gate
function flag_692_temple_of_moonlight_connection_to_graveyard() => byte(0x374E3C)

// $374E3D: [8-bit] Flag 693 - Temple of Moonlight - Connection to Graveyard
//          Pressed lower left dais
function flag_693_temple_of_moonlight_connection_to_graveyard() => byte(0x374E3D)

// $374E3E: [8-bit] Flag 694 - True Shrine of the Mother - Number of Mom's seals broken
function flag_694_true_shrine_of_the_mother_number_of_moms_seals_broken() => byte(0x374E3E)

// $374E3F: [8-bit] Flag 695 - True Shrine of the Mother - Moved tentacle on screen above grail point
function flag_695_true_shrine_of_the_mother_moved_tentacle_on_screen_above_grail_point() => byte(0x374E3F)

// $374E40: [8-bit] Flag 696 - Gate of Time - Reset Scales of the Heart
function flag_696_gate_of_time_reset_scales_of_the_heart() => byte(0x374E40)

// $374E41: [8-bit] Flag 697 - Chamber of Birth - 6 Door uncovered
function flag_697_chamber_of_birth_6_door_uncovered() => byte(0x374E41)

// $374E42: [8-bit] Flag 698 - Temple of Moonlight - Pyramid tip elevator related
//          Used to control state changes to flag 615
function flag_698_temple_of_moonlight_pyramid_tip_elevator_related() => byte(0x374E42)

// $374E43: [8-bit] Flag 699 - Tower of Ruin - Coin chest
function flag_699_tower_of_ruin_coin_chest() => byte(0x374E43)

// $374E44: [8-bit] Flag 700 - Dimensional Corridor - Map chest unlocked
function flag_700_dimensional_corridor_map_chest_unlocked() => byte(0x374E44)

// $374E45: [8-bit] Flag 701 - Dimensional Corridor - Anu's Room - Death seal broken
function flag_701_dimensional_corridor_anus_room_death_seal_broken() => byte(0x374E45)

// $374E46: [8-bit] Flag 702 - Dimensional Corridor - Coin chest unlocked
//          0x01 = Wall broken
//          0x02 = Chest unlocked
function flag_702_dimensional_corridor_coin_chest_unlocked() => byte(0x374E46)

// $374E47: [8-bit] Flag 703 - Dimensional Corridor - Coin chest
function flag_703_dimensional_corridor_coin_chest() => byte(0x374E47)

// $374E48: [8-bit] Flag 704 - Dimensional Corridor -  Dance puzzle to unlock Mushussu
//          0x01 - 0x04 = Number of dances performed in correct sequence
//          0x05 = Mushussu's Room unlocked
function flag_704_dimensional_corridor_dance_puzzle_to_unlock_mushussu() => byte(0x374E48)

// $374E49: [8-bit] Flag 705 - Dimensional Corridor - Weapon cover removed on Angel Shield
//          0x01 = Pressed dais
//          0x02 = Cover removed
function flag_705_dimensional_corridor_weapon_cover_removed_on_angel_shield() => byte(0x374E49)

// $374E4A: [8-bit] Flag 706 - Dimensional Corridor - Parity tracking for Angel Shield puzzle
function flag_706_dimensional_corridor_parity_tracking_for_angel_shield_puzzle() => byte(0x374E4A)

// $374E4B: [8-bit] Flag 707 - Dimensional Corridor - Girtablilu defeated
function flag_707_dimensional_corridor_girtablilu_defeated() => byte(0x374E4B)

// $374E4C: [8-bit] Flag 708 - Dimensional Corridor - Kulullu defeated
function flag_708_dimensional_corridor_kulullu_defeated() => byte(0x374E4C)

// $374E4D: [8-bit] Flag 709 - Dimensional Corridor - Kuusarikku defeated
function flag_709_dimensional_corridor_kuusarikku_defeated() => byte(0x374E4D)

// $374E4E: [8-bit] Flag 710 - Dimensional Corridor - Urmahlullu defeated
function flag_710_dimensional_corridor_urmahlullu_defeated() => byte(0x374E4E)

// $374E4F: [8-bit] Flag 711 - Dimensional Corridor - Ugallu defeated
function flag_711_dimensional_corridor_ugallu_defeated() => byte(0x374E4F)

// $374E50: [8-bit] Flag 712 - Dimensional Corridor - Ushum defeated
function flag_712_dimensional_corridor_ushum_defeated() => byte(0x374E50)

// $374E51: [8-bit] Flag 713 - Dimensional Corridor - Lahamu defeated
function flag_713_dimensional_corridor_lahamu_defeated() => byte(0x374E51)

// $374E52: [8-bit] Flag 714 - Dimensional Corridor - Mushnahhu defeated
function flag_714_dimensional_corridor_mushnahhu_defeated() => byte(0x374E52)

// $374E53: [8-bit] Flag 715 - Dimensional Corridor - Umu Dabrutu defeated
function flag_715_dimensional_corridor_umu_dabrutu_defeated() => byte(0x374E53)

// $374E54: [8-bit] Flag 716 - Dimensional Corridor - Ushumgallu defeated
function flag_716_dimensional_corridor_ushumgallu_defeated() => byte(0x374E54)

// $374E55: [8-bit] Flag 717 - (unused)
function flag_717() => byte(0x374E55)

// $374E56: [8-bit] Flag 718 - Dimensional Corridor - Kuusarikku's Room ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_718_dimensional_corridor_kuusarikkus_room_ladder() => byte(0x374E56)

// $374E57: [8-bit] Flag 719 - Dimensional Corridor - Ugallu's Room ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_719_dimensional_corridor_ugallus_room_ladder() => byte(0x374E57)

// $374E58: [8-bit] Flag 720 - Dimensional Corridor - Mushussu's Room ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_720_dimensional_corridor_mushussus_room_ladder() => byte(0x374E58)

// $374E59: [8-bit] Flag 721 - Dimensional Corridor - Lahamu's Room ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_721_dimensional_corridor_lahamus_room_ladder() => byte(0x374E59)

// $374E5A: [8-bit] Flag 722 - Dimensional Corridor - Angel shield puzzle left-hand dais pressed
function flag_722_dimensional_corridor_angel_shield_puzzle_lefthand_dais_pressed() => byte(0x374E5A)

// $374E5B: [8-bit] Flag 723 - Dimensional Corridor - Angel shield puzzle right-hand dais pressed
function flag_723_dimensional_corridor_angel_shield_puzzle_righthand_dais_pressed() => byte(0x374E5B)

// $374E5C: [8-bit] Flag 724 - Dimensional Corridor - Mushussu defeated
function flag_724_dimensional_corridor_mushussu_defeated() => byte(0x374E5C)

// $374E5D: [8-bit] Flag 725 - True Shrine of the Mother - Final obstacle
//          0x01 = Fairy block appeared
//          0x02 = Fairy Queen primed (the time has come!)
//          0x03 = Fairy block dispel animation -> returns to 0x02 upon leaving the screen
function flag_725_true_shrine_of_the_mother_final_obstacle() => byte(0x374E5D)

// $374E5E: [8-bit] Flag - Amphisbaena Defeated
function flag_amphisbaena_defeated() => byte(0x374E5E)

// $374E5F: [8-bit] Flag - Sakit Defeated
function flag_sakit_defeated() => byte(0x374E5F)

// $374E60: [8-bit] Flag - Ellmac Defeated
function flag_ellmac_defeated() => byte(0x374E60)

// $374E61: [8-bit] Flag - Bahamut Defeated
function flag_bahamut_defeated() => byte(0x374E61)

// $374E62: [8-bit] Flag - Viy Defeated
function flag_viy_defeated() => byte(0x374E62)

// $374E63: [8-bit] Flag - Palenque Defeated
function flag_palenque_defeated() => byte(0x374E63)

// $374E64: [8-bit] Flag - Baphomet Defeated
function flag_baphomet_defeated() => byte(0x374E64)

// $374E65: [8-bit] Flag - Tiamat Defeated
function flag_tiamat_defeated() => byte(0x374E65)

// $374E66: [8-bit] Flag 734 - True Shrine of the Mother - Seals
//          Bit0 = Origin seal broken
//          Bit1 = Birth seal broken
//          Bit2 = Life seal broken
//          Bit3 = Death seal broken
function flag_734_true_shrine_of_the_mother_seals() => byte(0x374E66)

// $374E67: [8-bit] Flag 735 - True Shrine of the Mother - Beelzebub defeated
function flag_735_true_shrine_of_the_mother_beelzebub_defeated() => byte(0x374E67)

// $374E68: [8-bit] Flag 736 - True Shrine of the Mother
//          0x01 = Placed weight to activate seals
//          0x03 = All seals destroyed
function flag_736_true_shrine_of_the_mother() => byte(0x374E68)

// $374E69: [8-bit] Flag 737 - Surface - Controls which music is played
//          0x00 = Mr. Explorer
//          0x01 = La-Mulana
function flag_737_surface_controls_which_music_is_played() => byte(0x374E69)

// $374E6A: [8-bit] Flag 738 - 8-bit Surface - La-Mulana chest unlocked
function flag_738_8_bit_surface_lamulana_chest_unlocked() => byte(0x374E6A)

// $374E6B: [8-bit] Flag 739 - 8-bit Surface - Spoke with 8-bit Xelpud
function flag_739_8_bit_surface_spoke_with_8_bit_xelpud() => byte(0x374E6B)

// $374E6C: [8-bit] Flag 740 - Control variable for a lot of NPC dialogues
function flag_740_control_variable_for_a_lot_of_npc_dialogues() => byte(0x374E6C)

// $374E6D: [8-bit] Flag 741 - Number of palaeographies read
//          (3 palaeographies in total)
function flag_741_number_of_palaeographies_read() => byte(0x374E6D)

// $374E6E: [8-bit] Flag 742 - Surface - Purchased Mobile Super X2
//          Used to return shop to initial item selection
function flag_742_surface_purchased_mobile_super_x2() => byte(0x374E6E)

// $374E6F: [8-bit] Flag 743 - Surface - Have shown Xelpud a use item
//          If this flag gets set before purchasing the Dragon Bone, email #44 becomes inacessible.
function flag_743_surface_have_shown_xelpud_a_use_item() => byte(0x374E6F)

// $374E70: [8-bit] Flag 744 - Number of pieces of game software collected
//          (9 pieces in total)
function flag_744_number_of_pieces_of_game_software_collected() => byte(0x374E70)

// $374E71: [8-bit] Flag 745 - Number of pieces of software collected
//          (20 pieces in total)
function flag_745_number_of_pieces_of_software_collected() => byte(0x374E71)

// $374E72: [8-bit] Flag 746 - Ancient La-Mulanese learned
function flag_746_ancient_lamulanese_learned() => byte(0x374E72)

// $374E73: [8-bit] Flag 747 - Read tablets counter used by Xelpud emails
//          Counts how many of the tablets tracked by flags 825-836 and flags 883-892 have been read.
//          When 1 tablet has been read, email #36 is sent.
//          When 5 tablets have been read, email #37 is sent.
function flag_747_read_tablets_counter_used_by_xelpud_emails() => byte(0x374E73)

// $374E74: [8-bit] Flag 748 - Dimensional Corridor - Number of Tiamat's children defeated
function flag_748_dimensional_corridor_number_of_tiamats_children_defeated() => byte(0x374E74)

// $374E75: [8-bit] Flag 749 - Dimensional Corridor - Tiamat's ankh exposed
//          Flag sets upon entering Tiamat's room if all 11 children have been defeated
function flag_749_dimensional_corridor_tiamats_ankh_exposed() => byte(0x374E75)

// $374E76: [43 bytes, 8-bit values] Flags 750-792 - Xelpud emails
//          0x00 = Unsent, 0x01 = Unread, 0x02 = Read
//          [0] = Email #00
//          [1] = Email #01
//          [2] = Email #04
//          [3] = Email #05
//          [4] = Email #06
//          [5] = Email #07
//          [6] = Email #08
//          [7] = Email #09
//          [8] = Email #10
//          [9] = Email #11
//          [10] = Email #12
//          [11] = Email #13
//          [12] = Email #14
//          [13] = Email #15
//          [14] = Email #16
//          [15] = Email #17
//          [16] = Email #18
//          [17] = Email #19
//          [18] = Email #20
//          [19] = Email #21
//          [20] = Email #22
//          [21] = Email #23
//          [22] = Email #24
//          [23] = Email #25
//          [24] = Email #26
//          [25] = Email #27
//          [26] = Email #28
//          [27] = Email #29
//          [28] = Email #30
//          [29] = Email #31
//          [30] = Email #32
//          [31] = Email #33
//          [32] = Email #34
//          [33] = Email #35
//          [34] = Email #36
//          [35] = Email #37
//          [36] = Email #38
//          [37] = Email #39
//          [38] = Email #40
//          [39] = Email #41
//          [40] = Email #42
//          [41] = Email #43
//          [42] = Email #44
function _43_bytes_8_bit_values_flags_750_792_xelpud_emails() => byte(0x374E76)

// $374EA1: [15 bytes, 8-bit values] Flags 793-807 - Xelpud show and tell dialogues
//          [0] = Magatama Jewel
//          [1] = Pepper
//          [2] = Cog of the Soul
//          [3] = Lamp of Time
//          [4] = Pochette Key
//          [5] = Dragon Bone
//          [6] = Woman Statue
//          [7] = Maternity Statue
//          [8] = Crystal Skull
//          [9] = Vessel
//          [10] = Key of Eternity
//          [11] = Serpent Staff
//          [12] = Mini Doll
//          [13] = Djed Pilar
//          [14] = Talisman
function _15_bytes_8_bit_values_flags_793_807_xelpud_show_and_tell_dialogues() => byte(0x374EA1)

// $374EB0: [8-bit] Flag 808 - Number of Xelpud emails received
//          Collecting 44 emails causes the Sacrificial Maiden to appear during the credits
function flag_808_number_of_xelpud_emails_received() => byte(0x374EB0)

// $374EB1: [8-bit] Flag 809 - (unused)
function flag_809() => byte(0x374EB1)

// $374EB2: [8 bytes, 8-bit values] Flags 810-817 - Mulbruk dialogues related to fields
//          0x01 = Dialogue primed to occur, 0x02 = Dialogue complete
//          [0] = Temple of Moonlight - Anubis / Book of the Dead
//          [1] = Inferno Cavern
//          [2] = Chamber of Extinction
//          [3] = Tower of the Goddess
//          [4] = Chamber of Birth #1
//          [5] = Chamber of Birth #2
//          [6] = Endless Corridor
//          [7] = Twin Labyrinths
function _8_bytes_8_bit_values_flags_810_817_mulbruk_dialogues_related_to_fields() => byte(0x374EB2)

// $374EBA: [4 bytes, 8-bit values] Flags 818-821 - (unused)
function _4_bytes_8_bit_values_flags_818_821() => dword(0x374EBA)

// $374EBE: [8-bit] Flag 822 - Mulbruk dialogue - laptop / ancient software
//          0x01 = Dialogue primed to occur
//          0x02 = Dialogue complete
function flag_822_mulbruk_dialogue_laptop_ancient_software() => byte(0x374EBE)

// $374EBF: [8-bit] Flag 823 -  Mulbruk dialogue - ocarina
//          0x01 = Dialogue primed to occur
//          0x02 = Dialogue complete
function flag_823_mulbruk_dialogue_ocarina() => byte(0x374EBF)

// $374EC0: [8-bit] Flag 824 - (unused)
function flag_824() => byte(0x374EC0)

// $374EC1: [12 bytes, 8-bit values] Flags 825-836 - Tracking for having read certain tablets
//          [0] = "Ugallu's body, Urmahlullu's voice..."
//          [1] = "Wisdom is buried within the wall...."
//          [2] = "In the place where the God of creation resides, these is a jewel shop..."
//          [3] = "The sigil of the spirit that controls life."
//          [4] = "Rusalii, who likes to play pranks..."
//          [5] = "Too quick for the eyes. That which conrtinues to move, even after time has been stopped..."
//          [6] = "The white diamond represents 'purity'..."
//          [7] = "That which continues without end. It is birth. It is death."
//          [8] = "The white opal represents 'joy'..."
//          [9] = "Dance in this place. Let's praise life."
//          [10] = "Three shall be lit. The light is dependent upon the number of lives the 11 children have."
//          [11] = "Obtain the Dimensional Key..."
function _12_bytes_8_bit_values_flags_825_836_tracking_for_having_read_certain_tablets() => byte(0x374EC1)

// $374ECD: [3 bytes, 8-bit values] Flags 837-839 - (unused)
function _3_bytes_8_bit_values_flags_837_839() => tbyte(0x374ECD)

// $374ED0: [8-bit] Flag 840 - miracle.exe + mirai.exe effect active
function flag_840_miracle_exe_mirai_exe_effect_active() => byte(0x374ED0)

// $374ED1: [8-bit] Flag 841 - Xelpud email #02
//          0x00 = Unsent, 0x01 = Received, 0x02 = Read
function flag_841_xelpud_email_02() => byte(0x374ED1)

// $374ED2: [8-bit] Flag 842 - Hell Temple unlock quest enabled
//          When value is > 0, the following events are available (some may also depend on other flags):
//          - Surface: Sleeping in front of Xelpud's statue
//          - Gate of Guidance: Doorway in Olmec face leading to first encounter with Dracuet
//          - Temple of the Sun: Conversation with Mulbruk about Dracuet
//          - Chamber of Extinction: Teleporter in Palenque's Coffin
function flag_842_hell_temple_unlock_quest_enabled() => byte(0x374ED2)

// $374ED3: [8-bit] Flag 843 - Chamber of Extinction - Antechamber - Breakable wall
function flag_843_chamber_of_extinction_antechamber_breakable_wall() => byte(0x374ED3)

// $374ED4: [8-bit] Flag 844 - Hell Temple unlock dialogue sequence
//          0x01 = Conversation with Mulbruk about Dracuet available
//          0x02 = Had first conversation with Mulbruk about Dracuet
//          0x03 = Had second conversation with Mulbruk about Dracuet
//          0x04 = Spoke with Dracuet in Guidance
//          0x05 = Received hint from Mulbruk about Xelpud's statue
//          0x06 = Sets in Thoth's Room if Hell Temple entrance is unlocked
//          0x07 = Had conversation with Mulbruk about Dracuet being in Hell Temple
//          0x08 = Sets in Thoth's Room if Lemeza has acquired the bathing suit
//          0x09 = Showed Mulbruk the bathing suit
function flag_844_hell_temple_unlock_dialogue_sequence() => byte(0x374ED4)

// $374ED5: [8-bit] Flag 845 - Lamp of Time
//          0x00 = Lamp empty
//          0x01 = Lamp has charge / lamp effect active
//          Used to control whether flame is present in Candlestick of Time objects
function flag_845_lamp_of_time() => byte(0x374ED5)

// $374ED6: [8-bit] Flag 846 - Tower of the Goddess - Path to Power statue has thrown shield
function flag_846_tower_of_the_goddess_path_to_power_statue_has_thrown_shield() => byte(0x374ED6)

// $374ED7: [8-bit] Flag 847 - Have Medicine of the Mind (any colour)
//          Talking with Fobos to reset the puzzle resets this flag
function flag_847_have_medicine_of_the_mind() => byte(0x374ED7)

// $374ED8: [8-bit] Flag 848 - Dimensional Corridor - Left path state
//          0x00 = Path not cleared
//          0x02 = All children killed on left path
function flag_848_dimensional_corridor_left_path_state() => byte(0x374ED8)

// $374ED9: [8-bit] Flag 849 - Dimensional Corridor - Right path state
//          0x00 = Path not cleared
//          0x02 = All children killed on right path
function flag_849_dimensional_corridor_right_path_state() => byte(0x374ED9)

// $374EDA: [8-bit] Flag 850 - Dimensional Corridor - Up path state
//          0x00 = Path not cleared
//          0x02 = All children killed on up path
function flag_850_dimensional_corridor_up_path_state() => byte(0x374EDA)

// $374EDB: [8-bit] Flag 851 - Gate of Guidance - Cover over Amphisbaena ladder removed
//          0x01 = Cover retracting
//          0x02 = Cover retracted
function flag_851_gate_of_guidance_cover_over_amphisbaena_ladder_removed() => byte(0x374EDB)

// $374EDC: [8-bit] Flag 852 - Number of Sacred Orbs collected
//          (10 orbs in total)
function flag_852_number_of_sacred_orbs_collected() => byte(0x374EDC)

// $374EDD: [10 bytes, 8-bit values] Flags 853-862 - Sacred Orb tracking
//          Flags get set to 0x01 after the chest flag for corresponding orb takes on a value of 0x02
//          [0] = Gate of Guidance
//          [1] = Surface
//          [2] = Mausoleum of the Giants
//          [3] = Temple of the Sun
//          [4] = Spring in the Sky
//          [5] = Chamber of Extinction
//          [6] = Twin Labyrinths
//          [7] = Shrine of the Mother
//          [8] = Tower of Ruin
//          [9] = Dimnsional Corridor
function _10_bytes_8_bit_values_flags_853_862_sacred_orb_tracking() => byte(0x374EDD)

// $374EE7: [8-bit] Flag 863 - (unused)
function flag_863() => byte(0x374EE7)

// $374EE8: [8-bit] Flag 864 - Inferno Cavern - Controls bottom floor breaking when Viy spawns in to fight
function flag_864_inferno_cavern_controls_bottom_floor_breaking_when_viy_spawns_in_to_fight() => byte(0x374EE8)

// $374EE9: [8-bit] Flag 865 - Gate of Illusion - Spawn timer control for Trials of the Cog tablets
//          Sets 2 seconds after entering room when event is primed
function flag_865_gate_of_illusion_spawn_timer_control_for_trials_of_the_cog_tablets() => byte(0x374EE9)

// $374EEA: [8-bit] Flag 866 - Gate of Illusion - Chi You chandelier dropped
function flag_866_gate_of_illusion_chi_you_chandelier_dropped() => byte(0x374EEA)

// $374EEB: [8-bit] Flag 867 - Gate of Illusion - Scanned blue wall element in Fool's Confusion Corridor to open hole in floor
function flag_867_gate_of_illusion_scanned_blue_wall_element_in_fools_confusion_corridor_to_open_hole_in_floor() => byte(0x374EEB)

// $374EEC: [8-bit] Flag 868 - Temple of Moonlight - Anubis' ladder
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_868_temple_of_moonlight_anubis_ladder() => byte(0x374EEC)

// $374EED: [8-bit] Flag 869 - Temple of Moonlight - Serdab of Treasure - Breakable floor
function flag_869_temple_of_moonlight_serdab_of_treasure_breakable_floor() => byte(0x374EED)

// $374EEE: [8-bit] Flag 870 - Temple of Moonlight - Serdab of Treasure - Breakable floor
function flag_870_temple_of_moonlight_serdab_of_treasure_breakable_floor() => byte(0x374EEE)

// $374EEF: [8-bit] Flag 871 - Tower of the Goddess - Unlocked shortcut door (Skuld's tower)
function flag_871_tower_of_the_goddess_unlocked_shortcut_door() => byte(0x374EEF)

// $374EF0: [8-bit] Flag 872 - Tower of the Goddess - Counter for falling down Skuld's tower
//          Once Lemeza has fallen 20 floors, the shortcut door unlocks
function flag_872_tower_of_the_goddess_counter_for_falling_down_skulds_tower() => byte(0x374EF0)

// $374EF1: [8-bit] Flag 873 - Tower of Ruin - Ladder connecting upper Ruin and Nüwa's Pyramid
//          0x01 = Ladder deploying
//          0x02 = Ladder deployed
function flag_873_tower_of_ruin_ladder_connecting_upper_ruin_and_nüwas_pyramid() => byte(0x374EF1)

// $374EF2: [8-bit] Flag 874 - Temple of the Sun - Mulbruk has run away after seeing Lemeza in the provocative bathing suit
function flag_874_temple_of_the_sun_mulbruk_has_run_away_after_seeing_lemeza_in_the_provocative_bathing_suit() => byte(0x374EF2)

// $374EF3: [8-bit] Flag 875 - True Shrine of the Mother - Related to spawn animation for Mother's ankh
function flag_875_true_shrine_of_the_mother_related_to_spawn_animation_for_mothers_ankh() => byte(0x374EF3)

// $374EF4: [8-bit] Flag 876 - (unused)
function flag_876() => byte(0x374EF4)

// $374EF5: [8-bit] Flag 877 - Tower of the Goddess - Broke open shortcut wall (Verdandi's tower)
function flag_877_tower_of_the_goddess_broke_open_shortcut_wall() => byte(0x374EF5)

// $374EF6: [8-bit] Flag 878 - Xelpud email #03
//          0x00 = Unsent, 0x01 = Received, 0x02 = Read
function flag_878_xelpud_email_03() => byte(0x374EF6)

// $374EF7: [8-bit] Flag 879 - Item pots:
//          Bit0 = Temple of the Sun G4 - Weight
//          Bit1 = Temple of the Sun G4 - Coins x 15
//          Bit2 = Temple of the Sun G4 - Rolling Shuriken Ammo x 10
//          Bit3 = Temple of the Sun G4 - Coins x 20
//          Bit4 = Temple of the Sun G4 - Shuriken Ammo x 10
//          Bit5 = Temple of the Sun G4 - Coins x 15
//          Bit6 = Temple of the Sun G4 - Caltrop Ammo x 5
function flag_879_item_pots() => byte(0x374EF7)

// $374EF8: [8-bit] Flag 880 - Chamber of Birth - Connection between Vishnu's room and Parvati's room
//          0x00 = Wall intact
//          0x01 = Wall broken
function flag_880_chamber_of_birth_connection_between_vishnus_room_and_parvatis_room() => byte(0x374EF8)

// $374EF9: [8-bit] Flag 881 - Dimensional Corridor - Cleared all three paths
function flag_881_dimensional_corridor_cleared_all_three_paths() => byte(0x374EF9)

// $374EFA: [8-bit] Flag 882 - Dimensional Corridor - Opened entrance to Mushussu's Room
function flag_882_dimensional_corridor_opened_entrance_to_mushussus_room() => byte(0x374EFA)

// $374EFB: [10 bytes, 8-bit values] Flags 883-892 - Tracking for having read certain tablets
//          [0] = "There is a potion that makes the large spirit visible..."
//          [1] = "The joyful heart is pearly white, the eloquent heart is black..."
//          [2] = "There are two Angel Shield, shining golden, in this world..."
//          [3] = "A great treasure lies within this land. The device that creates life..."
//          [4] = "11 children guard Tiamat's room..."
//          [5] = "A meeting of man and women. Inside the man the seed of life is born."
//          [6] = "The joyful heart is 20, the eloquent heart is 44..."
//          [7] = "The sound of the ocarina may be heard only by a woman with child."
//          [8] = "The guardian protects something else. There will be a wedge there..."
//          [9] = "The Crystal Skull suppresses Tiamat's powers..."
function _10_bytes_8_bit_values_flags_883_892_tracking_for_having_read_certain_tablets() => byte(0x374EFB)

// $374F05: [8-bit] Flag 893 - Surface - Showed Xelpud the Hand Scanner
function flag_893_surface_showed_xelpud_the_hand_scanner() => byte(0x374F05)

// $374F06: [8-bit] Flag 894 - Surface - Showed Xelpud the Mulana Talisman
function flag_894_surface_showed_xelpud_the_mulana_talisman() => byte(0x374F06)

// $374F07: [8-bit] Flag 895 - Temple of the Sun - Minecart elevator
//          0x00 = Top position
//          0x01 = Descending
//          0x02 = Bottom position
function flag_895_temple_of_the_sun_minecart_elevator() => byte(0x374F07)

// $374F08: [8-bit] Flag 896 - Gate of Guidance - Monument of Time - Miracle Witch check
//          This flag gets set when the player visits the screen containing the shop in Gate of Guidance after purchasing Miracle Witch, and is used to control adding 2 points to the hidden game score. Checks flag 233 (Miracle Witch) instead of flag 223 (Guild) as was probably intended.
function flag_896_gate_of_guidance_monument_of_time_miracle_witch_check() => byte(0x374F08)

// $374F09: [8-bit] Flag 897 - Gate of Illusion - Elevator spawned after Chi You
//          0x01 = Elevator spawn animation
//          0x02 = Elevator spawn animation
//          0x03 = Elevator active
function flag_897_gate_of_illusion_elevator_spawned_after_chi_you() => byte(0x374F09)

// $374F0A: [8-bit] Flag 898 - Mother defeated
function flag_898_mother_defeated() => byte(0x374F0A)

// $374F0B: [8-bit] Flag 899 - Shrine of the Mother - Four seals chest
//          0x01 = Origin seal broken
//          0x02 = All seals broken
function flag_899_shrine_of_the_mother_four_seals_chest() => byte(0x374F0B)

// $374F0C: [8-bit] Flag 900 - Number of fairy points used
//          (9 fairy points in total)
function flag_900_number_of_fairy_points_used() => byte(0x374F0C)

// $374F0D: [8-bit] Flag 901 - Shrine of the Mother - Four seals chest
//          0x01 = Birth seal broken
function flag_901_shrine_of_the_mother_four_seals_chest() => byte(0x374F0D)

// $374F0E: [8-bit] Flag 902 - Number of key fairy checks unlocked
//          (4 key fairy checks in total)
function flag_902_number_of_key_fairy_checks_unlocked() => byte(0x374F0E)

// $374F0F: [8-bit] Flag 903 - Spring in the Sky - Bought Shell Horn or Guild from Mr. Fishman
function flag_903_spring_in_the_sky_bought_shell_horn_or_guild_from_mr_fishman() => byte(0x374F0F)

// $374F10: [8-bit] Flag 904 - Tower of the Goddess - Visited Naramura's developer room
function flag_904_tower_of_the_goddess_visited_naramuras_developer_room() => byte(0x374F10)

// $374F11: [8-bit] Flag 905 - Gate of Illusion - Visited Duplex's developer room
function flag_905_gate_of_illusion_visited_duplexs_developer_room() => byte(0x374F11)

// $374F12: [8-bit] Flag 906 - Temple of Moonlight - Visited Samieru's developer room
function flag_906_temple_of_moonlight_visited_samierus_developer_room() => byte(0x374F12)

// $374F13: [4 bytes, 8-bit values] Flags 907-910 - Key fairy checks
//          0x00 = Locked, 0x01 = Unlocking, 0x02 = Unlocked
//          [0] = Spring in the Sky
//          [1] = Chamber of Extinction
//          [2] = Gate of Illusion
//          [3] = Tower of the Goddess
function _4_bytes_8_bit_values_flags_907_910_key_fairy_checks() => dword(0x374F13)

// $374F17: [8-bit] Flag 911 - Shrine of the Mother - Four seals chest
//          0x01 = Life seal broken
function flag_911_shrine_of_the_mother_four_seals_chest() => byte(0x374F17)

// $374F18: [8-bit] Flag 912 - Shrine of the Mother - Four seals chest
//          0x01 = Death seal broken
function flag_912_shrine_of_the_mother_four_seals_chest() => byte(0x374F18)

// $374F19: [8-bit] Flag 913 Temple of the Sun - Had initial conversation with Mulbruk about Wedjet
//          This flag enables all further hint/lore conversations with Mulbruk
function flag_913_temple_of_the_sun_had_initial_conversation_with_mulbruk_about_wedjet() => byte(0x374F19)

// $374F1A: [9 bytes, 8-bit values] Flags 914-922 - Fairy points used
//          [0] = Spring in the Sky
//          [1] = Chamber of Extinction
//          [2] = Shrine of the Mother
//          [3] = Endless Corridor
//          [4] = Temple of Moonlight
//          [5] = Tower of the Goddess
//          [6] = Twin Labyrinths
//          [7] = Gate of Illusion
//          [8] = True Shrine of the Mother
function _9_bytes_8_bit_values_flags_914_922_fairy_points_used() => byte(0x374F1A)

// $374F23: [8-bit] Flag 923 - Temple of the Sun - Horus' Room
//          Sets after ankh jewel collected, used to ensure game score is only updated once for solving Wedjet puzzle
function flag_923_temple_of_the_sun_horus_room() => byte(0x374F23)

// $374F24: [8-bit] Flag 924 - Dimensional Corridor
//          When Lemeza does not have the Dimensional Key, this flag is used to track state between Lahamu's room and Usum's room to reset some right-hand path flags
function flag_924_dimensional_corridor() => byte(0x374F24)

// $374F25: [8-bit] Flag 925 - Mausoleum of the Giants - Hard mode activated
//          Gets set after reading tablet for the second time. But flag 363 == 0x02 is the canonical hard mode check used by all objects in script.rcd.
//          Controls whether Mom's spirit appears during the credits.
function flag_925_mausoleum_of_the_giants_hard_mode_activated() => byte(0x374F25)

// $374F26: [22 bytes, 8-bit values] Flags 926-947 - Read tablets count control flags
//          These flags are used to ensure that read tablets tracked in flags 825-836 and flags 883-892 are only credited once in the read tablets count at flag 747. Each flag in this array gets set when the corresponding tablet flag is addted to flag 747.
//          [0] = Flag 825
//          [1] = Flag 826
//          [2] = Flag 827
//          [3] = Flag 828
//          [4] = Flag 829
//          [5] = Flag 830
//          [6] = Flag 832
//          [7] = Flag 833
//          [8] = Flag 834
//          [9] = Flag 835
//          [10] = Flag 836
//          [11] = Flag 831
//          [12] = Flag 883
//          [13] = Flag 884
//          [14] = Flag 885
//          [15] = Flag 886
//          [16] = Flag 887
//          [17] = (unused)
//          [18] = Flag 889
//          [19] = Flag 890
//          [20] = Flag 891
//          [21] = Flag 892
function _22_bytes_8_bit_values_flags_926_947_read_tablets_count_control_flags() => byte(0x374F26)

// $374F3C: [8-bit] Flag 948 - Graveyard of the Giants - Dropped ice block into hot springs
function flag_948_graveyard_of_the_giants_dropped_ice_block_into_hot_springs() => byte(0x374F3C)

// $374F3D: [8-bit] Flag 949 - Graveyard of the Giants - Hot springs temperature
//          0x00 = Scalding
//          0x01 = Just right
function flag_949_graveyard_of_the_giants_hot_springs_temperature() => byte(0x374F3D)

// $374F3E: [8-bit] Flag 950 - Surface - Xelpud's initial dialogue available
//          Flag sets as soon as Xelpud's tent opens. When this flag is 1 and flag 325 is 0, talking to Xelpud will result in the initial conversation that awards Xelpud Mailer
function flag_950_surface_xelpuds_initial_dialogue_available() => byte(0x374F3E)

// $374F3F: [8-bit] Flag 951 - Inferno Cavern - 5 door uncovered
function flag_951_inferno_cavern_5_door_uncovered() => byte(0x374F3F)

// $374F40: [8-bit] Flag 952 - Chamber of Extinction - Chest that holds Palenque's ankh jewel after exiting fight
//          0x00 = Empty
//          0x01 = In chest (gets set at start of fight)
//          0x03 = Palenque defeated
function flag_952_chamber_of_extinction_chest_that_holds_palenques_ankh_jewel_after_exiting_fight() => byte(0x374F40)

// $374F41: [8-bit] Flag 953 - True Shrine of the Mother - Final obstacle removed by fairies
function flag_953_true_shrine_of_the_mother_final_obstacle_removed_by_fairies() => byte(0x374F41)

// $374F42: [8-bit] Flag 594 - Hell Temple unlock sequence
//          0x01 = Had conversation with Mulbruk about Dracuet
//          0x02 = Had conversation with Dracuet in Guidance
//          0x03 = Slept in front of Xelpud Statue
//          0x04 = Talked to nighttime Xelpud
//          0x05 = Talked to fairy behind Mekuri Master tent
//          0x06 = Unlocked upside down room in Illusion
//          0x07 = Had conversation in Illusion / 8-bit Hell Temple entrance opened
//          0x08 = Had conversation in 8-bit Hell Temple / Teleporters active in Palenque's Coffin
//          0x09 = Had conversation in Tower of the Goddess inaccessible room / Hell Temple unlocked (see flag 955)
function flag_594_hell_temple_unlock_sequence() => byte(0x374F42)

// $374F43: [8-bit] Flag 955 - Hell Temple entrance unlocked
//          Opens the wall to allow Lemeza into the upper secition of Holy Temple of the Cross, if flag 842 is set also enables the entrance door to Hell Temple
function flag_955_hell_temple_entrance_unlocked() => byte(0x374F43)

// $374F44: [3 bytes, 8-bit values] Flags 956-958 - Dimensional Corridor - Tracking for first three Mushussu unlock dances
function _3_bytes_8_bit_values_flags_956_958_dimensional_corridor_tracking_for_first_three_mushussu_unlock_dances() => tbyte(0x374F44)

// $374F47: [8-bit] Flag 959 - Temple of Moonlight - Connection to Graveyard
//          Finished opening connection
function flag_959_temple_of_moonlight_connection_to_graveyard() => byte(0x374F47)

// $374F48: [8-bit] Flag 960 - Activated moving block one scren left of Skanda's room
function flag_960_activated_moving_block_one_scren_left_of_skandas_room() => byte(0x374F48)

// $374F49: [8-bit] Flag 961 - (unused)
function flag_961() => byte(0x374F49)

// $374F4A: [8-bit] Flag 962 - Chamber of Birth - Crystal Skull used
function flag_962_chamber_of_birth_crystal_skull_used() => byte(0x374F4A)

// $374F4B: [8-bit] Flag 963 - Chamber of Birth - Cog of the Soul used (second time)
function flag_963_chamber_of_birth_cog_of_the_soul_used() => byte(0x374F4B)

// $374F4C: [8-bit] Flag 964 - Chamber of Birth - Cog of the Soul used (first time)
function flag_964_chamber_of_birth_cog_of_the_soul_used() => byte(0x374F4C)

// $374F4D: [8-bit] Flag 965 - Chamber of Birth - Serpent Staff used
function flag_965_chamber_of_birth_serpent_staff_used() => byte(0x374F4D)

// $374F4E: [8-bit] Flag 966 - Chamber of Birth - Beheaded Asura with ring of light
function flag_966_chamber_of_birth_beheaded_asura_with_ring_of_light() => byte(0x374F4E)

// $374F4F: [8-bit] Flag 967 - Chamber of Birth - Pit of Eternity - Placed items in both alcoves
function flag_967_chamber_of_birth_pit_of_eternity_placed_items_in_both_alcoves() => byte(0x374F4F)

// $374F50: [8-bit] Flag 968 - Chamber of Birth - Scanned Gashesha's mural
function flag_968_chamber_of_birth_scanned_gasheshas_mural() => byte(0x374F50)

// $374F51: [8 bytes , 8-bit values] Flags 969-976 - Guardians defeated
//          These flags get set 1 second later than the corresponding flags 726-733
//          [0] = Amphisbaena
//          [1] = Sakit
//          [2] = Ellmac
//          [3] = Bahamut
//          [4] = Viy
//          [5] = Palenque
//          [6] = Baphomet
//          [7] = Tiamat
function _8_bytes_8_bit_values_flags_969_976_guardians_defeated() => byte(0x374F51)

// $374F59: [16 bytes, 8-bit values] Flags 977-992 - Room guards defeated
//          Tracks defeat of certain minibosses to enable spawning of other enemies in the room when revisited
//          [0] = Red Skeletons
//          [1] = Nuckelavee
//          [2] = Pazuzu
//          [3] = Hekatonkheires
//          [4] = Ba
//          [5] = Kamaitachi
//          [6] = Anubis
//          [7] = Skanda
//          [8] = Kulullu
//          [9] = Kuusarikku
//          [10] = Ushum
//          [11] = Lahamu
//          [12] = Urmahlullu
//          [13] = Mushnahhu
//          [14] = Umu Dabrutu
//          [15] = Ushumgallu
function _16_bytes_8_bit_values_flags_977_992_room_guards_defeated() => byte(0x374F59)

// $374F69: [8-bit] Flag 993 - Gate of Guidance - Controls push block in Snake Sanctuary falling out of wall after red skeletons defeated
function flag_993_gate_of_guidance_controls_push_block_in_snake_sanctuary_falling_out_of_wall_after_red_skeletons_defeated() => byte(0x374F69)

// $374F6A: [8-bit] Flag 994 - Chamber of Birth - Controls timing of removal of crusher covering teleporter in Lakshmi's Room after scanning the Ganeha mural
function flag_994_chamber_of_birth_controls_timing_of_removal_of_crusher_covering_teleporter_in_lakshmis_room_after_scanning_the_ganeha_mural() => byte(0x374F6A)

// $374F6B: [8-bit] Flag 995 - Dimensional Corridor - Set when Kussarikku defeated to enable dais that unlocks Fobos' room
function flag_995_dimensional_corridor_set_when_kussarikku_defeated_to_enable_dais_that_unlocks_fobos_room() => byte(0x374F6B)

// $374F6C: [8-bit] Flag 996 - Dimensional Corridor - Removed cover on Fobos' room
function flag_996_dimensional_corridor_removed_cover_on_fobos_room() => byte(0x374F6C)

// $374F6D: [8-bit] Flag 997 - Chamber of Birth - Pit of Eternity - Maternity Statue placed
function flag_997_chamber_of_birth_pit_of_eternity_maternity_statue_placed() => byte(0x374F6D)

// $374F6E: [8-bit] Flag 998 - Chamber of Birth - Pit of Eternity - Dragon Bone placed
function flag_998_chamber_of_birth_pit_of_eternity_dragon_bone_placed() => byte(0x374F6E)

// $374F6F: [8-bit] Flag 999 - Dimensional Corridor - Dimensional Key related
//          Gets set the first time player enters Dimensional Corridor with the key in posession, used to control zeroing out values in flags 848-850 (paths cleared), flags 985-982 (Tiamat's children defeated), and flag 748 (number of Tiamat's children defeated)
function flag_999_dimensional_corridor_dimensional_key_related() => byte(0x374F6F)

// $374F70: [8-bit] Flag 1000 - Assigned to escape timer
//          Purpose unknown
function flag_1000_assigned_to_escape_timer() => byte(0x374F70)

// $374F71: [8-bit] Flag 1001 - Escape timer elapsed
//          Value goes to 1 for a few frames when timer runs out
function flag_1001_escape_timer_elapsed() => byte(0x374F71)

// $374F72: [8-bit] Flag 1002 - Assigned to escape timer
//          Purpose unknown
function flag_1002_assigned_to_escape_timer() => byte(0x374F72)

// $374F73: [8-bit] Flag 1003 - Temple of the Sun - Aten's Room - Spike control
//          0x00 = Spikes present
//          0x01 = Spikes absent (minecart pushed down to room)
function flag_1003_temple_of_the_sun_atens_room_spike_control() => byte(0x374F73)

// $374F74: [8-bit] Flag 1004 - Temple of the Sun - Shawn Kosugi related
function flag_1004_temple_of_the_sun_shawn_kosugi_related() => byte(0x374F74)

// $374F75: [8-bit] Flag 1005 - Lamp of Time mystery flag
//          Gets set to 1 when the lamp is charged at a candlestick of time. Unlike flag 845, this is not cleared when the lamp effect expires, but is instead cleared by flag watchers in certain rooms of the ruins. Can be cleared while the lamp still has a charge, can still be set after the lamp effect expires. What purpose does it serve?
function flag_1005_lamp_of_time_mystery_flag() => byte(0x374F75)

// $374F76: [8-bit] Flag 1006 - True Shrine of the Mother - Timed trigger to control spawning of fairy wall
//          Sets 30 frames after entering appropriate screen, flag is used to ensure timer only runs once
function flag_1006_true_shrine_of_the_mother_timed_trigger_to_control_spawning_of_fairy_wall() => byte(0x374F76)

// $374F77: [8-bit] Flag 1007 - True Shrine of the Mother - Mother's ankh spawn animation has completed
function flag_1007_true_shrine_of_the_mother_mothers_ankh_spawn_animation_has_completed() => byte(0x374F77)

// $374F78: [8-bit] Flag 1008 - Spring in the Sky - Ankh exposure sequence
//          0x01 = Counterweight elevator depressed
//          0x02 = Dais spawned
//          0x03 = Dais pressed -> Dais spawned in Oannes' Waterfall (see flags 403 & 415)
function flag_1008_spring_in_the_sky_ankh_exposure_sequence() => byte(0x374F78)

// $374F79: [8-bit] Flag 1009 - Dimensional Corridor - Timing control for appearance of BIRTH and DEATH tablets
//          0x01 = Completed first conversation with Fobos
//          0x02 = Tablet spawn timer complete (2 seconds after leaving Fobos' room)
function flag_1009_dimensional_corridor_timing_control_for_appearance_of_birth_and_death_tablets() => byte(0x374F79)

// $374F7A: [8-bit] Flag 1010 - Gate of Guidance - Controls falling platform during escape
function flag_1010_gate_of_guidance_controls_falling_platform_during_escape() => byte(0x374F7A)

// $374F7B: [8-bit] Flag 1011 - Gate of Guidance - Mystery flag
//          If this flag has a value of 1 or 2, entering any of three different rooms will set its value to 3
//          There is no scripted event to ever change its value from the initial state of 0 (?!)
function flag_1011_gate_of_guidance_mystery_flag() => byte(0x374F7B)

// $374F7C: [8-bit] Flag 1012 - Gate of Guidance - Controls falling platform during escape
function flag_1012_gate_of_guidance_controls_falling_platform_during_escape() => byte(0x374F7C)

// $374F7D: [8-bit] Flag 1013 - Mausoleum of the Giants - Controls falling platform during escape
function flag_1013_mausoleum_of_the_giants_controls_falling_platform_during_escape() => byte(0x374F7D)

// $374F7E: [8-bit] Flag 1014 - Mausoleum of the Giants - Shaft to the Heavens - Controls animation during escape
//          Paired with flag 1024
function flag_1014_mausoleum_of_the_giants_shaft_to_the_heavens_controls_animation_during_escape() => byte(0x374F7E)

// $374F7F: [8-bit] Flag 1015 - Twin Labyrinths - Controls falling platform during escape (exposes Escape Chest)
function flag_1015_twin_labyrinths_controls_falling_platform_during_escape() => byte(0x374F7F)

// $374F80: [8-bit] Flag 1016 - Twin Labyrinths - Controls animation during escape
function flag_1016_twin_labyrinths_controls_animation_during_escape() => byte(0x374F80)

// $374F81: [8-bit] Flag 1017 - Twin Labyrinths - Controls animation during escape
function flag_1017_twin_labyrinths_controls_animation_during_escape() => byte(0x374F81)

// $374F82: [8-bit] Flag 1018 - Mausoleum of the Giants - Controls animation during escape
//          Abuto statue collapse, paired wth flag 1028
function flag_1018_mausoleum_of_the_giants_controls_animation_during_escape() => byte(0x374F82)

// $374F83: [8-bit] Flag 1019 - Endless Corridor - Escape shortcut opened
function flag_1019_endless_corridor_escape_shortcut_opened() => byte(0x374F83)

// $374F84: [8-bit] Flag 1020 - Twin Labyrinths - Coin chest (escape chest)
function flag_1020_twin_labyrinths_coin_chest() => byte(0x374F84)

// $374F85: [8-bit] Flag 1021 - Endless Corridor - Animation completed for opening escape shortcut
function flag_1021_endless_corridor_animation_completed_for_opening_escape_shortcut() => byte(0x374F85)

// $374F86: [8-bit] Flag 1022 - Twin Labyrinths - Controls room spawner during escape
//          Paired with flag 1016
function flag_1022_twin_labyrinths_controls_room_spawner_during_escape() => byte(0x374F86)

// $374F87: [8-bit] Flag 1023 - Twin Labyrinths - Controls room spawner during escape
//          Paired with flag 1017
function flag_1023_twin_labyrinths_controls_room_spawner_during_escape() => byte(0x374F87)

// $374F88: [8-bit] Flag 1024 - Mausoleum of the Giants - Controls animation during escape
function flag_1024_mausoleum_of_the_giants_controls_animation_during_escape() => byte(0x374F88)

// $374F89: [8-bit] Flag 1025 - Chamber of Extinction - Coin chest
function flag_1025_chamber_of_extinction_coin_chest() => byte(0x374F89)

// $374F8A: [8-bit] Flag 1026 - Chamber of Extinction - Coin chest unlock
//          0x01 = Covering object broken
//          0x02 = Chest unlocked
function flag_1026_chamber_of_extinction_coin_chest_unlock() => byte(0x374F8A)

// $374F8B: [8-bit] Flag 1027 - Escape timer and screenshake control
//          Sets to 1 upon climining up to Ellmac's Room or falling down to Palenque's Room while escape is active. Used to ensure timer and screen shake are only started the first time Lemeza enters Tiamat's Room after defeating the Mother.
function flag_1027_escape_timer_and_screenshake_control() => byte(0x374F8B)

// $374F8C: [8-bit] Flag 1028 - Mausoleum of the Giants - Controls animation during escape
//          Abuto statue collapse, pared with flag 1018
function flag_1028_mausoleum_of_the_giants_controls_animation_during_escape() => byte(0x374F8C)

// $374F8D: [8-bit] Flag 1029 - Gets set one second after the screen transition from Home of the Mother to Tiamat's Room if the Mother has been defeated
//          
//          Not referenced anywhere in game script except for the flag timer object that sets it. Possibly queried by event engine for a character appearance request during the credits. Can be used to detect glitched escape.
function flag_1029_gets_set_one_second_after_the_screen_transition_from_home_of_the_mother_to_tiamats_room_if_the_mother_has_been_defeated() => byte(0x374F8D)

// $374F8E: [8 bytes, 8-bit values] Flags 1030-1037 - (unused)
function _8_bytes_8_bit_values_flags_1030_1037() => byte(0x374F8E)

// $374F96: [8-bit] Flag 1038 - Chamber of Extinction - Controls animation for lowering Mural of Invocation
function flag_1038_chamber_of_extinction_controls_animation_for_lowering_mural_of_invocation() => byte(0x374F96)

// $374F97: [8-bit] Flag 1039 - Surface - Slept in front of Xelpud's Statue
//          Must be on Hell Temple quest to set this flag
function flag_1039_surface_slept_in_front_of_xelpuds_statue() => byte(0x374F97)

// $374F98: [8-bit] Flag 1040 - Temple of Moonlight - Mystery flag
//          Gets set after entering any of four screens, never referenced anywhere else in game script
function flag_1040_temple_of_moonlight_mystery_flag() => byte(0x374F98)

// $374F99: [3 bytes, 8-bit values] Flags 1041-1043 - (unused)
function _3_bytes_8_bit_values_flags_1041_1043() => tbyte(0x374F99)

// $374F9C: [8-bit] Flag 1044 - Surface - Entrance to the La-Mulana Ruins
//          0x01 = Lemeza proximity detection / crusher covering ruins entrance begins retracting
//          0x02 = Ruins entrance uncovered
function flag_1044_surface_entrance_to_the_lamulana_ruins() => byte(0x374F9C)

// $374F9D: [8-bit] Flag 1045 - Flag - Temple of the Sun - Altar of Mirrors
//          Controls timing for retracting the crusher blocking access to coin pots and Bronze Mirror chest. If the mirror wall in Extinction has been broken, this flag sets after one second on screen at Altar of Mirrors and retracts the crusher.
function flag_1045_flag_temple_of_the_sun_altar_of_mirrors() => byte(0x374F9D)

// $374F9E: [8-bit] Flag 1046 - Mausoleum of the Giants
//          Controls animation for rotating the hard mode tablet after it has been read for the first time.
function flag_1046_mausoleum_of_the_giants() => byte(0x374F9E)

// $374F9F: [8-bit] Flag 1047 - Endless Corridor - Third Endless Corridor - Wall blocking keyhole area
//          0x00 = Wall present
//          0x01 = Wall absent
function flag_1047_endless_corridor_third_endless_corridor_wall_blocking_keyhole_area() => byte(0x374F9F)

// $374FA0: [8-bit] Flag 1048 - Dimensional Corridor - Ankh jewel chest unlocked
function flag_1048_dimensional_corridor_ankh_jewel_chest_unlocked() => byte(0x374FA0)

// $374FA1: [8-bit] Flag 1049 - Gate of Illusion - Explosion chest triggered
//          Gets set when the explosion spawns, not referenced anywhere else in game script.
function flag_1049_gate_of_illusion_explosion_chest_triggered() => byte(0x374FA1)

// $374FA2: [8-bit] Flag 1050 - Dimensional Corridor - BIRTH and DEATH tablets are visible
function flag_1050_dimensional_corridor_birth_and_death_tablets_are_visible() => byte(0x374FA2)

// $374FA3: [8-bit] Flag 1051 - Gate of Illusion - Tracks state for sequencing flow of sacrificial maidens across rooms
function flag_1051_gate_of_illusion_tracks_state_for_sequencing_flow_of_sacrificial_maidens_across_rooms() => byte(0x374FA3)

// $374FA4: [8-bit] Flag 1052 - Tower of the Goddess - Flooded side chambers in Spring in the Sky
function flag_1052_tower_of_the_goddess_flooded_side_chambers_in_spring_in_the_sky() => byte(0x374FA4)

// $374FA5: [8-bit] Flag 1053 - Graveyard of the Giants - Bombable floor under trap chest
//          Floor underneath the trap chest in Path to the Graveyard can be bombed to open a wraparound shortcut to the grail point.
function flag_1053_graveyard_of_the_giants_bombable_floor_under_trap_chest() => byte(0x374FA5)

// $374FA6: [8-bit] Flag 1054 - Temple of the Sun - Isis' Room - Read tablet
//          Controls spawning of dais to unlock chest after reading the tablet in the room
function flag_1054_temple_of_the_sun_isis_room_read_tablet() => byte(0x374FA6)

// $374FA7: [195 bytes, 8-bit values] Flags 1055-1249 - (unused)
function _195_bytes_8_bit_values_flags_1055_1249() => byte(0x374FA7)

// $37506A: [8-bit] Flag 1250 - Read tablet ("Look to the weapon in thy hand. The key to the awakening lies within.")
function flag_1250_read_tablet() => byte(0x37506A)

// $37506B: [70 bytes, 8-bit values] Flags 1251-1320 - (unused)
function _70_bytes_8_bit_values_flags_1251_1320() => byte(0x37506B)

// $3750B1: [8-bit] Flag 1321 - Read tablet ("The Goddess of the Mountain changes her form...")
function flag_1321_read_tablet() => byte(0x3750B1)

// $3750B2: [7 bytes, 8-bit values] Flags 1322-1328 - (unused)
function _7_bytes_8_bit_values_flags_1322_1328() => byte(0x3750B2)

// $3750B9: [8-bit] Flag 1329 - Read tablet ("The cycle continues. The mother destroys the ill favored child, and gives birth to a new child...")
function flag_1329_read_tablet() => byte(0x3750B9)

// $3750BA: [2766  bytes, 8-bit values] Flags 1330-4095 - (unused)
function _2766_bytes_8_bit_values_flags_1330_4095() => byte(0x3750BA)

// $376169: [8-bit] Pause state
//          Bit2 = Paused
//          Bit6 = Lemeza fallen asleep
function pause_state() => byte(0x376169)

// $37616A: [8-bit] MSX open
//          Bit5 = MSX open
function msx_open() => bit5(0x37616A)

// $37616E: [8-bit] State related to shops/NPC rooms and boss fights
//          0x00 = Normal gameplay
//          0x01 = Breaking ankh / entering shop
//          0x04 = Boss fight - player has control
//          0x05 = Boss fight - player does not have control
//          0x41 = In shop/NPC room
//          0x80 = Raising ankh jewel
//          0x84 = Boss defeated?
function state_related_to_shops_npc_rooms_and_boss_fights() => byte(0x37616E)

// $376171: [8-bit] Partial game state
//          Bit4 = Grail ring open
//          Bit6 = Reading something with hand scanner / NPC dialogue / shop
function partial_game_state_reading_something_with_hand_scanner_npc_dialogue_shop() => bit6(0x376171)

// $376174: [8-bit] Flag indicating whether revive combo effect has been used
//          0x00 = Unused
//          0x02 = Used
function flag_indicating_whether_revive_combo_effect_has_been_used() => byte(0x376174)

// $37617A: [8-bit] Flag - Lamp of Time active
//          Bit0 = Lamp effect active
function flag_lamp_of_time_active() => byte(0x37617A)

// $376568: [20 bytes, 8-bit values] Array of equipped software titles
//          0x00 = (empty)
//          0x55 = Glyph Reader
//          0x56 = Xelpud Mailer
//          0x57 = Yagoo Map Reader
//          0x58 = Yagoo Map Street
//          0x59 = TextTrax
//          0x5a = Additional Text Memory
function _20_bytes_8_bit_values_array_of_equipped_software_titles() => byte(0x376568)

// $376580: [40 bytes, 16-bit BE values] Array of software memory costs
function _40_bytes_16_bit_be_values_array_of_software_memory_costs() => byte(0x376580)

// $376600: [20 bytes, 8-bit values] Array of flags indicating which software is activated
//          [0] = Glyph Reader
//          [1] = Xelpud Mailer
//          [2] = Yagoo Map Reader
//          [3] = Yagoo Map Street
//          [4] = TextTrax
//          [5] = Additional Text Memory
//          [6] = Snapshots
//          [7] = Guild
//          [8] = Mantra
//          [9] = Enga Musica
//          [10] = Beo La-Mulana
//          [11] = Death Village
//          [12] = Rose and Camellia
//          [13] = Space Capster II
//          [14] = Lonely House Moving
//          [15] = Mekuri Master
//          [16] = Bounce Shot
//          [17] = Miracle Witch
//          [18] = Future Development Company
//          [19] = La-Mulana
function _20_bytes_8_bit_values_array_of_flags_indicating_which_software_is_activated() => byte(0x376600)

// $3767E0: [10 bytes, 8-bit values] Flags - Learned mantras
//          [0] = BIRTH
//          [1] = DEATH
//          [2] = MARDUK
//          [3] = SABBAT
//          [4] = MU
//          [5] = VIY
//          [6] = BAHRUN
//          [7] = WEDJET
//          [8] = ABUTO
//          [9] = LAMULANA
function _10_bytes_8_bit_values_flags_learned_mantras() => byte(0x3767E0)

// $378B38: [32-bit BE] Index of last referenced script card from `script.dat`
//          0x00e2 = "To the one who toils for naught. Thou art foolish. Thou art foolish. Thou art foolish. Thou art foolish."
//          0x02f1 = Mulbruk: Base dialogue tree
//          0x039d = Mulbruk: "Escape this way! Hurry!"
//          
//          ---
//          Value can also hold the number of times a weapon has been swung this session and possible some other things. Can be safely assumed to be a script card ID whenever bit6 of 0x00376171 is set.
function index_of_last_referenced_script_card_from_script_dat() => dword_be(0x378B38)

// $3AFAFC: [32-bit BE] [JP] Music ID
//          See 0x363abc for list of values
function jp_music_id() => dword_be(0x3AFAFC)

// $3AFBCC: [32-bit BE] [JP] In-game time (milliseconds)
function jp_ingame_time() => dword_be(0x3AFBCC)

// $3AFC18: [32-bit BE] [JP] Health bar length
function jp_health_bar_length() => dword_be(0x3AFC18)

// $3AFC1C: [32-bit BE] [JP] EXP
function jp_exp() => dword_be(0x3AFC1C)

// $3AFC2C: [32-bit BE] [JP] Counter that tracks number of times weapon or subweapon used during a session
function jp_counter_that_tracks_number_of_times_weapon_or_subweapon_used_during_a_session() => dword_be(0x3AFC2C)

// $3AFC30: [32-bit BE] Pointer to inventory
//          See 0x363bf0 for details
function pointer_to_inventory_2() => dword_be(0x3AFC30)

// $3AFC58: [32-bit BE] [JP] RAM usage of current software loadout
function jp_ram_usage_of_current_software_loadout() => dword_be(0x3AFC58)

// $3AFC64: [32-bit BE] [JP] Pointer to Xelpud email timestamps
function jp_pointer_to_xelpud_email_timestamps() => dword_be(0x3AFC64)

// $3AFC68: [32-bit BE] [JP] Pointer to Xelpud email sort order
function jp_pointer_to_xelpud_email_sort_order() => dword_be(0x3AFC68)

// $3AFCCD: [8-bit] [JP] Map flags
//          See 0x363c95 for list of values
function jp_map_flags() => byte(0x3AFCCD)

// $3AFCCE: [8-bit] [JP] Map flags
//          See 0x363c96 for list of values
function jp_map_flags_2() => byte(0x3AFCCE)

// $3AFCCF: [8-bit] [JP] Map flags
//          See 0x363c97 for list of values
function jp_map_flags_3() => byte(0x3AFCCF)

// $3AFCFC: [32-bit BE] [JP] Pointer to inventory data (MSX)
//          See 0x363cc4 for details
function jp_pointer_to_inventory_data() => dword_be(0x3AFCFC)

// $3AFEF8: [16-bit BE] [JP] Used when allocating object data
//          See 0x363e88 for details
function jp_used_when_allocating_object_data() => word_be(0x3AFEF8)

// $3AFEFA: [16-bit BE] [JP] Number of sprites(?) or objects(?) on screen
//          See 0x363e8a for details
function jp_number_of_spritesor_objectson_screen() => word_be(0x3AFEFA)

// $3AFF50: [8-bit] [JP] Index (not-actually-a pointer) for controller input ring buffer
//          Increments every frame, counts 0-7
//          +0x4101f0: [32-bit BE] Controller input
//          | .... Bit2 = Left
//          | .... Bit3 = Right
function jp_index_notactuallya_pointer_for_controller_input_ring_buffer() => byte(0x3AFF50)

// $3AFFC8: [32-bit BE] [JP] Pointer to Lemeza data
//          See 0x363f60 for details
function jp_pointer_to_lemeza_data() => dword_be(0x3AFFC8)

// $3B0021: [8-bit] [JP] Weapon being used
//          See 0x363fb9 for list of values
function jp_weapon_being_used() => byte(0x3B0021)

// $3B0023: [8-bit] [JP] Subweapon being used
//          See 0x363fbb for list of values
function jp_subweapon_being_used() => byte(0x3B0023)

// $3B0038: [8-bit] [JP] Field ID
//          See 0x363fd0 for list of values
function jp_field_id() => byte(0x3B0038)

// $3B0039: [8-bit] [JP] Room ID
//          See 0x363fd1 for list of values
function jp_room_id() => byte(0x3B0039)

// $3B003A: [8-bit] [JP] Screen ID
function jp_screen_id() => byte(0x3B003A)

// $3B003B: [8-bit] [JP] Indicates which field objects list pointer is current
//          0x00 = 0x003b0060
//          0x01 = 0x003b0064
//          
//          Current list changes with every field transition
function jp_indicates_which_field_objects_list_pointer_is_current() => byte(0x3B003B)

// $3B003C: [8-bit] [JP] Indicates which room objects list pointer is current
//          0x00 = 0x003b0070
//          0x01 = 0x003b0074
//          
//          Current list changes with every room transition
function jp_indicates_which_room_objects_list_pointer_is_current() => byte(0x3B003C)

// $3B003D: [8-bit] [JP] Indicates which screen objects list pointer is current
//          0x00 = 0x003b0080
//          0x01 = 0x003b0084
//          
//          Current list changes with every screen transition
function jp_indicates_which_screen_objects_list_pointer_is_current() => byte(0x3B003D)

// $3B0050: [32-bit BE] [JP] Play time for current session (frames)
function jp_play_time_for_current_session() => dword_be(0x3B0050)

// $3B0060: [32-bit BE] [JP] Pointer to field objects meta-list #1
//          See 0x363ff8 for details
function jp_pointer_to_field_objects_metalist_1() => dword_be(0x3B0060)

// $3B0064: [32-bit BE] [JP] Pointer to field objects meta-list #2
//          See 0x363ffc for details
function jp_pointer_to_field_objects_metalist_2() => dword_be(0x3B0064)

// $3B0070: [32-bit BE] [JP] Pointer to field objects meta-list #1
//          See 0x364008 for details
function jp_pointer_to_field_objects_metalist_1_2() => dword_be(0x3B0070)

// $3B0074: [32-bit BE] [JP] Pointer to field objects meta-list #2
//          See 0x36400c for details
function jp_pointer_to_field_objects_metalist_2_2() => dword_be(0x3B0074)

// $3B0080: [32-bit BE] [JP] Pointer to screen objects meta-list #1
//          See 0x364018 for details
function jp_pointer_to_screen_objects_metalist_1() => dword_be(0x3B0080)

// $3B0084: [32-bit BE] [JP] Pointer to screen objects meta-list #2
//          See 0x36401c for details
function jp_pointer_to_screen_objects_metalist_2() => dword_be(0x3B0084)

// $3B0160: [32-bit BE] [JP] Index of script card used for last shop/NPC room visited
function jp_index_of_script_card_used_for_last_shop_npc_room_visited() => dword_be(0x3B0160)

// $3B0178: [32-bit BE] [JP] Pointer to global object data
//          See 0x364110 for details
function jp_pointer_to_global_object_data() => dword_be(0x3B0178)

// $3B0208: [4 bytes, ASCII] [JP] Title ID
//          "WLMJ" -> Japanese version
function _4_bytes_ascii_jp_title_id() => dword(0x3B0208)

// $3B1580: [Float BE] [JP] Walk speed scale factor - denominator
function jp_walk_speed_scale_factor_denominator() => float_be(0x3B1580)

// $3C0D88: [4096 bytes, 8-bit values] [JP] Event flags
//          See 0x374b88 - 0x3750ba for list of values
function _4096_bytes_8_bit_values_jp_event_flags() => byte(0x3C0D88)

// $3C2369: [8-bit] [JP] Pause state
//          See 0x376169 for details
function jp_pause_state() => byte(0x3C2369)

// $3C236A: [8-bit] [JP] MSX open
//          See 0x37616a for details
function jp_msx_open() => byte(0x3C236A)

// $3C236E: [8-bit] [JP] State related to shops/NPC rooms and boss fights
//          See 0x37616e for details
function jp_state_related_to_shops_npc_rooms_and_boss_fights() => byte(0x3C236E)

// $3C2371: [8-bit] [JP] Partial game state
//          See 0x376171 for details
function jp_partial_game_state() => byte(0x3C2371)

// $3C2374: [8-bit] [JP] Flag indicating whether revive combo effect has been used
//          See 0x376174 for details
function jp_flag_indicating_whether_revive_combo_effect_has_been_used() => byte(0x3C2374)

// $3C237A: [8-bit] [JP] Flag - Lamp of Time active
//          See 0x37617a for details
function jp_flag_lamp_of_time_active() => byte(0x3C237A)

// $3C2768: [20 bytes, 8-bit values] [JP] Array of equipped software titles
//          See 0x376568 for details
function _20_bytes_8_bit_values_jp_array_of_equipped_software_titles() => byte(0x3C2768)

// $3C2780: [40 bytes, 16-bit BE values] [JP] Array of software memory costs
function _40_bytes_16_bit_be_values_jp_array_of_software_memory_costs() => byte(0x3C2780)

// $3C2800: [20 bytes, 8-bit values] [JP] Array of flags indicating which software is activated
//          See 0x376600 for details
function _20_bytes_8_bit_values_jp_array_of_flags_indicating_which_software_is_activated() => byte(0x3C2800)

// $3C29E0: [10 bytes, 8-bit values] [JP] Flags - Learned mantras
//          See 0x3767e0 for details
function _10_bytes_8_bit_values_jp_flags_learned_mantras() => byte(0x3C29E0)

// $3C3DB0: [32 bytes, 32-bit BE values] Controller input ring buffer
function _32_bytes_32_bit_be_values_controller_input_ring_buffer() => byte(0x3C3DB0)

// $3C4F78: [32-bit BE] [JP] Index of last referenced script card from `script.dat`
//          See 0x378b38 for details
function jp_index_of_last_referenced_script_card_from_script_dat() => dword_be(0x3C4F78)

// $4101F0: [32 bytes, 32-bit BE values] [JP] Controller input ring buffer
function _32_bytes_32_bit_be_values_jp_controller_input_ring_buffer() => byte(0x4101F0)

// --- MAIN DATA -------------------------------------------------------------------

ITEM_WHIP_LEATHER = 0
ITEM_WHIP_CHAIN = 1
ITEM_WHIP_FLAIL = 2
ITEM_KNIFE = 3
ITEM_KEY_SWORD = 4
ITEM_AXE = 5
ITEM_KATANA = 6
ITEM_KEY_SWORD_EMPOWERED = 7
ITEM_SHURIKEN = 8
ITEM_ROLLING_SHURIKEN = 9
ITEM_EARTH_SPEAR = 10
ITEM_FLARE_GUN = 11
ITEM_BOMB = 12
ITEM_CHAKRAM = 13
ITEM_CALTROPS = 14
ITEM_PISTOL = 15
ITEM_SHIELD_BUCKLER = 16
ITEM_SHIELD_SILVER = 17
ITEM_SHIELD_ANGEL = 18
ITEM_ANKH_JEWELS = 19
ITEM_SCANNER = 20
ITEM_DJED_PILLAR = 21
ITEM_MINI_DOLL = 22
ITEM_MAGATAMA = 23
ITEM_COG = 24
ITEM_LAMP_CHARGED = 25
ITEM_POCHETTE_KEY = 26
ITEM_DRAGON_BONE = 27
ITEM_CRYSTAL_SKULL = 28
ITEM_VESSEL = 29
ITEM_PEPPER = 30
ITEM_STATUE_WOMAN = 31
ITEM_KEY_OF_ETERNITY = 32
ITEM_SERPENT_STAFF = 33
ITEM_TALISMAN = 34
ITEM_MSX = 35
ITEM_CASE_WATERPROOF = 36
ITEM_CASE_HEATPROOF = 37
ITEM_SHELL_HORN = 38
ITEM_GLOVE = 39
ITEM_HOLY_GRAIL = 40
ITEM_ISIS_PENDANT = 41
ITEM_CRUCIFIX = 42
ITEM_HELMET = 43
ITEM_GRAPPLE_CLAW = 44
ITEM_BRONZE_MIRROR = 45
ITEM_EYE_OF_TRUTH = 46
ITEM_RING = 47
ITEM_SCALESPHERE = 48
ITEM_GAUNTLET = 49
ITEM_ANCHOR = 50
ITEM_PLANE_MODEL = 51
ITEM_OCARINA = 52
ITEM_FEATHER = 53
ITEM_BOOK_OF_THE_DEAD = 54
ITEM_FAIRY_CLOTHES = 55
ITEM_SCRIPTURES = 56
ITEM_HERMES_BOOTS = 57
ITEM_FRUIT_OF_EDEN = 58
ITEM_TWIN_STATUE = 59
ITEM_BRACELET = 60
ITEM_PERFUME = 61
ITEM_SPAULDER = 62
ITEM_DIMENSIONAL_KEY = 63
ITEM_ICE_CAPE = 64
ITEM_SEAL_1_ORIGIN = 65
ITEM_SEAL_2_BIRTH = 66
ITEM_SEAL_3_LIFE = 67
ITEM_SEAL_4_DEATH = 68
ITEM_SACRED_ORB = 69
ITEM_MAPS = 70
ITEM_TREASURES = 71
ITEM_DIARY = 72
ITEM_MULANA_TALISMAN = 73
ITEM_BATHING_SUIT = 74
ITEM_SHIELD_SILVER_FAKE = 75
ITEM_MSX2 = 76
ITEM_MEDICINE_YELLOW = 77
ITEM_MEDICINE_GREEN = 78
ITEM_MEDICINE_RED = 79
ITEM_LAMP_UNCHARGED = 80
ITEM_STATUE_MATERNITY = 81
ITEM_HOLY_GRAIL_BROKEN = 82
ITEM_HOLY_GRAIL_EMPOWERED = 83
ITEM_SECRET_TREASURE_OF_LIFE = 84

SOFTWARE_GLYPH_READER = 85
SOFTWARE_XELPUD_MAILER = 86
SOFTWARE_YAGOO_MAP_READER = 87
SOFTWARE_YAGOO_MAP_STREET = 88
SOFTWARE_TEXTTRAX = 89
SOFTWARE_TEXTTRAX_MEMORY = 90
SOFTWARE_SNAPSHOTS = 91
SOFTWARE_GUILD = 92
SOFTWARE_MANTRA = 93
SOFTWARE_EMUSIC = 94
SOFTWARE_BEOLAMU = 95
SOFTWARE_DEATHV = 96
SOFTWARE_RANDC = 97
SOFTWARE_CAPSTAR = 98
SOFTWARE_MOVE = 99
SOFTWARE_MEKURI = 100
SOFTWARE_BOUNCE = 101
SOFTWARE_MIRACLE = 102
SOFTWARE_MIRAI = 103
SOFTWARE_LAMULANA = 104

QUANTITY_WEIGHTS = 105
QUANTITY_COINS = 106
QUANTITY_SHURIKEN = 107
QUANTITY_ROLLING_SHURIKEN = 108
QUANTITY_EARTH_SPEAR = 109
QUANTITY_FLARE_GUN = 110
QUANTITY_BOMB = 111
QUANTITY_CHAKRAM = 112
QUANTITY_CALTROPS = 113
QUANTITY_PISTOL_CLIPS = 114
QUANTITY_PISTOL_ROUNDS = 116 // ???

/*
deathv
randc
move
mekuri
lamulana

11111
*/

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------
