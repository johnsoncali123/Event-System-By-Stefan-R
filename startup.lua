version = "1.6.3" -- EVENT SYSTEM by Mevill
publicBuild = true
-- THIS IS THE MAIN COMPUTER, INSTRUCTIONS:

-- Spawn in a valid spawn structure schematic, then place this code onto the COMMAND COMPUTER.
ALL_CHAT_COMMANDS = [[# The following are chat commands.
## Send these in chat to communicate with the computer.
**Note that you do not need to type a player's FULL name.**
> `refill` Can be used by anyone, refills ammo and bandages.
> `:help` Shows you this list in-game incase you forget.
> `:lock` Locks spawns.
> `:unlock` Unlocks spawns.
> `:givekit` Gives everyone their kits.
> `:start` Teleports everyone and gives them ammo.
> `:go` Actually starts the match and begins cap depletion.
> `:return` Returns everyone back to the lobby.
> `:norespawn` Removes respawning (people go into spectator).
> `:kit [kit code] [name]` Gives a person a new kit.
> `:ticket [nation name] [+/-/= amount]` Adds tickets to a nation.
> `:swap [name]` Puts a person on the opposing side.
> `:m` Let's you interact with the main computer from wherever.
> `:tp` Sends you to the main computer and gives you creative.
> `:back` Sends you back to where you were and in the same gamemode.
> `:stp [spawn #]` Sends you to the nation's spawn, 0 is worldspawn, 3 is spectators.
> `:cap [cap name (optional)]` Creates a capture point at your position.
> `:clear` Unclaims all capture points.
> `:bring` Brings your nation to your location.
> `:auth [name]` Let's a person use chat commands.
> `:load` Logs any new users into the system.
> `:fix` Manually updates things which do not update automatically.
> `:setspawn [nation name/spec]` Moves the spawn of a side to your position.
> `:arty [x] [y (optional)] [z]` Sends an artillary bombardment to the location.
> `:buy [block name]` Allows someone to buy blocks to repair their vehicles. 
> `:save [profile name]` Saves the nearest recruit to your nation's database.
> `:view` Shows all the recruit save files you can spawn.
> `:spawn [profile name]` Let's you spawn a recruit.
> `:delete [profile name]` Deletes a recruit save file.]]

-- Savable Data
local set = {
	["team1Tickets"] = 200, -- default team 1 points amount
	["team2Tickets"] = 200, -- default team 2 points amount
	["team1"] = "",
	["team2"] = "",
	["gameSetup"] = false,
	["spawnsLocked"] = false,
	["kitsGivenOut"] = false,
	["gameBegun"] = false,
	["gameFinished"] = false,
	["respawnsDisabled"] = false,
	["teamTicketType"] = 1, -- 1 is count respawns, 2 is count cap points, 3 is rounds with no respawn
	["recruitsActive"] = true, -- Whether or not recruits options can be used
	["recruitTicketCost"] = 1, -- Cost to spawn a recruit
	["recruitSpawnRange"] = 30, -- Range from spawn you can spawn a recruit
	["ammoAmount"] = 128, -- The amount of ammo that is given to players when they respawn.
	["bandageAmount"] = 8, -- The amount of bandages that are given to players when they respawn
	["maxHealth"] = 10, -- The max health, out of 20, that a person spawns with.
	["lobbyName"] = "Skepsis", -- The name of the current lobby
	["go"] = false, -- has the event ACTUALLY started
	["refillRange"] = 60, -- The range to one's spawn that they need to be in order to refill their ammo
	["useArtillery"] = false,
	["team1LastUseArty"] = 0,
	["team2LastUseArty"] = 0,
	["showProTips"] = true,
	["capDistance"] = 20, -- how close you have to be to a point to cap it
	["miningFatigue"] = 1, -- mining fatigue effect strength
	["slowness"] = 1, -- slowness effect strength
	["spawnCampDistance"] = 40, -- The maximum range a player can be to their enemies spawn.
	["spareParts"] = {
		["allow"] = true, -- whether the purchase of spare parts is allowed at all
		["cost"] = 1, -- The cost of a spare part
		["team1LastBought"] = 0,
		["team2LastBought"] = 0,
		["create:gearbox"] = true,
		["create_connected:parallel_gearbox"] = true,
		["create:clutch"] = true,
		["create_connected:inverted_clutch"] = true,
		["create:gearshift"] = true,
		["create_connected:inverted_gearshift"] = true,
		["create:encased_chain_drive"] = true,
		["create:analog_lever"] = true,
		["vs_tournament:seat"] = true
	},
	["roundsLeft"] = 5,
	["roundWins1"] = 0,
	["roundWins2"] = 0,
	["roundSpawnSwap"] = false,
	["spawnProtection"] = true
}
local spawns = {"0 65 0", "0 65 0", "0 65 0"}
local caps = {}
local loggedUsers = {}
local auths = {}

-- Gloabal Variable declaration
local lookup = {
	["team1"] = "",
	["team2"] = ""
}
local permaLog = {
	["Mandus2000"] = {"104th", "GCT"},
	["Un0Amm0B0X"] = {"501st", "SVQ", "CVQ"},
	["Aron_Buler"] = {"3rd"},
	["WhovianLuke"] = {"NA"},
	["AVRaptor99"] = {"501st", "SVQ", "CVQ"},
	["Asser606"] = {"104th"},
	["CinnaminiMax"] = {"104th", "GCT", "SVQ"},
	["JacobWitzell"] = {"104th", "GCT", "SVQ"},
	["Mqnchy1010"] = {"2nd", "SVQ", "CVQ"},
	["Musicarych"] = {"104th", "GCT", "SVQ"},
	["NotDito_"] = {"2nd"},
	["OtakuHp"] = {"104th", "GCT", "SVQ"},
	["Tribulla"] = {"104th", "GCT", "SVQ"},
	["topictheddlc123"] = {"UNK"},
	["yacine_game_win"] = {"2nd", "GCT"},
	["Xstikezero"] = {"1st"},
	["beast10000"] = {"NA", "SVQ", "CVQ"},
	["CrocblancYT3165"] = {"2nd", "SVQ", "CVQ", "HQ"},
	["RAPTOR_T34"] = {"2nd"},
	["contestings"] = {"NA"},
	["Polish_Hussar10"] = {"501st", "GCT", "SVQ", "CVQ"},
	["polikmaz09"] = {"1st"},
	["Avrapator"] = {"501st", "SVQ", "CVQ"},
	["ErwinEkiller"] = {"1st"},
	["CzaroCzaruje4"] = {"1st"},
	["MaxSlayer"] = {"1st"},
	["DragoneKyt"] = {"1st"},
	["Pablogamer25pYT"] = {"3rd"},
	["enos696"] = {"NA"},
	["Frozenfire13"] = {"2nd"},
	["KnightCS"] = {"501st", "SVQ"},
	["JungleRootTree"] = {"3rd", "GCT", "HQ"},
	["Memosplays"] = {"3rd", "GCT"},
	["IamA_Canadian"] = {"3rd", "GCT"},
	["InvictusSouls"] = {"501st", "SVQ", "CVQ", "HQ"},
	["9i9an"] = {"3rd", "GCT"},
	["w1_0"] = {"7th", "HQ"},
	["Skycon7375"] = {"7th"},
	["VL0DIV0ST0K"] = {"501st"},
	["Vihaan2012"] = {"104th"},
	["GhastSand"] = {"104th"},
	["C4_Tech342538"] = {"104th"},
	["NocturneReaper"] = {"104th"},
	["Invist"] = {"104th"},
	["Juwen43"] = {"104th"},
	["t1MBERCEAFT"] = {"104th"},
	["DVTc00l"] = {"7th"},
	["8WICHER8"] = {"7th", "GCT", "SVQ"},
	["AdInVas"] = {"7th"},
	["Gallus_"] = {"3rd", "GCT", "AQ"},
	
	-- Admins
	["skepsi00"] = {"3rd", "ADM"},
	--["mrgreen2000"] = {"104th", "ADM"},
	["Submarine824"] = {"3rd", "ADM"},
	["CheezborgaXXL"] = {"501st", "ADM"},
	["Doragonsodo"] = {"104th", "ADM"},
	--["testmapVI"] = {"3rd", "ADM"},
	["Czechia_"] = {"501st", "ADM"},
	["ShrimpE_GOOB"] = {"3rd", "ADM"},
	--["Capt_Brickbeard"] = {"7th", "ADM"},
	["mevill"] = {"501st", "ADM"},
	["DiehardTried"] = {"501st", "ADM"}
}
local helpData = {
	[1] = {{"Lock Teams", 'This function teleports everyone to their respective team chambers in the main spawn structure and then places walls to lock everyone in. It will also make it so nobody can change their team without Admin intervention.'},
		   {"Give Kits", 'This function gives everyone their respected kits, however ammo is not given to ensure that guns are not abused while still in spawn, note that you can change people\'s kits in the player menu. This command can only be run after locking the spawns.'},
		   {"Start Game", 'This function teleports everyone to their respective spawns, gives them ammo, turns on teamkilling and some other needed gamerules, and it also makes it so new joiners get automatically given a random kit and sent out to their spawn. This command should be used to start the event, note that you can type ":title" into chat to announce the start of the event.'},
		   {"End Respawns", 'This function halts all respawns. This makes it so anyone who dies after respawns are ended will be sent into spectator mode and then get teleported to the location you set for spectators when starting up this program.'}},
	[2] = {"Checklist", 'This functions allows you to see what you need to do in order to start an event, you cannot interact with this menu, but it will help you not forget to setup certain things.'};
	[3] = {"Check Players", 'This function shows a comprehensive menu of all players in the event. It will only show players who\'ve picked a team, even if they left the game. You will see each player\'s team, squad affiliation, and more. You can click their "(RF)" to select their kit, or you can click the blue icon on the far left of their name to re-give their kit if they didn\'t get it for whatever reason.'},
	[4] = {"Event Settings", 'This function shows a menu where you can change various aspects of the event. Some can only be changed at certain points in the event, like before start.'},
	[5] = {"Manage Kits", 'This function allows you to manage and edit kits after they have been created. Using the menu you can change items, add/remove new items, alter the ammo used, or otherwise debug a kit if it\'s not working for whatever reason.'},
	[6] = {"Manage Mods", 'This functions allows you to add modifications to your event system. Modifications are .lua files that get compiled into the main event system code. They can significantly alter the way the event system runs for events that require a completely different system. Valid mods are named as such: "addon_[name].lua"'},
	[7] = {"Automatic Building", 'This function allows you to create procedurally generated structures in order to populate a map much faster than doing it by hand.'},
	[8] = {"Tech Support", 'This function allows you to communicate directly with the creators of this event system, even if they are not in-game.'},
	[9] = {"Reset Event System", 'This function deletes all stores files in the Data/ folder and then restarts the entire software. This should only be used if something has gone very wrong.'}
}
local keyTable = {
	-- Special Outputs, level 1
	['enter'] = {"ent", 1},
	['backspace'] = {"del", 1},
	-- Letters, level 1
	["a"] = {"a", 1},
	["b"] = {"b", 1},
	["c"] = {"c", 1},
	["d"] = {"d", 1},
	["e"] = {"e", 1},
	["f"] = {"f", 1},
	["g"] = {"g", 1},
	["h"] = {"h", 1},
	["i"] = {"i", 1},
	["j"] = {"j", 1},
	["k"] = {"k", 1},
	["l"] = {"l", 1},
	["m"] = {"m", 1},
	["n"] = {"n", 1},
	["o"] = {"o", 1},
	["p"] = {"p", 1},
	["q"] = {"q", 1},
	["r"] = {"r", 1},
	["s"] = {"s", 1},
	["t"] = {"t", 1},
	["u"] = {"u", 1},
	["v"] = {"v", 1},
	["w"] = {"w", 1},
	["x"] = {"x", 1},
	["y"] = {"y", 1},
	["z"] = {"z", 1},
	["shifta"] = {"A", 1},
	["shiftb"] = {"B", 1},
	["shiftc"] = {"C", 1},
	["shiftd"] = {"D", 1},
	["shifte"] = {"E", 1},
	["shiftf"] = {"F", 1},
	["shiftg"] = {"G", 1},
	["shifth"] = {"H", 1},
	["shifti"] = {"I", 1},
	["shiftj"] = {"J", 1},
	["shiftk"] = {"K", 1},
	["shiftl"] = {"L", 1},
	["shiftm"] = {"M", 1},
	["shiftn"] = {"N", 1},
	["shifto"] = {"O", 1},
	["shiftp"] = {"P", 1},
	["shiftq"] = {"Q", 1},
	["shiftr"] = {"R", 1},
	["shifts"] = {"S", 1},
	["shiftt"] = {"T", 1},
	["shiftu"] = {"U", 1},
	["shiftv"] = {"V", 1},
	["shiftw"] = {"W", 1},
	["shiftx"] = {"X", 1},
	["shifty"] = {"Y", 1},
	["shiftz"] = {"Z", 1},
	-- Numbers, level 2
	['zero'] = {"0", 2},
	['one'] = {"1", 2},
	['two'] = {"2", 2},
	['three'] = {"3", 2},
	['four'] = {"4", 2},
	['five'] = {"5", 2},
	['six'] = {"6", 2},
	['seven'] = {"7", 2},
	['eight'] = {"8", 2},
	['nine'] = {"9", 2},
	-- Special Characters, level 3
	['semicolon'] = {";", 3},
	['equals'] = {"=", 3},
	['shiftequals'] = {"+", 3},
	['space'] = {" ", 3},
	['apostrophe'] = {"'", 3},
	['comma'] = {",", 3},
	['minus'] = {"-", 3},
	['period'] = {".", 3},
	['slash'] = {"/", 3},
	['leftBracket'] = {"[", 3},
	['rightBracket'] = {"]", 3},
	['shiftleftBracket'] = {"{", 3},
	['shiftrightBracket'] = {"}", 3},
	['shiftzero'] = {")", 3},
	['shiftone'] = {"!", 3},
	['shifttwo'] = {"@", 3},
	['shiftthree'] = {"#", 3},
	['shiftfour'] = {"$", 3},
	['shiftfive'] = {"%", 3},
	['shiftsix'] = {"^", 3},
	['shiftseven'] = {"&", 3},
	['shifteight'] = {"*", 3},
	['shiftnine'] = {"(", 3}
}
local ammoReference = {
	-- 5.56 mm
	["pointblank:g36c"] = "pointblank:ammo556",
	["pointblank:g36k"] = "pointblank:ammo556",
	["pointblank:aug"] = "pointblank:ammo556",
	["pointblank:star15"] = "pointblank:ammo556",
	["pointblank:xm29"] = "pointblank:ammo556",
	["pointblank:m4a1"] = "pointblank:ammo556",
	["pointblank:m4a1mod1"] = "pointblank:ammo556",
	["pointblank:m16a1"] = "pointblank:ammo556",
	["pointblank:hk416"] = "pointblank:ammo556",
	["pointblank:k2q"] = "pointblank:ammo556",
	["pointblank:aughbar"] = "pointblank:ammo556",
	["pointblank:m249"] = "pointblank:ammo556",
	["pointblank:g41"] = "pointblank:ammo556",
	["pointblank:sl8"] = "pointblank:ammo556",
	["pointblank:m4sopmodii"] = "pointblank:ammo556",
	["pointblank:lamg"] = "pointblank:ammo556",
	["pointblank:scarl"] = "pointblank:ammo556",
	["pointblank:m134minigun"] = "pointblank:ammo556",
	["pointblank:t91"] = "pointblank:ammo556",
	["pointblank:xm177q"] = "pointblank:ammo556",
	
	-- 7.62x51 mm
	["pointblank:mk14ebr"] = "pointblank:ammo762x51",
	["pointblank:mk48"] = "pointblank:ammo762x51",
	["pointblank:pkmq"] = "pointblank:ammo762x51",
	["pointblank:pkpq"] = "pointblank:ammo762x51",
	["pointblank:mg42q"] = "pointblank:ammo762x51",
	["pointblank:mg3q"] = "pointblank:ammo762x51",
	["pointblank:mg42mq"] = "pointblank:ammo762x51",
	["pointblank:kar98kq"] = "pointblank:ammo762x51",
	["pointblank:g3"] = "pointblank:ammo762x51",
	["pointblank:xm3"] = "pointblank:ammo762x51",
	["pointblank:m14vsop"] = "pointblank:ammo762x51",
	["pointblank:t_57mg"] = "pointblank:ammo762x51",
	
	-- 9 mm
	["pointblank:lugerp08"] = "pointblank:ammo9mm",
	["pointblank:m9"] = "pointblank:ammo9mm",
	["pointblank:glock17"] = "pointblank:ammo9mm",
	["pointblank:mid_mp40"] = "pointblank:ammo9mm",
	["pointblank:mp5"] = "pointblank:ammo9mm",
	["pointblank:mp18"] = "pointblank:ammo9mm",
	["pointblank:glock18"] = "pointblank:ammo9mm",
	["pointblank:p30l"] = "pointblank:ammo9mm",
	["pointblank:glock34q"] = "pointblank:ammo9mm",
	["pointblank:ro635"] = "pointblank:ammo9mm",
	["pointblank:m950"] = "pointblank:ammo9mm",
	["pointblank:tmp"] = "pointblank:ammo9mm",
	
	-- 7.62 mm
	["pointblank:htg_ppsh"] = "pointblank:ammo762",
	["pointblank:sksq"] = "pointblank:ammo762",
	["pointblank:ak47"] = "pointblank:ammo762",
	["pointblank:type68q"] = "pointblank:ammo762",
	["pointblank:rpkq"] = "pointblank:ammo762",
	["pointblank:garandq"] = "pointblank:ammo762",
	["pointblank:stg44q"] = "pointblank:ammo762",
	
	-- 5.45 mm
	["pointblank:ak12"] = "pointblank:ammo545",
	["pointblank:ak74"] = "pointblank:ammo545",
	["pointblank:ak74suvsop"] = "pointblank:ammo545",
	["pointblank:an94"] = "pointblank:ammo545",
	
	-- 7.92x57mm Mauser Ammo
	["pointblank:kar98kvsop"] = "pointblank:ammo792x57",
	["pointblank:generalliurifle"] = "pointblank:ammo792x57",
	["pointblank:chiangkaishekrifle"] = "pointblank:ammo792x57",
	["pointblank:mid_kar98k"] = "pointblank:ammo792x57",
	["pointblank:mg34vsop"] = "pointblank:ammo792x57",
	
	-- 7.62x54 mm R
	["pointblank:svddragonovvsop"] = "pointblank:7_62_54mmr",
	["pointblank:mosin1891"] = "pointblank:7_62_54mmr",
	["pointblank:mosin189130"] = "pointblank:7_62_54mmr",
	
	-- .30-06 Springfield Ammo
	["pointblank:m1_gxrandvsop"] = "pointblank:ammo30-06",
	["pointblank:m1903_springfield"] = "pointblank:ammo30-06",
	["pointblank:tw_m1_garand"] = "pointblank:ammo30-06",
	
	-- .338 Lapua
	["pointblank:ballista"] = "pointblank:ammo338lapua",
	["pointblank:l96a1"] = "pointblank:ammo338lapua",
	["pointblank:c14"] = "pointblank:ammo338lapua",
	
	-- .45 ACP
	["pointblank:ump45"] = "pointblank:ammo45acp",
	["pointblank:vector"] = "pointblank:ammo45acp",
	
	-- .30-06 Springfield
	["pointblank:barm1918"] = "pointblank:30_06_springfield",
	["pointblank:m1903"] = "pointblank:30_06_springfield",
	
	-- 12 Gauge
	["pointblank:aa12"] = "pointblank:ammo12gauge",
	["pointblank:spas12"] = "pointblank:ammo12gauge",
	
	-- 6.5x50 mm SR Arisaka
	["pointblank:type38"] = "pointblank:6_5_50mmsr_arisaka",
	["pointblank:federov"] = "pointblank:6_5_50mmsr_arisaka",
	
	-- 5.7 mm
	["pointblank:ar57"] = "pointblank:ammo57",
	["pointblank:p90"] = "pointblank:ammo57",
	
	-- .303 British
	["pointblank:lewisgun"] = "pointblank:303_british",
	["pointblank:lee_enfield"] = "pointblank:303_british",
	
	-- .357
	["pointblank:htg_python"] = "pointblank:ammo357",
	["pointblank:rhino"] = "pointblank:ammo357",
	
	-- .50 BMG
	["pointblank:hecatevsop"] = "pointblank:ammo50bmg",
	
	-- .50 AE
	["pointblank:deserteagle"] = "pointblank:ammo50ae",
	
	-- 4.6 mm
	["pointblank:mp7"] = "pointblank:ammo46",
	
	-- 6.8 mm
	["pointblank:xm7"] = "pointblank:ammo68",
	
	-- 6.5x52 mm Carcano
	["pointblank:carcano1891"] = "pointblank:6_5_52mm_carcano",
	
	-- .351 Winchester Self-Loading
	["pointblank:winchestermodel1907"] = "pointblank:351_winchester_self_loading",
	
	-- 7.62x25 mm Tokarev
	["pointblank:ppsh41early"] = "pointblank:7_62_25mm_tokarev",
	
	-- 17.3 HVAP-T
	["pointblank:hissniper"] = "pointblank:ammo17mm",
	
	-- 13.2mm TuF
	["pointblank:tankgewehr"] = "pointblank:13_2mmtuf",
	
	-- 11x58 mm R
	["pointblank:werdl"] = "pointblank:11_58mmr",
	
	-- 10.4x47 mm R
	["pointblank:vetterlivitalim187087"] = "pointblank:10_4_47mmr"
}
local palettes = {
	["door"] = {
		"minecraft:dark_oak_door",
		"minecraft:oak_door",
		"minecraft:spruce_door",
		"minecraft:birch_door",
	},
	["floor"] = {
		"minecraft:stripped_spruce_wood",
		"minecraft:stripped_oak_wood",
		"minecraft:stripped_birch_wood",
		"minecraft:oak_planks",
		"tfmg:hardened_planks",
	},
	["ceiling"] = {
		"create:cut_calcite",
		"tfmg:white_concrete",
	},
	["window"] = {
		"create:oak_window_pane",
		"createdeco:copper_window_pane",
		"createdeco:zinc_window_pane",
	},
	["wallpaper"] = {
		"design_decor:wallpaper_striped_brown",
		"design_decor:wallpaper_arrow_brown",
		"design_decor:brown_wallpaper_wavy",
		"design_decor:orange_wallpaper_wavy",
	},
	["walls"] = {
		{"minecraft:stripped_birch_wood", "minecraft:stripped_oak_wood", "createdeco:dean_bricks", "create:cut_limestone_bricks"},
	},
	["lighting"] = {
		"light[level=10] replace air",
	},
	["bottomDetail"] = {
		{"minecraft:mud_bricks", "create:cut_dripstone"},
	},
	["innerBottomDetail"] = {
		{"create:layered_scoria", "create:scoria_pillar"},
	},
	["roof"] = {
		{"createdeco:tiled_umber_brick_slab", "createdeco:tiled_red_brick_slab"},
		{"createdeco:tiled_red_brick_slab", "createdeco:tiled_dean_brick_slab"},
		{"createdeco:tiled_dusk_brick_slab", "createdeco:tiled_dusk_brick_slab"},
	}
}
local partsMapping = {
	["gearbox"] = "create:gearbox",
	["parallel gearbox"] = "create_connected:parallel_gearbox",
	["clutch"] = "create:clutch",
	["inverted clutch"] = "create_connected:inverted_clutch",
	["gearshift"] = "create:gearshift",
	["inverted gearshift"] = "create_connected:inverted_gearshift",
	["chain drive"] = "create:encased_chain_drive",
	["lever"] = "create:analog_lever",
	["seat"] = "vs_tournament:seat"
}
local gamemodeTable = {
	["0"] = "survival", 
	["1"] = "creative", 
	["2"] = "adventure", 
	["3"] = "spectator"
}
local confirmations = {"i'm sure", "yes", "sure", "ok", "okay", "yep", "yeah", "ye", "yea", "alright", "mhm", "bet", "aight", "im sure", "confirm", "ong", "indeed", "roger", "aye", "true", "fine"}
local recruits = {}
local kitData = {}
local addonMetaData = {}
local discordQueue = {}
local positions = {}
local discordQueueLogged = 0
local resetMenu = false
local updatePause = false
local lastPlayer = ""
local playerPos = {"", "", ""}
local playerMode = ""
local isShiftPressed = false
local chatbox = peripheral.find("chatbox")
local modem = peripheral.find("modem")
local monitor = peripheral.find("monitor")
modem.open(65530)
modem.open(65531)
math.randomseed(os.epoch("utc"))
math.random()

-- Function declaration
function save()
	local file = fs.open("Data/loggedUsers.txt", "w")
	file.write(textutils.serialize(loggedUsers))
	file.close()
	local file = fs.open("Data/set.txt", "w")
	file.write(textutils.serialize(set))
	file.close()
	if (#caps > 0 or not fs.exists("Data/caps.txt")) then
		local file = fs.open("Data/caps.txt", "w")
		file.write(textutils.serialize(caps))
		file.close()
	end
	if (not fs.exists("Data/spawns.txt")) then
		local file = fs.open("Data/spawns.txt", "w")
		file.write(textutils.serialize(spawns))
		file.close()
	end
end

function readFiles()
	if (fs.exists("Data/set.txt")) then
		local file = fs.open("Data/loggedUsers.txt", "r")
		loggedUsers = textutils.unserialize(file.readAll())
		file.close()
		local file = fs.open("Data/set.txt", "r")
		set = textutils.unserialize(file.readAll())
		file.close()
		local file = fs.open("Data/spawns.txt", "r")
		spawns = textutils.unserialize(file.readAll())
		file.close()
		local file = fs.open("Data/caps.txt", "r")
		caps = textutils.unserialize(file.readAll())
		file.close()
		if (fs.exists("Data/auths.txt")) then
			local file = fs.open("Data/auths.txt", "r")
			auths = textutils.unserialize(file.readAll())
			file.close()
			for i = 1, #auths do
				if (permaLog[auths[i]]) then
					permaLog[auths[i]][2] = "ADM"
				else
					permaLog[auths[i]] = {"UNK", "ADM"}
				end
			end
		end
		return true
	else
		fs.makeDir("Data")
		fs.makeDir("Recruits")
		save()
		return false
	end
end

function commsSendRequest(data)
	modem.transmit(65530, 65531, data)
end

local comms = {
	writeText = function(text)
		commsSendRequest({"out", text})
		write(text)
	end,
	printText = function(text)
		if (text) then
			commsSendRequest({"out", text .. "\n"})
			print(text)
		else
			commsSendRequest({"out", "\n"})
			print()
		end
	end,
	setColor = function(color)
		commsSendRequest({"setColor", color})
		term.setTextColor(color)
	end,
	goLine = function(pos1, pos2)
		commsSendRequest({"goLine", pos1, pos2})
		term.setCursorPos(pos1, pos2)
	end,
	clearLine = function()
		commsSendRequest({"clearLine", 0})
		term.clearLine()
	end,
	clearAll = function()
		commsSendRequest({"clearAll", 0})
		term.clear()
	end,
	setBackground = function(color)
		commsSendRequest({"setBackground", color})
		term.setBackgroundColor(color)
	end
}

function getClickInput()
	local x = 0
	local y = 0
	parallel.waitForAny(
		function()
			_, _, x, y = os.pullEvent("mouse_click")
		end,
		function()
			commsSendRequest({"in", 2})
			while true do
				event, side, channel, replyChannel, data, distance = os.pullEvent("modem_message")
				if (channel == 65531) then
					x = data[1]
					y = data[2]
					break
				end
			end
		end,
		function()
			while true do
				if (resetMenu) then
					resetMenu = false
					x = 8
					y = 14
					return
				end
				sleep(0.05)
			end
		end
	)
	return x, y
end

function getTextInput()
	local input = ""
	parallel.waitForAny(
		function()
			input = read()
		end,
		function()
			commsSendRequest({"in", 1})
			while true do
				event, side, channel, replyChannel, data, distance = os.pullEvent("modem_message")
				if (channel == 65531) then
					input = data
					break
				end
			end
		end
	)
	return input
end

function typing(x, y, minimumChars, charLimit, charLevel, capitalize)
	local startPos = (51 * y) + x - 51
	local pos = startPos
	local length = 0
	local input = ""
	if (charLimit < 500) then
		comms.goLine(x, y)
		comms.writeText(string.rep("_", charLimit))
	end
	parallel.waitForAny(
		function()
			while true do
				local _, chr = os.pullEvent("keyEvent")
				if (chr == "ent") then
					if (#input >= minimumChars) then
						return
					end
				elseif (chr == "del") then
					if (pos > startPos) then
						length = length - 1
					end
					pos = math.max((pos - 1), startPos)
					comms.goLine((((pos - 1) % 51) + 1), (math.ceil(pos / 51)))
					if (charLimit < 500) then
						comms.writeText("_")
					else
						comms.writeText(" ")
					end
					input = string.sub(input, 1, length)
				else
					if (chr ~= "" and length < charLimit) then
						comms.goLine((((pos - 1) % 51) + 1), (math.ceil(pos / 51)))
						if (capitalize) then
							comms.writeText(string.upper(chr))
							input = input .. string.upper(chr)
						else
							comms.writeText(chr)
							input = input .. chr
						end
						pos = pos + 1
						length = length + 1
					end
				end
			end
		end,
		function()
			while true do
				local event, key, is_held = os.pullEvent()
				if (event == "key") then
					local keyName = keys.getName(key)
					if (isShiftPressed and keyTable["shift" .. keyName] and charLevel >= keyTable["shift" .. keyName][2]) then
						os.queueEvent("keyEvent", keyTable["shift" .. keyName][1])
					elseif (keyTable[keyName] and charLevel >= keyTable[keyName][2]) then
						os.queueEvent("keyEvent", keyTable[keyName][1])
					elseif (keyName == 'leftShift' or keyName == 'rightShift') then
						isShiftPressed = true
					end
				elseif (event == "key_up") then
					local keyName = keys.getName(key)
					if (keyName == 'leftShift' or keyName == 'rightShift') then
						isShiftPressed = false
					end
				end
			end
		end
	)
	return input
end

function makeKitBackup()
	for _, _ in pairs(kitData) do
		local file = fs.open("kitsall.txt", "w")
		file.write(textutils.serialize(kitData))
		file.close()
		return
	end
end

function readKits()
	kitData = {}
	local kitDataEmpty = true
	if (fs.exists("Kits/")) then
		fileNames = fs.list("Kits/")
		for i = 1, #fileNames do
			local file = fs.open("Kits/" .. fileNames[i], "r")
			local tempData = textutils.unserialize(file.readAll())
			kitData[tempData[1]] = tempData
			file.close()
			kitDataEmpty = false
		end
	end
	if (kitDataEmpty) then
		if (fs.exists("kitsall.txt")) then
			fs.makeDir("Kits")
			local file = fs.open("kitsall.txt", "r")
			kitData = textutils.unserialize(file.readAll())
			file.close()
			for key, value in pairs(kitData) do
				local file = fs.open("Kits/" .. kitData[key][1] .. ".txt", "w")
				file.write(textutils.serialize(kitData[key]))
				file.close()
			end	
		end
	end
	if (not fs.exists("kitsall.txt")) then
		makeKitBackup()
	end
end

function applyKit(kitName, destination)
	if (kitData[kitName]) then
		local cmdParallel = {}
		for i = 2, #kitData[kitName] do
			if (string.sub(kitData[kitName][i][2], 1, 15) ~= "pointblank:ammo") then
				cmdParallel[#cmdParallel + 1] = function()
					local success, output = commands.exec("item replace entity " .. destination .. " " .. kitData[kitName][i][1] .. " with " .. kitData[kitName][i][2] .. " " .. tostring(kitData[kitName][i][3]))
				end
			end
		end
		parallel.waitForAll(table.unpack(cmdParallel))
	end
end

function teamMenu()
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.cyan)
	comms.setBackground(colors.black)
	comms.writeText("Enter the name of ")
	comms.setColor(colors.black)
	comms.setBackground(colors.red)
	comms.writeText("[Team1]")
	comms.setColor(colors.cyan)
	comms.setBackground(colors.black)
	comms.printText("...")
	comms.setColor(colors.red)
	local team1 = typing(1, 2, 4, 4, 1, true)
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.cyan)
	comms.setBackground(colors.black)
	comms.writeText("Enter the name of ")
	comms.setColor(colors.black)
	comms.setBackground(colors.blue)
	comms.writeText("[Team2]")
	comms.setColor(colors.cyan)
	comms.setBackground(colors.black)
	comms.printText("...")
	comms.setColor(colors.blue)
	local team2 = typing(1, 2, 4, 4, 1, true)
	set.team1 = team1
	set.team2 = team2
end

function setupTeams()
	local file = fs.open("Data/spawns.txt", "r")
	spawns = textutils.unserialize(file.readAll())
	file.close()
	local file = fs.open("Data/caps.txt", "r")
	caps = textutils.unserialize(file.readAll())
	file.close()
	if (spawns[1] ~= "0 65 0") then
		comms.goLine(1, 5)
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("There are spawns already saved, proceed how?")
		comms.setColor(colors.cyan)
		comms.printText('\4 Use Saved Spawns')
		comms.setColor(colors.red)
		comms.printText('\4 Pick New Spawns')
		repeat
			x, y = getClickInput()
		until (y == 6 or y == 7)
		if (y == 7) then
			spawns = {"0 65 0", "0 65 0", "0 65 0"}
		end
	end
	if (#caps > 0) then
		comms.goLine(1, 5)
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.clearLine()
		comms.printText("There are caps already saved, proceed how?")
		comms.setColor(colors.cyan)
		comms.clearLine()
		comms.printText('\4 Restore Saved Caps')
		comms.setColor(colors.red)
		comms.clearLine()
		comms.printText('\4 Reset Caps')
		repeat
			x, y = getClickInput()
		until (y == 6 or y == 7)
		if (y == 7) then
			caps = {}
		else
			clearCaps()
		end
	end
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.white)
	comms.printText("Creating Teams...")
	parallel.waitForAll(
		function() commands.exec("team add " .. set.team1) end,
		function() commands.exec("team add " .. set.team2) end,
		function() commands.exec("team modify " .. set.team1 .. " color red") end,
		function() commands.exec("team modify " .. set.team2 .. " color blue") end,
		function() commands.exec("bossbar set event:main players @a") end,
		function() commands.exec("bossbar set event:main value 100") end,
		function() commands.exec("bossbar set event:main color purple") end,
		function() commands.exec("bossbar set event:main style notched_10") end,
		function() commands.exec("tag " .. set.team1 .. " add " .. set.team1) end,
		function() commands.exec("tag " .. set.team2 .. " add " .. set.team2) end,
		function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
		function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end,
		function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver2 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..18] add ' .. set.team2 .. '",auto:1b}') end,
		function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver1 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..18] add ' .. set.team1 .. '",auto:1b}') end,
		function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover2 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..19] remove ' .. set.team1 .. '",auto:1b}') end,
		function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover1 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..19] remove ' .. set.team2 .. '",auto:1b}') end,
		function() commands.exec('team modify ' .. set.team1 .. ' friendlyFire false') end,
		function() commands.exec('team modify ' .. set.team2 .. ' friendlyFire false') end,
		function() commands.exec('team modify ' .. set.team1 .. ' nametagVisibility hideForOtherTeams') end,
		function() commands.exec('team modify ' .. set.team2 .. ' nametagVisibility hideForOtherTeams') end
	)
end

function setup()
	ALL_CHAT_COMMANDS = string.gsub(ALL_CHAT_COMMANDS, "\n", "\\n")
	ALL_CHAT_COMMANDS = string.gsub(ALL_CHAT_COMMANDS, ">", "")
	ALL_CHAT_COMMANDS = string.gsub(ALL_CHAT_COMMANDS, "## Send these in chat to communicate with the computer.\\n", "")
	ALL_CHAT_COMMANDS = string.gsub(ALL_CHAT_COMMANDS, "\\n# The following are chat commands related to recruits.\\n", "")
	ALL_CHAT_COMMANDS = string.gsub(ALL_CHAT_COMMANDS, "# The following are chat commands.\\n", "")
	local success, output = commands.exec("data get block ~ ~ ~")
	ComX, ComY, ComZ = string.match(output[1], ("(-?%d+), (-?%d+), (-?%d+)"))
	positions = {
		Skepsis = {
			worldspawn = relativePos(8, -1, 0),
			tagRemover2 = relativePos(19, 0, 35),
			tagRemover1 = relativePos(19, 0, -35),
			tagGiver2 = relativePos(19, 1, 35),
			tagGiver1 = relativePos(19, 1, -35),
			under = relativePos(0, -1, 0),
			team1Door = relativePos(18, -1, -19) .. ' ' .. relativePos(20, 1, -19),
			team2Door = relativePos(18, -1, 19) .. ' ' .. relativePos(20, 1, 19),
			spawnBoxWalls = relativePos(19, 9, 2) .. ' ' .. relativePos(25, 13, 8), 
			spawnBoxRoof = relativePos(20, 13, 3) .. ' ' .. relativePos(24, 13, 7),
			invisCommand = relativePos(22, 8, 5),
			deathSpawn = relativePos(22, 10, 5),
			team1Room = relativePos(19, -1, -26),
			team2Room = relativePos(19, -1, 26),
			infrontComputer = relativePos(-1, -1, 0)
		},
		Mevills = {
			worldspawn = relativePos(0, 2, 0),
			tagRemover2 = relativePos(0, 2, 36),
			tagRemover1 = relativePos(0, 2, -36),
			tagGiver2 = relativePos(0, 3, 36),
			tagGiver1 = relativePos(0, 3, -36),
			under = relativePos(0, -1, 0),
			team1Door = relativePos(-1, 2, -21) .. ' ' .. relativePos(1, 4, -21),
			team2Door = relativePos(-1, 2, 21) .. ' ' .. relativePos(1, 4, 21),
			spawnBoxWalls = relativePos(22, 2, 2) .. ' ' .. relativePos(28, 10, 8),
			spawnBoxRoof = relativePos(23, 10, 3) .. ' ' .. relativePos(27, 10, 7),
			invisCommand = relativePos(25, 1, 5),
			deathSpawn = relativePos(25, 3, 5),
			team1Room = relativePos(0, 2, -26),
			team2Room = relativePos(0, 2, 26),
			infrontComputer = relativePos(-1, -1, 0)
		}
	}
	commsSendRequest({"in", 0})
	comms.printText("Starting...")
	if (not readFiles() or not set.gameSetup) then
		local cmdParallel = {}
		local tagList = {}
		for key, value in pairs(kitData) do
			tagList[string.sub(key, 6, #key)] = true
		end
		for key, value in pairs(tagList) do
			cmdParallel[#cmdParallel + 1] = function()
				commands.exec("tag @a remove " .. key)
			end
		end
		parallel.waitForAll(
			function() parallel.waitForAll(table.unpack(cmdParallel)) end,
			function() commands.exec("scoreboard objectives remove spawns") end,
			function() commands.exec('bossbar remove event:main') end,
			function() commands.exec('scoreboard objectives add spawns dummy "Team Points"') end,
			function() commands.exec('bossbar add event:main {"text":"Event Starting Soon...","color":"dark_purple","bold":true}') end,
			function() commands.exec('scoreboard objectives add Team dummy "Team"') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover2 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover1 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver2 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver1 .. ' minecraft:air') end,
			function() commands.exec('fill ' .. positions[set.lobbyName].team2Door .. ' minecraft:air') end,
			function() commands.exec('fill ' .. positions[set.lobbyName].team1Door .. ' minecraft:air') end,
			function() commands.exec("gamerule spawnRadius 0") end,
			function() commands.exec("defaultgamemode adventure") end,
			function() commands.exec('fill ' .. positions[set.lobbyName].spawnBoxWalls .. ' minecraft:black_concrete hollow') end,
			function() commands.exec('fill ' .. positions[set.lobbyName].spawnBoxRoof .. ' s_a_b:blakclightsteelslab') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].invisCommand .. ' minecraft:repeating_command_block{Command:"effect give @a[distance=..4,gamemode=survival] minecraft:invisibility 1 255 true",auto:1b}') end,
			function() commands.exec('setworldspawn ' .. positions[set.lobbyName].worldspawn) end,
			function() commands.exec('spawnpoint @a ' .. positions[set.lobbyName].worldspawn) end,
			function() commands.exec("gamerule keepInventory true") end,
			function() commands.exec("gamerule doTraderSpawning false") end,
			function() commands.exec("gamerule doWeatherCycle false") end,
			function() commands.exec("gamerule doDaylightCycle false") end,
			function() commands.exec("gamerule doMobSpawning false") end,
			function() commands.exec("gamerule doTileDrops false") end,
			function() commands.exec("gamerule pvp false") end,
			function() commands.exec("gamerule doImmediateRespawn true") end,
			function() commands.exec("attribute @a minecraft:generic.max_health base set 20") end
		)
		--local success, output = commands.exec("team modify lobby friendlyFire false")
		teamMenu()
		setupTeams()
		set.gameSetup = true
		save()
	end
end

function doMainMenu()
	local option4LastTime = 0
	function menuOption(str, color)
		comms.setBackground(colors.gray)
		comms.setColor(colors.black)
		comms.writeText("|?|")
		comms.setBackground(colors.black)
		comms.setColor(color)
		comms.printText(str)
	end
	while true do
		comms.clearAll()
		commsSendRequest({"in", 0})
		comms.goLine(1, 1)
		comms.setColor(colors.lightGray)
		comms.printText("    Control Panel")
		comms.setColor(colors.black)
		comms.setBackground(colors.red)
		comms.writeText(" " .. set.team1 .. " ")
		comms.setBackground(colors.black)
		comms.setColor(colors.lightGray)
		comms.writeText("   vs.   ")
		comms.setColor(colors.black)
		comms.setBackground(colors.blue)
		comms.printText(" " .. set.team2 .. " ")
		comms.goLine(1, 3)
		comms.setColor(colors.gray)
		comms.setBackground(colors.black)
		comms.printText("\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\132")
		comms.printText(" \131\131\131\131\131\131\131\131\131\131\131\131\131\131\131\131\131\131\129")
		comms.goLine(1, 5)
		if (set.gameBegun) then
			menuOption(" \4 End Respawns", colors.lightBlue)
		elseif (set.kitsGivenOut) then
			menuOption(" \4 Start Game", colors.lightBlue)
		elseif (set.spawnsLocked) then
			menuOption(" \4 Give Kits", colors.lightBlue)
		else
			menuOption(" \4 Lock Teams", colors.lightBlue)
		end
		menuOption(" \4 Checklist", colors.yellow)
		menuOption(" \4 Check Players", colors.yellow)
		menuOption(" \4 Event Settings", colors.yellow)
		menuOption(" \4 Manage Kits", colors.yellow)
		menuOption(" \4 Manage Mods", colors.orange)
		menuOption(" \4 Automatic Building", colors.orange)
		menuOption(" \4 Tech Support", colors.orange)
		menuOption(" \4 Reset Event System", colors.red)
		comms.goLine(1, 17)
		comms.setColor(colors.gray)
		comms.writeText("v" .. version .. "\nEvent System by Mevill")
		local input = 0
		local helpMode = false
		while (input < 1 or input > 10) do
			x, y = getClickInput()
			if (updatePause) then
				repeat 
					sleep(0.05)
				until (not updatePause)
				input = 10
			else
				input = y - 4
				if (x < 4) then
					helpMode = true
				end
			end
		end
		if (helpMode) then
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.black)
			comms.setBackground(colors.gray)
			comms.writeText('< RETURN ')
			comms.setBackground(colors.black)
			comms.setColor(colors.cyan)
			if (input == 1) then
				if (set.gameBegun) then
					input = 4
				elseif (set.kitsGivenOut) then
					input = 3
				elseif (set.spawnsLocked) then
					input = 2
				else
					input = 1
				end
				comms.printText("  How to use: " .. helpData[1][input][1] .. "\n")
				comms.setColor(colors.white)
				comms.printText(helpData[1][input][2])
			else
				comms.printText("  How to use: " .. helpData[input][1] .. "\n")
				comms.setColor(colors.white)
				comms.printText(helpData[input][2])
			end
			while true do
				x, y = getClickInput()
				if (y == 1 and x < 10) then
					break
				end
			end
		else
			if (input == 1 and (os.epoch("utc") - option4LastTime) > 500) then
				if (set.gameBegun) then
					if (not set.respawnsDisabled) then
						set.respawnsDisabled = true
						commands.exec('title @a actionbar {"bold":true,"color":"red","text":"NO MORE RESPAWNS!"}')
					end
				elseif (set.kitsGivenOut) then
					startGame()
				elseif (set.spawnsLocked) then
					kitAll()
				else
					lockSpawns()
				end
				save()
				option4LastTime = os.epoch("utc")
			elseif (input == 2) then
				checklistMenu()
			elseif (input == 3) then
				comms.clearAll()
				comms.goLine(4, 4)
				comms.setBackground(colors.black)
				comms.setColor(colors.cyan)
				comms.printText("\248 Loading Players...")
				getUsers()
				playerMenu()
				save()
			elseif (input == 4) then
				settingsMenu()
			elseif (input == 5) then
				kitsMenu()
			elseif (input == 6) then
				modsMenu()
			elseif (input == 7) then
				autoGenMenu()
			elseif (input == 8) then
				techSupportMenu()
			elseif (input == 9) then
				restartMenu()
			end
		end
	end
end

function checklistMenu()
	local function displayItem(name, bool)
		if (bool) then
			comms.setColor(colors.green)
			comms.writeText("\2")
		else
			comms.setColor(colors.red)
			comms.writeText("X")
		end
		comms.setColor(colors.gray)
		comms.printText(name)
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< RETURN ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Event Setup Checklist:\n")
		comms.setColor(colors.cyan)
		comms.printText("*Note, this list isn't fully accurate, and doesn't cover everything you need for a proper event.")
		local isKits = true
		for i = 1, #loggedUsers do
			if (not kitData[loggedUsers[i][3] .. "_" .. loggedUsers[i][2]]) then
				isKits = false
			end
		end
		displayItem("Setup event system", true)
		displayItem("Created kits for all used classes", isKits)
		displayItem("Spawns set for all teams and spectators", spawns[1] ~= "0 65 0" and spawns[2] ~= "0 65 0" and spawns[3] ~= "0 65 0")
		if (set.teamTicketType == 2) then
			displayItem("Capture points created", #caps > 0)
		end
		displayItem("Locked spawns", set.spawnsLocked)
		displayItem("Kits given out to players", set.kitsGivenOut)
		displayItem("Players brought to main map", set.gameBegun)
		displayItem("Game officially started", set.go)
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			return
		end
	end
end

function generateBuilding(pos1, pos2)
	-- Setup
	local plotXSize = math.abs(pos1[1] - pos2[1]) + 1
	local plotZSize = math.abs(pos1[3] - pos2[3]) + 1
	local offsetX = math.random(2, 3)
	local offsetZ = 3
	local xWidth = 0
	local zWidth = 0
	local rooms = {}
	local cmdParallel = {}
	local palette = {
		["door"] = 0,
		["floor"] = 0,
		["ceiling"] = 0,
		["window"] = 0,
		["wallpaper"] = 0,
		["walls"] = 0,
		["lighting"] = 0,
		["bottomDetail"] = 0,
		["innerBottomDetail"] = 0,
		["roof"] = 0
	}
	for key, _ in pairs(palette) do
		palette[key] = palettes[key][math.random(1, #palettes[key])]
	end
	local buildingSchem = {}
	for x = 1, plotXSize do
		buildingSchem[x] = {}
		for z = 1, plotZSize do
			buildingSchem[x][z] = {0}
		end
 	end
	local anchor = pos1 -- change later
	anchor[2] = math.ceil((pos1[2] + pos2[2]) / 2)
	local colorLookup = {colors.orange, colors.red, colors.lightBlue, colors.lime, colors.green, colors.brown}
	
	-- Generation Functions
	local function writeAt(posX, posY, posZ, color, more)
		monitor.setCursorPos((posX * 2) - 1, plotZSize - posZ + 2)
		monitor.setBackgroundColor(colorLookup[color])
		monitor.write("[]")
		monitor.setBackgroundColor(colors.black)
		buildingSchem[posX][posZ][1] = color
		if (more) then
			buildingSchem[posX][posZ][2] = more
		end		
	end
	local function fillSection(pos1, pos2, block)
		cmdParallel[#cmdParallel + 1] = function()
			commands.exec("fill " .. tostring(pos1[1] - 1 + anchor[1]) .. " " .. tostring(anchor[2] + pos1[2]) .. " " .. tostring(anchor[3] + 1 - pos1[3]) .. " " .. tostring(pos2[1] - 1 + anchor[1]) .. " " .. tostring(anchor[2] + pos2[2]) .. " " .. tostring(anchor[3] + 1 - pos2[3]) .. " " .. block)
		end
	end
	local function randomWallBlock()
		local randNum = math.random(1, 100)
		if (randNum <= 35) then
			return palette.walls[1]
		elseif (randNum <= 70) then
			return palette.walls[2]
		elseif (randNum <= 90) then
			return palette.walls[3]
		else
			return palette.walls[4]
		end
	end
	local function getDistanceEdge(x, z)
		local xDist1 = x - offsetX + 1
		local zDist1 = z - offsetZ + 1
		local xDist2 = offsetX + xWidth - 1 - x + 1
		local zDist2 = offsetZ + zWidth - 1 - z + 1
		return math.min(math.abs(xDist1), math.abs(zDist1), math.abs(xDist2), math.abs(zDist2))
	end
	local function fillAt(relX, relY, relZ, block)
		commands.exec("setblock " .. tostring(relX - 1 + anchor[1]) .. " " .. tostring(anchor[2] + relY) .. " " .. tostring(anchor[3] + 1 - relZ) .. " " .. block)
	end
	
	-- Setup
	monitor.setCursorPos(1, 1)
	monitor.clear()
	monitor.setTextScale(0.5)
	monitor.setTextColor(colors.gray)
	monitor.setBackgroundColor(colors.black)
	monitor.write("Size " .. tostring(plotXSize) .. "x" .. tostring(plotZSize) .. "\n")
	monitor.setCursorPos(1, 2)
	-- Drawing plot
	for z = 1, plotZSize do
		monitor.setBackgroundColor(colors.lightBlue)
		for x = 1, plotXSize do
			monitor.write("[]")
		end
		monitor.setBackgroundColor(colors.black)
		monitor.setCursorPos(1, z + 2)
	end
	-- Logging and drawing all of the rooms
	for x = 1, math.floor((plotXSize - 4) / 4) do
		rooms[x] = {}
		for z = 1, math.floor((plotZSize - 4) / 4) do
			rooms[x][z] = 0
			local xCenter = (((x - 1) * 4) + offsetX + 2)
			local zCenter = (((z - 1) * 4) + offsetZ + 2)
			--fillSection({xCenter - 2, -1, zCenter - 2}, {xCenter + 2, 4, zCenter + 2}, "minecraft:gold_block outline")
			for z = (zCenter  - 2), (zCenter  + 2) do
				writeAt((xCenter - 2), 0, z, 2)
				writeAt((xCenter + 2), 0, z, 2)
			end
			for x = (xCenter - 2), (xCenter + 2) do
				writeAt(x, 0, (zCenter - 2), 2)
				writeAt(x, 0, (zCenter + 2), 2)
			end
		end
	end
	xWidth = ((#rooms - 1) * 4) + 5
	zWidth = ((#rooms[1] - 1) * 4) + 5
	for z = offsetZ, offsetZ + zWidth - 1 do
		if ((z - offsetZ - 2) % 4 == 0) then
			writeAt(offsetX, 0, z, 6)
			writeAt(offsetX + xWidth - 1, 0, z, 6)
		else
			writeAt(offsetX, 0, z, 1)
			writeAt(offsetX + xWidth - 1, 0, z, 1)
		end
	end
	for x = offsetX, offsetX + xWidth - 1 do
		if ((x - offsetX - 2) % 4 == 0) then
			writeAt(x, 0, offsetZ, 6)
			writeAt(x, 0, offsetZ + zWidth - 1, 6)	
		else
			writeAt(x, 0, offsetZ, 1)
			writeAt(x, 0, offsetZ + zWidth - 1, 1)
		end
	end
	fillSection({offsetX, -1, offsetZ}, {(((#rooms - 1) * 4) + offsetX + 4), -1, offsetZ + zWidth - 1}, palette.floor)
	fillSection({offsetX + 1, 4, offsetZ + 1}, {(((#rooms - 1) * 4) + offsetX + 3), 4, offsetZ + zWidth - 1}, palette.ceiling)
	fillSection({offsetX + 1, 0, offsetZ + 1}, {(((#rooms - 1) * 4) + offsetX + 3), 3, offsetZ + zWidth - 1}, palette.lighting)
	
	-- Adding door offshoot codes to the rooms table
	local frontDoorX = math.random(1, #rooms)
	rooms[frontDoorX][1] = 2
	writeAt((((frontDoorX - 1) * 4) + offsetX + 2), 0, offsetZ, 5, "north")
	--fillSection({(((frontDoorX - 1) * 4) + offsetX + 2), 0, offsetZ}, {(((frontDoorX - 1) * 4) + offsetX + 2), 1, offsetZ}, palette.air)
	if (rooms[frontDoorX][2]) then
		rooms[frontDoorX][2] = 1
	end
	if (rooms[frontDoorX - 1]) then
		rooms[frontDoorX - 1][1] = 1
	end
	if (rooms[frontDoorX + 1]) then
		rooms[frontDoorX + 1][1] = 1
	end
	-- Looping through all rooms, connecting them to another room with a door
	for i = 1, ((#rooms * #rooms[1]) - 1) do
		local foundPos = false
		for j = 1, #rooms do
			for k = 1, #rooms[j] do
				if (rooms[j][k] == 1) then
					foundPos = {j, k}
					break
				end
			end
			if (foundPos) then
				break
			end
		end
		-- Setting surrounding rooms to checked next
		if (rooms[foundPos[1] + 1] and rooms[foundPos[1] + 1][foundPos[2]] == 0) then
			rooms[foundPos[1] + 1][foundPos[2]] = 1
		end
		if (rooms[foundPos[1] - 1] and rooms[foundPos[1] - 1][foundPos[2]] == 0) then
			rooms[foundPos[1] - 1][foundPos[2]] = 1
		end
		if (rooms[foundPos[1]] and rooms[foundPos[1]][foundPos[2] + 1] == 0) then
			rooms[foundPos[1]][foundPos[2] + 1] = 1
		end
		if (rooms[foundPos[1]] and rooms[foundPos[1]][foundPos[2] - 1] == 0) then
			rooms[foundPos[1]][foundPos[2] - 1] = 1
		end
		-- Checking for surrounding rooms to connect a door to
		rooms[foundPos[1]][foundPos[2]] = 2
		local filled = {false, false, false, false}
		local guess
		if (rooms[foundPos[1] + 1] and rooms[foundPos[1] + 1][foundPos[2]] == 2) then
			filled[1] = true
		end
		if (rooms[foundPos[1] - 1] and rooms[foundPos[1] - 1][foundPos[2]] == 2) then
			filled[2] = true
		end
		if (rooms[foundPos[1]] and rooms[foundPos[1]][foundPos[2] + 1] == 2) then
			filled[3] = true
		end
		if (rooms[foundPos[1]] and rooms[foundPos[1]][foundPos[2] - 1] == 2) then
			filled[4] = true
		end
		-- Punch a door to another room
		repeat
			guess = math.random(1, 4)
		until (filled[guess])
		local roomPos = {(((foundPos[1] - 1) * 4) + offsetX + 2), (((foundPos[2] - 1) * 4) + offsetZ + 2)}
		if (guess == 1) then -- x + 1
			if (math.random(1, 2) == 1) then
				writeAt(roomPos[1] + 2, 0, roomPos[2] + 1, 3)
				writeAt(roomPos[1] + 2, 0, roomPos[2] - 1, 3)
				writeAt(roomPos[1] + 2, 0, roomPos[2], 3)
			else
				writeAt(roomPos[1] + 2, 0, roomPos[2], 4, "west")
			end
		elseif (guess == 2) then -- x - 1
			if (math.random(1, 2) == 1) then
				writeAt(roomPos[1] - 2, 0, roomPos[2] + 1, 3)
				writeAt(roomPos[1] - 2, 0, roomPos[2] - 1, 3)
				writeAt(roomPos[1] - 2, 0, roomPos[2], 3)
			else
				writeAt(roomPos[1] - 2, 0, roomPos[2], 4, "east")
			end
		elseif (guess == 3) then -- z + 1
			if (math.random(1, 2) == 1) then
				writeAt(roomPos[1] + 1, 0, roomPos[2] + 2, 3)
				writeAt(roomPos[1] - 1, 0, roomPos[2] + 2, 3)
				writeAt(roomPos[1], 0, roomPos[2] + 2, 3)
			else
				writeAt(roomPos[1], 0, roomPos[2] + 2, 4, "south")
			end
		else -- z - 1
			if (math.random(1, 2) == 1) then
				writeAt(roomPos[1] + 1, 0, roomPos[2] - 2, 3)
				writeAt(roomPos[1] - 1, 0, roomPos[2] - 2, 3)
				writeAt(roomPos[1], 0, roomPos[2] - 2, 3)
			else
				writeAt(roomPos[1], 0, roomPos[2] - 2, 4, "north")
			end
		end
	end
	local generationTypes = {
		[1] = function(x, z)
			fillAt(x, 0, z, palette.bottomDetail[math.random(1, 2)])
			for y = 1, 4 do
				fillAt(x, y, z, randomWallBlock())
			end
		end,
		[3] = function(x, y)
		
		end,
		[2] = function(x, z)
			fillAt(x, 0, z, palette.innerBottomDetail[math.random(1, 2)])
			for y = 1, 3 do
				fillAt(x, y, z, palette.wallpaper)
			end
		end,
		[4] = function(x, z, more)
			fillAt(x, 0, z, palette.door .. "[half=lower,facing=" .. more .. "]")
			fillAt(x, 1, z, palette.door .. "[half=upper,facing=" .. more .. "]")
			for y = 2, 3 do
				fillAt(x, y, z, palette.wallpaper)
			end
		end,
		[5] = function(x, z, more)
			fillAt(x, 0, z, palette.door .. "[half=lower,facing=" .. more .. "]")
			fillAt(x, 1, z, palette.door .. "[half=upper,facing=" .. more .. "]")
			for y = 2, 4 do
				fillAt(x, y, z, randomWallBlock())
			end
		end,
		[6] = function(x, z)
			fillAt(x, 0, z, palette.bottomDetail[math.random(1, 2)])
			for y = 1, 2 do
				fillAt(x, y, z, palette.window)
			end
			for y = 3, 4 do
				fillAt(x, y, z, randomWallBlock())
			end
		end
	}
	local posY = 1
	for x = 1, plotXSize do
		for z = 1, plotZSize do
			local plotID = buildingSchem[x][z][1]
			cmdParallel[#cmdParallel + 1] = function()
				if (plotID > 0) then
					generationTypes[plotID](x, z, buildingSchem[x][z][2])
				end
				if (x >= (offsetX - 1) and z >= (offsetZ - 1) and x <= (offsetX + xWidth) and z <= (offsetZ + zWidth)) then
					local roofHeight = 4 + (getDistanceEdge(x, z) / 2)
					if (math.floor(roofHeight) == roofHeight) then
						fillAt(x, roofHeight, z, palette.roof[math.random(1, 2)] .. "[type=bottom]")
					else
						fillAt(x, math.floor(roofHeight), z, palette.roof[math.random(1, 2)] .. "[type=top]")
					end
				end
			end
		end
	end
	parallel.waitForAll(table.unpack(cmdParallel))
end

function autoGenMenu()
	if (publicBuild) then
		return
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< RETURN ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Automatic Building System:\n")
		generateBuilding({-68, 56 ,-9}, {-49, 56, -24})
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			return
		elseif (false) then
		
		end
	end
end

function modsMenu()
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< RETURN ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Active Modifications:\n")
		if (#addonMetaData == 0) then
			comms.setColor(colors.red)
			comms.printText("There seem to be no logged mods, did you install them correctly? Are they named and formatted correctly? Press ENTER to return to the main menu.")
			getTextInput()
			return
		else
			comms.setColor(colors.cyan)
			for i = 1, #addonMetaData do
				comms.printText("\4 " .. addonMetaData[i][1])
			end
		end
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			return
		elseif (y >= 3 and y < (#addonMetaData + 3)) then
			local modData = addonMetaData[y - 2]
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.black)
			comms.setBackground(colors.gray)
			comms.writeText('< RETURN ')
			comms.setColor(colors.white)
			comms.setBackground(colors.black)
			comms.printText('  Modification ' .. modData[1] .. ':\n')
			comms.setColor(colors.cyan)
			comms.printText("Mod Meta Data:")
			comms.setColor(colors.orange)
			comms.printText(modData[2])
			while true do
				local x, y = getClickInput()
				if (y == 1 and x < 10) then
					break
				end
			end
		end
	end
end

function techSupportMenu()
	local discordMessage = ""
	parallel.waitForAny(
		function()
			while true do
				if (discordMessage ~= "") then
					sendToDiscord(discordMessage)
					discordMessage = ""
				end
				sleep(0.05)
			end
		end,
		function()
			local function writeMessage(chatPerson, message)
				comms.setColor(colors.gray)
				comms.writeText("<" .. chatPerson .. "> ")
				if (chatPerson == "You") then
					comms.setColor(colors.cyan)
					comms.printText(message .. "\n")
				else
					comms.setColor(colors.red)
					comms.printText(message .. "\n")
				end
			end
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.orange)
			comms.setBackground(colors.black)
			comms.printText("This is the event system's tech support, press ENTER to return to the main menu.\n")
			discordMessage = "# Help Request\n **User has opened a chat.**"
			writeMessage("Mukesh", "Hello, I'm Mukesh, how may I help?")
			local input = ""
			while true do
				comms.setColor(colors.blue)
				comms.writeText("Respond ")
				comms.setColor(colors.white)
				input = getTextInput()
				if (input == "") then
					return
				end
				local x,y = term.getCursorPos()
				comms.goLine(1, y - 1)
				comms.clearLine()
				writeMessage("You", input)
				discordMessage = "||<@662784633649496064>|| **User says:** `" .. input .. "`"
			end
		end
	)
end

local settingFunctions = {
	[1] = function(passData)
		set.recruitsActive = not set.recruitsActive
		return 2
	end,
	[2] = function(passData)
		set.maxHealth = math.max(1, math.min(20, passData))
		parallel.waitForAll(
			function() commands.exec("execute as @a run attribute @s minecraft:generic.max_health base set " .. set.maxHealth) end,
			function() commands.exec("execute as @a run effect give @s minecraft:instant_health 1 1 true") end
		)
		return 1
	end,
	[3] = function(passData)
		set.ammoAmount = math.max(1, math.min(512, passData))
		return 1
	end,
	[4] = function(passData)
		set.team1Tickets = math.max(1, math.min(1000, passData))
		parallel.waitForAll(
			function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
			function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end
		)
		return 1
	end,
	[5] = function(passData)
		set.team2Tickets = math.max(1, math.min(1000, passData))
		parallel.waitForAll(
			function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
			function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end
		)
		return 1
	end,
	[6] = function(passData)
		set.recruitTicketCost = math.max(0, math.min(100, passData))
		return 1
	end,
	[7] = function(passData)
		set.teamTicketType = ((set.teamTicketType) % 3) + 1
		editBossbar(2)
		return 1
	end,
	[8] = function(passData)
		set.useArtillery = not set.useArtillery
		return 2
	end,
	[9] = function(passData)
		set.bandageAmount = math.max(1, math.min(64, passData))
		return 1
	end,
	[10] = function(passData)
		variableMenu()
		return 1
	end,
	[11] = function(passData)
		capMenu()
		return 1
	end,
	[12] = function(passData)
		set.showProTips = not set.showProTips
		return 2
	end,
	[13] = function(passData)
		return 2
	end,
	[14] = function(passData)
		set.miningFatigue = math.max(1, math.min(255, passData))
		return 2
	end,
	[15] = function(passData)
		set.slowness = math.max(1, math.min(255, passData))
		return 2
	end,
	[16] = function(passData)
		set.capDistance = math.max(1, math.min(50, passData))
		return 2
	end,
	[17] = function(passData)
		return 3
	end,
	[18] = function(passData)
		set.spareParts.allow = not set.spareParts.allow
		return 3
	end,
	[19] = function(passData)
		set.recruitTicketCost = math.max(0, math.min(50, passData))
		return 3
	end,
	[20] = function(passData)
		set.spareParts["create:gearbox"] = not set.spareParts["create:gearbox"]
		set.spareParts["create_connected:parallel_gearbox"] = set.spareParts["create_connected:parallel_gearbox"]
		return 3
	end,
	[21] = function(passData)
		set.spareParts["create:clutch"] = not set.spareParts["create:clutch"]
		set.spareParts["create_connected:inverted_clutch"] = set.spareParts["create:clutch"]
		return 3
	end,
	[22] = function(passData)
		set.spareParts["create:gearshift"] = not set.spareParts["create:gearshift"]
		set.spareParts["create_connected:inverted_gearshift"] = set.spareParts["create:gearshift"]
		return 3
	end,
	[23] = function(passData)
		set.spareParts["create:encased_chain_drive"] = not set.spareParts["create:encased_chain_drive"]
		return 3
	end,
	[24] = function(passData)
		set.spareParts["create:analog_lever"] = not set.spareParts["create:analog_lever"]
		return 3
	end,
	[25] = function(passData)
		set.spareParts["vs_tournament:seat"] = not set.spareParts["vs_tournament:seat"]
		return 3
	end,
	[26] = function(passData)
		set.roundsLeft = math.max(1, math.min(20, passData))
		return 1
	end,
	[27] = function(passData)
		set.roundSpawnSwap = not set.roundSpawnSwap
		return 1
	end,
	[28] = function(passData)
		set.spawnProtection = not set.spawnProtection
		return 2
	end
}

function settingsMenu()
	local settingsPageID = 1
	local pageNames = {"Settings", "Misc Settings", "Spare Parts System"}
	local options = {}
	local function addOption(optionID, optionType, optionName, data)
		options[#options + 1] = {optionID, optionType, optionName, data}
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< APPLY ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  " .. pageNames[settingsPageID] .. ":\n")
		options = {}
		-- Option format: (referenceID, type, string name, extra data)
		if (settingsPageID == 1) then
			addOption(7, 2, {"Counting Respawns", "Counting Cap Points", "Counting Rounds"}, set.teamTicketType)
			if (set.teamTicketType == 3) then
				addOption(27, 1, "Roundstart Spawn Swap", set.roundSpawnSwap)
			end
			addOption(0, 0, "", 0)
			if (set.teamTicketType == 3) then
				addOption(26, 4, "Rounds Left", set.roundsLeft)
			end
			addOption(2, 4, "Player Hearts", set.maxHealth)
			addOption(3, 4, "Ammo Given", set.ammoAmount)
			addOption(9, 4, "Bandages Given", set.bandageAmount)
			if (set.teamTicketType ~= 3) then
				addOption(4, 4, set.team1 .. " Tickets Amount", set.team1Tickets)
				addOption(5, 4, set.team2 .. " Tickets Amount", set.team2Tickets)
			end
			addOption(6, 4, "Recruit Ticket Cost", set.recruitTicketCost)
			addOption(0, 0, "", 0)
			addOption(10, 3, "Edit Variables", 0)
			addOption(11, 3, "Cap Points", 0)
			addOption(13, 3, "Misc Settings", 0)
			addOption(17, 3, "Spare Parts System", 0)
		elseif (settingsPageID == 2) then
			addOption(1, 1, "Use Recruits Mod", set.recruitsActive)
			addOption(12, 1, "Show Pro-Tips", set.showProTips)
			addOption(8, 1, "Enable Artillery", set.useArtillery)
			addOption(28, 1, "Spawn Camp Protection", set.spawnProtection)
			addOption(0, 0, "", 0)
			addOption(14, 4, "Mining Fatigue Strength", set.miningFatigue)
			addOption(15, 4, "Slowness Strength", set.slowness)
			addOption(16, 4, "Min Distance To Capture", set.capDistance)
		elseif (settingsPageID == 3) then
			addOption(18, 1, "Allow Spare-Parts Purchase", set.spareParts.allow)
			if (set.teamTicketType < 3) then
				addOption(19, 4, "Tickets Per Part", set.spareParts.cost)
			end
			addOption(0, 0, "", 0)
			addOption(20, 1, "Allow Gearbox Purchase", set.spareParts["create:gearbox"] and set.spareParts.allow)
			addOption(21, 1, "Allow Clutch Purchase", set.spareParts["create:clutch"] and set.spareParts.allow)
			addOption(22, 1, "Allow Gearshift Purchase", set.spareParts["create:gearshift"] and set.spareParts.allow)
			addOption(23, 1, "Allow Chain Drive Purchase", set.spareParts["create:encased_chain_drive"] and set.spareParts.allow)
			addOption(24, 1, "Allow Lever Purchase", set.spareParts["create:analog_lever"] and set.spareParts.allow)
			addOption(25, 1, "Allow Seat Purchase", set.spareParts["vs_tournament:seat"] and set.spareParts.allow)
		end
		-- Render Options
		for i = 1, #options do
			if (options[i][2] == 1) then -- Type 1: On/Off
				if (options[i][4]) then
					comms.setBackground(colors.green)
					comms.setColor(colors.black)
					comms.writeText("\127\127")
					comms.setBackground(colors.white)
					comms.setColor(colors.lightGray)
					comms.writeText("[]")
				else
					comms.setBackground(colors.white)
					comms.setColor(colors.lightGray)
					comms.writeText("[]")
					comms.setBackground(colors.red)
					comms.setColor(colors.black)
					comms.writeText("\127\127")
				end
				comms.setBackground(colors.black)
				comms.setColor(colors.yellow)
				comms.printText(" " .. options[i][3])
			elseif (options[i][2] == 2) then -- Type 2: Multiple options
				comms.setColor(colors.lightGray)
				comms.setBackground(colors.white)
				comms.writeText("[<]")
				comms.setBackground(colors.black)
				comms.setColor(colors.lightBlue)
				comms.writeText(" " .. options[i][3][options[i][4]] .. " ")
				comms.setColor(colors.lightGray)
				comms.setBackground(colors.white)
				comms.printText("[>]")
				comms.setBackground(colors.black)
			elseif (options[i][2] == 3) then -- Type 3: Offshoot menu
				comms.setColor(colors.yellow)
				comms.writeText(options[i][3] .. " ")
				comms.setColor(colors.lightGray)
				comms.setBackground(colors.white)
				comms.printText("[\42]")
				comms.setBackground(colors.black)
			elseif (options[i][2] == 4) then -- Type 4: Numerical selection
				comms.setBackground(colors.white)
				comms.setColor(colors.lightGray)
				comms.writeText("[-]")
				comms.setBackground(colors.black)
				comms.setColor(colors.lightBlue)
				comms.writeText(" " .. tostring(options[i][4]) .. " ")
				comms.setBackground(colors.white)
				comms.setColor(colors.lightGray)
				comms.goLine(9, (i + 2))
				comms.writeText("[+]")
				comms.setBackground(colors.black)
				comms.writeText(" ")
				comms.setBackground(colors.white)
				comms.writeText("[#]")
				comms.setBackground(colors.black)
				comms.setColor(colors.yellow)
				comms.printText(" " .. options[i][3])
			else
				comms.setColor(colors.gray)
				comms.printText("\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140\140")
			end
		end
		x, y = getClickInput()
		if (y == 1 and x < 10) then
			save()
			if (settingsPageID == 1) then
				return
			else
				settingsPageID = 1
			end
		elseif (y > 2 and y < (3 + #options)) then
			local settingData = options[(y - 2)]
			local setting = settingData[1]
			local passData = settingData[4]
			if (settingData[2] == 4) then -- Type 4: Numerical selection
				if (x < 4) then
					passData = settingData[4] - 1
				elseif (x > 8 and x < 12) then
					passData = settingData[4] + 1
				elseif (x > 12 and x < 16) then
					comms.setColor(colors.white)
					local input = getTextInput()
					if (tonumber(input)) then
						passData = math.floor(tonumber(input))
					end
				end
			end
			settingsPageID = settingFunctions[setting](passData)
		end
	end
end

function variableMenu()
	local keyList = {}
	local menuPage = 0
	for key, value in pairs(set) do
		keyList[#keyList + 1] = key
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< APPLY ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.writeText("  Edit Main Variables:\n")
		for i = (1 + 10 * (menuPage)), math.min(#keyList, 10 * (menuPage + 1)) do
			if ((i % 2) == 1) then
				comms.setColor(colors.cyan)
			else
				comms.setColor(colors.blue)
			end
			comms.writeText("\n" .. keyList[i])
			comms.setColor(colors.white)
			comms.writeText("=" .. tostring(set[keyList[i]]))
		end
		comms.goLine(1, 14)
		comms.setColor(colors.orange)
		comms.writeText("<<")
		comms.setColor(colors.white)
		comms.writeText("-pg" .. (menuPage + 1) .. "-")
		comms.setColor(colors.orange)
		comms.writeText(">>")
		comms.goLine(1, 1)
		x, y = getClickInput()
		if (y == 1 and x < 10) then
			return
		elseif (y > 2 and y < (math.min(#keyList - (10 * menuPage), 10) + 3)) then
			local pos = (y - 2) + (10 * menuPage)
			comms.goLine(1, y)
			comms.clearLine()
			comms.setColor(colors.red)
			comms.writeText(keyList[pos])
			comms.setColor(colors.white)
			comms.writeText("=")
			input = getTextInput()
			if (string.lower(input) == "true") then
				set[keyList[pos]] = true
			elseif (string.lower(input) == "false") then
				set[keyList[pos]] = false
			elseif (tonumber(input)) then
				set[keyList[pos]] = tonumber(input)
			else
				set[keyList[pos]] = input
			end
			save()
			comms.goLine(1, y)
			comms.clearLine()
			if ((pos % 2) == 1) then
				comms.setColor(colors.cyan)
			else
				comms.setColor(colors.blue)
			end
			comms.writeText("\n" .. keyList[pos])
			comms.setColor(colors.white)
			comms.writeText("=" .. tostring(set[keyList[pos]]))
		elseif (y == 14) then
			if (x > 5) then
				menuPage = menuPage + 1
				if (menuPage > math.ceil(#keyList / 10) - 1) then
					menuPage = menuPage - 1
				end
			else
				menuPage = menuPage - 1
				if (menuPage < 0) then
					menuPage = 0
				end
			end
		end
	end
end

function restartMenu()
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.red)
	comms.printText('Are you sure?')
	comms.setColor(colors.white)
	input = string.lower(getTextInput())
	for i = 1, #confirmations do
		if (confirmations[i] == input) then	
			parallel.waitForAll(
				function() commands.exec("team remove " .. set.team1) end,
				function() commands.exec("team remove " .. set.team2) end,
				function() commands.exec("tag @a remove " .. set.team1) end,
				function() commands.exec("tag @a remove " .. set.team2) end,
				function() commands.exec("tp @a[gamemode=spectator] " .. positions[set.lobbyName].worldspawn) end,
				function() commands.exec("gamemode adventure @a[gamemode=spectator]") end,
				function() commands.exec("setworldspawn " .. positions[set.lobbyName].worldspawn) end,
				function() commands.exec("spawnpoint @a " .. positions[set.lobbyName].worldspawn) end
			)
			fs.delete("Data/loggedUsers.txt")
			fs.delete("Data/set.txt")
			term.clear()
			error("Please restart the computer.", 0)
		end
	end
end

function kitsMenu()
	while true do
		local orderedNames = {}
		for key, value in pairs(kitData) do
			orderedNames[#orderedNames + 1] = {key, 0, 0, (#key + 2)} -- {name, screen y pos, screen x pos of leftmost side, length of name}
		end
		orderedNames[#orderedNames + 1] = {"NEW+", 0, 0, 6}
		orderedNames[#orderedNames + 1] = {"DOWNLOAD\25", 0, 0, 11}
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< RETURN ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Select a Kit:\n")
		comms.setColor(colors.black)
		comms.setBackground(colors.cyan)
		local yPos = 3
		local xPos = 1
		for i = 1, #orderedNames do
			if (xPos + orderedNames[i][4] >= 50) then
				comms.printText("")
				yPos = yPos + 1
				xPos = 1
			end
			if (orderedNames[i][1] == "NEW+" or orderedNames[i][1] == "DOWNLOAD\25") then
				comms.setBackground(colors.cyan)
			else
				comms.setBackground(colors.orange)
			end
			orderedNames[i][2] = yPos
			orderedNames[i][3] = xPos
			comms.writeText("[" .. orderedNames[i][1] .. "]")
			comms.setBackground(colors.black)
			comms.writeText("  ")
			xPos = xPos + orderedNames[i][4] + 2
		end
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			return
		else
			for i = 1, #orderedNames do
				if (orderedNames[i][2] == y and x >= orderedNames[i][3] and x < (orderedNames[i][3] + orderedNames[i][4])) then
					if (orderedNames[i][1] == "NEW+") then
						kitsMakingMenu()
					elseif (orderedNames[i][1] == "DOWNLOAD\25") then
						comms.clearAll()
						comms.goLine(1, 1)
						comms.setBackground(colors.black)
						comms.setColor(colors.cyan)
						comms.printText("Enter the pastebin URL for the accociated kit files...")
						comms.setColor(colors.orange)
						local pasteURL = getTextInput()
						pasteURL = string.gsub(pasteURL, "raw/", "")
						pasteURL = string.gsub(pasteURL, "https://pastebin.com/", "")
						pasteURL = "https://pastebin.com/raw/" .. pasteURL
						local gate, err = http.get(pasteURL)
						if (gate) then
							local success, body = pcall(function() return gate.readAll() end)
							if (success) then
								local tempKits = textutils.unserialize(body)
								local kitsAmount = 0
								for _ in pairs(tempKits) do
									kitsAmount = kitsAmount + 1
								end
								if (kitsAmount > 0) then
									comms.clearAll()
									comms.goLine(1, 1)
									comms.setColor(colors.cyan)
									comms.printText("There were " .. tostring(kitsAmount) .. " kits downloaded, procceed how?")
									comms.setColor(colors.orange)
									comms.printText("\4 Add Kits To Current List, Ignore Duplicates")
									comms.printText("\4 Add Kits To Current List, Replace Duplicates")
									comms.printText("\4 Fully Replace Kits With Downloaded Kits")
									comms.setColor(colors.red)
									comms.printText("\4 Cancel")
									local x, y
									repeat 
										x, y = getClickInput()
									until (y > 1 and y < 6)
									if (y == 2) then
										for key, value in pairs(tempKits) do
											if (not kitData[key]) then
												kitData[key] = value
												local file = fs.open("Kits/" .. key .. ".txt", "w")
												file.write(textutils.serialize(value))
												file.close()
											end
										end
									elseif (y == 3) then
										for key, value in pairs(tempKits) do
											kitData[key] = value
											local file = fs.open("Kits/" .. key .. ".txt", "w")
											file.write(textutils.serialize(value))
											file.close()
										end
									elseif (y == 4) then
										kitData = tempKits
										for key, value in pairs(kitData) do
											local file = fs.open("Kits/" .. key .. ".txt", "w")
											file.write(textutils.serialize(value))
											file.close()
										end
									end
									makeKitBackup()
								else
									comms.clearAll()
									comms.goLine(1, 1)
									comms.setColor(colors.red)
									comms.printText("Error, the file at " .. pasteURL .. " was downloaded, but was empty or formatted wrong, press ENTER to return.")
									getTextInput()
								end
							else
								comms.clearAll()
								comms.goLine(1, 1)
								comms.setColor(colors.red)
								comms.printText("Error, there was no data at " .. pasteURL .. ", press ENTER to return.")
								getTextInput()
							end
						else
							comms.clearAll()
							comms.goLine(1, 1)
							comms.setColor(colors.red)
							comms.printText("Error, could not connect to " .. pasteURL .. ", press ENTER to return.")
							getTextInput()
						end
					else
						individualKitMenu(orderedNames[i][1])
					end
					break
				end
			end
		end
	end
end

function individualKitMenu(kitName)
	local localKitData = {}
	local buttonList = {}
	for i = 2, #kitData[kitName] do
		localKitData[kitData[kitName][i][1]] = kitData[kitName][i]
	end
	local function makeButton(x, y, slotID)
		buttonList[#buttonList + 1] = {x, y, slotID}
		comms.goLine(x, y)
		if (localKitData[slotNumToName(slotID)]) then
			comms.setBackground(colors.cyan)
			comms.writeText("[#]")
		else
			comms.setBackground(colors.orange)
			comms.writeText("[+]")
		end
		comms.setBackground(colors.black)
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< APPLY ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Editing Kit " .. kitName .. ":\n")
		comms.printText("The following buttons map to slots in an inventory:")
		comms.setColor(colors.orange)
		comms.setBackground(colors.black)
		comms.writeText("[+]") 
		comms.setColor(colors.white)
		comms.writeText(" = Add New Item    ")
		comms.setColor(colors.cyan)
		comms.writeText("[#]")
		comms.setColor(colors.white)
		comms.writeText(" = Change Item")
		comms.setColor(colors.black)
		makeButton(15, 6, 103) -- head
		makeButton(25, 6, 101) -- leggings
		makeButton(15, 8, 102) -- chest
		makeButton(25, 8, 100) -- feet
		makeButton(10, 7, -106) -- offhand
		local slotID = 0
		for i = 1, 9 do
			makeButton((4 * i), 14, slotID)
			slotID = slotID + 1
		end
		for i = 10, 12 do
			for j = 1, 9 do
				makeButton((4 * j), i, slotID)
				slotID = slotID + 1
			end
		end
		comms.goLine(4, 16)
		comms.setColor(colors.lightGray)
		comms.printText("Made for version v" .. kitData[kitName].madeFor)
		comms.setColor(colors.cyan)
		comms.printText("   \4 Remake Ammo List")
		comms.setColor(colors.red)
		comms.printText("   \4 Delete Kit")
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			comms.setBackground(colors.black)
			local kitFileData = {
				[1] = kitName,
				["ammoList"] = kitData[kitName].ammoList,
				["madeFor"] = kitData[kitName].madeFor
			}
			for key, value in pairs(localKitData) do
				if (value) then
					kitFileData[#kitFileData + 1] = value
				end
			end
			kitData[kitName] = kitFileData
			local file = fs.open("Kits/" .. kitName .. ".txt", "w")
			file.write(textutils.serialize(kitFileData))
			file.close()
			makeKitBackup()
			return
		elseif (y == 17 and x < 23 and x > 3) then
			local ammoList = {}
			for i = 2, #kitData[kitName] do
				local itemName = ""
				for j = 1, #kitData[kitName][i][2] do
					if (string.sub(kitData[kitName][i][2], j, j) == "{") then
						itemName = string.sub(kitData[kitName][i][2], 1, (j - 1))
						break
					end
				end
				if (itemName == "") then
					itemName = kitData[kitName][i][2]
				end
				if (ammoReference[itemName]) then
					ammoList[#ammoList + 1] = ammoReference[itemName]
				end
			end
			kitData[kitName].ammoList = ammoMenu(kitName, ammoList)
		elseif (y == 18 and x < 23 and x > 3) then
			if (not confirming("Are you sure you want to delete " .. kitName .. "?", "Cancel", "Delete")) then
				kitData[kitName] = nil
				fs.delete("Kits/" .. kitName .. ".txt")
				local file = fs.open("kitsall.txt", "w")
				file.write(textutils.serialize(kitData))
				file.close()
				return
			end
		else
			for i = 1, #buttonList do
				if (buttonList[i][2] == y and x >= buttonList[i][1] and x < (buttonList[i][1] + 3)) then
					local newData = {}
					local slotName = slotNumToName(buttonList[i][3])
					if (localKitData[slotName]) then
						newData = individualItemMenu(localKitData[slotName], buttonList[i][3], kitName)
					else
						newData = individualItemMenu({slotName, "", 1}, buttonList[i][3], kitName)
					end
					localKitData[slotName] = newData
					break
				end
			end
		end
	end
end

function individualItemMenu(itemData, slotID, kitName)
	local itemName = ""
	local tags = ""
	for i = 1, #itemData[2] do 
		local chr = string.sub(itemData[2], i, i)
		if (chr == "{") then
			tags = string.sub(itemData[2], i, #itemData[2])
			break
		else
			itemName = itemName .. chr
		end
	end
	local function drawTag()
		comms.setColor(colors.red)
		for i = 1, #tags do
			comms.writeText(string.sub(tags, i, i))
		end
		comms.setColor(colors.white)
	end
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< APPLY ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Editing Slot " .. itemData[1] .. " of " .. kitName .. ":\n")
		if (itemName == "") then
			comms.setColor(colors.black)
			comms.setBackground(colors.cyan)
			comms.writeText("[+]")
			comms.setBackground(colors.black)
			comms.setColor(colors.orange)
			comms.printText(" No Item")
		else
			comms.setColor(colors.black)
			comms.setBackground(colors.cyan)
			comms.writeText("[#]")
			comms.setBackground(colors.black)
			comms.setColor(colors.orange)
			comms.printText(" Item: " .. itemName)
			comms.goLine(1, 5)
			comms.setColor(colors.black)
			comms.setBackground(colors.cyan)
			comms.writeText("[#]")
			comms.setBackground(colors.black)
			comms.setColor(colors.orange)
			comms.printText(" Count: " .. tostring(itemData[3]))
		end
		comms.goLine(1, 7)
		comms.setColor(colors.black)
		comms.setBackground(colors.red)
		comms.printText("[DELETE]")
		comms.setBackground(colors.black)
		local x, y = getClickInput()
		if (y == 1 and x < 10) then
			if (itemName ~= "") then
				itemData[2] = itemName .. tags
				return itemData
			else
				return nil
			end
		elseif (x < 4 or y == 7) then
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.cyan)
			if (y == 3) then
				comms.printText('Enter the full name of the new item, e.g. "combatgear:rations"...')
				comms.setColor(colors.white)
				itemName = getTextInput()
				if (tags ~= "") then
					comms.clearAll()
					comms.goLine(1, 1)
					comms.setColor(colors.cyan)
					comms.printText("This item has a tag:")
					comms.setColor(colors.white)
					comms.printText(tags)
					local input = 1
					repeat
						comms.goLine(1, 16)
						comms.setColor(colors.orange)
						comms.printText("What should be done with this tag?")
						comms.setColor(colors.cyan)
						comms.printText("\4 Keep It")
						comms.setColor(colors.red)
						comms.printText("\4 Remove It")
						_, input = getClickInput()
					until (input == 17 or input == 18)
					if (input == 18) then
						tags = ""
					end
				end
			elseif (y == 5) then
				comms.printText("Enter the quantity of the item in this slot (1-64)...")
				comms.setColor(colors.white)
				local input = tonumber(getTextInput())
				if (input) then
					itemData[3] = math.min(math.max(input, 1), 64)
				end
			elseif (y == 7) then
				return nil
			end
		end
	end
end

function nbtExtract(nbtString)
	nbtTable = {}
	local pos = 1
	while (pos <= #nbtString) do -- Loops through all the characters of the input string
		local layer = 0
		local startPos = pos
		repeat -- Repeats until it isolates an entire segment for 1 item
			if (string.sub(nbtString, pos, pos) == "{") then
				layer = layer + 1
			elseif (string.sub(nbtString, pos, pos) == "}") then
				layer = layer - 1
			end
			pos = pos + 1
		until (layer == 0)
		nbtTable[#nbtTable + 1] = string.sub(nbtString, (startPos + 1), (pos - 2)) -- Adds that 1 item segment to the table
		pos = pos + 2 -- +2 skips the comma and goes to the next part
	end
	for item = 1, #nbtTable do -- Go through all the invidivual item nbt data
		local pos = 1
		local tempTable = {}
		while (pos <= #nbtTable[item]) do -- Loop through all characters of the item nbt data
			local keyStartPos = pos -- Saves the starting character of the key
			while (string.sub(nbtTable[item], pos, pos) ~= ":") do -- Loops until the key is over
				pos = pos + 1
			end -- Ends at the ":"
			local keyName = string.sub(nbtTable[item], keyStartPos, (pos - 1)) -- Saves the entire name of the key to this variable
			pos = pos + 2 -- Now onto the data
			local dataStartPos = pos -- Saves the starting character of the data cooresponding to the key
			if (string.sub(nbtTable[item], pos, pos) == '"') then -- If it has a " then it's a string
				repeat -- Repeats until the string is over
					pos = pos + 1
				until (string.sub(nbtTable[item], pos, pos) == '"') -- Ends at the last character in the value
				tempTable[keyName] = string.sub(nbtTable[item], dataStartPos + 1, pos - 1)
				pos = pos + 3 -- Moves onto the next key-value pair
			elseif (string.sub(nbtTable[item], pos, pos) == "{") then -- If it has a { then it's a table
				local layer = 0
				repeat -- Repeats until it isolates the entire table
					if (string.sub(nbtTable[item], pos, pos) == "{") then
						layer = layer + 1
					elseif (string.sub(nbtTable[item], pos, pos) == "}") then
						layer = layer - 1
					end
					pos = pos + 1
				until (layer == 0) -- Ends at the comma
				tempTable[keyName] = string.sub(nbtTable[item], dataStartPos, pos - 1) -- Saves the entire table
				pos = pos + 2 -- Moves onto the next key-value pair
			else -- Otherwise it's just a number probably
				repeat -- Repeats until the number is over
					pos = pos + 1
				until (not tonumber(string.sub(nbtTable[item], pos, pos))) -- Ends at the last character in the value
				tempTable[keyName] = tonumber(string.sub(nbtTable[item], dataStartPos, pos - 1))
				pos = pos + 3 -- Moves onto the next key-value pair
			end
		end
		nbtTable[item] = tempTable
	end
	return nbtTable
end

function getInventoryData(player)
	local success, output = commands.exec("data get entity " .. player .. " Inventory")
	local logPoint = 1
	for i = 1, #output[1] do
		if (string.sub(output[1], i, i) == ":") then
			logPoint = i + 3
			break
		end
	end
	return string.sub(output[1], logPoint, (#output[1] - 1))
end

function slotNumToName(slotNumber)
	if (slotNumber == 103) then
		return "armor.head"
	elseif (slotNumber == 102) then
		return "armor.chest"
	elseif (slotNumber == 101) then
		return "armor.legs"
	elseif (slotNumber == 100) then
		return "armor.feet"
	elseif (slotNumber > 8) then
		return "inventory." .. tostring(slotNumber - 9)
	elseif (slotNumber == -106) then
		return "weapon.offhand"
	else
		return "hotbar." .. tostring(slotNumber)
	end
end

function kitsMakingMenu()
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.cyan)
	comms.setBackground(colors.black)
	comms.printText("Input the name of the team this kit is for...")
	comms.setColor(colors.orange)
	local teamName = typing(1, 2, 4, 4, 1, true)
	local input = teamName .. "_"
	comms.clearAll()
	comms.goLine(1, 1)
	comms.setColor(colors.orange)
	comms.printText('Editing kit: ' .. input)
	comms.setColor(colors.cyan)
	comms.printText('Enter a short identifier code for this kit...')
	comms.printText('e.g. "RF", "MG", "DMR"')
	comms.setColor(colors.orange)
	input = input .. typing(1, 4, 2, 4, 1, true)
	if (#input > 10) then
		comms.setColor(colors.red)
		comms.printText("\nError, your format is invalid, press ENTER to continue.")
		getTextInput()
	else
		if (fs.exists("Kits/" .. input .. ".txt")) then
			comms.setColor(colors.orange)
			comms.printText("\nThis kit already exists...")
			comms.setColor(colors.cyan)
			comms.printText("\4 Replace Kit")
			comms.setColor(colors.red)
			comms.printText("\4 Cancel")
			local confirmation = 1
			repeat
				_, confirmation = getClickInput()
			until (confirmation == 7 or confirmation == 8)
			if (confirmation == 8) then
				return
			end
		end
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.orange)
		comms.printText("Editing kit: " .. input)
		comms.setColor(colors.white)
		comms.printText('Follow these steps to create a kit:')
		comms.setColor(colors.cyan)
		comms.printText('\n[1] Set up your inventory to be exactly the kit.')
		comms.printText('\n[2] Press ENTER to save YOUR entire inventory, stand close to the computer.')
		comms.printText('\n[3] If you want, save the "kitsall.txt" file somewhere for later use.')
		comms.setColor(colors.red)
		comms.printText('\n[!] Do not use Curios items. Do not add ammo or bandages to the kit manually, as those are portioned automatically.')
		comms.setColor(colors.white)
		getTextInput()
		makeNewKit(input, ammoList)
	end
end

function ammoMenu(kitName, ammoList)
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.orange)
		comms.printText("Editing kit: " .. kitName)
		comms.setColor(colors.cyan)
		if (#ammoList > 0) then
			comms.printText('Enter another ammo item name for this kit, e.g. "ammo9mm", or press ENTER to continue.\n')
		else
			comms.printText('Enter a ammo item name for this kit, e.g. "ammo9mm".')
		end
		for i = 1, #ammoList do
			comms.setColor(colors.red)
			comms.writeText("[X] ")
			comms.setColor(colors.orange)
			comms.printText(ammoList[i])
		end
		comms.setColor(colors.orange)
		local y = false
		local ammoInput = ""
		parallel.waitForAny(
			function()
				repeat
					x, y = getClickInput()
					y = y - 4
				until (y > 0 and y <= #ammoList and x < 5)
			end,
			function()
				ammoInput = "pointblank:" .. string.gsub(string.lower(getTextInput()), "pointblank:", "")
			end
		)
		if (y) then
			for i = y, #ammoList do
				ammoList[i] = ammoList[i + 1]
			end
		else
			if (ammoInput == "pointblank:") then
				return ammoList
			else
				ammoList[#ammoList + 1] = ammoInput
			end
		end
	end
end

function makeNewKit(fileName)
	local kitFileData = {
		[1] = fileName,
		["ammoList"] = {},
		["madeFor"] = version
	}
	local inventoryData = nbtExtract(getInventoryData("@a[gamemode=creative,sort=nearest,limit=1]"))
	for i = 1, #inventoryData do
		if (ammoReference[inventoryData[i].id]) then
			kitFileData.ammoList[#kitFileData.ammoList + 1] = ammoReference[inventoryData[i].id]
		end
		if (inventoryData[i].tag) then
			kitFileData[#kitFileData + 1] = {slotNumToName(inventoryData[i].Slot), inventoryData[i].id .. inventoryData[i].tag, inventoryData[i].Count}
		else
			kitFileData[#kitFileData + 1] = {slotNumToName(inventoryData[i].Slot), inventoryData[i].id, inventoryData[i].Count}
		end
	end
	kitFileData.ammoList = ammoMenu(fileName, kitFileData.ammoList)
	local file = fs.open("Kits/" .. fileName .. ".txt", "w")
	file.write(textutils.serialize(kitFileData))
	file.close()
	kitData[fileName] = kitFileData
	makeKitBackup()
end

function drawName(userID)
	comms.setColor(colors.cyan)
	comms.writeText("\21")
	comms.setColor(colors.orange)
	if (userID < 10) then
	comms.writeText("0")
	end
	comms.writeText(tostring(userID) .. ": ")
	if (loggedUsers[userID][3] == set.team1) then
		comms.setBackground(colors.red)
	else
		comms.setBackground(colors.blue)
	end
	comms.setColor(colors.black)
	comms.writeText(loggedUsers[userID][1])
	if (permaLog[loggedUsers[userID][1]]) then
		if (permaLog[loggedUsers[userID][1]][1] ~= "NA") then
			comms.writeText(" [" .. permaLog[loggedUsers[userID][1]][1] .. "]")
		end
		comms.setBackground(colors.black)
		comms.setColor(colors.orange)
		comms.writeText(" (" .. loggedUsers[userID][2] .. ") ")
		comms.setBackground(colors.cyan)
		comms.setColor(colors.black)
		for i = 2, #permaLog[loggedUsers[userID][1]] do
			if (i == 2) then
				comms.writeText("{")
			end
			comms.writeText(permaLog[loggedUsers[userID][1]][i])
			if (i ~= #permaLog[loggedUsers[userID][1]]) then
				comms.writeText(",")
			else
				comms.writeText("}")
			end
		end
	else
		comms.setBackground(colors.black)
		comms.setColor(colors.orange)
		comms.writeText(" (" .. loggedUsers[userID][2] .. ")")
	end
	comms.printText()
	comms.setColor(colors.white)
	comms.setBackground(colors.black)
end

function playerMenu()
	local menuPage = 0
	if (#loggedUsers == 0) then
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.red)
		comms.printText('There is nobody in the server with a team, press ENTER to continue.')
		getTextInput()
	else
		while true do
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.black)
			comms.setBackground(colors.gray)
			comms.writeText('< RETURN ')
			comms.setColor(colors.white)
			comms.setBackground(colors.black)
			comms.printText("  Logged Users:\n")
			for i = (1 + 10 * (menuPage)), math.min(#loggedUsers, 10 * (menuPage + 1)) do
				drawName(i)
			end
			comms.goLine(1, 14)
			comms.setColor(colors.orange)
			comms.writeText("<<")
			comms.setColor(colors.white)
			comms.writeText("-pg" .. (menuPage + 1) .. "-")
			comms.setColor(colors.orange)
			comms.writeText(">>")
			x, y = getClickInput()
			if (y == 1 and x < 10) then
				return
			elseif (y > 2 and y < (math.min(#loggedUsers - (10 * menuPage), 10) + 3)) then
				local userID = (y - 2) + (10 * menuPage)
				if (x == 1) then
					if (set.kitsGivenOut) then
						reKit(false, userID) 
					end
				else
					comms.clearAll()
					comms.goLine(1, 1)
					comms.setColor(colors.cyan)
					comms.printText("Select a new kit...")
					comms.setColor(colors.orange)
					local classes = {}
					for key, value in pairs(kitData) do
						if (string.sub(kitData[key][1], 1, 4) == loggedUsers[userID][3]) then
							classes[#classes + 1] = string.sub(kitData[key][1], 6, #kitData[key][1])
							comms.printText("[" .. classes[#classes] .. "]")
						end
					end
					if (#classes == 0) then
						comms.setColor(colors.red)
						comms.printText("No kits for this team! Press enter to return.")
						getTextInput()
					else
						comms.setColor(colors.orange)
						comms.printText("\n\4 Switch Team")
						x, y = getClickInput()
						if (y > 1 and y < (#classes + 2)) then
							loggedUsers[userID][2] = classes[y - 1]
							if (set.kitsGivenOut) then
								reKit(true, userID)
							end
						elseif (y == (#classes + 3)) then
							swapTeam(userID)
						end
					end
				end
			elseif (y == 14) then
				if (x > 5) then
					menuPage = menuPage + 1
					if (menuPage > math.ceil(#loggedUsers / 10) - 1) then
						menuPage = menuPage - 1
					end
				else
					menuPage = menuPage - 1
					if (menuPage < 0) then
						menuPage = 0
					end
				end
			end
		end
	end
end

function capMenu()
	while true do
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.black)
		comms.setBackground(colors.gray)
		comms.writeText('< RETURN ')
		comms.setColor(colors.white)
		comms.setBackground(colors.black)
		comms.printText("  Available Caps:")
		for i = 1, #caps do
			comms.setColor(colors.black)
			comms.setBackground(colors.cyan)
			comms.writeText("\n[?]")
			comms.setBackground(colors.black)
			comms.setColor(colors.orange)
			comms.writeText(" " .. caps[i][1])
		end
		comms.setColor(colors.black)
		comms.setBackground(colors.cyan)
		comms.printText("\n\n[+]")
		comms.setBackground(colors.black)
		x, y = getClickInput()
		if (y == 1 and x < 10) then
			save()
			return
		elseif (y > 2 and y < (#caps + 3)) then
			local capPoint = y - 2
			local runMenu = true
			while (runMenu) do
				comms.clearAll()
				comms.goLine(1, 1)
				comms.setColor(colors.black)
				comms.setBackground(colors.gray)
				comms.printText('< RETURN ')
				comms.setColor(colors.black)
				comms.setBackground(colors.cyan)
				comms.writeText("\n[#]")
				comms.setBackground(colors.black)
				comms.setColor(colors.orange)
				comms.writeText(" Name: ")
				comms.setColor(colors.white)
				comms.printText(caps[capPoint][1])
				comms.setColor(colors.black)
				comms.setBackground(colors.cyan)
				comms.writeText("[#]")
				comms.setBackground(colors.black)
				comms.setColor(colors.orange)
				comms.writeText(" Position: ")
				comms.setColor(colors.white)
				comms.printText(caps[capPoint][2])
				comms.setColor(colors.black)
				comms.setBackground(colors.red)
				comms.printText('\n[DELETE]')
				comms.setBackground(colors.black)
				x, y = getClickInput()
				if (y == 1 and x < 10) then
					runMenu = false
				elseif (y == 3 and x < 4) then
					comms.clearAll()
					comms.goLine(1, 1)
					comms.setColor(colors.orange)
					comms.printText("Enter the new name...")
					comms.setColor(colors.white)
					caps[capPoint][1] = getTextInput()
				elseif (y == 4 and x < 4) then
					comms.clearAll()
					comms.goLine(1, 1)
					comms.setColor(colors.orange)
					comms.printText("Enter the new position...")
					comms.printText('"e.g. "-98 65 50"')
					comms.setColor(colors.white)
					caps[capPoint][2] = getTextInput()
				elseif (y == 6 and x < 9) then
					for i = capPoint, (#caps - 1) do
						caps[i] = caps[i + 1]
					end
					caps[#caps] = nil
					runMenu = false
				end
			end
			local file = fs.open("Data/caps.txt", "w")
			file.write(textutils.serialize(caps))
			file.close()
		elseif (y == (#caps + 4)) then
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.orange)
			comms.printText("Enter the name of the cap...")
			comms.setColor(colors.white)
			caps[#caps + 1] = {"", "", 0, 0} -- CAP FORMAT: {Name str, Coords str, team#, capped%}
			caps[#caps][1] = getTextInput()
			comms.setColor(colors.orange)
			comms.printText("Enter its coordinates...")
			comms.printText('"e.g. "-45 45 -23"')
			comms.setColor(colors.white)
			caps[#caps][2] = getTextInput()
			local file = fs.open("Data/caps.txt", "w")
			file.write(textutils.serialize(caps))
			file.close()
		end
		comms.setBackground(colors.black)
	end
end

function getAmmoList(userID)
	if (kitData[loggedUsers[userID][3] .. "_" .. loggedUsers[userID][2]]) then
		return kitData[loggedUsers[userID][3] .. "_" .. loggedUsers[userID][2]].ammoList
	else
		return {"pointblank:ammocreative"}
	end
end

function returnPlayers()
	set.gameBegun = false
	set.go = false
	parallel.waitForAll(
		function() kitAll() end,
		function() commands.exec("tp @a[tag=" .. set.team1 .. "] " .. positions[set.lobbyName].team1Room) end,
		function() commands.exec("tp @a[tag=" .. set.team2 .. "] " .. positions[set.lobbyName].team2Room) end,
		function() commands.exec("setworldspawn " .. positions[set.lobbyName].worldspawn) end,
		function() commands.exec("spawnpoint @a " .. positions[set.lobbyName].worldspawn) end,
		function() commands.exec("effect give @a minecraft:regeneration 10 255 true") end,
		function() commands.exec("effect give @a clear") end,
		function() commands.exec('gamemode adventure @a') end,
		function() commands.exec("gamerule pvp false") end,
		function() commands.exec("scoreboard objectives setdisplay sidebar spawns") end
	)
	save()
end

function startGame()
	getUsers()
	local cmdParallel = {}
	for i = 1, #loggedUsers do
		local ammoList = getAmmoList(i)
		for j = 1, #ammoList do
			cmdParallel[#cmdParallel + 1] = function()
				commands.exec('clear ' .. loggedUsers[i][1] .. ' ' .. ammoList[j])
				commands.exec('give ' .. loggedUsers[i][1] .. ' ' .. ammoList[j] .. ' ' .. set.ammoAmount)
			end
		end
	end
	if (set.teamTicketType == 3 and (set.roundWins1 > 0 or set.roundWins2 > 0)) then
		kitAll()
	else
		set.team1Tickets = 0
		set.team2Tickets = 0
	end
	parallel.waitForAll(
		function() commands.exec("effect clear @a") end,
		function() 
			if (set.teamTicketType == 3) then
				parallel.waitForAll(
					function() 
						if (set.roundsLeft < 1) then
							commands.exec('title @a subtitle {"bold":true,"color":"dark_aqua","text":"< OVERTIME >"}') 
						end
					end,
					function() commands.exec('title @a title {"bold":true,"color":"gold","text":"Round ' .. tostring(set.roundWins1 + set.roundWins2 + 1) .. '"}') end,
					function() commands.exec('title @a actionbar {"bold":true,"color":"red","text":"THERE ARE NO RESPAWNS!"}') end
				)
				set.respawnsDisabled = true
			end 
		end,
		function() commands.exec('clear @a combatgear:bandagerealistic') end,
		function() commands.exec('give @a combatgear:bandagerealistic ' .. set.bandageAmount) end,
		function() parallel.waitForAll(table.unpack(cmdParallel)) end,
		function() commands.exec("tp @a[tag=" .. set.team1 .. "] " .. spawns[1]) end,
		function() commands.exec("tp @a[tag=" .. set.team2 .. "] " .. spawns[2]) end,
		function() commands.exec("tp @a[tag=!" .. set.team1 .. ",tag=!" .. set.team2 .. "] " .. positions[set.lobbyName].deathSpawn) end,
		function() commands.exec("setworldspawn " .. positions[set.lobbyName].deathSpawn) end,
		function() commands.exec("spawnpoint @a " .. positions[set.lobbyName].deathSpawn) end,
		function() commands.exec("effect give @a minecraft:regeneration 20 255 true") end,
		function() commands.exec("effect give @a minecraft:slowness infinite " .. tostring(set.slowness - 1) .. " true") end,
		function() commands.exec("effect give @a minecraft:mining_fatigue infinite " .. tostring(set.miningFatigue - 1) .. " true") end,
		function() commands.exec("bossbar set event:main players @a") end,
		function() commands.exec("effect give @a xaerominimap:no_entity_radar infinite 0 true") end,
		function() commands.exec("execute as @a run attribute @s minecraft:generic.max_health base set " .. set.maxHealth) end,
		function() commands.exec("execute as @a run effect give @s minecraft:instant_health 1 1 true") end,
		function() commands.exec('team modify ' .. set.team1 .. ' friendlyFire false') end,
		function() commands.exec('team modify ' .. set.team2 .. ' friendlyFire false') end,
		function() commands.exec('gamemode survival @a') end,
		function() commands.exec('kill @e[type=boat]') end,
		function() commands.exec("gamerule pvp true") end,
		function() commands.exec("scoreboard objectives setdisplay sidebar spawns") end,
		function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
		function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end,
		function() commands.exec('tellraw @a [{"text":"Event Starting...\\n","color":"dark_red"},{"text":"Hello, please know that this event system is still in Beta, please report any issues to Admins via the Discord or in-game. Thank you! Have fun!","color":"blue"}]') end,
		function() commands.exec('gamerule naturalRegeneration false') end
	)
	set.gameBegun = true
	editBossbar(2)
	save()
end

function relativePos(relX, relY, relZ)
	return tostring(ComX + relX) .. " " .. tostring(ComY + relY) .. " " .. tostring(ComZ + relZ)
end

function lockSpawns() 
	if (not set.spawnsLocked and not set.kitsGivenOut) then
		getUsers()
		local cmdParallel = {}
		for i = 1, #loggedUsers do
			cmdParallel[#cmdParallel + 1] = function()
				commands.exec('team join ' .. loggedUsers[i][3] .. ' ' .. loggedUsers[i][1])
			end
		end
		parallel.waitForAll(
			function() commands.exec('tag @a[tag=!' .. set.team1 .. ',tag=!' .. set.team2 .. '] add ' .. set.team1) end,
			function() getUsers() end,
			function() commands.exec('fill ' .. positions[set.lobbyName].team1Door .. ' minecraft:deepslate_brick_wall') end,
			function() commands.exec('fill ' .. positions[set.lobbyName].team2Door .. ' minecraft:deepslate_brick_wall') end,
			function() commands.exec("tp @a[tag=" .. set.team1 .. ",gamemode=adventure] " .. positions[set.lobbyName].team1Room) end,
			function() commands.exec("tp @a[tag=" .. set.team2 .. ",gamemode=adventure] " .. positions[set.lobbyName].team2Room) end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver2 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver1 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover2 .. ' minecraft:air') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover1 .. ' minecraft:air') end,
			function() parallel.waitForAll(table.unpack(cmdParallel)) end
		)
		set.spawnsLocked = true
		save()
	end
end

function unlockSpawns() 
	if (set.spawnsLocked and not set.kitsGivenOut) then
		parallel.waitForAll(
			function() commands.exec('fill ' .. positions[set.lobbyName].team1Door .. ' air') end,
			function() commands.exec('fill ' .. positions[set.lobbyName].team2Door .. ' air') end,
			function() commands.exec('team leave @a') end,
			function() commands.exec("tp @a[tag=" .. set.team1 .. ",gamemode=adventure] " .. positions[set.lobbyName].worldspawn) end,
			function() commands.exec("tp @a[tag=" .. set.team2 .. ",gamemode=adventure] " .. positions[set.lobbyName].worldspawn) end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver2 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..18] add ' .. set.team2 .. '",auto:1b}') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagGiver1 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..18] add ' .. set.team1 .. '",auto:1b}') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover2 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..19] remove ' .. set.team1 .. '",auto:1b}') end,
			function() commands.exec('setblock ' .. positions[set.lobbyName].tagRemover1 .. ' minecraft:repeating_command_block{Command:"tag @a[distance=..19] remove ' .. set.team2 .. '",auto:1b}') end
		)
		set.spawnsLocked = false
		save()
	end
end

function permaKill(playerName)
	if (playerName) then
		parallel.waitForAll(
			function() commands.exec("clear " .. playerName) end,
			function() commands.exec("gamemode spectator " .. playerName) end,
			function() commands.exec("tp " .. playerName .. " "  .. spawns[3]) end
		)
	end
end

function checkWipeout(playerData)
	if ((set.teamTicketType == 1 and set.go) or set.respawnsDisabled) then
		local aliveTeammates, _ = commands.exec('data get entity @a[limit=1,gamemode=survival,tag=' .. playerData[3] .. '] Tags')
		if (not aliveTeammates) then
			if (set.team1 == playerData[3]) then
				winCondition(2)
			else
				winCondition(1)
			end
		end
	end
end

function deathCheck()
	while true do
		if (set.gameFinished) then
			return
		end
		local success, output = commands.exec('execute positioned ' .. positions[set.lobbyName].invisCommand .. ' as @a[distance=..4,gamemode=!creative,gamemode=!spectator,limit=1] run data get entity @p Health')
		if (success) then
			local deadPlayerName = string.match(output[1], ("^(%S+) has the following entity data"))
			deadPlayer = getGovernmentID(deadPlayerName)
			if (set.gameBegun) then
				if (set.respawnsDisabled and set.go) then
					if (deadPlayer) then
						permaKill(loggedUsers[deadPlayer][1])
						checkWipeout(loggedUsers[deadPlayer])
					else
						loggedUsers[#loggedUsers + 1] = {deadPlayerName, "RF", set["team" .. tostring(math.random(1, 2))]}
						local deadPlayer = #loggedUsers
						commands.exec("tag " .. loggedUsers[deadPlayer][1] .. " add " .. loggedUsers[deadPlayer][3])
						parallel.waitForAll(
							function() commands.exec("gamemode spectator " .. loggedUsers[deadPlayer][1]) end,
							function() commands.exec('team join ' .. loggedUsers[deadPlayer][3] .. ' ' .. loggedUsers[deadPlayer][1]) end,
							function() commands.exec("tp " .. deadPlayerName .. " " .. spawns[3]) end
						)
					end
				else
					local isSpectator = false
					if (deadPlayer) then
						local ammoList = getAmmoList(deadPlayer)
						local cmdParallel = {}
						for j = 1, #ammoList do
							cmdParallel[#cmdParallel + 1] = function()
								commands.exec('clear ' .. loggedUsers[deadPlayer][1] .. ' ' .. ammoList[j])
							end
							cmdParallel[#cmdParallel + 1] = function()
								commands.exec('give ' .. loggedUsers[deadPlayer][1] .. ' ' .. ammoList[j] .. ' ' .. set.ammoAmount)
							end
						end
						parallel.waitForAll(
							function() commands.exec('clear ' .. loggedUsers[deadPlayer][1] .. ' combatgear:bandagerealistic') end,
							function() commands.exec('give ' .. loggedUsers[deadPlayer][1] .. ' combatgear:bandagerealistic ' .. set.bandageAmount) end,
							function() parallel.waitForAll(table.unpack(cmdParallel)) end
						)
						if (set.teamTicketType == 1) then
							local userTeam = 2
							if (loggedUsers[deadPlayer][3] == set.team1) then
								userTeam = 1
							end
							if (set["team" .. tostring(userTeam) .. "Tickets"] > 0) then
								if (set.go) then
									set["team" .. tostring(userTeam) .. "Tickets"] = set["team" .. tostring(userTeam) .. "Tickets"] - 1
									editBossbar(1)
									local file = fs.open("Data/set.txt", "w")
									file.write(textutils.serialize(set))
									file.close()
									local success, output = commands.exec("scoreboard players set " .. set["team" .. tostring(userTeam)] .. " spawns " .. tostring(set["team" .. tostring(userTeam) .. "Tickets"]))
								end
							else
								permaKill(loggedUsers[deadPlayer][1])
								checkWipeout(loggedUsers[deadPlayer])
								isSpectator = true
							end
						end
					else
						loggedUsers[#loggedUsers + 1] = {deadPlayerName, "RF", set["team" .. tostring(math.random(1, 2))]}
						local deadPlayer = #loggedUsers
						commands.exec("tag " .. loggedUsers[deadPlayer][1] .. " add " .. loggedUsers[deadPlayer][3])
						parallel.waitForAll(
							function() reKit(false, deadPlayer) end,
							function() commands.exec("gamemode survival " .. loggedUsers[deadPlayer][1]) end,
							function() commands.exec('team join ' .. loggedUsers[deadPlayer][3] .. ' ' .. loggedUsers[deadPlayer][1]) end
						)
					end
					if (not isSpectator) then
						parallel.waitForAll(
							function() commands.exec("attribute " .. loggedUsers[deadPlayer][1] .. " minecraft:generic.max_health base set " .. set.maxHealth) end,
							function() commands.exec("effect clear " .. loggedUsers[deadPlayer][1]) end,
							function() commands.exec("effect give " .. loggedUsers[deadPlayer][1] .. " minecraft:slowness infinite " .. tostring(set.slowness - 1) .. " true") end,
							function() commands.exec("effect give " .. loggedUsers[deadPlayer][1] .. " minecraft:mining_fatigue infinite " .. tostring(set.miningFatigue - 1) .. " true") end,
							function() commands.exec("effect give " .. loggedUsers[deadPlayer][1] .. " xaerominimap:no_entity_radar infinite 0 true") end,
							function()
								if (loggedUsers[deadPlayer][3] == set.team1) then
									local success, output = commands.exec("tp " .. loggedUsers[deadPlayer][1] .. " " .. spawns[1])
								else
									local success, output = commands.exec("tp " .. loggedUsers[deadPlayer][1] .. " " .. spawns[2])
								end
							end
						)
						local success, output = commands.exec("execute as " .. loggedUsers[deadPlayer][1] .. " run effect give @s minecraft:instant_health 1 1 true")
					end
				end
			else
				parallel.waitForAll(
					function() commands.exec("spawnpoint " .. deadPlayerName .. " " .. positions[set.lobbyName].worldspawn) end,
					function() commands.exec("tp " .. deadPlayerName .. " " .. positions[set.lobbyName].worldspawn) end,
					function() commands.exec("gamemode adventure " .. deadPlayerName) end
				)
			end
		end
		sleep(0.05)
	end
end

function reKit(kitChange, player)
	if (kitChange) then
		local success, output = commands.exec('title ' .. loggedUsers[player][1] .. ' actionbar {"bold":true,"color":"yellow","text":"Your kit has been changed to ' .. loggedUsers[player][2] .. '."}')
	end
	local success, output = commands.exec("clear " .. loggedUsers[player][1])
	applyKit(loggedUsers[player][3] .. "_" .. loggedUsers[player][2], loggedUsers[player][1])
	if (set.gameBegun) then
		local ammoList = getAmmoList(player)
		local cmdParallel = {}
		for j = 1, #ammoList do
			cmdParallel[#cmdParallel + 1] = function()
				commands.exec('give ' .. loggedUsers[player][1] .. ' ' .. ammoList[j] .. ' ' .. set.ammoAmount)
			end
		end
		parallel.waitForAll(
			function() commands.exec('give ' .. loggedUsers[player][1] .. ' combatgear:bandagerealistic ' .. set.bandageAmount) end,
			function() parallel.waitForAll(table.unpack(cmdParallel)) end
		)
	end
end

function logUser(username)
	if (username[1] ~= "" and username[1] ~= set.team1 and username[1] ~= set.team2) then
		local success, output = commands.exec("data get entity " .. username[1] .. " Tags")
		local pos = 1
		local team = ""
		repeat
			if (string.sub(output[1], pos, pos) == '"') then
				team = string.sub(output[1], (pos + 1), (pos + 4))
				break
			end
			pos = pos + 1
		until (pos >= #output[1])
		if (team ~= "") then
			username[3] = team
			local loggable = true
			for j = 1, #loggedUsers do
				if (loggedUsers[j][1] == username[1]) then
					loggable = false
					loggedUsers[j][3] = username[3]
					break
				end
			end
			if (loggable) then
				loggedUsers[#loggedUsers + 1] = username
			end
		end
	end
end

function getUsers()
	loggedUsers2 = {}
	local playerList
	parallel.waitForAll(
		function() commands.exec("execute as @a[tag=" .. set.team1 .. "] run scoreboard players set @s Team 1") end,
		function() commands.exec("execute as @a[tag=" .. set.team2 .. "] run scoreboard players set @s Team 2") end,
		function() _, playerList = commands.exec("scoreboard players list") end
	)
	loggedUsers2[#loggedUsers2 + 1] = {"", "RF", ""} -- {Name, Class, Team}
	local logMode = false
	local pos = 1
	repeat -- Loop through all characters of playerList[1], which is a string that is a list of all players with a team.
		local chr = string.sub(playerList[1], pos, pos) -- Get current character (letter).
		if (chr == ":") then -- If there's a colon (start of the names) skip a bit and start logging.
			pos = pos + 1
			logMode = true
		elseif (chr == ",") then -- If there's a comma, start logging someone else.
			pos = pos + 1
			loggedUsers2[#loggedUsers2 + 1] = {"", "RF", ""}
		elseif (logMode and chr ~= " ") then -- If you are logging and there's text, log it and save the username.
			loggedUsers2[#loggedUsers2][1] = loggedUsers2[#loggedUsers2][1] .. chr
		end
		pos = pos + 1
	until (pos > #playerList[1])
	-- Begin logging the users using the individual log function.
	local cmdParallel = {}
	for i = 1, #loggedUsers2 do
		cmdParallel[#cmdParallel + 1] = function()
			logUser(loggedUsers2[i])
		end
	end
	parallel.waitForAll(table.unpack(cmdParallel))
	save()
end

function kitAll()
	getUsers()
	commands.exec("tag @a remove RF")
	commands.exec("tag @a remove MG")
	local cmdParallel = {}
	local kitTags = {}
	for i = 1, #loggedUsers do
		cmdParallel[#cmdParallel + 1] = function()
			commands.exec("tag " .. loggedUsers[i][1] .. " add " .. loggedUsers[i][2])
		end
		kitTags[loggedUsers[i][2]] = true -- Logs all USED kit codes without duplicates
	end
	cmdParallel[#cmdParallel + 1] = function() local success, output = commands.exec("clear @a") end
	parallel.waitForAll(table.unpack(cmdParallel))
	local cmdParallel = {}
	for key, value in pairs(kitData) do
		cmdParallel[#cmdParallel + 1] = function()
			applyKit(kitData[key][1], "@a[tag=" .. string.sub(kitData[key][1], 1, 4) .. ",tag=" .. string.sub(kitData[key][1], 6, #kitData[key][1]) .. "]")
		end
	end
	parallel.waitForAll(table.unpack(cmdParallel))
	cmdParallel = {}
	for key, value in pairs(kitTags) do 
		cmdParallel[#cmdParallel + 1] = function()
			commands.exec("tag @a remove " .. key)
		end
	end
	parallel.waitForAll(table.unpack(cmdParallel))
	set.kitsGivenOut = true
	save()
end

function fillName(frontChunk)
	if (frontChunk and #frontChunk > 0) then
		for i = 1, #loggedUsers do
			if (string.lower(string.sub(loggedUsers[i][1], 1, #frontChunk)) == string.lower(frontChunk)) then
				return loggedUsers[i][1]
			end
		end
	end
	return nil
end

function getGovernmentID(username)
	for i = 1, #loggedUsers do
		if (loggedUsers[i][1] == username) then
			return i
		end
	end
	return nil
end

function getPlayerPos(username)
	local success, result = commands.exec("data get entity " .. username .. " Pos")
	return string.match(result[1], "%[([%-%.%d]+)d?,%s*([%-%.%d]+)d?,%s*([%-%.%d]+)d?%]")
end

function swapTeam(target)
	if (not set.gameFinished) then
		if (loggedUsers[target][3] == set.team1) then
			loggedUsers[target][3] = set.team2
		else
			loggedUsers[target][3] = set.team1
		end
		parallel.waitForAll(
			function()
				if (set.gameBegun) then
					parallel.waitForAll(
						function() commands.exec("team join " .. loggedUsers[target][3] .. " " .. loggedUsers[target][1]) end,
						function() commands.exec("tp " .. loggedUsers[target][1] .. " " .. spawns[(loggedUsers[target][3] == set.team1 and 1) or 2]) end
					)
				elseif (set.spawnsLocked) then
					if (loggedUsers[target][3] == set.team1) then
						parallel.waitForAll(
							function() commands.exec("tp " .. loggedUsers[target][1] .. " " .. positions[set.lobbyName].team1Room) end,
							function() commands.exec("team join " .. loggedUsers[target][3] .. " " .. loggedUsers[target][1]) end
						)
					else
						parallel.waitForAll(
							function() commands.exec("tp " .. loggedUsers[target][1] .. " " .. positions[set.lobbyName].team2Room) end,
							function() commands.exec("team join " .. loggedUsers[target][3] .. " " .. loggedUsers[target][1]) end
						)
					end
				end
			end,
			function() 
				if (loggedUsers[target][3] == set.team1) then
					parallel.waitForAll(
						function() commands.exec("tag " .. loggedUsers[target][1] .. " remove " .. set.team2) end,
						function() commands.exec("tag " .. loggedUsers[target][1] .. " add " .. set.team1) end
					)
				else
					parallel.waitForAll(
						function() commands.exec("tag " .. loggedUsers[target][1] .. " remove " .. set.team1) end,
						function() commands.exec("tag " .. loggedUsers[target][1] .. " add " .. set.team2) end
					)
				end
			end
		)
		local kitIsOnNewTeam = false
		for key, value in pairs(kitData) do
			if (string.sub(key, 1, 4) == loggedUsers[target][3] and string.sub(key, 6, #key) == loggedUsers[target][2]) then
				kitIsOnNewTeam = true
			end
		end
		if (not kitIsOnNewTeam) then
			loggedUsers[target][2] = "RF"
		end
		if (set.kitsGivenOut) then
			reKit(not kitIsOnNewTeam, target)
		end
	end
end

function capitalizeText(input)
	input = string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2, #input)
	for i = 1, #input do
		if (string.sub(input, i, i) == " ") then
			input = string.sub(input, 1, i) .. string.upper(string.sub(input, (i + 1), (i + 1))) .. string.sub(input, (i + 2), #input)
		end
	end
	return input
end

allCommands = {
	["refill"] = function(username, commandParts)
		local userID = getGovernmentID(username)
		local closeEnough, result
		if (set.team1 == loggedUsers[userID][3]) then
			closeEnough, result = commands.exec('execute positioned ' .. spawns[1] .. ' as @a[name=' .. username .. ',distance=..' .. set.refillRange .. '] at @s positioned ~ ~2 ~ run tp @s @s')
		else
			closeEnough, result = commands.exec('execute positioned ' .. spawns[2] .. ' as @a[name=' .. username .. ',distance=..' .. set.refillRange .. '] at @s positioned ~ ~2 ~ run tp @s @s')
		end
		if (closeEnough) then
			local ammoList = getAmmoList(userID)
			local cmdParallel = {}
			for i = 1, #ammoList do
				cmdParallel[#cmdParallel + 1] = function()
					commands.exec('clear ' .. username .. ' ' .. ammoList[i])
				end
				cmdParallel[#cmdParallel + 1] = function()
					commands.exec('give ' .. username .. ' ' .. ammoList[i] .. ' ' .. set.ammoAmount)
				end
			end
			parallel.waitForAll(
				function() commands.exec('clear ' .. username .. ' combatgear:bandagerealistic') end,
				function() commands.exec('give ' .. username .. ' combatgear:bandagerealistic ' .. set.bandageAmount) end,
				function() parallel.waitForAll(table.unpack(cmdParallel)) end
			)
		else
			commands.exec('tellraw ' .. username .. ' [{"text":"Get closer to your spawn to refill!","bold":true,"color":"dark_red"}]')
		end
	end,	
	["lock"] = function(username, commandParts)
		lockSpawns()
		resetMenu = true
		return "Spawned locked.", "green"
	end,
	["unlock"] = function(username, commandParts)
		unlockSpawns()
		resetMenu = true
		return "Spawns unlocked.", "green"
	end,
	["givekit"] = function(username, commandParts)
		if (set.spawnsLocked) then
			kitAll()
			resetMenu = true
			return "Kits given out.", "green"
		else
			return "You must lock spawns first!", "dark_red"
		end
	end,
	["start"] = function(username, commandParts)
		if (set.kitsGivenOut) then
			startGame()
			resetMenu = true
			return "Game started.", "green"
		else
			return "You must give out kits first!", "dark_red"
		end
	end,
	["go"] = function(username, commandParts)
		if (set.gameBegun) then
			if (set.go) then
				return "This command has already been run.", "dark_red"
			else
				commands.exec('title @a title {"bold":true,"color":"red","text":"START! GO FIGHT!"}')
				set.go = true
			end
		else
			return "You cannot do this while players are still in their spawns.", "dark_red"
		end
	end,
	["return"] = function(username, commandParts)
		if (set.gameBegun and not set.go) then
			returnPlayers()
			save()
			resetMenu = true
			return "Players have been returned to the lobby.", "green"
		else
			if (set.go) then
				return "It is too late for you to do this.", "dark_red"
			else
				return "Players are already in the lobby.", "dark_red"
			end
		end
	end,
	["load"] = function(username, commandParts)
		getUsers()
		return "New players have been loaded into the system.", "green"
	end,
	["ticket"] = function(username, commandParts)
		local team = commandParts[1]
		local amount = string.gsub(commandParts[2], "+", "")
		local setToAmount = false
		if (string.sub(amount, 1, 1) == "=") then
			setToAmount = true
			amount = string.sub(amount, 2, #amount)
		end
		if (team and tonumber(amount)) then
			amount = tonumber(math.floor(amount + 0.5))
			team = string.upper(team)
			if (team == set.team1) then
				if (setToAmount) then
					set.team1Tickets = amount
				else
					set.team1Tickets = set.team1Tickets + amount
				end
				set.team1Tickets = math.max(set.team1Tickets, 1)
			elseif (team == set.team2) then
				if (setToAmount) then
					set.team2Tickets = amount
				else
					set.team2Tickets = set.team2Tickets + amount
				end
				set.team2Tickets = math.max(set.team2Tickets, 1)
			end
			parallel.waitForAll(
				function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
				function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end
			)
			editBossbar(1)
			save()
			if (setToAmount) then
				return 'Set team ' .. team .. "'s tickets to " .. tostring(amount), "green"
			else
				return 'Increased team ' .. team .. "'s tickets by " .. tostring(amount), "green"
			end
		else
			return 'Error, impoper command format.', "dark_red"
		end
	end,
	["swap"] = function(username, commandParts)
		target = getGovernmentID(fillName(commandParts[1]))
		if (target) then
			swapTeam(target)
			return "Team swapped successfully for this person.", "green"
		else
			return "This person is not logged in the system.", "dark_red"
		end
	end,
	["kit"] = function(username, commandParts)
		local kitCode = commandParts[1]
		local target = commandParts[2]
		if (kitCode and target) then
			target = getGovernmentID(fillName(target))
			if (not target) then
				return "Error, cannot find this player", "dark_red"
			end
			kitCode = string.upper(kitCode)
			local isValidCode = false
			for key, value in pairs(kitData) do
				if (loggedUsers[target] and string.sub(key, 6, #key) == kitCode and string.sub(key, 1, 4) == loggedUsers[target][3]) then
					isValidCode = true
					break
				end
			end
			if (isValidCode) then
				loggedUsers[target][2] = kitCode
				reKit(true, target)
			else
				return "Error, this kit does not exist for this team.", "dark_red"
			end
		else
			return "Error, cannot find this player", "dark_red"
		end
	end,
	["norespawn"] = function(username, commandParts)
		if (set.gameBegun and not set.respawnsDisabled) then
			set.respawnsDisabled = true
			local success, output = commands.exec('title @a actionbar {"bold":true,"color":"red","text":"NO RESPAWNS!"}')
			save()
		else
			if (set.respawnsDisabled) then
				return "You must start the game first (:start, :go).", "dark_red"
			else
				return "Respawns already are disabled.", "dark_red"
			end
		end
	end,
	["tp"] = function(username, commandParts)
		lastPlayer = username
		playerPos[1], playerPos[2], playerPos[3] = getPlayerPos(username)
		local success, result = commands.exec("data get entity " .. username .. " playerGameType")
		playerMode = gamemodeTable[string.match(result[1], "entity data:%s*(%d+)%s*$")]
		commands.exec("gamemode creative " .. username)
		commands.exec("tp " .. username .. " " .. positions[set.lobbyName].infrontComputer .. " facing " .. positions[set.lobbyName].under)
	end,
	["back"] = function(username, commandParts)
		commands.exec("gamemode " .. playerMode .. " " .. username)
		commands.exec("tp " .. username .. " " .. tostring(playerPos[1]) .. " " .. tostring(playerPos[2]) .. " " .. tostring(playerPos[3]))
	end,
	["stp"] = function(username, commandParts)
		local tpLocation = commandParts[1]
		if (tpLocation) then
			if (positions[set.lobbyName][tpLocation]) then
				commands.exec("tp " .. username .. " " .. positions[set.lobbyName][tpLocation])
			elseif (spawns[tonumber(tpLocation)]) then
				commands.exec("tp " .. username .. " " .. spawns[tonumber(tpLocation)])
			elseif (tpLocation == "0") then
				commands.exec("tp " .. username .. " " .. positions[set.lobbyName].worldspawn)
			end
		end
	end,
	["cap"] = function(username, commandParts)
		local UserX, UserY, UserZ = getPlayerPos(username)
		local capName = table.concat(commandParts, " ")
		local capPos = tostring(math.floor(tonumber(UserX))) .. " " .. tostring(math.floor(tonumber(UserY))) .. " " .. tostring(math.floor(tonumber(UserZ)))
		if (capName) then
			capName = capitalizeText(capName)
		else
			capName = "Cap" .. tostring(#caps)
		end
		local alreadyExists = false
		for i = 1, #caps do
			if (string.lower(caps[i][1]) == string.lower(capName)) then
				alreadyExists = true
				caps[i] = {capName, capPos, 0, 0}
				break
			end
		end
		if (not alreadyExists) then
			caps[#caps + 1] = {capName, capPos, 0, 0}
		end
		local file = fs.open("Data/caps.txt", "w")
		file.write(textutils.serialize(caps))
		file.close()
		if (alreadyExists) then
			return [[The cap \"]] .. capName .. [[\" has been moved to ]]  .. capPos .. '.', "green"
		else
			return [[A new cap \"]] .. capName .. [[\" has been created at ]]  .. capPos .. '.', "green"
		end
	end,
	["bring"] = function(username, commandParts)
		if (loggedUsers[getGovernmentID(username)]) then
			local userTeam = loggedUsers[getGovernmentID(username)][3]
			comms.exec('tp @a[tag=' .. userTeam .. ',gamemode=!creative] ^ ^ ^5')
		else
			return "You are not logged in the system.", "dark_red"
		end
	end,
	["auth"] = function(username, commandParts)
		local authorized = fillName(commandParts[1])
		if (authorized) then
			for i = 1, #auths do 
				if (auths[i] == authorized) then
					return authorized .. ' has been previously logged.', "green"
				end
			end
			if (permaLog[authorized]) then
				if (permaLog[authorized][2] == "ADM") then
					return authorized .. ' is already logged.', "green"
				end
				permaLog[authorized][2] = "ADM"
			else
				permaLog[authorized] = {"UNK", "ADM"}
			end
			auths[#auths + 1] = authorized
			local file = fs.open("Data/auths.txt", "w")
			file.write(textutils.serialize(auths))
			file.close()
			return authorized .. ' has been given chat commands permission.', "green"
		else
			return "Could not find this player, check spelling and refresh the player tracker.", "dark_red"
		end
	end,
	["setspawn"] = function(username, commandParts)
		local userX, userY, userZ = getPlayerPos(username)
		local newSpawn = tostring(math.floor(tonumber(userX))) .. " " .. tostring(math.floor(tonumber(userY))) .. " " .. tostring(math.floor(tonumber(userZ)))
		local selectTeam = commandParts[1]
		local output = "", ""
		if (selectTeam == string.lower(set.team1)) then
			spawns[1] = newSpawn 
			output = {'Changed the spawn location for ' .. set.team1 .. '.', "green"}
		elseif (selectTeam == string.lower(set.team2)) then
			spawns[2] = newSpawn
			output = {'Changed the spawn location for ' .. set.team2 .. '.', "green"}
		elseif (selectTeam == "spec" or selectTeam == "spectator" or selectTeam == "spectators") then
			spawns[3] = newSpawn
			output = {'Changed the spawn location for spectators.', "green"}
		else
			output = {'Error, invalid command format.', "dark_red"}
		end
		local file = fs.open("Data/spawns.txt", "w")
		file.write(textutils.serialize(spawns))
		file.close()
		return output[1], output[2]
	end,
	["help"] = function(username, commandParts)
		commands.exec('tellraw ' .. username .. ' [{"text":"The following are all chat commands you can run:","bold":true,"color":"dark_aqua"},{"text":"' .. ALL_CHAT_COMMANDS .. '","bold":false,"color":"gold"}]')
	end,
	["view"] = function(username, commandParts)
		local text = '[{"text":"You have access to the following recruits:","bold":true,"color":"dark_aqua"}'
		if (fs.exists("Recruits/")) then
			local userData = getGovernmentID(username)
			if (loggedUsers[userData]) then
				fileNames = fs.list("Recruits/")
				for i = 1, #fileNames do
					local file = fs.open("Recruits/" .. fileNames[i], "r")
					local tempData = textutils.unserialize(file.readAll())
					local profileName = string.upper(string.sub(tempData[1], 1, 1)) .. string.sub(tempData[1], 2, #tempData[1])
					if (tempData[2] == loggedUsers[userData][3]) then
						text = text .. ',{"text":"\\n[' .. tostring(i) .. [[] \"]] .. profileName .. [[\"","color":"gold"}]]
					end
					file.close()
				end
			end
		end
		commands.exec('tellraw ' .. username .. ' ' .. text .. "]")
	end,
	["save"] = function(username, commandParts)
		if (set.recruitsActive) then
			local saveName = commandParts[1]
			local success, result = commands.exec('execute as ' .. username .. ' positioned ~ ~ ~ run data get entity @e[limit=1,sort=nearest,type=recruits:crossbowman]')
			if (success) then
				local userData = loggedUsers[getGovernmentID(username)]
				if (userData) then
					local nbt = {saveName, userData[3], string.match(result[1], "{.*}")}
					nbt[3] = string.gsub(nbt[3], ',?%s*([,{])%s*UUID:%s*%b[]', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*PortalCooldown: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Health: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*HurtTime: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*DeathTime: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*([,{])%s*FallDistance:%s*[^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Air: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*OnGround: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Invulnerable: [^,%}]+', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Pos: %b[]', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Motion: %b[]', '')
					nbt[3] = string.gsub(nbt[3], ',?%s*Rotation: %b[]', '')
					local file = fs.open("Recruits/" .. saveName .. ".txt", "w")
					file.write(textutils.serialize(nbt))
					file.close()
					nbt = nil
					return 'Saved to profile: ' .. saveName .. '.', "green"
				else
					return 'You are not logged in the system.', "dark_red"
				end
			else
				return 'Error, you can only save crossbowmen.', "dark_red"
			end
		end
	end,
	["spawn"] = function(username, commandParts)
		local saveName = commandParts[1]
		if (fs.exists("Recruits/" .. saveName .. ".txt") and set.recruitsActive) then
			local userTeam = loggedUsers[getGovernmentID(username)][3]
			local file = fs.open("Recruits/" .. saveName .. ".txt", "r")
			local nbt = textutils.unserialize(file.readAll())
			file.close()
			if (nbt[2] == userTeam and ((set.team1 == userTeam and set.team1Tickets >= set.recruitTicketCost) or (set.team2 == userTeam and set.team2Tickets >= set.recruitTicketCost))) then
				local spawned, result
				if (set.team1 == userTeam) then
					spawned, result = commands.exec('execute positioned ' .. spawns[1] .. ' as @a[name=' .. username .. ',distance=..' .. set.recruitSpawnRange .. '] at @s positioned ~ ~2 ~ run summon recruits:crossbowman ^ ^ ^3 ' .. nbt[3])
				else
					spawned, result = commands.exec('execute positioned ' .. spawns[2] .. ' as @a[name=' .. username .. ',distance=..' .. set.recruitSpawnRange .. '] at @s positioned ~ ~2 ~ run summon recruits:crossbowman ^ ^ ^3 ' .. nbt[3])
				end
				if (spawned) then
					if (set.go) then
						if (set.team1 == userTeam) then
							set.team1Tickets = set.team1Tickets - set.recruitTicketCost
							commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets))
						else
							set.team2Tickets = set.team2Tickets - set.recruitTicketCost
							commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets))
						end
					end
					editBossbar(1)
					local file = fs.open("Data/set.txt", "w")
					file.write(textutils.serialize(set))
					file.close()
				elseif (result and result[1]) then
					return 'Failed to spawn: ' .. result[1] .. '.', "dark_red"
				end
			end
		end
	end,
	["delete"] = function(username, commandParts)
		if (set.recruitsActive) then
			local saveName = commandParts[1]
			fs.delete("Recruits/" .. saveName .. ".txt")
			return 'Deleted profile: ' .. saveName .. ".", "green"
		end
	end,
	["arty"] = function(username, commandParts)
		if (set.useArtillery) then
			local user = getGovernmentID(username)
			if (loggedUsers[user]) then
				for i = 1, #commandParts do
					local cleanedValue = string.gsub(commandParts[i], ",", "")
					if (tonumber(cleanedValue)) then
						commandParts[i] = tonumber(cleanedValue)
					else
						commandParts[i] = nil
					end
				end
				local setCode
				if (loggedUsers[user][3] == set.team1) then
					setCode = "team1LastUseArty"
				else
					setCode = "team2LastUseArty"
				end
				if (#commandParts == 3 or #commandParts == 2) then
					if (#commandParts == 2) then
						commandParts[3] = commandParts[2]
						commandParts[2] = 70
					end
					if ((os.epoch("utc") - set[setCode]) > 120000) then
						local function canClearZone(posX, posZ)
							return (math.abs(commandParts[1] - posX) > 60) or (math.abs(commandParts[3] - posZ) > 60)
						end
						if (canClearZone(ComX, ComZ) and canClearZone(tonumber(stringToList(spawns[1])[1]), tonumber(stringToList(spawns[1])[3])) and canClearZone(tonumber(stringToList(spawns[2])[1]), tonumber(stringToList(spawns[2])[3]))) then
							set[setCode] = os.epoch("utc")
							parallelFunction.parallelSend("artillery", commandParts)
							commands.exec("execute positioned " .. tostring(commandParts[1]) .. " 70 " .. tostring(commandParts[3]) .. ' run title @a[distance=..40] actionbar {"bold":true,"color":"red","text":"Artillery inbound, evacuate or take cover!"}')
							save()
						else
							return "Selected location is too close to a protected area.", "dark_red"
						end
					else
						return "Your team has used artillery too recently, wait " .. tostring(math.floor(120 - ((os.epoch("utc") - set[setCode]) / 1000))) .. " more seconds.", "dark_red"
					end
				else
					return "Improper command format, .arty [pos1] [pos2] [pos3]", "dark_red"
				end
			else
				return "You are not logged into the system.", "dark_red"
			end
		else
			return "This system is not available right now.", "dark_red"
		end
	end,
	["m"] = function(username, commandParts)
		commands.exec('gamemode creative ' .. username)
		commands.exec('execute as ' .. username .. ' run computercraft view ' .. tostring(os.getComputerID()))
	end,
	["clear"] = function(username, commandParts)
		clearCaps()
		editBossbar(2)
		return "All caps have been unclaimed", "green"
	end,
	["log"] = function(username, commandParts)
		sendLog()
		return "Data logged to Discord.", "gold"
	end,
	["buy"] = function(username, commandParts)
		if (set.spareParts.allow and set.go) then
			local userData = loggedUsers[getGovernmentID(username)]
			local itemName = table.concat(commandParts, " ")
			local itemID = partsMapping[itemName]
			if (userData) then
				local userTeam = 2
				if (userData[3] == set.team1) then
					userTeam = 1
				end
				local teamTickets = "team" .. tostring(userTeam) .. "Tickets"
				if ((os.epoch("utc") - set.spareParts["team" .. tostring(userTeam) .. "LastBought"]) > 15000) then
					if (itemID and set.spareParts[itemID]) then
						if (set[teamTickets] >= set.spareParts.cost or set.teamTicketType == 3) then
							if (set.teamTicketType < 3) then
								set[teamTickets] = set[teamTickets] - set.spareParts.cost
								commands.exec("scoreboard players set " .. set["team" .. tostring(userTeam)] .. " spawns " .. tostring(set[teamTickets]))
								editBossbar(1)
							end
							commands.exec('execute as ' .. username .. ' at @s run summon falling_block ~ 150 ~ {BlockState:{Name:"minecraft:barrel"},Time:1,TileEntityData:{Items:[{Slot:13,id:"' .. itemID .. '",Count:1}]}}')
							set.spareParts["team" .. tostring(userTeam) .. "LastBought"] = os.epoch("utc")
							save()
							return "The supply drop is coming, please wait.", "green"
						else
							return "Your team cannot afford this.", "dark_red"
						end
					else
						local textOutput = "You can only buy: "
						for key, value in pairs(partsMapping) do
							if (set.spareParts[value]) then
								textOutput = textOutput .. capitalizeText(key) .. ", "
							end
						end
						return textOutput .. "ensure it is spelt correctly.", "dark_red"
					end
				else
					return "Your team has bought parts too recently, wait " .. tostring(math.floor(15 - ((os.epoch("utc") - set.spareParts["team" .. tostring(userTeam) .. "LastBought"]) / 1000))) .. " more seconds.", "dark_red"
				end
			else
				return "You are not logged into the system.", "dark_red"
			end
		else
			return "This system is not available right now.", "dark_red"
		end
	end,
	["fix"] = function(username, commandParts)
		parallel.waitForAll(
			function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
			function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end
		)
		editBossbar(2)
		return "Attempted to fix stuck issues.", "green"
	end
}

function chatCommands()
	while true do
		local event, username, message = os.pullEvent("chat")
		if (permaLog[username] and permaLog[username][2] == "ADM") then
			if (string.sub(message, 1, 1) == ":" or string.sub(message, 1, 1) == ".") then
				message = string.lower(message)
				local commandName = string.sub(message, 2, #message)
				local commandParts = {}
				for i = 2, #message do
					if (string.sub(message, i, i) == " ") then
						commandName = string.sub(message, 2, (i - 1))
						local positionCounter = i + 1
						local counterSavedPosition = positionCounter
						while (positionCounter <= #message) do
							if (string.sub(message, positionCounter, positionCounter) == " ") then
								commandParts[#commandParts + 1] = string.sub(message, counterSavedPosition, (positionCounter - 1))
								counterSavedPosition = positionCounter + 1
							end
							positionCounter = positionCounter + 1
						end
						commandParts[#commandParts + 1] = string.sub(message, counterSavedPosition, #message)
						break
					end
				end
				if (allCommands[commandName]) then
					local response, color = allCommands[commandName](username, commandParts)
					local commandLog = "**<" .. username .. ">** ran `" .. ":" .. commandName
					for i = 1, #commandParts do
						commandLog = commandLog .. " " .. commandParts[i]
					end
					if (response) then
						commandLog = commandLog .. "` **==>** " .. response
					else
						commandLog = commandLog .. "` **==>** no detail."
					end
					sendToDiscord(commandLog)
					if (response and color) then
						commands.exec('tellraw ' .. username .. ' [{"text":"' .. response .. '","bold":true,"color":"' .. color .. '"}]')
					end
				else
					commands.exec('tellraw ' .. username .. ' [{"text":"This command does not exist or is formatted incorrectly, do :help to learn more.","bold":true,"color":"dark_red"}]')
				end
			end
		end
		if (set.gameBegun and string.sub(string.lower(message), 1, 5) == "refil") then
			allCommands.refill(username, commandParts)
		end
	end
end

function stringToList(input)
	local savedPos = 1
	local outputList = {}
	for i = 1, #input do
		local chr = string.sub(input, i, i)
		if (chr == " " or chr == ",") then
			outputList[#outputList + 1] = string.gsub(string.gsub(string.sub(input, savedPos, (i - 1)), '"', ""), " ", "")
			savedPos = i + 1
		end
	end
	outputList[#outputList + 1] = string.gsub(string.gsub(string.sub(input, savedPos, #input), '"', ""), " ", "")
	return outputList
end

function sendToDiscord(sendData)
	discordQueue[#discordQueue + 1] = sendData
end

function pastebinUpload(text, name)
	local IP = "https://pastebin.com/api/api_post.php"
	local body = "api_dev_key=" .. textutils.urlEncode("NnIohZds7NOQQXtubE5Z1t8cxCTAWSxR") .. "&api_option=paste" .. "&api_paste_code=" .. textutils.urlEncode(text) .. "&api_paste_name=" .. textutils.urlEncode(name)
	local response = http.post(IP, body, {["Content-Type"] = "application/x-www-form-urlencoded"})
	if response then
		local result = response.readAll()
		response.close()
		return result
	else
		return "Error, cannot post to pastebin."
	end
end

function sendLog()
	local text = "Error, an event attempted to log, but there were no players."
	if (#loggedUsers > 0) then
		text = "# Event Logged\n## " .. set.team1 .. " vs. " .. set.team2 .. "\n**Players:**\n```"
		for i = 1, #loggedUsers do
			if (permaLog[loggedUsers[i][1]]) then
				text = text .. loggedUsers[i][1]
			else
				text = text .. "*" .. loggedUsers[i][1]
			end
			if (i < #loggedUsers) then
				text = text .. ", "
			end
		end
		text = text .. "```\n"
		if (#caps > 0) then
			text = text .. "**Caps:**\n```"
			for i = 1, #caps do
				text = text .. caps[i][1]
				if (i < #caps) then
					text = text .. ", "
				end
			end
			text = text .. "```\n"
		end
		local pasteURL = pastebinUpload(textutils.serialize(kitData), "Event Kit Backup " .. tostring(math.random(1000, 9999)))
		text = text .. "**All Kits Saved To:**\n" .. pasteURL .. "\nTo use these same kits in future events without remaking them, go to Manage Kits > Download > Paste the above URL."
	end
	sendToDiscord(text)
end

function editBossbar(requestPower)
	if (set.gameBegun) then
		if (requestPower == 2) then
			local text = "["
			if (set.teamTicketType ~= 2) then
				text = '[{"text":"' .. set.team1 .. '","color":"red","bold":true},{"text":" vs. ","color":"gray","bold":true},{"text":"' .. set.team2 .. '","color":"blue","bold":true}]'
			else
				for i = 1, #caps do 
					if (caps[i][3] == 0) then -- gray
						text = text .. '{"text":"' .. caps[i][1] .. '","color":"gray","bold":true}'
					else
						if (caps[i][3] == 1) then -- red
							text = text .. '{"text":"' .. caps[i][1] .. '","color":"red","bold":true}'
						else -- blue
							text = text .. '{"text":"' .. caps[i][1] .. '","color":"blue","bold":true}'
						end
					end
					if (i < #caps) then
						text = text .. ',{"text":" <> ","color":"gray","bold":false},'
					end
				end
				text = text .. "]"
			end
			commands.exec('bossbar set event:main name ' .. text)
		end
		local totalPoints = set.team1Tickets + set.team2Tickets
		local percentPoints = (math.max((set.team1Tickets / totalPoints), (set.team2Tickets / totalPoints))) * 100
		local barColor = "white"
		if (math.abs(percentPoints - 50) > 1) then
			if (set.team1Tickets > set.team2Tickets) then
				barColor = "red" 
			else
				barColor = "blue"
			end
		end
		parallel.waitForAll(
			function() commands.exec('bossbar set event:main color ' .. barColor) end,
			function() commands.exec('bossbar set event:main value ' .. tostring(math.floor(percentPoints + 0.5))) end
		)
	end
end

function clearCaps()
	for i = 1, #caps do
		caps[i][3] = 0
		caps[i][4] = 0
		set.teamTicketType = 2
	end
end

function capManage()
	while true do
		if (set.go and set.teamTicketType == 2 and not set.gameFinished) then
			if (set.gameFinished) then
				return
			end
			local cmdParallel = {}
			for i = 1, #caps do
				cmdParallel[#cmdParallel + 1] = function()
					if (caps[i][3] == 0) then
						commands.exec("execute positioned " .. caps[i][2] .. ' run title @a[distance=..' .. tostring(set.capDistance) .. '] actionbar {"bold":true,"color":"gray","text":"You are taking ' .. caps[i][1] .. ": " .. caps[i][4] .. '%..."}')
						commands.exec('particle dust 0.3 0.3 0.3 10 ' .. caps[i][2] .. ' 2 3 2 1 10')
					else
						if (caps[i][3] == 1) then
							commands.exec("execute positioned " .. caps[i][2] .. ' run title @a[distance=..' .. tostring(set.capDistance) .. '] actionbar {"bold":true,"color":"red","text":"You are taking ' .. caps[i][1] .. ": " .. caps[i][4] .. '%..."}')
							commands.exec('particle dust 1 0 0 10 ' .. caps[i][2] .. ' 2 3 2 1 10')
						else
							commands.exec("execute positioned " .. caps[i][2] .. ' run title @a[distance=..' .. tostring(set.capDistance) .. '] actionbar {"bold":true,"color":"blue","text":"You are taking ' .. caps[i][1] .. ": " .. caps[i][4] .. '%..."}')
							commands.exec('particle dust 0 0 1 10 ' .. caps[i][2] .. ' 2 3 2 1 10')
						end
					end
					local success, output = commands.exec("execute positioned " .. caps[i][2] .. ' run data get entity @a[distance=..' .. tostring(set.capDistance) .. ',gamemode=survival,limit=1,sort=nearest] Pos')
					if (success) then
						local username = string.match(output[1], "^(%S+)")
						username = getGovernmentID(username)
						if (caps[i][3] and caps[i][3] == 0) then
							if (loggedUsers[username][3] == set.team1) then
								caps[i][3] = 1
							else
								caps[i][3] = 2
							end
							editBossbar(2)
						else
							if (loggedUsers[username] and set["team" .. tostring(caps[i][3])] and loggedUsers[username][3] == set["team" .. tostring(caps[i][3])]) then
								caps[i][4] = math.min(caps[i][4] + 1, 100)
							else
								caps[i][4] = math.max(caps[i][4] - 1, 0)
								if (caps[i][4] == 0) then
									caps[i][3] = 0
								end
							end
						end
					end
				end
			end
			save()
			parallel.waitForAll(table.unpack(cmdParallel))
		else
			sleep(1)
		end
		sleep(0.05)
	end
end

function winCondition(teamLeft)
	winnerTeam = 0
	if (set.teamTicketType == 3) then
		set.roundsLeft = set.roundsLeft - 1
		set["roundWins" .. tostring(teamLeft)] = set["roundWins" .. tostring(teamLeft)] + 1
		set["team" .. tostring(teamLeft) .. "Tickets"] = set["team" .. tostring(teamLeft) .. "Tickets"] + 1
		commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set["roundWins" .. tostring(teamLeft)]))
		if (set.roundWins1 ~= set.roundWins2 and set.roundsLeft == 0) then
			if (set.roundWins1 > set.roundWins2) then
				winnerTeam = 1
			else
				winnerTeam = 2
			end
		else
			if (set.roundSpawnSwap) then
				local spawn = spawns[1]
				spawns[1] = spawns[2]
				spawns[2] = spawn
			end
			startGame()
			parallel.waitForAll(
				function() commands.exec('effect give @a minecraft:resistance 30 255 true') end,
				function() commands.exec('effect give @a minecraft:absorption 30 5 true') end,
				function() commands.exec('title @a title {"bold":true,"color":"red","text":"FIGHT IN 30 SECONDS!"}') end
			)
		end
	else
		winnerTeam = teamLeft
	end
	if (winnerTeam ~= 0) then
		set.gameFinished = true
		editBossbar(1)
		parallel.waitForAll(
			function() commands.exec('title @a title {"bold":true,"color":"red","text":"TEAM ' .. set["team" .. tostring(winnerTeam)] .. ' HAS WON!"}') end,
			function() commands.exec('clear @a[gamemode=survival]') end,
			function() commands.exec('execute as @a[gamemode=survival] at @s run tp @s ~ ~25 ~') end,
			function() commands.exec('execute as @a[gamemode=survival] at @s run particle dust 1 0.5 0 10 ~ ~ ~ 0.6 3 0.6 1 40') end
		)
		commands.exec('gamemode spectator @a[gamemode=survival]')
	end
	save()
end

function capDepletion()
	while true do
		if (set.teamTicketType == 2 and set.go and not set.gameFinished) then
			local updateTickets = false
			local allCapOwner = 3
			for i = 1, #caps do
				if (caps[i][4] == 100) then -- Only depletes if the capture% is 100% to give the other team a chance
					if (set["team" .. tostring(3 - caps[i][3]) .. "Tickets"] == 1) then
						commands.exec('title @a actionbar {"bold":true,"color":"red","text":"' .. set["team" .. tostring(3 - caps[i][3])] .. ' has 0 tickets, they will lose if ' .. set["team" .. tostring(caps[i][3])] .. ' controls all caps."}')
					end
					set["team" .. tostring(3 - caps[i][3]) .. "Tickets"] = math.max(0, set["team" .. tostring(3 - caps[i][3]) .. "Tickets"] - 1)
					updateTickets = true
					if (allCapOwner == 3 or allCapOwner == caps[i][3]) then
						allCapOwner = caps[i][3]
					else
						allCapOwner = nil
					end
				else
					allCapOwner = nil
				end
			end
			if (updateTickets) then
				parallel.waitForAll(
					function() commands.exec("scoreboard players set " .. set.team1 .. " spawns " .. tostring(set.team1Tickets)) end,
					function() commands.exec("scoreboard players set " .. set.team2 .. " spawns " .. tostring(set.team2Tickets)) end
				)
				editBossbar(1)
			end
			if (allCapOwner and set["team" .. tostring(3 - allCapOwner) .. "Tickets"] == 0) then
				winCondition(allCapOwner)
			end
		end
		sleep(20)
	end
end

function getFile(fileName)
	if (fileName) then
		local file = fs.open(fileName, "r")
		local fileData = file.readAll()
		file.close()
		return fileData
	end
	return nil
end

function pasteFile(fileName, fileData)
	if (fileName and fileData) then
		local file = fs.open(fileName, "w")
		file.write(fileData)
		file.close()
	end
end

function confirming(question, option1, option2)
	local input = 1
	local offset = 0
	if (#question > 50) then
		offset = 1
	end
	repeat
		comms.clearAll()
		comms.goLine(1, 1)
		comms.setColor(colors.orange)
		comms.printText(question)
		comms.setColor(colors.cyan)
		comms.printText("\4 " .. option1)
		comms.setColor(colors.red)
		comms.printText("\4 " .. option2)
		_, input = getClickInput()
		input = input - offset
	until (input == 2 or input == 3)
	if (input == 2) then
		return true
	else
		return false
	end
end

function update(body)
	local endPoint = false
	for i = 14, 18 do
		if (string.sub(body, i, i) == '"') then
			endPoint = i - 1
		end
	end
	if (endPoint and (tonumber(string.sub(body, 14, endPoint)) > tonumber(string.sub(version, 3, #version)))) then
		updatePause = true
		resetMenu = true
		local input = 1
		repeat
			comms.clearAll()
			comms.goLine(1, 1)
			comms.setColor(colors.orange)
			comms.printText("A new official update (v" .. string.sub(body, 12, endPoint) .. ") has been released, would you like to switch to using this new version?")
			comms.setColor(colors.cyan)
			comms.printText("\4 Update to v" .. string.sub(body, 12, endPoint))
			comms.setColor(colors.red)
			comms.printText("\4 Keep this version.")
			_, input = getClickInput()
		until (input == 3 or input == 4)
		if (input == 3) then
			pasteFile("startup.lua", body)
			term.clear()
			error("Please restart the computer for the update to take effect.", 0)
		end
		updatePause = false
		resetMenu = false
	end
end

function tips()
	local currentTip = 1
	local tips = {
		'Say \'refill\' in chat near your spawn to refill on ammo and bandages without dying!',
		"Keep close to members of your team, you're NOT John Wick.",
		'Move from cover to cover, or respawn to respawn.',
		"NPC soldiers aren't as bad of shots as they seem, especially in close range.",
		"Never go where the enemy expects you to.",
		"When using tanks, use them sparingly, don't risk it all for one kill.",
		"Tactics are usually more important than kills."
	}
	repeat
		sleep(60)
		if (set.gameBegun and set.showProTips) then
			commands.exec('tellraw @a [{"text":"Pro Tip:\\n","color":"gold"},{"text":"' .. tips[currentTip] .. '","color":"yellow"}]')
		end
		currentTip = (currentTip % #tips) + 1
	until (set.gameFinished)
end

function logging()
	local gate, err = http.get("https://pastebin.com/raw/nuk9w93y")
	if (gate) then
		local success, body = pcall(function() return gate.readAll() end)
		if (success and publicBuild) then
			update(body)
		end
	end
	if (not set.gameBegun) then
		repeat
			sleep(2)
		until(set.gameBegun)
		sendLog()
	end
end

function fixerCommands()
	repeat
		sleep(1)
	until (set.gameSetup)
	while true do
		if (set.gameBegun) then
			commands.exec("spawnpoint @a " .. positions[set.lobbyName].deathSpawn)
		end
		if (not set.go) then
			commands.exec('effect give @a minecraft:regeneration 11 255 true')
		end
		if (set.gameBegun and set.spawnProtection) then
			local success, _ = commands.exec('execute positioned ' .. spawns[1] .. ' run title @a[tag=' .. set.team2 .. ',gamemode=survival,distance=..' .. tostring(set.spawnCampDistance) .. '] actionbar {"bold":true,"color":"red","text":"You were too close to the enemy\'s spawn."}')
			if (success) then
				local success, output = commands.exec('execute positioned ' .. spawns[1] .. ' run tp @a[tag=' .. set.team2 .. ',gamemode=survival,distance=..' .. tostring(set.spawnCampDistance) .. '] ' .. spawns[2])
				sendToDiscord(output[1])
			end
			local success, _ = commands.exec('execute positioned ' .. spawns[2] .. ' run title @a[tag=' .. set.team1 .. ',gamemode=survival,distance=..' .. tostring(set.spawnCampDistance) .. '] actionbar {"bold":true,"color":"red","text":"You were too close to the enemy\'s spawn."}')
			if (success) then
				local success, output = commands.exec('execute positioned ' .. spawns[2] .. ' run tp @a[tag=' .. set.team1 .. ',gamemode=survival,distance=..' .. tostring(set.spawnCampDistance) .. '] ' .. spawns[1])
				sendToDiscord(output[1])
			end
		end
		sleep(10)
	end
end

parallelFunction = {
	["parallelSend"] = function(command, data)
		os.queueEvent("parallelHandler", command, data)
	end,
	["parallelHandler"] = function()
		local canEnd = false
		repeat
			local event, param1, param2 = os.pullEvent("parallelHandler")
			if (parallelFunction[param1]) then
				parallelFunction[param1](param2)
			end
		until (canEnd)
	end,
	["artillery"] = function(data)
		local coordinates = 0
		for i = 1, math.random(20, 25) do
			coordinates = tostring(data[1] + (math.random(1, 80) - 40)) .. " 300 " .. tostring(data[3] + (math.random(1, 80) - 40))
			commands.exec('summon createbigcannons:he_shell ' .. coordinates .. ' {HasBeenShot:1b,Fuze:{id:"createbigcannons:impact_fuze",Count:1b}}')
			sleep(0.5)
		end
	end
}

function modsCheck()
	local fileNames = fs.list("")
	local addonFileNames = {}
	for i = 1, #fileNames do
		if (string.sub(fileNames[i], 1, 6) == "addon_") then
			addonFileNames[#addonFileNames + 1] = fileNames[i]
		end
	end
	if (#addonFileNames > 0) then
		local codeLines = {}
		local file = fs.open("startup.lua","r")
		while true do
			local line = file.readLine()
			if (not line) then 
				break 
			end
			codeLines[#codeLines + 1] = line
		end
		file.close()
		codeLines[#codeLines] = nil
		addonMetaData = {}
		for i = 1, #addonFileNames do
			local file = fs.open(addonFileNames[i], "r")
			local line = file.readLine()
			addonMetaData[#addonMetaData + 1] = {string.upper(string.sub(addonFileNames[i], 7, 7)) .. string.lower(string.sub(addonFileNames[i], 8, (#addonFileNames[i] - 4))), string.sub(line, 4, math.min(#line, 500))}
			while true do
				local line = file.readLine()
				if (not line) then 
					break 
				end
				codeLines[#codeLines + 1] = line
			end
			file.close()
		end
		local file = fs.open("modded.lua", "w")
		file.write("")
		file.close()
		local file = fs.open("modded.lua", "a")
		for i = 1, #codeLines do
			file.write(codeLines[i] .. "\n")
		end
		for i = 1, #addonMetaData do
			file.write('addonMetaData[#addonMetaData + 1] = {"' .. addonMetaData[i][1] .. '", "' .. addonMetaData[i][2] .. '"}\n')
		end
		file.write("readKits(); setup(); parallel.waitForAll(doMainMenu, deathCheck, chatCommands, capManage, capDepletion, logging, tips, fixerCommands, parallelFunction.parallelHandler, discordTerminal)")
		file.close()
		shell.run("modded.lua")
		error("The modded instance has crashed.", 0)
	end
end

function verifyAmmoReference()
	local ammoSorted = {}
	for key, value in pairs(ammoReference) do
		if (not ammoSorted[value]) then
			ammoSorted[value] = {}
		end
		ammoSorted[value][#ammoSorted[value] + 1] = key
	end
	local textLog = "# The following weapons are logged:\n"
	for key, value in pairs(ammoSorted) do
		textLog = textLog .. "## " .. key .. "\n"
		for i = 1, #ammoSorted[key] do
			textLog = textLog .. "> " .. ammoSorted[key][i] .. "\n"
		end
	end
	textLog = string.gsub(textLog, "pointblank:", "")
	sendToDiscord(textLog)
end

function discordTerminal()
	while true do
		while (#discordQueue <= discordQueueLogged) do
			sleep(0.1)
		end
		discordQueueLogged = discordQueueLogged + 1
		local IP = "https://discord.com/api/webhooks/1403528633582096519/DM-MwaL6lbei8liMh3pt75fdoERsqt14i01jdGCdXx0m0nFLFrLuVU3fLDdHcoltyLtt"
		http.post(IP, textutils.serializeJSON({["content"] = discordQueue[discordQueueLogged]}), {["Content-Type"] = "application/json"})
		discordQueue[discordQueueLogged] = nil
	end
end


-- Main Cycle & Addons
modsCheck(); readKits(); setup(); parallel.waitForAll(doMainMenu, deathCheck, chatCommands, capManage, capDepletion, logging, tips, fixerCommands, parallelFunction.parallelHandler, discordTerminal)