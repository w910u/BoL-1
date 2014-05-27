local version = "0.15"
local autoupdate = true
local scriptname = "AutoCarry_Plugin_HFP"
-----
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/HFPDarkAlex/BoL/master/"..scriptname..".lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

function AutoupdaterMsg(msg) print("<font color=\"#FF0000\">"..scriptname..":</font> <font color=\"#FFFFFF\">"..msg..".</font>")
end

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

Menu:addSubMenu("Drawings", "Drawings")
DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)

TickLimiter(AutoR, 15)
end

function OnTick()
SOWi:EnableAttacks()

if Menu.Combo.Enabled then
Combo()
end
end
