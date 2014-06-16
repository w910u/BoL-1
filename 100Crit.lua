-- Credits:
-- TheMaynard  - For the script... Sorry For didn't see his topic and made script by Jire Idea
-- Jire - For topic on forum)


--- [[Info]] ---
local version = 0.20
local AUTOUPDATE = true
local SCRIPT_NAME = "100Crit"
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
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_PHYSICAL)
	DLib = DamageLib()
	DManager = DrawManager()
	
	Menu = scriptConfig("OnlyCritical", "OnlyCritical")
	Menu:addParam("enable", "Enable script?", SCRIPT_PARAM_ONKEYTOGGLE, false,   string.byte("I"))
	Menu:addParam("TargSelect", "Select Good Target (Bind Orbwalker Carry Me Hotkey)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
	Menu:addParam("OnlyJungle", "Only Jungle Creeps", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("J"))
	Menu:permaShow("enable")
	Menu:addParam("critChance", "Minimum Crititcal Chance", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
	-- Menu:addParam("MinObj", "Minimum Targets For Script Active", SCRIPT_PARAM_SLICE, 1, 1, 5, 1)
	DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu, "AA Range", true, true, true)
	
	Menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Menu.Orbwalking)

	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)
	
	EnemyMinions = minionManager(MINION_ENEMY, SOWi:MyRange(), player, MINION_SORT_HEALTH_ASC)
	JungleMinions = minionManager(MINION_JUNGLE, SOWi:MyRange(), player, MINION_SORT_MAXHEALTH_DEC)
	
	PrintChat("<font color=\"#FFFFFF\">Only<font color=\"#FE642E\">Critical<font color=\"#04B404\"> has been loaded")
end

local deac = 0
local _Objects = 0

function CountObjects(objects)
	local n = 0
    for i, object in ipairs(objects) do
        if GetDistance(myHero.visionPos, object) <= (SOWi:MyRange() + 40) then
            n = n + 1
        end
    end

    return n
end


function OnTick()
	if player.dead or GetGame().isOver then return end
	EnemyMinions:update()
	JungleMinions:update()
	-- if Menu.TargSelect then
		-- Combo()
	-- end
end

-- function Combo()
	-- local AATarget = STS:GetTarget(SOWi:MyRange())
	-- if AATarget then
		-- player:Attack(target)
	-- end
-- end

function OnProcessSpell(unit, spell)
	if not Menu.enable or player.critChance < (Menu.critChance / 100) or spell.target == nil or spell.target.name:find("Turret_") ~= nil or deac == 1 then
		return
	end
	
	_Objects = CountObjects(GetEnemyHeroes()) + CountObjects(EnemyMinions.objects) + CountObjects(JungleMinions.objects) 
	if Menu.OnlyJungle then
		_Objects = CountObjects(JungleMinions.objects)
	end
	if _Objects <= 1 then
		return
	end
	
	if unit.isMe and spell.name:find("BasicAttack") ~= nil then
		player:HoldPosition()
		target = findTargetOtherThan(spell.target)
		if target ~= nil then
			player:Attack(target)
		else
		end
	end
end

function findTargetOtherThan(target)
	local temp
	for i = 0, heroManager.iCount, 1 do
		temp = heroManager:getHero(i)
		if temp.team ~= player.team and temp ~= target and ValidTarget(temp, SOWi:MyRange() + 40) then
			return temp -- valid hero
		end
	end
	for k = 0, objManager.maxObjects do
		temp = objManager:GetObject(k)
		if temp and temp.name:find("Minion_") ~= nil and temp ~= target and ValidTarget(temp, SOWi:MyRange() + 40) then
			return temp -- valid minion
		end
	end
	for l, minion in pairs(JungleMinions.objects) do
		temp = minion
		if temp ~= nil and 
		temp.valid and GetDistance(temp) < (SOWi:MyRange() + 40) and temp ~= target then
			return minion
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