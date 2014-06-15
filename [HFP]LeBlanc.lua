--[[
	LeBlanc Combo 1.3
		by eXtragoZ

	Features:
		- Full combo: Items -> Q -> R (Mimic Q) -> W -> E
		- Supports: Deathfire Grasp, Liandry's Torment, Blackfire Torch, Bilgewater Cutlass, Hextech Gunblade, Blade of the Ruined King, Sheen, Trinity, Lich Bane, Iceborn Gauntlet, Shard of True Ice, Randuin's Omen and Ignite
		- Harass mode: Q
		- Informs where will use E / default off
		- Checks minion collision for E
		- The first circle is the range of Q, the second circle is the range of Q+W
		- Mark killable target with a combo
		- Target configuration
		- Press shift to configure

	Explanation of the marks:
		Green circle: Marks the current target to which you will do the combo
		Blue circle: Mark a target that can be killed with a combo, if all the skills were available
		Red circle: Mark a target that can be killed using items + 2 hits + Q x2 + Q mark x2 + W + E + E Root + R (Mimic Q) + ignite
		2 Red circles: Mark a target that can be killed using items + 1 hit + Q + Q mark + W + E + E Root + R (Mimic Q) + ignite
		3 Red circles: Mark a target that can be killed using items (without on hit items) + Q + Q mark + E + R (Mimic Q)
]]
--leBlanc_shackle_mis.troy
--1480
--250
if myHero.charName ~= "Leblanc" then return end
--- [[Info]] ---
local version = 0.02
local AUTOUPDATE = true
local SCRIPT_NAME = "[HFP]Cassio"
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
local MainCombo = {_Q, _Q, _W, _E, _E, _R, _IGNITE}

--Spell Data
local Ranges = {[_Q] = 700, [_W] = 600, [_E] = 925}
local Widths = {[_Q] = 0, [_W] = 220, [_E] = 70}
local Delays = {[_Q] = 0.5, [_W] = 0.5, [_E] = 0.5}
local Speeds = {[_Q] = 2000, [_W] = math.huge, [_E] = 1600}
-- local range2 = 700
-- local range = range2+600
-- local tick = nil
-- local objminionTable = {}
-- local rmimic = 0
-- local wstate = 1
-- local lastw = 0
-- local waittxt = {}
-- local calculationenemy = 1
-- local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
-- local killable = {}
-- local ts
-- local distancetstarget = 0
-- local eDelay = 250
-- local wayPointManager = WayPointManager()
-- local targetPrediction2 = TargetPredictionVIP(10000, 1480, eDelay/1000)

local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	DLib = DamageLib()
	DManager = DrawManager()
	
	Q = Spell(_Q, Ranges[_Q])
	W = Spell(_W, Ranges[_W])
	E = Spell(_E, Ranges[_E])
	R = Spell(_R, Ranges[_Q])

	W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_W], Delays[_W], Speeds[_W], false)
	E:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_E], Delays [_E], Speeds[_E], true)

	W:SetAOE(true, Widths[_W], 0)

	DLib:RegisterDamageSource(_Q, _MAGIC, 60, 50, _MAGIC, _AP, 0.8, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_W, _MAGIC, 45, 40, _MAGIC, _AP, 0.6, function() return (player:CanUseSpell(_W) == READY) end)
	DLib:RegisterDamageSource(_E, _MAGIC, 30, 50, _MAGIC, _AP, 1.0, function() return (player:CanUseSpell(_E) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 60, 50, _MAGIC, _AP, 0.8, function() return (player:CanUseSpell(_R) == READY) end)
	
	Menu = scriptConfig("LeBlanc Combo 1.2", "leblanccombo")
	Menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Menu.Orbwalking)
	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)
	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Combo:addParam("UseIgnite", "Use ignite if the target is killable", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("Harass", "Harass")
		-- Menu.Harass:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 84)
		Menu.Harass:addParam("UseQ", "Harass using Q", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseW", "Harass using W", SCRIPT_PARAM_ONOFF, false)
		Menu.Harass:addParam("UseE", "Harass using E on poisoned", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("Enabled", "Harass! (hold)", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
		Menu.Harass:addParam("Enabled2", "Harass! (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false,   string.byte("Y"))
	Menu:addSubMenu("Jungle Farm", "JungleFarm")
		Menu.JungleFarm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, false)
		Menu.JungleFarm:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, false)
		Menu.JungleFarm:addParam("Enabled", "Farm jungle!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	--[ PermaShow ]--
	Menu.Combo:permaShow("scriptActive")
	Menu.Harass:permaShow("Enabled2")
	--[ Drawings ]--
	Menu:addSubMenu("Drawings", "Drawings")
	--Spell ranges
	for spell, range in pairs(Ranges) do
		DManager:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, SpellToString(spell).." Range", true, true, true)
	end
	DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)
	DManager:CreateCircle(myHero, Ranges[_Q] + Ranges[_W], 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "W + Q Range", true, true, true)
	--Predicted damage on healthbars
	DLib:AddToMenu(Menu.Drawings, MainCombo)

	EnemyMinions = minionManager(MINION_ENEMY, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end

	print("<font color='#ff8000'> >> LeBlanc Script loaded! </font>")
end

function OnTick()
	--Prediction__OnTick()
	DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
	STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
	ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	if myHero:GetSpellData(_R).name == "LeblancChaosOrbM" then rmimic = 1
	elseif myHero:GetSpellData(_R).name == "LeblancSlideM" then rmimic = 2
	elseif myHero:GetSpellData(_R).name == "leblancslidereturnm" then rmimic = 3
	elseif myHero:GetSpellData(_R).name == "LeblancSoulShackleM" then rmimic = 4
	else rmimic = 0 end
	if myHero:GetSpellData(_W).name == "LeblancSlide" then wstate = 1 else wstate = 2 end
	
	SOWi:EnableAttacks()

	if Menu.Combo.Enabled then
		Combo()
	elseif Menu.Harass.Enabled or Menu.Harass.Enabled2 then
		Harass()
	end

	-- if Menu.Farm then
		-- Farm()
	-- end

	if Menu.JungleFarm.Enabled then
		JungleFarm()
	end
	
	-- if ts.target ~= nil then distancetstarget = GetDistance(ts.target) end
	-- if Menu.harass and ts.target then
		-- if QREADY and distancetstarget<=725 then CastSpell(_Q, ts.target) end
	-- end
	-- local qused = false
	-- if Menu.scriptActive and ts.target then
		-- if DFGREADY then CastSpell(DFGSlot, ts.target) end
		-- if HXGREADY then CastSpell(HXGSlot, ts.target) end
		-- if BWCREADY then CastSpell(BWCSlot, ts.target) end
		-- if BRKREADY then CastSpell(BRKSlot, ts.target) end
		-- if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
		-- if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end		
		-- if RREADY and rmimic == 1 and distancetstarget<=725 then CastSpell(_R, ts.target) end
		-- if QREADY and distancetstarget<=725 then
			-- CastSpell(_Q, ts.target)
			-- qused = true
		-- end
		-- if not qused or not RREADY then
			-- if WREADY and wstate == 1 and GetTickCount()-lastw>=1000 then
				-- CastSpell(_W, ts.target.x, ts.target.z)
				-- lastw = GetTickCount()
			-- end
			-- if EREADY and ((myHero:CanUseSpell(_W) == COOLDOWN) or (WREADY and wstate ~= 1)) then
				-- if VIP_USER then
					-- local EPos, t = targetPrediction2:GetPrediction(ts.target)
					-- if EPos and GetDistance(EPos) <= 950 then
						-- local Collision1 = GetMinionCollision(myHero, EPos, 200, objminionTable)
						-- if not Collision1 then
							-- CastSpell(_E, EPos.x, EPos.z)
						-- end
					-- end
				-- else
					-- if GetDistance(ts.target) <= 950 then
						-- local Collision1 = GetMinionCollision(myHero, ts.target, 200, objminionTable)
						-- if not Collision1 then
							-- CastSpell(_E, ts.target.x, ts.target.z)
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
end

function Combo()
	if Menu.Combo.UseIgnite and _IGNITE then
		local Ignitetarget = STS:GetTarget(600)
		if Ignitetarget and DLib:IsKillable(Ignitetarget, MainCombo) then
			CastSpell(_IGNITE, Ignitetarget)
		end
	end

	UseSpells(Menu.Combo.UseQ, Menu.Combo.UseW, Menu.Combo.UseE, Menu.Combo.UseR)
	SetAttacks()
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
-- function OnSendChat(msg)
	-- ts:OnSendChat(msg, "pri")
-- end
-- function OnCreateObj(obj)
	-- if obj and obj.type == "obj_AI_Minion" then
		-- if (obj.name:find("T200") or obj.name:find("Red")) and myHero.team == TEAM_BLUE then
			-- table.insert(objminionTable, obj)
		-- elseif (obj.name:find("T100") or obj.name:find("Blue")) and myHero.team == TEAM_RED then
			-- table.insert(objminionTable, obj)
		-- end
	-- end
-- end
-- function OnDeleteObj(obj)
	-- for i,v in ipairs(objminionTable) do
		-- if not v.valid or obj.name:find(v.name) then
			-- table.remove(objminionTable,i)
		-- end
	-- end
-- end
-- function LBCLoadMinions()
	-- for i=1, objManager.maxObjects do
		-- local object = objManager:getObject(i)
		-- if object and object.valid and object.team ~= myHero.team and object.type == "obj_AI_Minion" and not object.dead then
			-- table.insert(objminionTable, object)
		-- end
	-- end
-- end