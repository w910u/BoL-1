--- [[Info]] ---
local version = 0.01
local AUTOUPDATE = true
local SCRIPT_NAME = "[HFP]Rengar"
--- [[Update + Libs]] ---
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
if FileExist(SOURCELIB_PATH) then
require("SourceLib")
else
DOWNLOADING_SOURCELIB = true
DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end
if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end
if AUTOUPDATE then
SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/HFPDarkAlex/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/HFPDarkAlex/BoL/master/versions/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/SOW.lua")
RequireI:Check()
if RequireI.downloadNeeded == true then return end				
--- [[Spell Data]] ---
local Ranges = {[_Q] = 125, [_W] = 500, [_E] = 1000, [_R] = 600}
local Widths = {[_Q] = 75, [_W] = 106, [_R] = 80 * math.pi / 180}
local Delays = {[_Q] = 0.6, [_W] = 0.5, [_R] = 0.3}
local Speeds = {[_Q] = math.huge, [_W] = 2500, [_R] = 6000}
--- [[Body]] ---
function OnLoad()
	Vars()
	Menu()
	print("<font color=\"#FF8000\"><b>" ..">>  Rengar Combo</b> by HFPDarkAlex has been loaded")
end

function OnTick()
	SOWi:EnableAttacks()
	
	if Menu.Combo then
		Combo()
	end
    if Menu.Harass then
        Harass()
    end
end


function Menu()
			Menu = scriptConfig("Rengar Combo", "Rengar")
			Menu:addParam("sep", "----- [ General Settings ] -----", SCRIPT_PARAM_INFO, "")
			
            Menu:addParam("Combo","Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
            Menu:addSubMenu("Combo Settings", "ComboS")
			
			Menu:addParam("Harass", "Harass", SCRIPT_PARAM_ONOFF

			Menu:addSubMenu("OrbWalking", "OrbWalking")
				SOWi:LoadToMenu(Menu.OrbWalking)
				
			Menu:addSubMenu("TargetSelector", "STS")
				STS:AddToMenu(Menu.STS)
end



function Vars()
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

end