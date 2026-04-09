// Tales of Monkey Island
// #ID = 35531

// --- HELPERS -------------------------------------------------------------------

function is_set(acc) => acc > prev(acc)
function rich_presence_number(x) => rich_presence_value("_N", x, "VALUE")
function plural(x) => rich_presence_lookup("_Pl", x, {1: ""}, fallback="s")
function if_else(p, t, f) { if (p) { return t } else return f }

function ptr(x) => dword_be(x) & 0x1fffffff
function ptr_chain(addr, offsets)
{
	for offset in offsets
		addr = ptr(addr) + offset
	return addr
}

// --- MEMORY -------------------------------------------------------------------

class Chapter
{
	diskname = ""
	chapternum = 0
	chaptername = ""
	script_addr = -1
	cutscene_addr = -1
	cutscene_id_path = []
	cutscene_len_path = []
	cutscene_timer_path = []
	locations = {}

	function is_chapter() => ascii_string_equals(0x3180, this.diskname)

	function get_map_name() => ptr(this.script_addr) + 0x00
	function is_map_name(x) => ascii_string_equals(this.get_map_name(), x, length(x)+1)

	function get_cutscene_id() => dword_be(ptr_chain(this.cutscene_addr, this.cutscene_id_path))
	function get_cutscene_len_id() => dword_be(ptr_chain(this.cutscene_addr, this.cutscene_len_path))
	function get_cutscene_len() => float_be(ptr_chain(this.cutscene_addr, this.cutscene_len_path))
	function get_cutscene_timer() => float_be(ptr_chain(this.cutscene_addr, this.cutscene_timer_path))
}

CHAPTER1 = Chapter(
	diskname = "WILE",
	chapternum = 1,
	chaptername = "Launch of the Screaming Narwhal",
	script_addr = 0x5A36EC,
	cutscene_addr = 0x5A3A14,
	cutscene_id_path = [0x18, 0x80, 0x28],
	cutscene_len_path = [0x18, 0x80, 0x2C],
	cutscene_timer_path = [0x18, 0x80, 0x30],
	locations = {
		"Legal.lua": "is getting ready to set sail",
		"Prologue.lua": "is moored outside the Rock of Gelato",
		"Beach.lua": "is in Flotsam Island town",
		"Dock.lua": "is in Flotsam Island town",
		"FlotsamJungle": "is in the jungles of Flotsam Island",
		"VoodooLady.lua": "is in the Voodoo Lady's hut",
		"Lab.lua": "is in De Singe's Lab",
		"Finale.lua": "is aboard the Screaming Narwhal",
	}
)
CHAPTER2 = Chapter(
	diskname = "WISE",
	chapternum = 2,
	chaptername = "The Siege of Spinner Cay",
	script_addr = 0x495A64,
	cutscene_addr = 0x495D78,
	cutscene_id_path = [0x18, 0x00, 0x30],
	cutscene_len_path = [0x18, 0x00, 0x34],
	cutscene_timer_path = [0x18, 0x00, 0x38],
	locations = {
		"Legal.lua": "is getting ready to set sail",
		"Prologue.lua": "is aboard the Screaming Narwhal",
		"SpinnerIsland.lua": "is anchored at Spinner Cay",
		"RoeIsland.lua": "is ashore on Roe Island",
		"SpoonJungle": "is wandering Spoon Isle",
		"IsleOfEwe.lua": "is on the Isle of Ewe",
		"BoulderBeachIsland.lua": "is on Boulder Beach",
		"BrilligIsland.lua": "is ashore on Brillig Island",
		"Blockade.lua": "is navigating the blockade",
		"OpenSea.lua": "is aboard the Screaming Narwhal",
		"ShipBattle.lua": "is at McGillicutty's Ship",
		"Finale.lua": "is aboard the Screaming Narwhal",
	}
)
CHAPTER3 = Chapter(
	diskname = "WIEE",
	chapternum = 3,
	chaptername = "Lair of the Leviathan",
	script_addr = 0x49D124,
	cutscene_addr = 0x49D438,
	cutscene_id_path = [0x18, 0x04, 0x74, 0x3C],
	cutscene_len_path = [0x18, 0x04, 0x74, 0x3C],
	cutscene_timer_path = [0x18, 0x04, 0x74, 0x1C],
	locations = {
		"Legal.lua": "is getting ready to set sail",
		"Prologue.lua": "is getting ready to set sail",
		"ManateeMouth.lua": "is in the mouth of the manatee",
		"ManateeBelly.lua": "is in the belly of the manatee",
		"OpenSea.lua": "is aboard the Screaming Narwhal",
		"OceanFloor.lua": "is walking on the ocean floor",
		"VoodooLady.lua": "is lost in a trance",
		"Finale.lua": "is aboard the Screaming Narwhal",
	}
)
CHAPTER4 = Chapter(
	diskname = "WIYE",
	chapternum = 4,
	chaptername = "The Trial and Execution of Guybrush Threepwood",
	script_addr = 0x49EDA4,
	cutscene_addr = 0x49F0B8,
	cutscene_id_path = [0x18, 0x04, 0x74, 0x38],
	cutscene_len_path = [0x18, 0x04, 0x74, 0x3C],
	cutscene_timer_path = [0x18, 0x04, 0x74, 0x1C],
	locations = {
		"Legal.lua": "is getting ready to set sail",
		"Dock.lua": "is in Flotsam Island town",
		"Courtroom.lua": "is in the Flotsam Island courthouse",
		"Beach.lua": "is in Flotsam Island town",
		"Club.lua": "is hanging out at Club 41",
		"Lab.lua": "is in De Singe's Lab",
		"FlotsamJungle": "is in the jungles of Flotsam Island",
	}
)
CHAPTER5 = Chapter(
	diskname = "WIRE",
	chapternum = 5,
	chaptername = "Rise of the Pirate God",
	script_addr = 0x49EDA4,
	cutscene_addr = 0x49F0B8,
	cutscene_id_path = [0x18, 0x04, 0x74, 0x38],
	cutscene_len_path = [0x18, 0x04, 0x74, 0x3C],
	cutscene_timer_path = [0x18, 0x04, 0x74, 0x1C],
	locations = {
		"Legal.lua": "is getting ready to set sail",
		"OceanShip.lua": "is aboard LeChuck's ship",
		"OceanRaft.lua": "is on a raft at sea",
		"OceanFloor.lua": "is walking on the ocean floor",
		"Club.lua": "is hanging out at Club 41",
		"Jail.lua": "is in the Flotsam Island jail",
		"JungleClearing.lua": "is in the jungles of Flotsam Island",
		"Finale.lua": "is aboard LeChuck's ship",
		"Epilogue.lua": "is in the Epilogue",
	}
)

ALL_CHAPTERS = [
	CHAPTER1,
	CHAPTER2,
	CHAPTER3,
	CHAPTER4,
	CHAPTER5,
]

// --- MAIN DATA -------------------------------------------------------------------

C5_CROSSROADS_LOCATIONS = {
	"CrossroadsGateway.lua": "is at the gateway to the crossroads",
	"CrossroadsCenter.lua": "is at the center of the crossroads",
	"CrossroadsSwordfight.lua": "is at the swordfighting branch of the crossroads",
	"CrossroadsThievesDen.lua": "is at the thieves' den",
	"CrossroadsTreasureHunt.lua": "is at the treasure hunt branch of the crossroads",
}

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function cs_time_by_len(c, scene, len, t) => (
	c.is_chapter() && c.is_map_name(scene) &&
	c.get_cutscene_len_id() == len &&
	prev(c.get_cutscene_timer()) < t && 
	c.get_cutscene_timer() >= t
)

function cs_end_by_len(c, scene, len) => cs_time_by_len(c, scene, len, c.get_cutscene_len())

function cs_end_by_len_id(c, scene, len, id) => cs_end_by_len(c, scene, len) && c.get_cutscene_id() == id

function cs_end_no_location(c, len, id) => (
	c.is_chapter() &&
	c.get_cutscene_len_id() == len &&
	c.get_cutscene_id() == id &&
	prev(c.get_cutscene_timer()) < c.get_cutscene_len() && 
	c.get_cutscene_timer() >= c.get_cutscene_len()
)

// --- RICH PRESENCE -------------------------------------------------------------------

FORMAT = "📖 Chapter {0}: {1} 🏴‍☠️ Guybrush {2}"
ACTION_FALLBACK = "is somewhere at sea"

rich_presence_conditional_display(CHAPTER5.is_chapter() && ascii_string_equals(CHAPTER5.get_map_name(), "Cros"),
	FORMAT, CHAPTER5.chapternum, CHAPTER5.chaptername,
	rich_presence_ascii_string_lookup("ActionsCrossroads", CHAPTER5.get_map_name(), C5_CROSSROADS_LOCATIONS, fallback=ACTION_FALLBACK)
)

for c in ALL_CHAPTERS
{
	lookupname = format("ActionsChapter{0}", c.chapternum)
	rich_presence_conditional_display(c.is_chapter(),
		FORMAT, c.chapternum, c.chaptername,
		rich_presence_ascii_string_lookup(lookupname, c.get_map_name(), c.locations, fallback=ACTION_FALLBACK)
	)
}

rich_presence_display(
	"Playing Tales of Monkey Island"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// >>> CHAPTER 1

achievement(
	title="My Faithful Crew",
	description="Once we reached the Rock of Gelato, I whipped my crew into shape with a motivational pep-talk.",
	points=1,
	trigger=cs_end_by_len(CHAPTER1, "Prologue.lua", 1090442128)
)

achievement(
	title="Taste Cold Steel, Feeble Canon Antagonist",
	description="With a little bit of clever improvization, I defeated my nemesis LeChuck in a sword fight.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER1, "Prologue.lua", 1124441693)
)

achievement(
	title="Well Wishes",
	description="I arrived at Flotsam Island, where I wished for good fortune at a wishing well in the jungle.",
	points=1,
	trigger=cs_end_by_len(CHAPTER1, "FlotsamJungleDay_10.lua", 1092385049)
)

achievement(
	title="High Seas Havoc",
	description="I stirred up some trouble on Flotsam Island by commandeering a ship, the Screaming Narwhal.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER1, "Dock.lua", 1117150249)
)

achievement(
	title="41 Bottles of Grog on the Wall",
	description="I started a fight at a local Flotsam Island bar, and they kicked me out.",
	type="progression",
	points=2,
	trigger=cs_end_by_len(CHAPTER1, "Beach.lua", 1109301658)
)

achievement(
	title="Six Feet Under",
	description="I helped a local pirate find genuine buried treasure too!",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER1, "FlotsamJungleDay_13.lua", 1113946948)
)

achievement(
	title="Would a Pirate by Any Other Name Still Smell as Foul?",
	description="I met with the Voodoo Lady. After all these years, I still don't know her name, so I asked her.",
	points=1,
	trigger=cs_end_by_len(CHAPTER1, "VoodooLady.lua", 1096216455)
)

achievement(
	title="The Curse of Monkey Island",
	description="I investigated the Voodoo Lady's books and started to feel unwell. Maybe it's the weather.",
	points=1,
	trigger=cs_end_by_len_id(CHAPTER1, "VoodooLady.lua", CHAPTER1.get_cutscene_len_id(), 6)
	/*(
		CHAPTER1.is_chapter() && CHAPTER1.is_map_name("VoodooLady.lua") && 
		CHAPTER1.get_cutscene_id() == 6 &&
		prev(CHAPTER1.get_cutscene_timer()) < CHAPTER1.get_cutscene_len() && 
		CHAPTER1.get_cutscene_timer() >= CHAPTER1.get_cutscene_len()
	)*/
)

achievement(
	title="The Vitruvian Pirate",
	description="Back in town, I was captured by the sadistic Marquis de Singe, but I managed a daring escape!",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER1, "Lab.lua", 1102661354)
)

achievement(
	title="Breaking Wind",
	description="After finding a strange machine in the jungle, I summoned four wind gods and dispelled the death cloud.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER1, "FlotsamJungleDay_4.lua", 1116400517)
)

achievement(
	title="Set Sail for Adventure",
	description="Once aboard my new ship, we set off for the Rock of Gelato to rescue Elaine.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER1, "Finale.lua", 1099169792)
)

achievement(
	title="The Vorpal Blade Went Snicker-Snack",
	description="But at the last moment, my plans were interrupted by an manxome foe...",
	type="progression",
	points=25,
	trigger=cs_end_by_len(CHAPTER1, "Finale.lua", 1116864512)
)

// >>> CHAPTER 2

achievement(
	title="Mast-erful Explanation",
	description="On my ship, I explained how my mast worked to Morgan several times. I think she enjoyed the lesson!",
	points=1,
	trigger=cs_end_by_len(CHAPTER2, "Prologue.lua", 1077500725)
)

achievement(
	title="Give Her a Hand, Guybrush",
	description="I managed to escape being captured by Morgan LeFlay, my biggest fan, on the high seas.",
	type="progression",
	points=3,
	trigger=cs_time_by_len(CHAPTER2, "Prologue.lua", 1118189092, t=19.0)
)

achievement(
	title="A Pirate I Was Meant to Be",
	description="On Roe Island, I found a talking manatee that sang a familiar song.",
	points=2,
	trigger=cs_time_by_len(CHAPTER2, "RoeIsland.lua", 1100288895, t=8.2)
)

achievement(
	title="Pearls Before Swine",
	description="I actually helped LeChuck solve a puzzle at the top of Spoon Isle. Now he knows what I go through.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER2, "SpoonJungleSunset_11.lua", 1101822689)
)

achievement(
	title="O Frabjous Day! Callooh! Callay!",
	description="I tricked a few mangy pirates and managed to steal the summoning seahorse artifact buried on Brillig Island.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER2, "BrilligIsland.lua", 1109917696)
)

achievement(
	title="Just for the Halibut",
	description="Back on Spoon Isle, I found a summoning fish artifact in an unlikely place. Well, not *that* unlikely.",
	type="progression",
	points=2,
	trigger=cs_end_by_len(CHAPTER2, "SpoonJungleSunset_4.lua", 1108213760)
)

achievement(
	title="Big Whooped",
	description="In the forests of Spoon Isle, LeChuck lost a fight to a group of pox-ridden pirates.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER2, "SpoonJungleSunset_7.lua", 1114780236)
)

achievement(
	title="Taken Like a Fish to Water",
	description="I heroically rode out through the blockade of Spinner Cay and rescued the Mer-Leader from McGillicutty and his crew.",
	type="progression",
	points=5,
	trigger=cs_time_by_len(CHAPTER2, "ShipBattle.lua", 1115947008, t=44.5)
)

achievement(
	title="Oh the Huge Manatee",
	description="Back at sea, we set sail to find La Esponja Grande, but we encountered a bit of a detour...",
	type="progression",
	points=25,
	trigger=cs_end_by_len(CHAPTER2, "Finale.lua", 1103189334)
)

// >>> CHAPTER 3

achievement(
	title="The Newlywed Game",
	description="In the mouth of the manatee, Morgan and I pretended to be married to appease the jealous Coronada De Cava.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER3, "ManateeMouth.lua", 1110035661)
)

achievement(
	title="Season of Grubs",
	description="De Cava wanted to build a new manatee cochlea, so I brought him a throat grub. Ew!",
	points=1,
	trigger=cs_end_by_len(CHAPTER3, "ManateeMouth.lua", 1108006586)
)

achievement(
	title="A Really Evil-Looking Doorstop",
	description="I found an old friend hanging around in a treasure chest in the belly of the manatee.",
	points=2,
	trigger=cs_end_by_len(CHAPTER3, "ManateeBelly.lua", 1116547445)
)

achievement(
	title="Guybrush Threepwood, Mighty Wingman",
	description="I helped a bongo-playing pirate get a date with Morgan LeFlay, and earned his vote.",
	points=3,
	trigger=cs_end_by_len(CHAPTER3, "ManateeBelly.lua", 1112046726)
)

achievement(
	title="I Ain't Got No Body",
	description="I convinced \"Santino\" to vote for me to join the brotherhood. Oh, and Moose too.",
	points=3,
	trigger=cs_end_by_len(CHAPTER3, "ManateeBelly.lua", 1111674061)
)

achievement(
	title="The Nastiest Mug This Side of the Hypothalamus",
	description="After winning the face-off, I earned Bugeye's vote to join the brotherhood.",
	points=5,
	trigger=cs_end_by_len(CHAPTER3, "ManateeBelly.lua", 1112932352)
)

achievement(
	title="Eustachian Station",
	description="I replaced the cochlea, and we escaped the manatee and found ourselves on the open sea again!",
	type="progression",
	points=10,
	trigger=cs_end_by_len(CHAPTER3, "OpenSea.lua", 1118502422)
)

achievement(
	title="Babel Fishing",
	description="Thanks to a book that the Voodoo Lady had, I learned to speak the language of the manatees.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER3, "VoodooLady.lua", 1102782276)
)

achievement(
	title="I Can Only Hold My Breath for Ten Minutes",
	description="After returning to the sea floor for a second time, I held my breath for ten minutes, just to prove I could.",
	points=1,
	trigger=cs_end_by_len(CHAPTER3, "OceanFloor.lua", 1089887101)
)

achievement(
	title="La Esponja No Es Grande",
	description="I managed to help the manatee find a mate, and I finally got my hands on La Esponja Grande.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER3, "OceanFloor.lua", 1115234781)
)

achievement(
	title="Benedict Arrr-nold",
	description="But once again, my plans were interrupted by Morgan LeFlay...",
	type="progression",
	points=25,
	trigger=cs_end_by_len(CHAPTER3, "Finale.lua", 1123432661)
)

// >>> CHAPTER 4

achievement(
	title="A Fool for a Client",
	description="Back on Flotsam Island, I did a little smooth talking and managed to break out of jail.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER4, "Beach.lua", 1104730783)
)

achievement(
	title="A Little Diddy",
	description="Heh, when I examine the monkey in my pocket, it reminds me of a funny little song.",
	points=1,
	trigger=cs_end_no_location(CHAPTER4, 1088883261, id=144)
)

achievement(
	title="It's a Major Award",
	description="I defended myself in the case of Threepwood v. Krebbs and was acquitted of all charges.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER4, "Courtroom.lua", 1118510551)
)

achievement(
	title="Colluding with the Plaintiff",
	description="I defended myself in the case of Threepwood v. D'Oro and was acquitted of all charges.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER4, "Courtroom.lua", 1116837512)
)

achievement(
	title="Jacques' Shocking Testimony",
	description="I defended myself in the case of Threepwood v. McGee and was acquitted of all charges.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER4, "Courtroom.lua", 1117774152)
)

achievement(
	title="Badgering the Witness",
	description="I defended myself in the case of Threepwood v. Hardtack and was acquitted of all charges.",
	type="progression",
	points=1,
	trigger=cs_end_by_len(CHAPTER4, "Courtroom.lua", 1111545610)
)

achievement(
	title="This Isn't What I Meant by \"Summoned\"",
	description="I managed to serve Elaine with a summons to appear in court, which was no easy task!",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER4, "Club.lua", 1117353422)
)

TREP_CUTSCENES = [
	1089533438, // 1st button (numb)
	1099868895, // 2nd button (tiny)
	1090723587, // 3rd button (blind)
	1092959117, // 4th button (spin)
]
achievement(
	title="Cutting the Stone",
	description="In one session, I experimented with all of the buttons on the auto-trepination helmet in De Singe's lab.",
	points=1,
	trigger=(
		measured(tally_of(TREP_CUTSCENES, length(TREP_CUTSCENES), (x) => once(cs_end_by_len(CHAPTER4, "Lab.lua", x))))	
	)
)

achievement(
	title="That Guy's Not Gonna Be in Monkey Island 6",
	description="We finished the Feast for the Senses ritual, and I was dying to see what would happen next...",
	type="progression",
	points=25,
	trigger=cs_end_by_len(CHAPTER4, "FlotsamJungleNight_1.lua", 1130496000)
)

// >>> CHAPTER 5

achievement(
	title="Ask Me About Grim Fandango",
	description="At the gateway, I paid the ferryman to take me to the center of the crossroads.",
	type="progression",
	points=2,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsGateway.lua", 1103474196)
)

achievement(
	title="A Pirate's Best Friend",
	description="I found a novel way to get around leash laws. Good boy!",
	points=2,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsGateway.lua", 1095279575)
)

achievement(
	title="Duel Wielding",
	description="I met Morgan at the crossroads and I helped her get her confidence back.",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsSwordfight.lua", 1113587712)
)

achievement(
	title="A Recipe for Soul Food",
	description="I finally managed to get my hands on LeChuck's scroll, explaining how to get back to the physical realm.",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsTreasureHunt.lua", 1102226391)
)

achievement(
	title="Getting the Hell Outta Dodge",
	description="With the spell prepared, I finally opened a pathway out of the crossroads.",
	type="progression",
	points=2,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsCenter.lua", 1119289344)
)

achievement(
	title="Banang",
	description="I took a break to enjoy some dancing back in Club 41. Eight glasses of banang went straight to my head.",
	points=1,
	trigger=cs_end_by_len(CHAPTER5, "Club.lua", 1104756081)
)

achievement(
	title="Guybrush Threepwood, Undead Pirate",
	description="I used voodoo magic to temporarily re-possess my old body. What a weird feeling!",
	type="progression",
	points=3,
	trigger=cs_end_by_len(CHAPTER5, "Club.lua", 1103170063)
)

achievement(
	title="What It Feels Like to Chew Spirit Gum",
	description="Thanks to the Voodoo Lady's advice, I re-possessed my body permanently. Does that make me a zombie?",
	type="progression",
	points=5,
	trigger=cs_end_by_len(CHAPTER5, "Jail.lua", 1104233270)
)

achievement(
	title="Cutting Calories",
	description="I completed the Diet of the Senses and managed to shrink La Esponja Grande down to a more manageable size.",
	type="progression",
	points=10,
	trigger=cs_end_by_len(CHAPTER5, "CrossroadsCenter.lua", 1075755090)
)

achievement(
	title="The Pox Exsponjed",
	description="With help from Laneypoo, we managed to finally save the Gulf of Melange from the ravages of the Pox of LeChuck.",
	type="win_condition",
	points=25,
	trigger=cs_end_by_len(CHAPTER5, "Finale.lua", 1107727224)
)

achievement(
	title="The Tides of Destiny",
	description="In the end, it seems that the Voodoo Lady was even able to help Morgan.",
	points=1,
	trigger=cs_end_by_len(CHAPTER5, "Epilogue.lua", 1112117880)
)
