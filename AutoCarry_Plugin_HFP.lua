local version = "0.03"
local autoupdate = true
local scriptname = "AutoCarry_Plugin_HFP"
-----
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/HFPDarkAlex/BoL/master/"..scriptname..".lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..scriptname..".lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

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

Menu = scriptConfig("AutoCarry_Plugin_HFP", "HFPDarkAlex")

Menu:addSubMenu("Orbwalking", "Orbwalking")
SOWi:LoadToMenu(Menu.Orbwalking)

Menu:addSubMenu("Target selector", "STS")
STS:AddToMenu(Menu.STS)

Menu:addSubMenu("Combo", "Combo")
Menu.Combo:addParam("UseQ", "Use Q in combo", SCRIPT_PARAM_ONOFF , true)
Menu.Combo:addParam("UseIgnite", "Use ignite if the target is killable", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)

Menu:addSubMenu("Drawings", "Drawings")
DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)
PrintChat(" >> Auto Carry Plugin by HFPDarkAlex v"..versin.." loaded!")
end

function OnTick()
SOWi:EnableAttacks()

if Menu.Combo.Enabled then
Combo()
end
end
function AutoIgnite(enemy)
	--- Simple Auto Ignite ---
	--->
		if enemy.health <= iDmg and GetDistanceSqr(enemy) <= 600*600 then
			if iReady then CastSpell(ignite, enemy) end
		end
	---<
	--- Simple Auto Ignite ---
end
function UseItems(enemy)
	--- Use Items (Will Improve Soon) ---
	--->
		if not enemy then
			enemy = Target
		end
		if ValidTarget(enemy) and enemy ~= nil then
			if dfgReady and GetDistanceSqr(enemy) <= 600*600 then CastSpell(dfgSlot, enemy) end
			if bftReady and GetDistanceSqr(enemy) <= 600*600 then CastSpell(bftSlot, enemy) end
			if hxgReady and GetDistanceSqr(enemy) <= 600*600 then CastSpell(hxgSlot, enemy) end
			if bwcReady and GetDistanceSqr(enemy) <= 450*450 then CastSpell(bwcSlot, enemy) end
			if brkReady and GetDistanceSqr(enemy) <= 450*450 then CastSpell(brkSlot, enemy) end
		end
	---<
	--- Use Items ---
end
function CastR()
	--- Dynamic R Cast ---
	--->
		if not SkillR.ready then
			return false
		else
			CastSpell(_R)
			SkillR.castingUlt = true
		end
	---<
	--- Dymanic R Cast --
end
