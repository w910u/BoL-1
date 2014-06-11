--[[
	Vladimir Combo 0.1
		by HFPDarkAlex
		
	Features:
		- Full combo: R -> Items -> E -> Q -> W
		- Supports: Deathfire Grasp, Liandry's Torment, Blackfire Torch, Bilgewater Cutlass, Hextech Gunblade, Blade of the Ruined King, Sheen, Trinity, Lich Bane, Iceborn Gauntlet, Shard of True Ice, Randuin's Omen and Ignite
		- Harass mode: E -> Q
		- Stack mode: E
		- Mark killable target with a combo
		- Target configuration
		- Press shift to configure
	
	Explanation of the marks:

	Green circle:  Marks the current target to which you will do the combo
	Blue circle:  Mark a target that can be killed with a combo, if all the skills were available
	Red circle:  Mark a target that can be killed using items + 3 hits + Q x2 + W + E x2 (2 stacks x E) + R + ignite
	2 Red circles:  Mark a target that can be killed using items + 2 hits + Q + W + E (2 stacks)+ R + ignite
	3 Red circles:  Mark a target that can be killed using items + 1 hits + Q + W + E + R
	
]]
if myHero.charName ~= "Vladimir" then return end
--- [[Info]] ---
local version = 0.01
local AUTOUPDATE = true
local SCRIPT_NAME = "[HFP]Vladimir"
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
local MainCombo = {_E, _Q, _R, _IGNITE, _W}

--Spell Data
local Q = {range = 600, width = 0, speed = 1400, delay = 0.5}
local W = {range = 350, width = 350, speed = 1600, delay = 0.5}
local E = {range = 610, width = 610, speed = 1100, delay = 0.5}
local R = {range = 875, width = 375, speed = 1200, delay = 0.5}
local AArange
--[[		Config		]]     
local HK = 32 --spacebar
local HHK = 84 --T
local SHK = 67
-- Active
local lastE = 0
-- draw
local waittxt = {}
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}
local calculationenemy = 1
-- ts
local ts
local distancetstarget = 0
--
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	Menu = scriptConfig("Vladimir Combo 1.4", "vladimircombo")
	Menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Menu.Orbwalking)
	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)
	Menu:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, HK)
	Menu:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, HHK)
	Menu:addParam("stackE", "Stack E", SCRIPT_PARAM_ONKEYTOGGLE, false, SHK)
	Menu:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useult", "Use Ult", SCRIPT_PARAM_ONOFF, true)
	Menu:permaShow("scriptActive")
	Menu:permaShow("harass")
	Menu:permaShow("stackE")
	Menu:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	PrintChat(" >> Vladimir Combo 1.4 loaded!")
end

function OnTick()
	SOWi:EnableAttacks()
	DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
	STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	QREADY = myHero:CanUseSpell(_Q) == READY
	WREADY = myHero:CanUseSpell(_W) == READY
	EREADY = myHero:CanUseSpell(_E) == READY
	RREADY = myHero:CanUseSpell(_R) == READY
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
	ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	if tick == nil or GetTickCount()-tick >= 100 then
		tick = GetTickCount()
		VCDmgCalculation()
	end
	local Target = STS:
	if ts.target ~= nil then distancetstarget = GetDistance(ts.target) end
	if Menu.stackE then
		if EREADY and GetTickCount()-lastE>=9900 then
			lastE = GetTickCount()
			CastSpell(_E)
		end
	end
	if Menu.harass and ts.target ~= nil then
		if EREADY and distancetstarget<=600 then CastSpell(_E) end
		if QREADY then CastSpell(_Q, ts.target) end
	end
	if Menu.scriptActive and ts.target ~= nil then
		if RREADY and Menu.useult then CastSpell(_R,ts.target.x,ts.target.z) end
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end
		if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
		if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end
		if EREADY and distancetstarget<=600 then CastSpell(_E) end
		if QREADY then CastSpell(_Q, ts.target) end
		if WREADY and distancetstarget<=450 and Menu.useW and not QREADY and not EREADY and (not RREADY or not useult) then				
			CastSpell(_W)
			myHero:MoveTo(ts.target.x,ts.target.z)
		end
	end
end

function VCDmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local qdamage = getDmg("Q",enemy,myHero)
		local wdamage = getDmg("W",enemy,myHero) --(over 2 sec)
		local edamage = getDmg("E",enemy,myHero) --25% more base damage x stack
		local edamage2 = getDmg("E",enemy,myHero,2) --x stack
		local rdamage = getDmg("R",enemy,myHero) --increases the damage 12%
		local hitdamage = getDmg("AD",enemy,myHero)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
		local onspelldamage = (LTSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BTSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
		local onspelldamage2 = 0
		
		local combo1 = rdamage + (hitdamage*3 + qdamage + wdamage + edamage*2 + edamage2*4 + onhitdmg)*1.12 + onspelldamage*4 --0 cd
		local combo2 = (hitdamage*3 + onhitdmg)*(RREADY and 1.12 or 1)
		local combo3 = (hitdamage*2 + onhitdmg)*(RREADY and 1.12 or 1)
		local combo4 = hitdamage + onhitdmg
		if QREADY then
			combo2 = combo2 + qdamage*2*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo3 = combo3 + qdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo4 = combo4 + qdamage
			onspelldamage2 = onspelldamage2+1
		end
		if WREADY then
			combo2 = combo2 + wdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo3 = combo3 + wdamage*0.5*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			onspelldamage2 = onspelldamage2+1
		end
		if EREADY then
			combo2 = combo2 + (edamage*2 + edamage2*4)*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo3 = combo3 + (edamage + edamage2*2)*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo4 = combo4 + edamage
			onspelldamage2 = onspelldamage2+1
		end
		if RREADY then
			combo2 = combo2 + rdamage
			combo3 = combo3 + rdamage
			combo4 = combo4 + rdamage
			onspelldamage2 = onspelldamage2+1
		end
		if DFGREADY then		
			combo1 = combo1 + dfgdamage*(RREADY and 1.12 or 1)
			combo2 = combo2 + dfgdamage*(RREADY and 1.12 or 1)
			combo3 = combo3 + dfgdamage*(RREADY and 1.12 or 1)
			combo4 = combo4 + dfgdamage
		end
		if HXGREADY then		
			combo1 = combo1 + hxgdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + hxgdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo3 = combo3 + hxgdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo4 = combo4 + hxgdamage
		end
		if BWCREADY then
			combo1 = combo1 + bwcdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + bwcdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo3 = combo3 + bwcdamage*(RREADY and 1.12 or 1)*(DFGREADY and 1.2 or 1)
			combo4 = combo4 + bwcdamage
		end
		if BRKREADY then
			combo1 = combo1 + brkdamage
			combo2 = combo2 + brkdamage
			combo3 = combo3 + brkdamage
			combo4 = combo4 + brkdamage
		end
		if IREADY then
			combo1 = combo1 + ignitedamage
			combo2 = combo2 + ignitedamage
			combo3 = combo3 + ignitedamage
		end
		combo2 = combo2 + onspelldamage*onspelldamage2
		combo3 = combo3 + onspelldamage/2 + onspelldamage*onspelldamage2/2
		combo4 = combo4 + onspelldamage
		if combo4 >= enemy.health then killable[calculationenemy] = 4
		elseif combo3 >= enemy.health then killable[calculationenemy] = 3
		elseif combo2 >= enemy.health then killable[calculationenemy] = 2
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1
		else killable[calculationenemy] = 0 end   
	end
	if calculationenemy == 1 then calculationenemy = heroManager.iCount
	else calculationenemy = calculationenemy-1 end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "VladimirTidesofBlood" then lastE = GetTickCount()-300 end
end

function OnDraw()
	if Menu.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
		if ts.target ~= nil then
			for j=0, 10 do
				DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
			end
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if Menu.drawcircles then
				if killable[i] == 1 then
					for j=0, 20 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
					end
				elseif killable[i] == 2 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
					end
				elseif killable[i] == 3 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
					end
				elseif killable[i] == 4 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
					end
				end
			end
			if Menu.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
				PrintFloatText(enemydraw,0,floattext[killable[i]])
			end
		end
		if waittxt[i] == 1 then waittxt[i] = 30
		else waittxt[i] = waittxt[i]-1 end
	end
end
function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end