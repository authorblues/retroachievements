# ALTTP Community Puzzles Subset
This document serves as a design document, detailing simple readable versions of each prompt, expressed in a consistent way, as well as notes about implementation and detailing the glitches that are either needed or banned.

- [ALTTP Community Puzzles Subset](#alttp-community-puzzles-subset)
  - [Glitches](#glitches)
    - [No Exploration Glitch](#no-exploration-glitch)
    - [No JP 1.0 Glitches](#no-jp-10-glitches)
  - [Puzzles](#puzzles)
    - [#00 Dessyreqt](#00-dessyreqt)
    - [#01 ChristosOwen](#01-christosowen)
    - [#02 Crippe](#02-crippe)
    - [#03 Tompa](#03-tompa)
    - [#04 Traylini](#04-traylini)
    - [#05 SeanCass](#05-seancass)
    - [#06 ChristosOwen](#06-christosowen)
    - [#07 Acmlm](#07-acmlm)
    - [#08 ChristosOwen](#08-christosowen)
    - [#09 Lanturn](#09-lanturn)
    - [#10 Kinghippo](#10-kinghippo)
    - [#11 Barnowl](#11-barnowl)
    - [#12 ChristosOwen](#12-christosowen)
    - [#13 Dessyreqt](#13-dessyreqt)
    - [#14 FFGamer86](#14-ffgamer86)
    - [#15 Spimmmm](#15-spimmmm)
    - [#16 FFGamer86](#16-ffgamer86)
    - [#17 Lanturn](#17-lanturn)
    - [#18 SeanCass \& T1](#18-seancass--t1)
    - [#19 ChristosOwen](#19-christosowen)
    - [#20 x10power](#20-x10power)

## Glitches
### No Exploration Glitch
Expanding the definition of Exploration Glitch to include glitches with similar power to EG, to modernize these puzzles for the current year

- exploration glitch
  - Link can only be on layer 1 in 124 of the 1024 quadrants on the map. Look at the supertile ID and the quadrant that Link is in and use this to determine if he should even be allowed on layer 1 at all. if not, that player is using EG.
- door glitches
  - these glitches are done on quadrant or supertile boundaries and essentially trick the game into updating the quadrant and/or supertile ID while Link is not physically moved into the area the game thinks he should be in. this desync can create various broken effects.
- wrong warps
  - the player should only activate pit transitions in the underworld from rooms that actually have a valid pit transition. relevant addresses here are $7E0010 (the game mode, which is set to 7 when Link is in the underworld) and $7E0011 (the submodule for the current game mode, which is set to 7 on a pitfall transition).
- misslotting (ancillae glitches)
  - ancillae are run out of a 10 element buffer at $7E0C53. most items should only ever by indexed into the first 5 positions at that address. bombs should only be indexed into the first two positions.

### No JP 1.0 Glitches
- fake flippers
- item dashing
- spinspeed

## Puzzles
### #00 Dessyreqt
![prompt](<prompts/00 - Dessyreqt.png>)
- no banned glitches?
- goal: defeat Kholdstare with red mail + IP big key
- banned items: hookshot, somaria, power glove, boomerangs

### #01 ChristosOwen
![prompt](<prompts/01 - ChristosOwen.png>)
- no EG, no fake flippers
- goal: defeat Aga 1 with blue mail + sword4 + shield2
  - must kill Helma King, Blind, Vitreous, Kholdstare
- banned: fire rod, hookshot, sword2, waterfalls

### #02 Crippe
![prompt](<prompts/02 - Crippe.png>)
- no EG
- goal: defeat Mothula with green mail + sword1 + byrna
  - must kill Helma King, Blind, Moldorm
- banned: bug net, fire rod (vs Mothula)

### #03 Tompa
- no EG, no JP 1.0 glitches
- goal list:
  1. without moon pearl, kill Mothula, no fire rod for torches
  2. kill Aga 1
  3. open all 13 chests in PoD, kill Helma King
  4. perfect score shooting gallery
- sword and boots banned for damaging enemies after escape

### #04 Traylini
- no fake flippers
- goal list:
  1. kill Armos in Eastern without sword or bow
  2. kill Helma King in PoD without hammer on mask, hammer only after mask
  3. kill Blind with hammer
  4. kill Mothula using items (no fire rod)
  5. kill Kholdstare using fire rod with no sword equipped
  6. kill Vitreous using the bow
  7. kill Lanmo with fire rod
  8. kill Moldorm with hammer
  9. obtain sword2 in Lost Woods with sword4 + shield2 + blue mail
- <= 11 hearts, no killing Aga 1
- banned: hookshot, double magic, item dashing, IPBJ, swinging sword after escape

### #05 SeanCass
![prompt](<prompts/05 - SeanCass.png>)
- no EG, no fake flippers
- goal list:
  1. kill Kholdstare + Vitreous
  2. kill Moldorm
  3. kill Lanmo using only silver arrows
- cannot kill with arrows, fire rod, sword3
- banned: ice rod, bottle under bridge, Kak chest game bottle

### #06 ChristosOwen
![prompt](<prompts/06 - ChristosOwen.png>)
- no EG, no JP 1.0 glitches
- goal: equip magic boom in Chris Houlihan room
  - no sword + shield, 20 heart pieces, 2 uniquely filled bottles, 3 crystals, 6 magic consuming items
- banned: flippers, pendants 2 & 3, bug net, potion shop
- in every dungeon must: obtain map + compass, obtain heart container

### #07 Acmlm
![prompt](<prompts/07 - Acmlm.jpeg>)
- no EG, no fake flippers
- goals:
  - defeat Lamno, no sword, with shield2
  - defeat Moldorm, no sword, no shield
  - defat Arrghus, no sword, with shield3
- finish with 999 rupees, no more than 13 item slots filled
- banned: sword hits with sword2 + sword3, hammer hits except pegs/bosses

### #08 ChristosOwen
![prompt](<prompts/08 - ChristosOwen.png>)
- no EG, no JP 1.0 glitches
- goal: defeat Aga 1 with sword2
  - open 11 big chests, 11 compasses, open the mysterious chest
- no item/weapon on more than one boss
- no potion shop
- 1 bottle max
- conditional restrictions:
  - no crystals until 2 pendants
  - no super bomb until 3 pendants
  - no tempered sword until 2 crystals
  - no ether medallion until 3 crystals
  - no pendant2 until 4 crystals
  - no fire rod until visited fat faerie
  - no ice rod until 6 crystals
  - no bug net until 7 crystals
  - no magic cape until 20 hearts
  - no sword1 on bosses until 1 crystal
  - no regular bow on bosses until 3 medallions
  - no bombs on bosses until 5 crystals

### #09 Lanturn
![prompt](<prompts/09 - Lanturn.png>)
- no EG, no JP 1.0 Glitches
- goal: collect all level-1 Y items without upgrades
  - bow: kill ball & chain trooper with Zelda following
  - boom: get all other Y items, no sword/shield
  - hookshot: kill Trinexx
  - bomb: 2+ heart pieces
  - mushroom: sword level == shield level
  - fire rod: shield2, no mushroom
  - ice rod: exactly 5 Y items
  - bombos: kill Blind
  - ether: kill Helma King swordless
  - quake: kill Aga 1
  - lamp: no sword/shield
  - hammer: fire rod
  - shovel: kill Vitreous + Arrghus
  - bug net: 10+ hearts
  - book: 500+ rupees displayed
  - bottles: 1 per 2 maps collected
  - somaria: complete row 2
  - byrna: exactly 4 hearts
  - cape: 3+ bottles
  - mirror: exactly 5 Y items
- boss item restrictions?

### #10 Kinghippo
![prompt](<prompts/10 - Kinghippo.png>)
- no EG, no JP 1.0 Glitches, no DMD
- goal: open IP big chest with flippers + shield2
- dungeons required in order with rupee requirements to enter
  - eastern: 92
  - desert: 669
  - hera: 0 + full health
  - darkness: 231
  - thief: 0
  - skull: 301
  - ice: 623
- bottles only contain fairies
- gambling game, archery game, digging games banned
- only dash in dungeons + library
- no bomb jump
- no thiefs

### #11 Barnowl
![prompt](<prompts/11 - Barnowl.jpeg>)
- No EG, no JP 1.0 Glitches
- goal: minimal item run - defeat Ganon using sword2, no shield
- banned: boomerangs, recovery heart, powder, bug net, bombos, byrna, cape, tempered, big bomb, blue/red mail, fire/mirror shield
- max 1 bottle
- boss restrictions:
    - hammer can be used on 3 bosses
    - sword2 can be used on 3 bosses
    - no arrows on bosses
    - ganon, aga 1/2, and boss refights count

### #12 ChristosOwen
![prompt](<prompts/12 - ChristosOwen.png>)
- no EG, no JP 1.0 Glitches
- goal: obtain sword2, shield2 (but blue), blue mail
- restrictions:
    - may not bomb floor above blue mail
    - flippers requires 3 crystals
    - pearl requires 9 hearts
    - all level 2 items require 2 pendants
        - silver arrows, boom2, powder, flute, glove2
    - any item used to damage a boss must not be used against next 3 bosses
    - only upgrade from one great fairy
    - no 300 rupee chests
    - banned on LW bosses:
        - boom1, sword1, sword3, hammer, bow, green potion, fire rod
    - banned on DW bosses:
        - byrna, sword1, sword3, hammer, green potion, blue potion
    - banned in "complete all enemies to advance" rooms:
        - sword1, bow, bombs, boots

### #13 Dessyreqt
![prompt](<prompts/13 - Dessyreqt.png>)
- No EG, no fake flippers
- goal: open the purple chest and defeat Lanmo, Aga 1, Helma King, Mothula with shield3
- only 1 bottle, no magic powder (only while mirror shield?)
- boss restrictions:
    - no sword, fire rod, hammer, somaria against bosses (except Moldorm)

### #14 FFGamer86
![prompt](<prompts/14 - FFGamer86.png>)
- No EG, no JP 1.0 Glitches
- goal: defeat Aga1 with sword2
- defeat each LW boss with different equipment set
    - set #1: sword1, shield1, green mail
    - set #2: sword3, shield2, blue mail
    - set #3: sword4, shield3, red mail
    - Sword Only on LW bosses (does this mean no non-sword on LW bosses, or no sword on DW bosses?)
- banned: byrna, cape, bug net, powder, boom2, bombos, recovery heart
- only purple chest bottle, no others. 1 bomb on hand max (probably detect on changing rooms/screens)

### #15 Spimmmm
![prompt](<prompts/15 - Spimmmm.png>)
- No EG, no JP 1.0 Glitches
- goal: get magic cape, after
    - kill Vitreous, no shield, green mail, bow only on big eye, 5 heart containers
    - kill Helma King, sword2, blue mail, shield1, 8 heart containers
    - kill Arrghus, shield2, no sword, 10 hearts
- banned: recovery heart (heart pieces?), powder, fire rod
- restrictions:
    - sanc heart requires 3 crystals
    - 2 bottles max, 2nd bottle requires 3 pendants
    - no hammer or swords on DW bosses

### #16 FFGamer86
![prompt](<prompts/16 - FFGamer86.jpeg>)
- No EG
- goal list:
    1. kill Aga 1
    2. kill Blind with sword1
    3. kill Helma King with sword4
    4. kill Mothula
    5. kill Trinexx
    6. kill Arrghus
    7. kill Aga 2 with sword3
- banned: bug net, shovel, fire rod (fire rod allowed in turtle rock and opening skull woods)
- restrictions:
    - pendants baned until 3 bottles
    - bottles banned until real flippers
    - sword1, boom1, silver arrows (?), hammer banned on bosses until 2 pendants
    - all swords, bombs banned on DW bosses (except Blind) when even crystals
    - silver arrows(?), hammer banned on DW bosses when odd crystals

### #17 Lanturn
![prompt](<prompts/17 - Lanturn.jpeg>)
- No EG, no DMD, no JP 1.0 Glitches
- goal: multi-file restrictive playthrough, killing a target boss on each file
  1. kill Mothula on file 1
    - LW only: top Y row may only be used for Y items(?)
    - can only collect row 1 and 2 Y items
    - no A items besides flippers
  2. kill Kholdstare on file 2
    - no row 1 Y items (except bombs)
    - may only collect row 2 and 3 Y items + bombs
    - must use only A items on boss fights (may use Y for Kholdstare's ice)
  3. kill Vitreous on file 3 (at least 1 little eye must be alive?)
    - can only collect row 4 Y items + ether + bombs
    - must use only row 4 Y items on boss fights (and sword)
    - can't lift anything (pots, rocks, grass) (except portal rocks)
- may copy files to obtain unobtainable items on each file
- may only recieve a DW item once max between files (except hammer)
- must have half magic to start picking up DW items (except hammer)
- copying files banned after collecting DW item (except hammer)
- banned: fairies on file 3, all potions

### #18 SeanCass & T1
![prompt](<prompts/18 - SeanCass and T1.png>)
- (no glitch restrictions)
- goal: defeat Helma King without using swords, hammer, normal bow
  - with equipment sword2, shield2, blue mail
- boss restrictions:
  - no sword, normal bow vs Armos, Lanmo
  - no sword, hammer vs Mothula, Vitreous, Kholdstare, Blind
  - no sword vs Moldorm, Aga 1
- must collect pendants 1-3, crystals 3-6
- must not enter witch's hut

### #19 ChristosOwen
![prompt](<prompts/19 - ChristosOwen.png>)
- no EG
- goal: MST - 100% complete Mire, Swamp, Turtle Rock
  - map, compass, 100% map coverage, crystal, big chest
- boss restrictions:
  - LW: no boom, sword1, bow
  - no sword2 or sword3 vs Vitreous, Arrghus, Trinexx
- no sword2, bottles, Aga 1 until full clear(?) an MST dungeon
- any item used against a boss may not be used against another boss
- may only open 1 chest in Hyrule Castle
- may not spend rupees until boots
- may not obtain flippers until Vitreous and Trinexx defeated
- may not light torches with lamp
- may not use hammer + hookshot outside dungeons

### #20 x10power
![prompt](<prompts/20 - x10power.jpeg>)
- no JP 1.0 Glitches (EG?)
- goals:
  - boss dash challenge, defeat bosses with only dash
    - Lanmo: 4 hearts max, no filled bottles
    - Arrghus: 7 hearts max, 1 filled bottle max, hookshot allowed
    - Blind: 8 hearts max, 1 filled bottle max
    - Kholdstare: 10 hearts max, 1 filled bottle max (fire allowed?)
  - must DMD to DW
  - finish with 3 heart pieces, sword3, byrna, cape, blue tunic, boom2
  - finish with 500+ rupees
- banned: flute