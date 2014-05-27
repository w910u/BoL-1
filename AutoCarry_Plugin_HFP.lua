local version = 0.15
local autoupdate = true
local scriptname = "AutoCarry_Plugin_HFP"
-----
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/HFPDarkAlex/BoL/master/"..scriptname..".lua".."?rand="..math.random(1,10000)

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if autoupdate then
	 local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/honda7/BoL/master/Common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end

function OnLoad()
VP = VPrediction()
SOWi = SOW(VP)
STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
DLib = DamageLib()
DManager = DrawManager()

Q = Spell(_Q, Ranges[_Q])
W = Spell(_W, Ranges[_W])
E = Spell(_E, Ranges[_E])
R = Spell(_R, Ranges[_R])

Q:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_Q], Delays[_Q], Speeds[_Q], false)
W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_W], Delays[_W], Speeds[_R], false)
R:SetSkillshot(VP, SKILLSHOT_CONE, Widths[_R], Delays[_R], Speeds[_R], false)

Q:SetAOE(true)
W:SetAOE(true)
R:SetAOE(true, R.width, 0)

DLib:RegisterDamageSource(_Q, _MAGIC, 35, 40, _MAGIC, _AP, 0.8)
DLib:RegisterDamageSource(_W, _MAGIC, 15, 10, _MAGIC, _AP, 0.15, function() return (player:CanUseSpell(_W) == READY) end)
DLib:RegisterDamageSource(_E, _MAGIC, 35, 35, _MAGIC, _AP, 0.55)
DLib:RegisterDamageSource(_R, _MAGIC, 75, 125, _MAGIC, _AP, 0.6, function() return (player:CanUseSpell(_R) == READY) end)

Menu = scriptConfig("Cassiopeia", "Cassiopeia")

Menu:addSubMenu("Orbwalking", "Orbwalking")
SOWi:LoadToMenu(Menu.Orbwalking)

Menu:addSubMenu("Target selector", "STS")
STS:AddToMenu(Menu.STS)

Menu:addSubMenu("Combo", "Combo")
Menu.Combo:addParam("UseQ", "Use Q in combo", SCRIPT_PARAM_ONOFF , true)
Menu.Combo:addParam("UseW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("UseE", "Use E on poisoned targets", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("UseEP", "Use E using packets", SCRIPT_PARAM_ONOFF, false)
Menu.Combo:addParam("UseR", "Use R if enemy killable", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("UseIgnite", "Use ignite if the target is killable", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)

Menu:addSubMenu("Harass", "Harass")
Menu.Harass:addParam("UseQ", "Harass using Q", SCRIPT_PARAM_ONOFF, true)
Menu.Harass:addParam("UseW", "Harass using W", SCRIPT_PARAM_ONOFF, false)
Menu.Harass:addParam("UseE", "Harass using E on poisoned", SCRIPT_PARAM_ONOFF, true)
Menu.Harass:addParam("Enabled", "Harass! (hold)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
Menu.Harass:addParam("Enabled2", "Harass! (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))

Menu:addSubMenu("Farm", "Farm")
Menu.Farm:addParam("UseQ", "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freeze", "LaneClear", "Both" })
Menu.Farm:addParam("UseW", "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
Menu.Farm:addParam("UseE", "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
Menu.Farm:addParam("Freeze", "Farm freezing", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
Menu.Farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))

Menu:addSubMenu("JungleFarm", "JungleFarm")
Menu.JungleFarm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Menu.JungleFarm:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, false)
Menu.JungleFarm:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, false)
Menu.JungleFarm:addParam("Enabled", "Farm jungle!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))

Menu:addSubMenu("Ultimate", "Ultimate")
Menu.Ultimate:addParam("Auto", "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 targets", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
Menu.Ultimate:addParam("AutoAim", "Cast ultimate!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))

Menu:addSubMenu("Drawings", "Drawings")
--Spell ranges
for spell, range in pairs(Ranges) do
DManager:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, SpellToString(spell).." Range", true, true, true)
end
DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)
--Predicted damage on healthbars
DLib:AddToMenu(Menu.Drawings, MainCombo)

EnemyMinions = minionManager(MINION_ENEMY, Ranges[_W], myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, Ranges[_W], myHero, MINION_SORT_MAXHEALTH_DEC)

TickLimiter(AutoR, 15)
end
