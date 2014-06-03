--- Info
local version = 0.09
local AUTOUPDATE = true
local SCRIPT_NAME = "AutoCarryHFP"
--- Update
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
SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/HFPDarkAlex/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/honda7/BoL/master/versions/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end
--- libs
local ignite = nil
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, SOTDSlot, EntropySlot, YGSlot, HealthSlot, ManaSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, BRKREADY, DFGREADY, HXGREADY, BWCREADY, TMTREADY, RAHREADY, RNDREADY, SOTDREADY, EntropyREADY, YGREADY, HEALTHREADY, MANAREADY = false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
local ts
local tick = nil
local AArange = 550 --[[        Auto attack range of Vayne      ]]--
local Qrange = 250 --[[ Tumble distance ]]--
local Erange = 575 --[[ The range of your condemn. Max distance is 450.  ]]--
local tumblebufferrange = 200 --[[      When an enemy hero enters this range on rambo mode, Vayne will automatically tumble to your mouse.      ]]--
local tumbleattacknowrange = 250 --[[   After vayne tumbles to your mouse, it will check if enemy hero is 250 distance away. If yes, attack.    ]]--

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
Menu.Combo:addParam("UseR", "Use R in combo", SCRIPT_PARAM_ONOFF , true)
Menu.Combo:addParam("UseAutoE", "Use E in enemy stanable", SCRIPT_PARAM_ONOFF , true)
Menu.Combo:addParam("UseIgnite", "Use ignite if the target is killable", SCRIPT_PARAM_ONOFF, true)
Menu.Combo:addParam("BRKUse", "BRK Health Use", SCRIPT_PARAM_SLICE, .85, 0, 1, 2)
Menu.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)

Menu:addSubMenu("Drawings", "Drawings")
DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)
PrintChat("<font color=\"#FF0000\"> >> Auto Carry Plugin by HFPDarkAlex v"..version.." loaded!")
end

function SetAttacks()
SOWi:DisableAttacks()
if not QREADY and not EREADY then
SOWi:EnableAttacks()
end
end

function OnTick()
SOWi:EnableAttacks()
if Menu.Combo.Enabled then
Combo()
end
if myHero:GetSpellData(_E).level > 0 then
	StunPos = nil
	local Etarget = STS:GetTarget(1000, n)
	if EREADY and AgaistWall(Etarget) and Menu.Combo.UseAutoE then
		CastSpell(_E, Etarget)
	end
end
        BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, SOTDSlot, EntropySlot, YGSlot, HealthSlot, ManaSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074),  GetInventorySlotItem(3143), GetInventorySlotItem(3131), GetInventorySlotItem(3184), GetInventorySlotItem(3142), GetInventorySlotItem(2003), GetInventorySlotItem(2004)
        DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
        HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
        BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
        BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
        TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
        RAHREADY = (RAHSlot ~= nil and myHero:CanUseSpell(RAHSlot) == READY)
        RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
        EntropyREADY = (EntropySlot ~= nil and myHero:CanUseSpell(EntropySlot) == READY)
        YGREADY = (YGSlot ~= nil and myHero:CanUseSpell(YGSlot) == READY)
        HEALTHREADY = (HEALTHSlot ~= nil and myHero:CanUseSpell(HEALTHSlot) == READY)
        MANAREADY = (MANASlot ~= nil and myHero:CanUseSpell(MANASlot) == READY)
        SOTDREADY = (SOTDSlot ~= nil and myHero:CanUseSpell(SOTDSlot) == READY)
        IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
end

function AgainstWall(Target)
        TargetPos = Vector(Target.x, Target.y, Target.z)
        MyPos = Vector(myHero.x, myHero.y, myHero.z)
        StunPos = TargetPos+(TargetPos-MyPos)*((VayneParameters.stunDistance/GetDistance(Target)))
  if StunPos ~= nil and mapPosition:intersectsWall(Point(StunPos.x, StunPos.z)) then
                return true
        end
end

function Combo()
	local target = STS:GetTarget(1000,n)
	if DFGREADY then CastSpell(DFGSlot, target) end
          if HXGREADY then CastSpell(HXGSlot, target) end
          if BWCREADY then CastSpell(BWCSlot, target) end
          if BRKREADY and player.health/player.maxHealth <= Menu.Combo.BRKUSE then CastSpell(BRKSlot, target) end
          if SOTDREADY then CastSpell(SOTDSlot) end
          if EntropyREADY then CastSpell(EntropySlot) end
          if YGREADY then CastSpell(YGSlot) end
          if HEALTHREADY then CastSpell(HEALTHSlot) end
          if MANAREADY then CastSpell(MANASlot) end
          if TMTREADY and GetDistance(target) < 275 then CastSpell(TMTSlot) end
          if RAHREADY and GetDistance(target) < 275 then CastSpell(RAHSlot) end
          if RNDREADY and GetDistance(target) < 275 then CastSpell(RNDSlot) end
if Menu.Combo.UseR and RREADY then
	CastSpell(_R)
end
if Menu.Combo.UseIgnite and _IGNITE then
local Ignitetarget = STS:GetTarget(600)
if Ignitetarget and DLib:IsKillable(Ignitetarget, MainCombo) then
CastSpell(_IGNITE, Ignitetarget)
end
end
UseSpells(Menu.Combo.UseQ, Menu.Combo.UseR)
SetAttacks()
end

function UseSpells(UseQ, UseR)
--Q
if UseQ then
local Qtarget = STS:GetTarget(AArange, n)
if Qtarget and QREADY then
CastSpell(_Q, mousePos.x, mousePos.z)
end
end
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
