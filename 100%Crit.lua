-- Credits:
-- Jire - For basic script and idea

--- [[Info]] ---
local version = 0.01
local AUTOUPDATE = true
local SCRIPT_NAME = "100%Crit"
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
RequireI:Add("vPrediction", "https://raw.githubusercontent.com/HFPDarkAlex/Scripts/master/Common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.githubusercontent.com/HFPDarkAlex/Scripts/master/Common/SOW.lua")
RequireI:Check()
if RequireI.downloadNeeded == true then return end

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	DLib = DamageLib()
	DManager = DrawManager()
	
	Menu = scriptConfig("OnlyCritical", "OnlyCritical")
	Menu:addParam("enable", "Enable script?", SCRIPT_PARAM_ONKEYTOGGLE, false,   string.byte("I"))
	Menu:addParam("critChance", "Minimum Crititcal Chance", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
	Menu:addParam("minTarg", "Targets In Range For Deactivate", SCRIPT_PARAM_SLICE, 1, 0, 5, 1)
	Menu:addParam("Print", "Print to chat number of targets", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))
	DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu, "AA Range", true, true, true)
	
	Menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Menu.Orbwalking)

	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)
	
	EnemyMinions = minionManager(MINION_ENEMY, 1000, player, MINION_SORT_HEALTH_ASC)
	
	PrintChat("<font color=\"#FFFFFF\">Only<font color=\"#FE642E\">Critical<font color=\"#04B404\"> has been loaded")
end

local deac = 0
local obj = 0

function CountObjects()
	obj = 0
	for k = 0, objManager.maxObjects do
		temp = objManager:GetObject(k)
		if temp and temp.team ~= myHero.team and ValidTarget(temp, player.range + 40) then
			obj = obj + 1
		end
	end
		PrintChat(obj)
	
	-- CountObjectsNearPos(myHero, player.range, player.range, SelectUnits(GetEnemyHeroes(), function(t) return ValidTarget(t) end))
end


function OnTick()
	if player.dead or GetGame().isOver then return end
	EnemyMinions:update()
	if Menu.Print then 
		CountObjects()
	end
end

function OnProcessSpell(unit, spell)
	if not Menu.enable or player.critChance < (Menu.critChance / 100) or spell.target == nil or spell.target.name:find("Turret_") ~= nil or deac == 1 then
		return
	end
	if unit.isMe and spell.name:find("BasicAttack") ~= nil then
		player:HoldPosition()
		target = findTargetOtherThan(spell.target)
		if target ~= nil then
			CountObjects()
			player:Attack(target)
		else
		end
	end
end

function findTargetOtherThan(target)
	local temp
	for i = 0, heroManager.iCount, 1 do
		temp = heroManager:getHero(i)
		if temp.team ~= player.team and temp ~= target and ValidTarget(temp, player.range + 40) then
			return temp -- valid hero
		end
	end
	for k = 0, objManager.maxObjects do
		temp = objManager:GetObject(k)
		if temp and temp.name:find("Minion_") ~= nil and temp ~= target and ValidTarget(temp, player.range + 40) then
			return temp -- valid minion
		end
	end
	return nil
end

function OnDraw()
		if player.dead or GetGame().isOver then return end
		for index,object in pairs(EnemyMinions.objects) do
			if object.valid and ValidTarget(object) and object.health < player:CalcDamage(object, player.totalDamage) then
				DrawCircle(object.x, object.y, object.z, 90, 0xFFFFFF)
				DrawCircle(object.x, object.y, object.z, 91, 0xFFFFFF)
				DrawCircle(object.x, object.y, object.z, 92, 0xFFFFFF)
			end
		end
end