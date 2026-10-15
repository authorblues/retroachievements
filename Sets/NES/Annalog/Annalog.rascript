// ~Homebrew~ Annalog
// #ID = 38175
// #MinimumVersion = 1.3

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("PLURAL", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

// --- MEMORY -------------------------------------------------------------------

// $0020: Current Music [8 bit]
//        0x00 = Silence
//        0x01 = Attack
//        0x02 = Boss1
//        0x03 = Boss2
//        0x04 = Calm
//        0x05 = City
//        0x06 = Core
//        0x07 = Crypt
//        0x08 = Epilogue
//        0x09 = Factory
//        0x0A = Florist
//        0x0B = Garden
//        0x0C = Lava
//        0x0D = Mermaid
//        0x0E = Mine
//        0x0F = Prison
//        0x10 = Sewer
//        0x11 = Shadow
//        0x12 = Suspense
//        0x13 = Temple
//        0x14 = Title
//        0x15 = Town
//        0x16 = Upgrade
function current_music() => byte(0x0020)

// $0043: X Position [16 bit]
function x_position() => word(0x0043)

// $0045: Y Position [16 bit]
function y_position() => word(0x0045)

// $004F: Avatar Pose [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/avatar.asm#L131
//        0 = hidden
function avatar_pose() => byte(0x004F)

// $0050: Avatar Harm Timer [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/avatar.asm#L136
//        if =0, getting hit will set to 239
//        if >0, count down by 1 every frame
//        if >0, getting hit will kill
function harm_timer() => byte(0x0050)

// $0053: Boss State [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/boss.inc#L36
//        0 = BossBattle     ; waiting for the player to defeat the boss
//        1 = BossBlinking   ; boss is dead, and is blinking
//        2 = BossExploding  ; boss is dead, and is blinking and exploding
//        3 = FlashWhite     ; flashing to white, then fading back to normal
//        4 = SpawnUpgrade   ; waiting for upgrade to spawn
//        5 = GetUpgrade     ; waiting for the player to collect the upgrade
//        6 = SpawnBreaker   ; waiting for breaker to spawn
//        7 = FlipBreaker    ; waiting for the player to activate the breaker
//        8 = Done           ; nothing else to do
function boss_state() => byte(0x0053)

// $0057: Console Machine Index [8 bit]
//        0xFF = not interacting with a machine
function console_machine_index() => byte(0x0057)

// $0058: Pointer to Current Program [16 bit]
function console_program_ptr() => word(0x0058)

// $006D: Epilogue State [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/epilogue.asm#L342
//        0 = AlexSearches
//        1 = HumansAscend
//        2 = OrcsAscend
function epilogue_state() => byte(0x006D)

// $006E: Epilogue Screen [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/epilogue.asm#L345
//        19->20 is the transition when the completion screen is shown
function epilogue_screen() => byte(0x006E)

// $0070: Next Cutscene ID [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/explore.asm#L132
//        0 = None
//        1 = CityCenterBreakerCity
//        2 = CityFlowerOrcAttack
//        3 = CityOutskirtsLook
//        4 = CoreBossFinaleReactivate
//        5 = CoreBossFinaleSelfDestruct
//        6 = CoreBossGrontaDefeated
//        7 = CoreBossPowerUpCircuit
//        8 = CoreBossStartBattle
//        9 = CoreLockBreakerShadow
//        10 = CoreSouthCorraHelping
//        11 = FactoryEastCorraHelping
//        12 = FactoryElevatorWaitUp
//        13 = FactoryVaultLookAtTank
//        14 = GardenShrineBreakerMine
//        15 = MermaidHut1AlexPetition
//        16 = MermaidHut1BreakerCrypt
//        17 = MermaidHut1BreakerGarden
//        18 = MermaidSpringFixConsole
//        19 = MermaidVillageAlexLeave
//        20 = PrisonCellGetThrownIn
//        21 = PrisonUpperBreakerTemple
//        22 = PrisonUpperFreeAlex
//        23 = PrisonUpperFreeKids
//        24 = PrisonUpperLoosenBrick
//        25 = PrisonUpperWaitUp
//        26 = SewerPoolFeedDucks
//        27 = SharedFlipBreaker
//        28 = SharedTeleportIn
//        29 = SharedTeleportOut
//        30 = TempleEntryWaitUp
//        31 = TempleNaveAlexBoosting
//        32 = TownHouse2WakeUp
//        33 = TownHouse4BreakerLava
//        34 = TownOutdoorsFinaleGaveRemote1
//        35 = TownOutdoorsFinaleGaveRemote3
//        36 = TownOutdoorsFinaleGaveRemote5
//        37 = TownOutdoorsFinaleReactivate1
//        38 = TownOutdoorsFinaleReactivate3
//        39 = TownOutdoorsFinaleReactivate5
//        40 = TownOutdoorsFinaleYearsLater
//        41 = TownOutdoorsGetCaught
//        42 = TownOutdoorsOrcAttack
//        43 = TownSkyFinaleGaveRemote2
//        44 = TownSkyFinaleGaveRemote4
//        45 = TownSkyFinaleGaveRemote6
//        46 = TownSkyFinaleReactivate2
//        47 = TownSkyFinaleReactivate4
//        48 = TownSkyFinaleReactivate6
function next_cutscene_id() => byte(0x0070)

// $0076: Ending State [8 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/finale.asm#L60
//        0 = GaveRemote1Outdoors  ; ground splits open, Gronta emerges riding the core
//        1 = GaveRemote2Sky       ; Gronta rides the core into the sky
//        2 = GaveRemote3Outdoors  ; Thurg comes out of the town hall and sees the core
//        3 = GaveRemote4Sky       ; Gronta banishes all humans from the area
//        4 = GaveRemote5Outdoors  ; The humans protest, but get chased off
//        5 = GaveRemote6Sky       ; Jerome's recorded message plays
//        6 = Reactivate1Outdoors  ; ground splits open, Anna emerges riding the core
//        7 = Reactivate2Sky       ; Anna rides the core into the sky
//        8 = Reactivate3Outdoors  ; Thurg comes out of the town hall and sees the core
//        9 = Reactivate4Sky       ; Jerome's recorded message begins to play
//        10 = Reactivate5Outdoors  ; Thurg and the other orc protest, but get laser-ed
//        11 = Reactivate6Sky       ; Jerome's recorded message concludes
//        12 = YearsLater1Outdoors
function ending_state() => byte(0x0076)

// $0080: Current IRQ Pointer [16 bit]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/irq.asm#L42
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/irq.inc#L33
//        0xF794 = Title Screen
function current_irq_pointer() => word(0x0080)

// $00B4: Room ID [8 bit]
//        0x00 = BossCity
//        0x01 = BossCrypt
//        0x02 = BossGarden
//        0x03 = BossLava
//        0x04 = BossMine
//        0x05 = BossShadow
//        0x06 = BossTemple
//        0x07 = CityBuilding1
//        0x08 = CityBuilding2
//        0x09 = CityBuilding3
//        0x0A = CityBuilding4
//        0x0B = CityBuilding5
//        0x0C = CityBuilding6
//        0x0D = CityBuilding7
//        0x0E = CityCenter
//        0x0F = CityDrain
//        0x10 = CityDump
//        0x11 = CityEast
//        0x12 = CityFlower
//        0x13 = CityOutskirts
//        0x14 = CitySinkhole
//        0x15 = CityWest
//        0x16 = CoreBoss
//        0x17 = CoreEast
//        0x18 = CoreElevator
//        0x19 = CoreFlower
//        0x1A = CoreJunction
//        0x1B = CoreLock
//        0x1C = CoreSouth
//        0x1D = CoreWest
//        0x1E = CryptCenter
//        0x1F = CryptChains
//        0x20 = CryptEast
//        0x21 = CryptEscape
//        0x22 = CryptFlower
//        0x23 = CryptGallery
//        0x24 = CryptLanding
//        0x25 = CryptNest
//        0x26 = CryptNorth
//        0x27 = CryptSouth
//        0x28 = CryptSpiral
//        0x29 = CryptTomb
//        0x2A = CryptWest
//        0x2B = FactoryAccess
//        0x2C = FactoryBridge
//        0x2D = FactoryCenter
//        0x2E = FactoryEast
//        0x2F = FactoryElevator
//        0x30 = FactoryFlower
//        0x31 = FactoryLock
//        0x32 = FactoryPass
//        0x33 = FactoryUpper
//        0x34 = FactoryVault
//        0x35 = FactoryWest
//        0x36 = GardenCrossroad
//        0x37 = GardenEast
//        0x38 = GardenFlower
//        0x39 = GardenHallway
//        0x3A = GardenLanding
//        0x3B = GardenShaft
//        0x3C = GardenShrine
//        0x3D = GardenTower
//        0x3E = GardenTunnel
//        0x3F = LavaCavern
//        0x40 = LavaCenter
//        0x41 = LavaEast
//        0x42 = LavaFlower
//        0x43 = LavaShaft
//        0x44 = LavaStation
//        0x45 = LavaTeleport
//        0x46 = LavaTunnel
//        0x47 = LavaVent
//        0x48 = LavaWest
//        0x49 = MermaidCellar
//        0x4A = MermaidEast
//        0x4B = MermaidElevator
//        0x4C = MermaidEntry
//        0x4D = MermaidFlower
//        0x4E = MermaidHut1
//        0x4F = MermaidHut2
//        0x50 = MermaidHut3
//        0x51 = MermaidHut4
//        0x52 = MermaidHut5
//        0x53 = MermaidHut6
//        0x54 = MermaidSpring
//        0x55 = MermaidVillage
//        0x56 = MineBurrow
//        0x57 = MineCenter
//        0x58 = MineCollapse
//        0x59 = MineDrift
//        0x5A = MineEast
//        0x5B = MineEntry
//        0x5C = MineFlower
//        0x5D = MineNorth
//        0x5E = MinePit
//        0x5F = MineSouth
//        0x60 = MineWest
//        0x61 = PrisonCell
//        0x62 = PrisonCrossroad
//        0x63 = PrisonEast
//        0x64 = PrisonEscape
//        0x65 = PrisonFlower
//        0x66 = PrisonLower
//        0x67 = PrisonUpper
//        0x68 = SewerAscent
//        0x69 = SewerBasin
//        0x6A = SewerEast
//        0x6B = SewerFaucet
//        0x6C = SewerFlower
//        0x6D = SewerNorth
//        0x6E = SewerPipe
//        0x6F = SewerPool
//        0x70 = SewerSouth
//        0x71 = SewerTrap
//        0x72 = SewerWest
//        0x73 = ShadowDepths
//        0x74 = ShadowDescent
//        0x75 = ShadowDrill
//        0x76 = ShadowEntry
//        0x77 = ShadowFlower
//        0x78 = ShadowGate
//        0x79 = ShadowHall
//        0x7A = ShadowHeart
//        0x7B = ShadowOffice
//        0x7C = ShadowTeleport
//        0x7D = ShadowTrap
//        0x7E = TempleAltar
//        0x7F = TempleApse
//        0x80 = TempleChevet
//        0x81 = TempleEntry
//        0x82 = TempleFlower
//        0x83 = TempleFoyer
//        0x84 = TempleNave
//        0x85 = TemplePit
//        0x86 = TempleSpire
//        0x87 = TempleWest
//        0x88 = TownHouse1
//        0x89 = TownHouse2
//        0x8A = TownHouse3
//        0x8B = TownHouse4
//        0x8C = TownHouse5
//        0x8D = TownHouse6
//        0x8E = TownOutdoors
//        0x8F = TownSky
function room_id() => byte(0x00B4)

// $00B5: Min Scroll X [8 bit]
//        in screens with west exit, should be 8 or 16
//        
//        == start of sRoom struct
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/room.inc#L310
function min_scroll_x() => byte(0x00B5)

// $00B6: Max Scroll X [16 bit]
function max_scroll_x() => word(0x00B6)

// $00B8: Room Flags [8 bit]
function room_flags() => byte(0x00B8)

// $00B9: Minimap Row [8 bit]
function minimap_row() => byte(0x00B9)

// $00BA: Minimap Column [8 bit]
function minimap_column() => byte(0x00BA)

// $00BB: Pointer to Terrain Block Data [16 bit]
function pointer_to_terrain_block_data() => word(0x00BB)

// $00BD: Num Machines in Room [8 bit]
function num_machines_in_room() => byte(0x00BD)

// $00BE: Pointer to Machine Array [16 bit]
function pointer_to_machine_array() => word(0x00BE)

// $00C0: Chr18Bank_u8 [8 bit]
function chr18bank_u8() => byte(0x00C0)

// $00C1: Ext_sRoomExt_ptr [16 bit]
function ext_sroomext_ptr() => word(0x00C1)

// $00CD: Boss Mode: Gronta [8 bit] (room=0x16)
//        0 = WaitingToTalk
//        1 = Talking
//        2 = GettingRemote
//        3 = Fighting
//        4 = Defeated
//        
//        == start of sRoom struct [24 bytes]
function boss_gronta_mode() => byte(0x00CD)

// $00CE: Boss Mode: Labs [8 bit] (room=0x05)
//        0 = Dead
//        1 = FinalGhostDying      ; final ghost has been hit and is about to die
//        2 = FinalGhostWaiting    ; final ghost has appeared and is waiting to be hit
//        3 = Intro                ; start of the fight
//        4 = GravityPending       ; waiting to begin a special gravity attack
//        5 = GravityActive        ; mermaid ghost is starting a special gravity attack
//        6 = LavaPending          ; waiting to begin a special lava attack
//        7 = LavaActive           ; orc ghost is starting a special lava attack
//        8 = LavaRising           ; lava is currently rising
//        9 = LavaFalling          ; lava is currently falling
//        10 = SingleAttackPending  ; waiting to begin next attack (one ghost at a time)
//        11 = DoubleAttackPending  ; waiting to begin next attack (both ghosts at once)
//        12 = DoubleAttackHalf     ; one half of the double-ghost attack is in progress
//        13 = AttackActive         ; ghost attack wave is in progress
//        14 = MergePending         ; waiting to begin merging into the final ghost
//        15 = MergeActive          ; waiting to finish merging into the final ghost
//        
//        Boss Health: Gronta [8 bit] (room=0x16) (Winch)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/core_boss.asm#L312
//        starts at 0, increment when machine deals damage
//        when =2, destroyed and set to 0xFF
function boss_gronta_health(i) => byte(0x00CE + i)

// $00CF: Boss Mode: Temple [8 bit] (room=0x06)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_temple.asm#L220
//        0 = Dead
//        1 = Dying       ; impaled on spikes; will die when cooldown expires
//        2 = Paused      ; eyes closed; will shoot a breakball when cooldown expires
//        3 = Waiting     ; eyes closed; waiting for projectiles to finish
//        4 = Stunned     ; active eye open; can shoot it to make boss crawl up
//        5 = ShootBreak  ; shooting a breakball from active eye
//        
//        Boss Mode: Volcano [8 bit] (room=0x03)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_lava.asm#L212
//        0 = Dead
//        1 = EggPrepare          ; move into position to drop an egg
//        2 = EggDrop             ; drop an egg
//        3 = EggWait             ; wait for the egg to hatch and the solifuge killed
//        4 = FiresprayPrepare    ; move into position to shoot a spray of fireballs
//        5 = FiresprayWindup     ; open jaws before shooting a spray of fireballs
//        6 = FiresprayShoot      ; shoot a spray of fireballs
//        7 = FiresprayRecover    ; waiting for a bit after a fireball spray
//        8 = FlamestrikePrepare  ; move into position to shoot a flamestrike projectile
//        9 = FlamestrikeShoot    ; open jaws and shoot the flamestrike
//        10 = FlamestrikeDescend  ; stay in place while the flamestrike descends
//        11 = FlamestrikeRetreat  ; move upwards while the flamestrike is paused
//        12 = Hurt                ; closing jaws, vibrating in place
//        13 = Scuttling           ; moving around randomly
//        
//        Boss Mode: Mine [8 bit] (room=0x04)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_mine.asm#L202
//        0 = Dead
//        1 = Hiding      ; within the walls
//        2 = Burrowing   ; making the room shake just before emerging
//        3 = Emerging    ; emerging from the wall
//        4 = Shooting    ; firing projectiles
//        5 = Retreating  ; retreating back into the wall
//        6 = Hurt        ; was just hit by a boulder
//        
//        Wall Damage: City [8 bit] (room=0x00)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_city.asm#L284
//        bitN | Nth block down (starting from zero) has been damaged
//        
//        Boss Health: Labs [8 bit] (room=0x05) (max=12)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_shadow.asm#L187
//        
//        Boss Health: Gronta [8 bit] (room=0x16) (Blaster)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/core_boss.asm#L312
//        starts at 0, increment when machine deals damage
//        when =2, destroyed and set to 0xFF
function boss_temple_mode() => byte(0x00CF)
function boss_volcano_mode() => byte(0x00CF)
function boss_mine_mode() => byte(0x00CF)
function boss_city_walldmg() => bitcount(0x00CF)
function boss_labs_health() => byte(0x00CF)

// $00D0: Boss Mode: Garden [8 bit] (room=0x02)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_garden.asm#L158
//        0 = Dead
//        1 = Waiting      ; eyes closed
//        2 = Angry        ; eyes closed, dropping spikes
//        3 = Shoot        ; active eye open, shooting fireballs one at a time
//        4 = SprayWindup  ; active eye open, about to shoot a wave of fireballs
//        5 = SprayFire    ; active eye open, shooting a wave of fireballs
//        
//        Boss Mode: Crypt [8 bit] (room=0x01)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_crypt.asm#L204
//        0 = Dead
//        1 = Waiting   ; pausing before choosing a new goal position
//        2 = Firing    ; moving to goal position, shooting fireballs
//        3 = Strafing  ; moving from one side of the room to the other, dropping embers
//        4 = Hurt      ; just got hit, moving away and eye flashing
//        
//        Boss Mode: City [8 bit] (room=0x00)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_city.asm#L245
//        0 = Dead
//        1 = Hurt
//        2 = Open
//        3 = Close
//        4 = ShootSpines
//        5 = Weaving
//        
//        Boss Health: Gronta [8 bit] (room=0x16) (Laser)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/core_boss.asm#L312
//        starts at 0, increment when machine deals damage
//        when =2, destroyed and set to 0xFF
function boss_garden_mode() => byte(0x00D0)
function boss_crypt_mode() => byte(0x00D0)
function boss_city_mode() => byte(0x00D0)

// $00D1: Boss Health: City [8 bit] (room=0x00) (max=8)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_city.asm#L288
//        
//        Boss Health: Gronta [8 bit] (room=0x16) (Cannon)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/core_boss.asm#L312
//        starts at 0, increment when machine deals damage
//        when =2, destroyed and set to 0xFF
function boss_city_health() => byte(0x00D1)

// $00D2: Boss Health: Crypt [8 bit] (room=0x01) (max=6)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_crypt.asm#L241
//        
//        Boss Health: Volcano [8 bit] (room=0x03) (max=6)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_lava.asm#L269
//        
//        Boss Health: Mine [8 bit] (room=0x04) (max=6)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_mine.asm#L304
function boss_crypt_health() => byte(0x00D2)
function boss_volcano_health() => byte(0x00D2)
function boss_mine_health() => byte(0x00D2)

// $00D4: Boss Health: Garden (Left Eye) [8 bit] (room=0x02) (max=4)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_garden.asm#L202
function boss_garden_healthL() => byte(0x00D4)

// $00D5: Boss Health: Garden (Right Eye) [8 bit] (room=0x02) (max=4)
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/rooms/boss_garden.asm#L202
function boss_garden_healthR() => byte(0x00D5)

// $00EF: Held Flower ID [8 bit]
//        0x10 = Lost Temple flower
//        0x11 = Prison Caves flower
//        0x12 = Power Core flower
//        0x13 =
//        0x14 = Old Waterway flower (0x6c)
//        0x15 = Ancient City flower (0x12)
//        0x16 = Hidden Crypt flower
//        0x17 = Shadow Labs flower (0x77)
//        0x18 = Vine Garden flower (0x38)
//        0x19 = Mermaid Vale flower
//        0x1a = Volcanic Pit flower
//        0x1b = Salt Mines flower
function has_flower() => high4(0x00EF)
function held_flower_id() => byte(0x00EF)

// $0300: Actor IDs [16 bytes]
//        0x00 = None
//        0x01 = BadBat
//        0x02 = BadBeetleHorz
//        0x03 = BadBeetleVert
//        0x04 = BadBird
//        0x05 = BadCrab
//        0x06 = BadFirefly
//        0x07 = BadFish
//        0x08 = BadFlower
//        0x09 = BadFlydrop
//        0x0A = BadGhostMermaid
//        0x0B = BadGhostOrc
//        0x0C = BadGooGreen
//        0x0D = BadGooRed
//        0x0E = BadGronta
//        0x0F = BadGrub
//        0x10 = BadGrubFire
//        0x11 = BadGrubRoll
//        0x12 = BadHotheadHorz
//        0x13 = BadHotheadVert
//        0x14 = BadJelly
//        0x15 = BadLavaball
//        0x16 = BadOrc
//        0x17 = BadRhino
//        0x18 = BadRodent
//        0x19 = BadSlime
//        0x1A = BadSolifuge
//        0x1B = BadSpider
//        0x1C = BadToad
//        0x1D = BadVinebug
//        0x1E = BadWasp
//        0x1F = NpcAdult
//        0x20 = NpcBlinky
//        0x21 = NpcChild
//        0x22 = NpcDuck
//        0x23 = NpcOrc
//        0x24 = NpcOrcSleeping
//        0x25 = NpcQueen
//        0x26 = NpcSquare
//        0x27 = NpcToddler
//        0x28 = ProjAcid
//        0x29 = ProjAxeBoomer
//        0x2A = ProjAxeSmash
//        0x2B = ProjBreakball
//        0x2C = ProjBreakbomb
//        0x2D = ProjBreakfire
//        0x2E = ProjBullet
//        0x2F = ProjEgg
//        0x30 = ProjEmber
//        0x31 = ProjFireball
//        0x32 = ProjFireblast
//        0x33 = ProjFlamestrike
//        0x34 = ProjFood
//        0x35 = ProjGrenade
//        0x36 = ProjRocket
//        0x37 = ProjSpike
//        0x38 = ProjSpine
//        0x39 = ProjSteamRight
//        0x3A = ProjSteamUp
//        0x3B = SmokeAxe
//        0x3C = SmokeBeam
//        0x3D = SmokeBlood
//        0x3E = SmokeDirt
//        0x3F = SmokeExplosion
//        0x40 = SmokeFragment
//        0x41 = SmokeParticle
//        0x42 = SmokeRaindrop
//        0x43 = SmokeSteamRight
//        0x44 = SmokeSteamUp
//        0x44 = SmokeWaterfall
function actor_id(i) => byte(0x0300 + i)

// $03C0: Actor State1 [16 bytes]
function actor_param1(i) => byte(0x03C0 + i)

// $0400: Device Types [16 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/device.asm#L57
//        0x00 = None            ; empty slot
//        0x01 = Boiler          ; boiler tank that can be hit by a fireblast
//        0x02 = BreakerDone     ; circuit breaker, after being activated
//        0x03 = BreakerRising   ; circuit breaker, rising out of the ground
//        0x04 = Door1Locked     ; leads to another Door1*; can't be entered until unlocked
//        0x05 = FlowerInert     ; a flower that can't be picked
//        0x06 = Mousehole       ; used by rodent baddies
//        0x07 = Placeholder     ; invisible and does nothing
//        0x08 = Teleporter      ; invisible spawn point for teleport field machines
//        0x09 = BreakerReady    ; circuit breaker, ready to be activated
//        0x0A = ConsoleCeiling  ; operates a machine
//        0x0B = ConsoleFloor    ; operates a machine
//        0x0C = Door1Open       ; leads to another Door1*; is never locked
//        0x0D = Door1Unlocked   ; leads to another Door1*; can be locked by room scripts
//        0x0E = Door2Open       ; leads to another Door2*; is never locked
//        0x0F = Door3Open       ; leads to another Door3*; is never locked
//        0x10 = FakeConsole     ; opens a console-looking window with an error message
//        0x11 = Flower
//        0x12 = LeverCeiling
//        0x13 = LeverFloor
//        0x14 = Paper           ; collects the paper, and initiates dialogue for it
//        0x15 = ScreenCeiling   ; initiates dialogue with the avatar's back to the camera
//        0x16 = ScreenGreen     ; initiates dialogue with the avatar's back to the camera
//        0x17 = ScreenRed       ; initiates dialogue with the avatar's back to the camera
//        0x18 = Sign            ; initiates dialogue with the avatar's back to the camera
//        0x19 = TalkLeft        ; initiates dialogue with the avatar facing to the left
//        0x1A = TalkRight       ; initiates dialogue with the avatar facing to the right
//        0x1B = Upgrade         ; collects the upgrade
function device_type(i) => byte(0x0400 + i)

// $0440: Device Animation Frames [16 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/device.asm#L57
//        
//        Door1Locked (0x04) starts with an animation counter of 11 and counts down
function device_anim(i) => byte(0x0440 + i)

// $0483: Boss Y Position: Temple [8 bit] (room=0x06)
//        initial 0x43, dies when <= 0x27
function boss_temple_ypos() => byte(0x0483)

// $05CA: Machine Statuses [4 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/machine.inc#L103
//        0 = Running    ; The machine is executing its program.
//        1 = Working    ; Execution is blocked until the machine reaches its goal.
//        2 = Syncing    ; Execution is blocked on a SYNC instruction.
//        3 = Waiting    ; Execution is blocked for a set number of frames.
//        4 = Halted     ; Execution is halted until the machine is reset.
//        5 = Error      ; The machine tried to do something it couldn't do.
//        6 = ResetRun   ; The machine is resetting (then will resume running).
//        7 = ResetHalt  ; The machine is resetting (then will halt execution).
//        
//        ZP RAM_Machine
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/machine.asm#L71
function machine_status(i) => byte(0x05CA + i)

// $05CE: Machine Program Counters [4 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/machine.asm#L81
function machine_pc(i) => byte(0x05CE + i)

// $05D2: Machine $A Register [4 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/machine.asm#L86
function machine_areg(i) => byte(0x05D2 + i)

// $05D6: Machine Wait Cycles [4 bytes]
//        https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/machine.asm#L90
function machine_wait_cycles(i) => byte(0x05D6 + i)

// $0700: Chips [8 bit]
//        bit1 | RAM #1 (room=0x02)
//        bit2 | RAM #2 (room=0x06)
//        bit3 | RAM #3 (room=0x03)
//        bit4 | RAM #4 (room=0x04)
//        bit5 | B module (room=0x00)
//        bit6 | IF (room=0x3c)
//        bit7 | TIL (room=0x83)
function ram(i) => bit(i, 0x0700)
function chip_bmod() => bit5(0x0700)
function chip_if() => bit6(0x0700)
function chip_til() => bit7(0x0700)

// $0701: Chips [8 bit]
//        bit0 | COPY (room=0x44)
//        bit1 | ADD/SUB (room=0x69)
//        bit2 | MUL (room=0x05)
//        bit3 | BEEP (room=0x49)
//        bit4 | GOTO (room=0x23)
//        bit5 | SKIP (room=0x2d)
//        bit6 | REST (room=0x01)
//        bit7 | SYNC (room=0x5e)
function chip_copy() => bit0(0x0701)
function chip_addsub() => bit1(0x0701)
function chip_mul() => bit2(0x0701)
function chip_beep() => bit3(0x0701)
function chip_goto() => bit4(0x0701)
function chip_skip() => bit5(0x0701)
function chip_rest() => bit6(0x0701)
function chip_sync() => bit7(0x0701)

// $0702: Flowers [8 bit]
//        bit0 =
//        bit1 =
//        bit2 =
//        bit3 =
//        bit4 =
//        bit5 =
//        bit6 =
//        bit7 =

// $0703: Flowers [8 bit]
//        bit0 =
//        bit1 = Mermaid Vale flower
//        bit2 =
//        bit3 =
function flower_count() => bitcount(0x0702) + sum_of(range(0,3), b => bit(b, 0x0703))

// $0704: Power Circuits [8 bit]
//        bit3 = power circuit 1
//        bit4 = power circuit 2
//        bit5 = power circuit 3
//        bit6 = power circuit 4
//        bit7 = power circuit 5
function circuit(i) => bit(2+i, 0x0704)

// $0705: Power Circuits [8 bit]
//        bit0 = power circuit 6
//        bit1 = power circuit 7
//        
//        Pages [8 bit]
//        bit2 = room 0x76 (day 1)
//        bit3 = room 0x79 (day 2)
//        bit4 = room 0x6e (day 3)
//        bit5 = room 0x7a (day 4)
//        bit6 = room 0x72 (day 5)
//        bit7 = room 0x7b (day 6)
function page_diary_day(i) => bit((1+i) % 8, 0x0705 + (1+i)/8)

// $0706: Pages [8 bit]
//        bit0 = room 0x2c (day 7)
//        bit1 = room 0x1e (day 8)
//        bit2 = room 0x5c (day 9)
//        bit3 = room 0x48 (day 10)
//        bit4 = room 0x28 (day 11)
//        bit5 = room 0x39 (day 12)
//        bit6 = room 0x3a (day 13)
//        bit7 = room 0x38 (day 14)

// $0707: Pages [8 bit]
//        bit0 = room 0x66 (day 15)
//        bit1 = room 0x0c (day 16)
//        bit2 = room 0x0a (day 17)
//        bit3 = room 0x35 (day 18)
//        bit4 = room 0x69 (day 19)
//        bit5 = room 0x74 (day 20)
//        bit6 = room 0x21 (day 21)
//        bit7 = room 0x6c (day 22)

// $0708: Pages [8 bit]
//        bit0 = room 0x1b (day 23)
//        bit1 = room 0x07 (day 24)
//        bit2 = room 0x5d (day 25)
//        bit3 = room 0x5a (day 26)
//        bit4 = room 0x46 (day 27)
//        bit5 = room 0x80 (day 28)
//        bit6 = room 0x4b (day 29)
//        bit7 = room 0x0b (day 30)

// $0709: Pages [8 bit]
//        bit0 = room 0x19 (day 31)
//        bit1 = room 0x73 (day 32)
//        bit2 = room 0x0f (day 33)
//        bit3 = room 0x85 (day 34)
//        bit4 = room 0x10 (day 35)
//        bit5 = room 0x61 (day 36)
//        bit6 = room 0x83 (field manual pg 1)
//        bit7 = room 0x64 (field manual pg 2)
function page_field_manual(i) => bit((5+i) % 8, 0x0709 + (5+i)/8)

// $070A: Pages [8 bit]
//        bit0 = room 0x36 (field manual pg 3)
//        bit1 = room 0x44 (field manual pg 4)
//        bit2 = room 0x33 (field manual pg 5)
//        bit3 = room 0x3b (field manual pg 6)
//        bit4 = room 0x18 (field manual pg 7)
//        bit5 = room 0x09 (field manual pg 8) (ammo loader puzzle)
//        bit6 = room 0x7f (field manual pg 9)

// $070B: World Flags [8 bit]
//        bit4 | shortcut opened (room=0x13)
function shortcut_0x13() => bit4(0x070B)

// $070C: World Flags [8 bit]
//        bit5 | shortcut opened (room=0x32)
function shortcut_0x32() => bit5(0x070C)

// $0720: Minimap Data [48 bytes]
//        each bit corresponds to a map tile being revealed on the minimap
MINIMAP_DATA_RAM = 0x0720

// $0750: Game Timer - frames [8 bit]
function _timer_frames() => byte(0x0750)

// $0751: Game Timer - 000:00:0X [8 bit]
function _timer_000_00_0x() => byte(0x0751)

// $0752: Game Timer - 000:00:X0 [8 bit]
function _timer_000_00_x0() => byte(0x0752)

// $0753: Game Timer - 000:0X:00 [8 bit]
function _timer_000_0x_00() => byte(0x0753)

// $0754: Game Timer - 000:X0:00 [8 bit]
function _timer_000_x0_00() => byte(0x0754)

// $0755: Game Timer - 00X:00:00 [8 bit]
function _timer_00x_00_00() => byte(0x0755)

// $0756: Game Timer - 0X0:00:00 [8 bit]
function _timer_0x0_00_00() => byte(0x0756)

// $0757: Game Timer - X00:00:00 [8 bit]
function _timer_x00_00_00() => byte(0x0757)

// $6004: Deaths (00X) [8 bit]
function _deaths_00x() => byte(0x6004)

// $6005: Deaths (0X0) [8 bit]
function _deaths_0x0() => byte(0x6005)

// $6006: Deaths (X00) [8 bit]
function _deaths_x00() => byte(0x6006)

// $6010: Minimap Data [48 bytes]
MINIMAP_DATA_SRAM = 0x6010

// $6060: Programs Table [3232 bytes] [32 bytes per program x 100 programs]
//        each program is made up of 2 bytes per 16 instructions
//        each instruction is an arg byte (hi=arg3, lo=arg2) and op byte (hi=opcode, lo=arg1)
//        
//        Opcodes
//        Empty = 0x00  ; (no args)        Jumps to program start (in zero cycles).
//        Copy  = 0x01  ; r, r/i           Sets register to value of second arg.
//        Sync  = 0x02  ; (no args)        Pauses until all machines are at a SYNC
//        Add   = 0x03  ; r, r/i, r/i      Sets register to sum of other args.
//        Sub   = 0x04  ; r, r/i, r/i      Sets register to difference of other args.
//        Mul   = 0x05  ; r, r/i, r/i      Sets register to product of other args.
//        Goto  = 0x06  ; addr             Jumps to an absolute address (0-15).
//        Skip  = 0x07  ; r/i              Skips next N instructions.
//        If    = 0x08  ; oper, r/i, r/i   Skips next instruction if false.
//        Til   = 0x09  ; oper, r/i, r/i   Jumps to prev instruction if false.
//        Act   = 0x0a  ; (no args)        Performs machine action (e.g. firing gun).
//        Move  = 0x0b  ; dir              Moves machine in the specified direction.
//        Rest  = 0x0c  ; r/i              Pauses for N * 16 frames.
//        Beep  = 0x0d  ; r/i              Plays a sound with one of ten pitches.
//        End   = 0x0e  ; (no args)        Halts the program.
//        Nop   = 0x0f  ; (no args)        Does nothing (but still takes a cycle).
//        
//        Comparison
//        Eq = 0 ; equal
//        Ne = 1  ; not equal
//        Lt = 2  ; less than
//        Le = 3  ; less than or equal
//        Gt = 4  ; greater than
//        Ge = 5  ; greater than or equal
//        
//        Direction
//        Up    = 0
//        Right = 1
//        Down  = 2
//        Left  = 3
function prg_op(p, line) => high4(0x6060 + 0x20*p + line*2 + 1)
function prg_a1(p, line) => low4( 0x6060 + 0x20*p + line*2 + 1)
function prg_a2(p, line) => low4( 0x6060 + 0x20*p + line*2 + 0)
function prg_a3(p, line) => high4(0x6060 + 0x20*p + line*2 + 0)

// helper to grab the whole byte
function __prg_b0(p, line) => byte(0x6060 + 0x20*p + line*2 + 0)
function __prg_b1(p, line) => byte(0x6060 + 0x20*p + line*2 + 1)

// --- MAIN DATA -------------------------------------------------------------------

MAX_MAP_PROGRESS = 243

MUSIC_NONE = 0x00
MUSIC_EPILOGUE = 0x08
MUSIC_TITLE = 0x14

ACTOR_NONE = 0x00
ACTOR_DUCK = 0x22
ACTOR_BREAKBALL = 0x2B
ACTOR_BREAKFIRE = 0x2D
ACTOR_DUCKFOOD = 0x34

ALL_MACHINES = range(0,3)
MACHINE_ERROR = 0x05

OPCODE_EMPTY = 0x00
OPCODE_COPY  = 0x01
OPCODE_SYNC  = 0x02
OPCODE_ADD   = 0x03
OPCODE_SUB   = 0x04
OPCODE_MUL   = 0x05
OPCODE_GOTO  = 0x06
OPCODE_SKIP  = 0x07
OPCODE_IF    = 0x08
OPCODE_TIL   = 0x09
OPCODE_ACT   = 0x0a
OPCODE_MOVE  = 0x0b
OPCODE_REST  = 0x0c
OPCODE_BEEP  = 0x0d
OPCODE_END   = 0x0e
OPCODE_NOP   = 0x0f

CMP_EQ = 0
CMP_NE = 1
CMP_LT = 2
CMP_LE = 3
CMP_GT = 4
CMP_GE = 5

DIR_UP    = 0
DIR_RIGHT = 1
DIR_DOWN  = 2
DIR_LEFT  = 3

PROG_BossCityAmmoRack = 0
PROG_BossCityLauncher = 1
PROG_BossCityReloader = 2
PROG_BossCryptWinch = 3
PROG_BossGardenCannon = 4
PROG_BossLavaBlaster = 5
PROG_BossLavaBoiler = 6
PROG_BossMineCrane = 7
PROG_BossMineTrolley = 8
PROG_BossShadowEmitterX = 9
PROG_BossShadowEmitterY = 10
PROG_BossTempleMinigun = 11
PROG_CityBuilding3AmmoRack = 12
PROG_CityBuilding3Launcher = 13
PROG_CityBuilding3Reloader = 14
PROG_CityCenterSemaphore1 = 15
PROG_CityCenterSemaphore2 = 16
PROG_CityCenterSemaphore3 = 17
PROG_CityCenterSemaphore4 = 18
PROG_CityOutskirtsLauncher = 19
PROG_CitySinkholeLift = 20
PROG_CoreBossBlaster = 21
PROG_CoreBossCannon = 22
PROG_CoreBossLaser = 23
PROG_CoreBossWinch = 24
PROG_CoreElevatorJet = 25
PROG_CoreLockLift1 = 26
PROG_CoreLockLift2 = 27
PROG_CoreLockLift3 = 28
PROG_CryptFlowerWinch = 29
PROG_CryptGalleryWinch = 30
PROG_CryptNorthLift = 31
PROG_CryptNorthWinch = 32
PROG_CryptSouthWinch = 33
PROG_CryptTombWinch = 34
PROG_CryptWestWinch = 35
PROG_FactoryAccessRotor = 36
PROG_FactoryFlowerLowerRotor = 37
PROG_FactoryFlowerUpperRotor = 38
PROG_FactoryLockLift = 39
PROG_FactoryUpperRotor = 40
PROG_FactoryWestCrane = 41
PROG_GardenCrossroadLift = 42
PROG_GardenEastBridge = 43
PROG_GardenEastCannon = 44
PROG_GardenHallwayLift = 45
PROG_GardenShaftLowerBridge = 46
PROG_GardenShaftUpperBridge = 47
PROG_GardenTowerCannon = 48
PROG_LavaCavernBoiler = 49
PROG_LavaCenterBlaster = 50
PROG_LavaEastBlaster = 51
PROG_LavaEastLowerBoiler = 52
PROG_LavaEastUpperBoiler = 53
PROG_LavaStationBoiler = 54
PROG_LavaTeleportField = 55
PROG_LavaTunnelBoiler = 56
PROG_LavaVentLift = 57
PROG_LavaWestBoiler = 58
PROG_MermaidElevatorJet = 59
PROG_MermaidHut6Drums = 60
PROG_MermaidHut6Organ = 61
PROG_MermaidHut6Trombone = 62
PROG_MermaidSpringPump = 63
PROG_MineCollapseCrane = 64
PROG_MineCollapseTrolley = 65
PROG_MineEastHoist = 66
PROG_MineEastLift = 67
PROG_MineFlowerHoistEast = 68
PROG_MineFlowerHoistWest = 69
PROG_MineNorthConveyor = 70
PROG_MineNorthHoist = 71
PROG_MinePitHoistEast = 72
PROG_MinePitHoistWest = 73
PROG_MineSouthHoist = 74
PROG_MineSouthTrolley = 75
PROG_MineWestCrane = 76
PROG_PrisonCellLauncher = 77
PROG_PrisonCellLift = 78
PROG_PrisonEastLift = 79
PROG_PrisonEscapeTrolley = 80
PROG_SewerBasinMultiplexer = 81
PROG_SewerFlowerPump = 82
PROG_SewerNorthMultiplexer = 83
PROG_SewerSouthMultiplexer = 84
PROG_SewerTrapLift = 85
PROG_SewerWestMultiplexer = 86
PROG_ShadowDrillLaser = 87
PROG_ShadowEntryLift = 88
PROG_ShadowFlowerLaser = 89
PROG_ShadowHallMinigun = 90
PROG_ShadowHeartEmitterX = 91
PROG_ShadowHeartEmitterY = 92
PROG_ShadowOfficeLift = 93
PROG_ShadowTeleportField = 94
PROG_ShadowTrapLaser = 95
PROG_TempleAltarLowerMinigun = 96
PROG_TempleAltarUpperMinigun = 97
PROG_TempleFoyerCarriage = 98
PROG_TempleNaveLowerCarriage = 99
PROG_TempleNaveUpperCarriage = 100

ALL_CHIPS = [
	ram(1),
	ram(2),
	ram(3),
	ram(4),
	chip_bmod(),
	chip_if(),
	chip_til(),
	chip_copy(),
	chip_addsub(),
	chip_mul(),
	chip_beep(),
	chip_goto(),
	chip_skip(),
	chip_rest(),
	chip_sync(),
]

class BossData
{
	name = ""
	room = -1
	circuit = -1
	health = -1
	maxhealth = 999
	programs = []

	function flip_circuit() => room_id() == this.room && boss_state() >= 7 && is_set(circuit(this.circuit))
	function start_fight() => room_id() == this.room && device_type(0) == 0x04 && prev(device_anim(0)) == 11 && device_anim(0) == 10
	function challenge() => once(this.start_fight()) &&	trigger_when(prev(boss_state()) == 1) && trigger_when(boss_state() == 2) &&	never(room_id() != this.room)
	function perfect() => this.challenge() && never(harm_timer() > 0) && all_of(ALL_MACHINES, i => never(machine_status(i) == MACHINE_ERROR))
}

bossPolyclops = BossData(
	name="Polyclops", room=0x02, circuit=1,
	health=boss_garden_healthL() + boss_garden_healthR(), maxhealth=8,
	programs=[PROG_BossGardenCannon,]
)
bossOutbreak = BossData(
	name="Outbreak", room=0x06, circuit=2,
	health=boss_temple_ypos(), maxhealth=0x43,
	programs=[PROG_BossTempleMinigun,]
)
bossDoomgaze = BossData(
	name="Doomgaze", room=0x01, circuit=3,
	health=boss_crypt_health(), maxhealth=6,
	programs=[PROG_BossCryptWinch,]
)
bossPyrofuge = BossData(
	name="Pyrofuge", room=0x03, circuit=4,
	health=boss_volcano_health(), maxhealth=6,
	programs=[PROG_BossLavaBlaster, PROG_BossLavaBoiler,]
)
bossSaltwyrm = BossData(
	name="Saltwyrm", room=0x04, circuit=5,
	health=boss_mine_health(), maxhealth=6,
	programs=[PROG_BossMineTrolley, PROG_BossMineCrane,]
)
bossBombshell = BossData(
	name="Bombshell", room=0x00, circuit=6,
	health=boss_city_health(), maxhealth=8,
	programs=[PROG_BossCityAmmoRack, PROG_BossCityLauncher, PROG_BossCityReloader,]
)
bossAldaEgo = BossData(
	name="Alda Ego", room=0x05, circuit=7,
	health=boss_labs_health(), maxhealth=12,
	programs=[PROG_BossShadowEmitterX, PROG_BossShadowEmitterY,]
)

BOSSES = [
	bossPolyclops,
	bossOutbreak,
	bossDoomgaze,
	bossPyrofuge,
	bossSaltwyrm,
	bossBombshell,
	bossAldaEgo,
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// this counts the number of lines of code totalled over a combination of programs
// checks latest non-empty opcode and uses max_of to choose the correct value
// produces 17^n non-trivial alt groups, which is too large for 3 programs (4913 groups)
function sloc_count(programs)
{
	class Measure
	{
		count = 0
		pred = always_true()
	}

	measures = [Measure(count=0, pred=always_true()),]
	for p in programs
	{
		ms = measures
		measures = []
		
		for c in ms
		{
			array_push(measures, c)
			for len in range(0,15) 
				array_push(measures, 
					Measure(
						count=c.count+len+1, 
						pred=c.pred && prg_op(p, len) != OPCODE_EMPTY
					)
				)
		}
			
	}

	return max_of(array_map(measures, m => measured(m.count, when=m.pred)))
}

function sloc_count_hits(programs) => tally_of(programs, 0, p => tally_of(range(0,15), 0, i => once(prg_op(p,i) != OPCODE_EMPTY)))

function map_progress() => sum_of(range(0,47), i => bitcount(MINIMAP_DATA_RAM + i))

function deaths() => (
	_deaths_x00() * 100 +
	_deaths_0x0() * 10 +
	_deaths_00x()
)

// in frames
function game_time() => (
	// _timer_frames() +
	_timer_000_00_0x() * 60 +
	_timer_000_00_x0() * 600 +
	_timer_000_0x_00() * 3600 +
	_timer_000_x0_00() * 36000 +
	_timer_00x_00_00() * 216000 +
	_timer_0x0_00_00() * 2160000 +
	_timer_x00_00_00() * 21600000
)

function game_time_nonzero() => dword(0x0750) != 0 && dword(0x0754) != 0

function circuit_count() => sum_of(range(1,7), i => circuit(i))
function chip_count() => sum_of(ALL_CHIPS, x => x)

function diary_pages() => sum_of(range(1,36), i => page_diary_day(i))
function manual_pages() => sum_of(range(1,9), i => page_field_manual(i))
function notes_count() => diary_pages() + manual_pages()

// https://github.com/mdsteele/annalog/blob/dc2b5c9a650e1f4c9a1a247c657e5f3bbcb6306f/src/epilogue.asm#L528
function completion_percent() => (
	4 - (epilogue_state() / 2) +
	flower_count() * 3 +
	notes_count() + chip_count()
)

function on_title() => current_music() == MUSIC_TITLE // && current_irq_pointer() == 0xF794
function on_epilogue() => current_music() == MUSIC_EPILOGUE
function in_game() => once(on_title()) && !on_title()

function epilogue_show_percent() => on_epilogue() && prev(epilogue_screen()) == 19 && epilogue_screen() == 20

function program_contains_opcode(p, opcode) => __ornext(any_of(range(0,15), line => prg_op(p, line) == opcode))
function program_maxlength(p, len) => len >= 12 || prg_op(p, len) == OPCODE_EMPTY

// helper method to determine that a program is running without error
function machine_is_looping(i) => (
	// machine is either Running, Working, or Waiting; not Syncing
	machine_status(i) < 4 && machine_status(i) != 2 &&
	// the wait time has run out
	prev(machine_wait_cycles(i)) == 1 && machine_wait_cycles(i) == 0 &&
	// the program counter has either stayed put or moved backwards
	machine_pc(i) <= prev(machine_pc(i))
)

function win_the_game() => prev(!on_epilogue()) && on_epilogue()

// --- RICH PRESENCE -------------------------------------------------------------------

ROOM_NAMES = {
	0x00: "Ancient City (Boss)",
	0x01: "Hidden Crypt (Boss)",
	0x02: "Vine Garden (Boss)",
	0x03: "Volcanic Pit (Boss)",
	0x04: "Salt Mines (Boss)",
	0x05: "Shadow Labs (Boss)",
	0x06: "Lost Temple (Boss)",
	0x07: "Ancient City",
	0x08: "Ancient City",
	0x09: "Ancient City",
	0x0A: "Ancient City",
	0x0B: "Ancient City",
	0x0C: "Ancient City",
	0x0D: "Ancient City",
	0x0E: "Ancient City",
	0x0F: "Ancient City",
	0x10: "Ancient City",
	0x11: "Ancient City",
	0x12: "Ancient City",
	0x13: "Ancient City",
	0x14: "Ancient City",
	0x15: "Ancient City",
	0x16: "Power Core",
	0x17: "Power Core",
	0x18: "Power Core",
	0x19: "Power Core",
	0x1A: "Power Core",
	0x1B: "Power Core",
	0x1C: "Power Core",
	0x1D: "Power Core",
	0x1E: "Hidden Crypt",
	0x1F: "Hidden Crypt",
	0x20: "Hidden Crypt",
	0x21: "Hidden Crypt",
	0x22: "Hidden Crypt",
	0x23: "Hidden Crypt",
	0x24: "Hidden Crypt",
	0x25: "Hidden Crypt",
	0x26: "Hidden Crypt",
	0x27: "Hidden Crypt",
	0x28: "Hidden Crypt",
	0x29: "Hidden Crypt",
	0x2A: "Hidden Crypt",
	0x2B: "Rust Factory",
	0x2C: "Rust Factory",
	0x2D: "Rust Factory",
	0x2E: "Rust Factory",
	0x2F: "Rust Factory",
	0x30: "Rust Factory",
	0x31: "Rust Factory",
	0x32: "Rust Factory",
	0x33: "Rust Factory",
	0x34: "Rust Factory",
	0x35: "Rust Factory",
	0x36: "Vine Garden",
	0x37: "Vine Garden",
	0x38: "Vine Garden",
	0x39: "Vine Garden",
	0x3A: "Vine Garden",
	0x3B: "Vine Garden",
	0x3C: "Vine Garden",
	0x3D: "Vine Garden",
	0x3E: "Vine Garden",
	0x3F: "Volcanic Pit",
	0x40: "Volcanic Pit",
	0x41: "Volcanic Pit",
	0x42: "Volcanic Pit",
	0x43: "Volcanic Pit",
	0x44: "Volcanic Pit",
	0x45: "Volcanic Pit",
	0x46: "Volcanic Pit",
	0x47: "Volcanic Pit",
	0x48: "Volcanic Pit",
	0x49: "Mermaid Vale",
	0x4A: "Mermaid Vale",
	0x4B: "Mermaid Vale",
	0x4C: "Mermaid Vale",
	0x4D: "Mermaid Vale",
	0x4E: "Mermaid Vale",
	0x4F: "Mermaid Vale",
	0x50: "Mermaid Vale",
	0x51: "Mermaid Vale",
	0x52: "Mermaid Vale",
	0x53: "Mermaid Vale",
	0x54: "Mermaid Vale",
	0x55: "Mermaid Vale",
	0x56: "Salt Mines",
	0x57: "Salt Mines",
	0x58: "Salt Mines",
	0x59: "Salt Mines",
	0x5A: "Salt Mines",
	0x5B: "Salt Mines",
	0x5C: "Salt Mines",
	0x5D: "Salt Mines",
	0x5E: "Salt Mines",
	0x5F: "Salt Mines",
	0x60: "Salt Mines",
	0x61: "Prison Caves",
	0x62: "Prison Caves",
	0x63: "Prison Caves",
	0x64: "Prison Caves",
	0x65: "Prison Caves",
	0x66: "Prison Caves",
	0x67: "Prison Caves",
	0x68: "Old Waterway",
	0x69: "Old Waterway",
	0x6A: "Old Waterway",
	0x6B: "Old Waterway",
	0x6C: "Old Waterway",
	0x6D: "Old Waterway",
	0x6E: "Old Waterway",
	0x6F: "Old Waterway",
	0x70: "Old Waterway",
	0x71: "Old Waterway",
	0x72: "Old Waterway",
	0x73: "Shadow Labs",
	0x74: "Shadow Labs",
	0x75: "Shadow Labs",
	0x76: "Shadow Labs",
	0x77: "Shadow Labs",
	0x78: "Shadow Labs",
	0x79: "Shadow Labs",
	0x7A: "Shadow Labs",
	0x7B: "Shadow Labs",
	0x7C: "Shadow Labs",
	0x7D: "Shadow Labs",
	0x7E: "Lost Temple",
	0x7F: "Lost Temple",
	0x80: "Lost Temple",
	0x81: "Lost Temple",
	0x82: "Lost Temple",
	0x83: "Lost Temple",
	0x84: "Lost Temple",
	0x85: "Lost Temple",
	0x86: "Lost Temple",
	0x87: "Lost Temple",
	0x88: "Bartik Town",
	0x89: "Bartik Town",
	0x8A: "Bartik Town",
	0x8B: "Bartik Town",
	0x8C: "Bartik Town",
	0x8D: "Bartik Town",
	0x8E: "Bartik Town",
	0x8F: "Bartik Town",
}

rich_presence_conditional_display(on_title(),
	"Title Screen"
)

rich_presence_conditional_display(on_epilogue(),
	"Epilogue ({11}% completion) · {4} chip{5} · 🌼 {6} 📃 {7} 🗺️ {8}% [{9}, 💀{10}]",
	rich_presence_lookup("ROOM", room_id(), ROOM_NAMES, fallback="???"),
	rich_presence_lookup("HAVEFLOWER", has_flower(), {1: " 🌼"}, fallback=""),
	rich_presence_number(circuit_count()), plural(circuit_count()),
	rich_presence_number(chip_count()), plural(chip_count()),
	rich_presence_number(flower_count()),
	rich_presence_number(notes_count()),
	rich_presence_number(100 * map_progress() / MAX_MAP_PROGRESS),
	rich_presence_value("GAMETIME", game_time() / 60, "SECS"),
	rich_presence_number(deaths()),
	rich_presence_number(completion_percent())
)

rich_presence_conditional_display(in_game(),
	"{0}{1} · {2} circuit{3}, {4} chip{5} · 🌼 {6} 📃 {7} 🗺️ {8}% [{9}, 💀{10}]",
	rich_presence_lookup("ROOM", room_id(), ROOM_NAMES, fallback="???"),
	rich_presence_lookup("HAVEFLOWER", has_flower(), {1: " 🌼"}, fallback=""),
	rich_presence_number(circuit_count()), plural(circuit_count()),
	rich_presence_number(chip_count()), plural(chip_count()),
	rich_presence_number(flower_count()),
	rich_presence_number(notes_count()),
	rich_presence_number(100 * map_progress() / MAX_MAP_PROGRESS),
	rich_presence_value("GAMETIME", game_time() / 60, "SECS"),
	rich_presence_number(deaths())
)

rich_presence_display(
	"Playing Annalog"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Every Rose Has Its Thorn",
	description="Defeat Polyclops, the carniverous overgrowth, and activate Power Circuit 1",
	type="progression",
	points=5,
	trigger=bossPolyclops.flip_circuit()
)

achievement(
	title="Weed Killer",
	description="Defeat Polyclops without taking damage or any computer errors, without using IF",
	type="missable",
	points=5,
	trigger=(
		bossPolyclops.perfect() &&
		never(program_contains_opcode(PROG_BossGardenCannon, OPCODE_IF))
	)
)

achievement(
	title="Game, Set, Match",
	description="Defeat Outbreak, the mutant abomination, and activate Power Circuit 2",
	type="progression",
	points=10,
	trigger=bossOutbreak.flip_circuit()
)

achievement(
	title="Pong Perfect",
	description="Defeat Outbreak without taking damage or any computer errors, and without allowing any breakballs to touch the floor",
	type="missable",
	points=5,
	trigger=(
		bossOutbreak.perfect() &&
		all_of(range(0,15), i => never(actor_id(i) == ACTOR_BREAKFIRE))
	)
)

achievement(
	title="You Can Run DOOM on This Thing?",
	description="Defeat Doomgaze, the cryptic fiend, and activate Power Circuit 3",
	type="progression",
	points=10,
	trigger=bossDoomgaze.flip_circuit()
)

achievement(
	title="Black Dahlia",
	description="Defeat Doomgaze without any computer errors, and with a flower in hand",
	type="missable",
	points=10,
	trigger=(
		bossDoomgaze.perfect() &&
		has_flower() == 1
	)
)

achievement(
	title="What's the Scuttlebutt?",
	description="Defeat Pyrofuge, the lavaborn spider, and activate Power Circuit 4",
	type="progression",
	points=10,
	trigger=bossPyrofuge.flip_circuit()
)

achievement(
	title="In Harm's Way",
	description="Defeat Pyrofuge without taking damage or any computer errors",
	type="missable",
	points=5,
	trigger=bossPyrofuge.perfect()
)

achievement(
	title="All I Need Is One Computer",
	description="Defeat Pyrofuge using only the left computer",
	type="missable",
	points=3,
	trigger=(
		bossPyrofuge.challenge() &&
		never(boss_volcano_health() < 6 && !program_maxlength(PROG_BossLavaBoiler, 0))
	)
)

achievement(
	title="Peek-a-Boo",
	description="Defeat Saltwyrm, the gargantuan annelid, and activate Power Circuit 5",
	type="progression",
	points=10,
	trigger=bossSaltwyrm.flip_circuit()
)

achievement(
	title="Claw Machine Master",
	description="Defeat Saltwyrm without taking damage or any computer errors",
	type="missable",
	points=5,
	trigger=bossSaltwyrm.perfect()
)

achievement(
	title="Code Golf Hacker",
	description="Defeat Saltwyrm using no more than 18 lines of code across both machines. Editing a program mid-fight is banned",
	type="missable",
	points=10,
	trigger=(
		// checkpoint on the start of the fight
		once(bossSaltwyrm.start_fight()) &&
		// challenge indicator will appear if the length of the programs satisfy the challenge
		any_of(range(0,18), i => program_maxlength(PROG_BossMineTrolley, i) && program_maxlength(PROG_BossMineCrane, 18-i)) &&
		// reset if we leave the room
		never(room_id() != bossSaltwyrm.room) && 
		// reset if a program is being edited after the fight has started
		never(bossSaltwyrm.health != bossSaltwyrm.maxhealth && console_machine_index() != 0xFF)
	)
)

achievement(
	title="We Have Spore Spawn at Home",
	description="Defeat Bombshell, the antigravity bivalve, and activate Power Circuit 6",
	type="progression",
	points=10,
	trigger=bossBombshell.flip_circuit()
)

achievement(
	title="All Brains, No Mussels",
	description="Defeat Bombshell without taking damage or any computer errors",
	type="missable",
	points=5,
	trigger=bossBombshell.perfect()
)

achievement(
	title="Ancient City Demolition Crew",
	description="Destroy the back wall in Bombshell's room",
	type="missable",
	points=5,
	trigger=(
		prev(boss_city_walldmg()) == 4 &&
		measured(boss_city_walldmg() == 5, when=room_id() == bossBombshell.room)
	)
)

achievement(
	title="Danse Macabre",
	description="Defeat Alda Ego, the forgotten phantom, and activate Power Circuit 7",
	type="progression",
	points=10,
	trigger=bossAldaEgo.flip_circuit()
)

achievement(
	title="Running Interference",
	description="Defeat Alda Ego without taking damage or any computer errors",
	type="missable",
	points=5,
	trigger=bossAldaEgo.perfect()
)

achievement(
	title="Please B Mine",
	description="Give Chief Gronta the B Module and earn the bad ending",
	points=1,
	trigger=win_the_game() && epilogue_state() == 2
)

achievement(
	title="AWAITING COMMANDS",
	description="Defeat Chief Gronta, the defiant warlord, and either destroy or reactivate the complex",
	type="win_condition",
	points=25,
	trigger=win_the_game() && epilogue_state() < 2
)

achievement(
	title="All Tests Passed: 100% Code Coverage",
	description="Complete the game with 100% completion percentage",
	points=25,
	trigger=epilogue_show_percent() && completion_percent() == 100
)

achievement(
	title="Decision Time",
	description="Collect the IF opcode",
	points=2,
	trigger=room_id() == 0x3c && is_set(chip_if())
)

achievement(
	title="Getting Loopy",
	description="Collect the TIL opcode",
	points=3,
	trigger=room_id() == 0x3c && is_set(chip_til())
)

achievement(
	title="A Reasonable Facsimile",
	description="Collect the COPY opcode",
	points=3,
	trigger=room_id() == 0x44 && is_set(chip_copy())
)

achievement(
	title="It Was My Understanding That There Would Be No Math",
	description="Collect the ADD/SUB opcode",
	points=3,
	trigger=room_id() == 0x69 && is_set(chip_addsub())
)

achievement(
	title="GOTO Considered Harmful",
	description="Collect the GOTO opcode",
	points=3,
	trigger=room_id() == 0x23 && is_set(chip_goto())
)

achievement(
	title="Segmentation Fault",
	description="Collect the SKIP opcode",
	points=3,
	trigger=room_id() == 0x2d && is_set(chip_skip())
)

achievement(
	title="Synchronicity",
	description="Collect the SYNC opcode",
	points=3,
	trigger=room_id() == 0x5e && is_set(chip_sync())
)

achievement(
	title="Download More RAM",
	description="Collect all RAM upgrades",
	points=5,
	trigger=(
		game_time_nonzero() &&
		measured(sum_of(range(1,4), i => ram(i)) == 4) &&
		prev(sum_of(range(1,4), i => ram(i))) == 3
	)
)

achievement(
	title="Grey Mermaid",
	description="Find a deliver a flower to the florist in Mermaid Vale",
	points=3,
	trigger=(
		room_id() == 0x51 &&
		flower_count() > prev(flower_count())
	)
)

achievement(
	title="One Dozen Fragile Flowers",
	description="Retrieve all flowers and earn a reward",
	points=25,
	trigger=(
		room_id() == 0x49 &&
		measured(flower_count() == 12) &&
		is_set(chip_beep())
	)
)

achievement(
	title="Complex Feelings",
	description="Collect all 36 pages of Jerome's diary",
	points=25,
	trigger=(
		game_time_nonzero() &&
		prev(diary_pages()) == 35 &&
		diary_pages() == 36
	)
)

achievement(
	title="Programming for Dummies",
	description="Collect all 9 pages of the field manual",
	points=10,
	trigger=(
		game_time_nonzero() &&
		prev(manual_pages()) == 8 &&
		manual_pages() == 9
	)
)

achievement(
	title="One-Ann Band",
	description="Build a complete band in the music room in the Mermaid Vale incorporating all instruments fully",
	points=2,
	trigger=(
		// confirm that we have opened a console at least once in this room
		room_id() == 0x53 && once(prev(console_machine_index()) != 0xFF) &&
		// all machines/instruments contain an ACT
		program_contains_opcode(PROG_MermaidHut6Organ, OPCODE_ACT) &&
		program_contains_opcode(PROG_MermaidHut6Trombone, OPCODE_ACT) &&
		program_contains_opcode(PROG_MermaidHut6Drums, OPCODE_ACT) &&
		// hi-hat is sounding sometimes as well
		__ornext(any_of(range(0,15), line => __prg_b1(PROG_MermaidHut6Drums, line) == OPCODE_MOVE * 0x10 + DIR_DOWN)) &&
		// a hit for each machine if it loops without an error
		all_of(range(0,2), i => tally(2, machine_is_looping(i))) &&
		// reset all hits if any machine errors
		all_of(range(0,2), i => never(machine_status(i) == MACHINE_ERROR)) &&
		// reset all hits if we are interacting with a console
		never(console_machine_index() != 0xFF) &&
		// reset all hits if we leave the room
		never(room_id() != 0x53)
	)
)

achievement(
	title="Ducks Dine-asty",
	description="Spend some time feeding the ducks in the Old Waterway",
	points=1,
	trigger=(
		// correct room
		room_id() == 0x6f &&
		// five times the ducks have been fed
		tally_of(range(0,2), 5, i => (
			// actor is a duck
			actor_id(i) == ACTOR_DUCK &&
			// actor was in Chasing mode
			prev(actor_param1(i)) < 0x80 && 
			// actor is in Eating mode
			actor_param1(i) > 0x80
		)) &&
		// reset all hits if we leave the room
		never(room_id() != 0x6f)
	)
)

achievement(
	title="A Bool in a China Shop",
	description="Complete the game without collecting the IF opcode",
	points=25,
	trigger=win_the_game() && chip_if() == 0
)

achievement(
	title="Control Freak",
	description="Complete the game without collecting the TIL, GOTO, and SKIP opcodes",
	points=50,
	trigger=win_the_game() && chip_til() == 0 && chip_goto() == 0 && chip_skip() == 0
)

achievement(
	title="Death Is a Bug, Not a Feature",
	description="Complete the game with 25 deaths or fewer",
	points=25,
	trigger=win_the_game() && deaths() <= 25
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="SELECT * FROM Completions ORDER BY percent ASC",
	description="Lowest percentage completion at end of game",

	start=epilogue_show_percent(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(completion_percent()),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="SELECT * FROM Playthroughs ORDER BY deaths ASC",
	description="Fewest deaths to complete the game",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(deaths()),
	format="VALUE",
	lower_is_better=true
)

leaderboard(
	title="SELECT * FROM Speedruns ORDER BY time ASC",
	description="Fastest time to complete the game",

	start=win_the_game(),
	cancel=always_false(),
	submit=always_true(),

	value=measured(game_time()),
	format="FRAMES",
	lower_is_better=true
)

for boss in BOSSES
{
	leaderboard(
		title=format("SELECT * FROM CodeGolf WHERE boss = '{0}' ORDER BY sloccount ASC", boss.name),
		description=format("Minimum lines of code used to defeat {0}. Editing a program mid-fight will cancel the leaderboard", boss.name),
	
		start=boss.start_fight(),
		cancel=room_id() != boss.room || (boss.health != boss.maxhealth && console_machine_index() != 0xFF),
		submit=prev(boss_state()) == 1 && boss_state() == 2,
	
		// value=sloc_count(boss.programs),
		value=sloc_count_hits(boss.programs) && never(console_machine_index() != 0xFF) && never(room_id() != boss.room),
		format="VALUE",
		lower_is_better=true
	)
}
