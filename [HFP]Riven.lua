--- Info
local version = 0.01
local AUTOUPDATE = true
local SCRIPT_NAME = "[HFP]Rengar"
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
SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/HFPDarkAlex/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/HFPDarkAlex/BoL/master/versions/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end

Ranges = {[_Q] = 112.5, [_W] = 125, [_E] = 325, [_R] = 900} -- Updating in OnBuff
Delays = {[_Q] = 0.5, [_W] = 0.25, [_R] = 0.25}
Speeds = {[_Q] = math.huge, [_E] = 1500, [_R] = 2200} -- E updates in OnDash
Angles = {[_R] = 45*math.pi/180}

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_LESS_CAST_PHYSICAL)
	DLib = DamageLib()
	DManager = DrawManager()
	
	Menu = scriptConfig('Beta [HFP]Riven', 'Riven')
	Menu:addSubMenu('SOW', 'sow')
	Menu:addSubMenu('Simple TS', 'sts')

	Menu:addParam('enabled', 'Combo', SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addParam('useQ', 'Use Q', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('useW', 'Use W', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('useE', 'Use E', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('useR1', 'Use R1', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('useR2', 'Use R2', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('useTiamat', 'Use Tiamat/Hydra', SCRIPT_PARAM_ONOFF, true)

	STS:AddToMenu(Menu.sts)
	SOWi:LoadToMenu(Menu.sow, STS)
	SOWi:RegisterAfterAttackCallback(AfterAttack)
	SOWi.Menu.Mode = 2

	AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnBuff(unit, buff, false) end)
	AdvancedCallback:bind('OnUpdateBuff', function(unit, buff) OnBuff(unit, buff, false) end)
	AdvancedCallback:bind('OnLoseBuff', function(unit, buff) OnBuff(unit, buff, true) end)

	print("<font color=\"#FF8000\"><b>" .."Beta [HFP]Riven Loaded!</b>")
end

function OnTick()
	local target = GetTarget() or spell.target
	SOWi:EnableAttacks()
	if Menu.enabled and ValidTarget(target) and target.type == myHero.type then
		Combo()
	end
end

function Combo()

end

-- function OnProcessSpell(object, spell)
	-- if object.isMe and Menu.enabled then
		-- local target = GetTarget() or spell.target

		-- if ValidTarget(target) and target.type == myHero.type then
			-- if spell.name == 'RivenTriCleave' then -- _Q
				-- DelayAction(function()
					-- if CastE(target) == false then
						-- Packet('S_MOVE', {x = target.x, y = target.z}):send()
					-- end
				-- end, Delays[_Q] + GetLatency() / 2000)
			-- end

			-- if spell.name == 'RivenMartyr' then -- _W
				-- DelayAction(function()
					-- if CastE(target) == false then
						-- CastR1()
					-- end
				-- end, Delays[_W] + GetLatency() / 2000)
			-- end

			-- if spell.name == 'RivenFeint' then -- _E
				-- if CastW(target) == false and CastR1() == false and CastTiamat() == false then
					-- SendChat('/l')
				-- end
			-- end

			-- if spell.name == 'RivenFengShuiEngine' then -- _R first cast
				-- if CastE(target) == false and CastTiamat() == false then
					-- SendChat('/l')
				-- end
			-- end

			-- if spell.name == 'rivenizunablade' then -- _R second cast
				-- if CastE(target) == false and CastQ(target) == false and CastTiamat() == false then
					-- SendChat('/l')
				-- end
			-- end

			-- if spell.name == 'ItemTiamatCleave' then -- Tiamat / Hydra
				-- if CastSpell(_W) == false and CastQ(target) == false and CastE(target) == false then
					-- SendChat('/l')
				-- end
			-- end
		-- end
	-- end
-- end

-- function OnTick()
	-- CheckR()
-- end

-- function OnDash(unit, dash)
	-- if unit.isMe then
		-- Speeds[_E] = dash.speed
	-- end
-- end

-- function OnBuff(unit, buff, isLose)
	-- if buff and buff.name and unit and unit.isMe then
		-- UpdateRanges(buff.name, isLose)
	-- end
-- end

-- function AfterAttack(target, mode)
	-- if Menu.enabled then
		-- CastQ(target)
	-- end
-- end

function CastQ(target)
	if Menu.useQ and ValidTarget(target) then
		local predictionPos = VP:GetCircularAOECastPosition(target, Delays[_Q], Ranges[_Q], Ranges[_Q], Speeds[_Q], myHero, false)

		if predictionPos ~= nil and  GetDistanceSqr(target.visionPos, predictionPos) <= Ranges[_Q] * Ranges[_Q] and CastSpell(_Q, predictionPos.x, predictionPos.z) then
			DelayAction(function() SOWi:resetAA() end, Delays[_Q] + 0.25)
			return true
		end
	end

	return false
end

function CastW(target)
	if Menu.useW and ValidTarget(target) then
		local predictionPos = VP:GetPredictedPos(target, Delays[_W], nil, myHero, false)

		if predictionPos ~= nil and GetDistanceSqr(target.visionPos, predictionPos) <= Ranges[_W] * Ranges[_W] and CastSpell(_W) then
			DelayAction(function() SOWi:resetAA() end, Delays[_W] + 0.25)
			return true
		end
	end

	return false
end

function CastE(target)
	if Menu.useE and ValidTarget(target) then
		local predictionPos = VP:GetPredictedPos(target, Ranges[_E] / Speeds[_E], nil, myHero, false)

		if predictionPos ~= nil then
			local endPos = Vector(myHero.visionPos) + Ranges[_E] * (Vector(predictionPos) - Vector(myHero.visionPos)):normalized()

			if IsWall(D3DXVECTOR3(predictionPos.x, predictionPos.y, predictionPos.z)) == false and CastSpell(_E, predictionPos.x, predictionPos.z) then
				DelayAction(function() SOWi:resetAA() end, 0.25)
				return true
			end
		end
	end

	return false
end

function CastR1(target)
	if Menu.useR1 and ValidTarget(target) and GetComboDmg(target) > target.health then
		return CastSpell(_R)
	end

	return false
end

function CastR2(target)
	if Menu.useR2 and ValidTarget(target) then
		local predictionPos = VP:GetConeAOECastPosition(target, Delays[_R], Angles[_R], Ranges[_R], Speeds[_R], myHero)

		if predictionPos ~= nil and GetDistanceSqr(target.visionPos, predictionPos) <= Ranges[_R] * Ranges[_R] and CastSpell(_R, predictionPos.x, predictionPos.z) then
			DelayAction(function() SOWi:resetAA() end, Delays[_R] + 0.25)
			return true
		end
	end

	return false
end

function CastTiamat()
	if Menu.useTiamat and (CastItem(3077) or CastItem(3074)) then
		DelayAction(function() SOWi:resetAA() end, 0.25)
		return true
	end

	return false
end

function GetComboDmg(target)
	local count = 0
	local totalDmg = 0

	if myHero:CanUseSpell(_Q) == READY then
		count = count + 3
		totalDmg = totalDmg + getDmg('Q', target, myHero) * 3
	end

	if myHero:CanUseSpell(_W) == READY then
		count = count + 1
		totalDmg = totalDmg + getDmg('W', target, myHero)
	end

	if myHero:CanUseSpell(_E) == READY then
		count = count + 1
	end

	if myHero:CanUseSpell(_R) == READY then
		count = count + 2
		totalDmg = totalDmg + getDmg('R', target, myHero)
	end

	totalDmg = totalDmg + getDmg('P', target, myHero) * count

	return totalDmg
end

-- function CheckR()
	-- if Menu.useR2 then
		-- for _, enemy in pairs(GetEnemyHeroes()) do
			-- if ValidTarget(enemy, Ranges[_R]) and getDmg('R', enemy, myHero) > enemy.health + enemy.hpRegen/5 * (Delays[_R] + GetDistance(enemy) / Speeds[_R]) then
				-- CastR2(enemy)
			-- end
		-- end
	-- end
-- end

function UpdateRanges(name, isLose)
	if name == 'RivenFengShuiEngine' then
		for index, range in pairs(Ranges) do
			Ranges[index] = isLose and (range - 50) or (range + 50)
		end
	end

	if name == 'riventricleavesoundtwo' then
		Ranges[_Q] = isLose and 112.5 or 150
	end
end
