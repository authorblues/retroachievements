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
- item dashing
- fake flippers
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