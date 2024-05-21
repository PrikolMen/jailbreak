local EffectData = EffectData
local Jailbreak = Jailbreak
local ceil, max
do
	local _obj_0 = math
	ceil, max = _obj_0.ceil, _obj_0.max
end
local IsValid = IsValid
local Simple = timer.Simple
local ENTITY = ENTITY
local pairs = pairs
local Run = hook.Run
local util = util
local Effect = util.Effect
local GetClass = ENTITY.GetClass
util.AddNetworkString("Jailbreak::Networking")
resource.AddWorkshop("3212160573")
resource.AddWorkshop("2950445307")
resource.AddWorkshop("2661291057")
resource.AddWorkshop("643148462")
NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4
do
	local Start, WriteUInt, WriteString, Broadcast
	do
		local _obj_0 = net
		Start, WriteUInt, WriteString, Broadcast = _obj_0.Start, _obj_0.WriteUInt, _obj_0.WriteString, _obj_0.Broadcast
	end
	Jailbreak.PlaySound = function(soundPath)
		Start("Jailbreak::Networking")
		WriteUInt(3, 4)
		WriteString(soundPath)
		Broadcast()
		return
	end
end
do
	local BlastDamage = util.BlastDamage
	Jailbreak.Explosion = function(inflictor, attacker, origin, radius, damage)
		local fx = EffectData()
		fx:SetOrigin(origin)
		local scale = ceil(radius / 125)
		fx:SetRadius(scale)
		fx:SetScale(scale)
		fx:SetMagnitude(ceil(damage / 18.75))
		Effect("Sparks", fx)
		Effect("Explosion", fx)
		BlastDamage(inflictor, attacker, origin, radius, damage)
		return
	end
end
do
	NOTIFY_ERROR = NOTIFY_ERROR
	local Teams = Jailbreak.Teams
	local changeTeam
	changeTeam = function(self, teamID, force)
		local oldTeamID = self:Team()
		if not force then
			local allowed, reason, lifetime = Run("PlayerCanJoinTeam", self, teamID, oldTeamID)
			if not allowed then
				self:SendNotify(reason or "#jb.error.cant-do-that", NOTIFY_ERROR, lifetime or 3)
				return
			end
		end
		if self:Alive() then
			if Teams[oldTeamID] then
				self:Kill()
			else
				self:KillSilent()
			end
		end
		self:SetTeam(teamID)
		return
	end
	Jailbreak.ChangeTeam = changeTeam
	GM.PlayerRequestTeam = changeTeam
end
do
	local SetGlobal2Bool = SetGlobal2Bool
	do
		local IsFemalePrison = Jailbreak.IsFemalePrison
		Jailbreak.SetFemalePrison = function(bool)
			if bool == IsFemalePrison() then
				return
			end
			SetGlobal2Bool("female-prison", bool)
			return
		end
	end
	do
		local IsShockCollarsActive = Jailbreak.IsShockCollarsActive
		Jailbreak.SetShockCollars = function(bool, silent)
			if bool == IsShockCollarsActive() then
				return
			end
			SetGlobal2Bool("shock-collars", bool)
			if not silent then
				Run("ShockCollarsToggled", bool)
			end
			return
		end
	end
end
do
	local SetGlobal2Int = SetGlobal2Int
	local GetWardenCoins = Jailbreak.GetWardenCoins
	local setWardenCoins
	setWardenCoins = function(value, silent)
		local oldValue = GetWardenCoins()
		if oldValue == value then
			return
		end
		SetGlobal2Int("warden-coins", value)
		if not silent then
			Run("WardenCoins", oldValue, value)
		end
		return
	end
	Jailbreak.SetWardenCoins = setWardenCoins
	Jailbreak.TakeWardenCoins = function(value, silent)
		setWardenCoins(max(0, GetWardenCoins() - value), silent)
		return
	end
	Jailbreak.GiveWardenCoins = function(value, silent)
		setWardenCoins(max(0, GetWardenCoins() + value), silent)
		return
	end
end
do
	local shopItems = Jailbreak.ShopItems
	if not shopItems then
		shopItems = { }
		Jailbreak.ShopItems = shopItems
	end
	local ShopItem
	do
		local _class_0
		local _base_0 = {
			GetModel = function(self)
				return self.model
			end,
			SetModel = function(self, model)
				self.model = model or "models/weapons/w_bugbait.mdl"
			end,
			GetSkin = function(self)
				return self.skin
			end,
			SetSkin = function(self, skin)
				self.skin = skin
			end,
			GetBodygroups = function(self)
				return self.bodygroups
			end,
			SetBodygroups = function(self, bodygroups)
				self.bodygroups = bodygroups
			end,
			GetPrice = function(self)
				return self.price
			end,
			SetPrice = function(self, price)
				self.price = max(1, price)
			end,
			GetAction = function(self)
				return self.action
			end,
			SetAction = function(self, action)
				self.action = action
			end
		}
		if _base_0.__index == nil then
			_base_0.__index = _base_0
		end
		_class_0 = setmetatable({
			__init = function(self, name)
				self.title = "#jb." .. name
				self.bodygroups = ""
				self.name = name
				self.skin = 0
			end,
			__base = _base_0,
			__name = "ShopItem"
		}, {
			__index = _base_0,
			__call = function(cls, ...)
				local _self_0 = setmetatable({ }, _base_0)
				cls.__init(_self_0, ...)
				return _self_0
			end
		})
		_base_0.__class = _class_0
		ShopItem = _class_0
	end
	Jailbreak.ShopItem = ShopItem
	Jailbreak.AddShopItem = function(name, model, price, action)
		if not name or #name == 0 then
			name = "shopitem"
		end
		local item = shopItems[name]
		if item == nil then
			item = ShopItem(name)
			shopItems[name] = item
			shopItems[#shopItems + 1] = item
		end
		item:SetModel(model)
		item:SetPrice(price)
		item:SetAction(action)
		return item
	end
	Simple(0.5, function()
		table.Empty(shopItems)
		Run("ShopItems", Jailbreak.AddShopItem)
		return
	end)
end
do
	local timer_Create = timer.Create
	local CleanUpMap = game.CleanUpMap
	Jailbreak.SafeCleanUpMap = function()
		return timer_Create("Jailbreak::CleanUpMap", 0.25, 1, function()
			CleanUpMap(false)
			return
		end)
	end
end
do
	local GetPhysicsObjectCount, GetPhysicsObjectNum = ENTITY.GetPhysicsObjectCount, ENTITY.GetPhysicsObjectNum
	ENTITY.GetPhysicsMass = function(self)
		local objectMass = 0
		for physNum = 0, GetPhysicsObjectCount(self) - 1 do
			local phys = GetPhysicsObjectNum(self, physNum)
			if IsValid(phys) then
				objectMass = objectMass + phys:GetMass()
			end
		end
		return ceil(objectMass)
	end
end
ENTITY.Dissolve = function(self)
	local dissolver = ENTITY.Dissolver
	if not IsValid(dissolver) then
		dissolver = ents.Create("env_entity_dissolver")
		ENTITY.Dissolver = dissolver
		dissolver:SetKeyValue("dissolvetype", 0)
		dissolver:SetKeyValue("magnitude", 0)
		dissolver:Spawn()
	end
	if not IsValid(dissolver) then
		return false
	end
	dissolver:SetPos(self:WorldSpaceCenter())
	local temporaryName = "dissolver" .. dissolver:EntIndex() .. "_request" .. self:EntIndex()
	self:SetName(temporaryName)
	dissolver:Fire("dissolve", temporaryName, 0)
	timer.Create("Jailbreak::Dissolver", 0.25, 1, function()
		if self:IsValid() then
			return self:SetName("")
		end
	end)
	return true
end
do
	local AllowRagdollSpectate = Jailbreak.AllowRagdollSpectate
	ENTITY.IsValidObserveTarget = function(self)
		if self:IsPlayer() and self:Alive() then
			return true
		end
		if self:IsPlayerRagdoll() then
			return AllowRagdollSpectate:GetBool()
		end
		return GetClass(self) == "info_observer_point"
	end
end
do
	local ObserveTargets = Jailbreak.ObserveTargets
	local remove = table.remove
	local removeAsObserveTarget
	removeAsObserveTarget = function(self)
		for index = 1, #ObserveTargets do
			if ObserveTargets[index] == self then
				remove(ObserveTargets, index)
				break
			end
		end
	end
	ENTITY.RemoveFromObserveTargets = removeAsObserveTarget
	ENTITY.AddToObserveTargets = function(self)
		if self:IsValidObserveTarget() then
			removeAsObserveTarget(self)
			ObserveTargets[#ObserveTargets + 1] = self
			return true
		end
		return false
	end
	Jailbreak.ClearObserveTargets = function()
		for key in pairs(ObserveTargets) do
			ObserveTargets[key] = nil
		end
	end
end
do
	local GetInternalVariable = ENTITY.GetInternalVariable
	ENTITY.IsDoorLocked = function(self)
		return GetInternalVariable(self, "m_bLocked")
	end
	ENTITY.GetDoorState = function(self)
		if GetClass(self) == "prop_door_rotating" then
			return GetInternalVariable(self, "m_eDoorState")
		end
		return 0
	end
end
ENTITY.SetTeam = function(self, teamID)
	return self:SetNW2Int("player-team", teamID)
end
ENTITY.SetAlive = function(self, alive)
	return self:SetNW2Bool("alive", alive)
end
do
	local CTAKE_DAMAGE_INFO = CTAKE_DAMAGE_INFO
	local GetDamageType = CTAKE_DAMAGE_INFO.GetDamageType
	local band = bit.band
	do
		local DMG_NEVERGIB = DMG_NEVERGIB
		CTAKE_DAMAGE_INFO.IsNeverGibDamage = function(self)
			return band(GetDamageType(self), DMG_NEVERGIB) == DMG_NEVERGIB
		end
	end
	do
		local DMG_BURN = DMG_BURN
		CTAKE_DAMAGE_INFO.IsBurnDamage = function(self)
			return band(GetDamageType(self), DMG_BURN) ~= 0
		end
	end
	do
		local DMG_CLOSE_RANGE = bit.bor(DMG_SLASH, DMG_FALL, DMG_CLUB, DMG_CRUSH)
		CTAKE_DAMAGE_INFO.IsCloseRangeDamage = function(self)
			return band(GetDamageType(self), DMG_CLOSE_RANGE) ~= 0
		end
	end
	do
		local DMG_DISSOLVE = DMG_DISSOLVE
		CTAKE_DAMAGE_INFO.IsDissolveDamage = function(self)
			return band(GetDamageType(self), DMG_DISSOLVE) == DMG_DISSOLVE
		end
	end
	do
		local damageTypes = {
			DMG_DROWN,
			DMG_POISON,
			DMG_RADIATION,
			DMG_NERVEGAS,
			DMG_PARALYZE,
			DMG_SHOCK,
			DMG_SONIC,
			DMG_BURN
		}
		local damageTypesLength = #damageTypes
		local damageType = 0
		CTAKE_DAMAGE_INFO.IsNonPhysicalDamage = function(self)
			damageType = GetDamageType(self)
			for index = 1, damageTypesLength do
				if band(damageType, damageTypes[index]) ~= 0 then
					return true
				end
			end
			return false
		end
	end
	do
		local DMG_CRUSH = DMG_CRUSH
		CTAKE_DAMAGE_INFO.IsCrushDamage = function(self)
			return band(GetDamageType(self), DMG_CRUSH) == DMG_CRUSH
		end
	end
	do
		local DMG_SHOCK = DMG_SHOCK
		CTAKE_DAMAGE_INFO.IsShockDamage = function(self)
			return band(GetDamageType(self), DMG_SHOCK) == DMG_SHOCK
		end
	end
end
do
	local tobool = tobool
	local lower = string.lower
	GM.AcceptInput = function(self, entity, key)
		local className = GetClass(entity)
		if className == "prop_door_rotating" or className == "func_door_rotating" then
			local _exp_0 = lower(key)
			if "lock" == _exp_0 then
				return entity:SetNW2Bool("m_bLocked", true)
			elseif "unlock" == _exp_0 then
				return entity:SetNW2Bool("m_bLocked", false)
			end
		end
	end
	GM.EntityKeyValue = function(self, entity, key, value)
		local className = GetClass(entity)
		if (className == "prop_door_rotating" or className == "func_door_rotating") and lower(key) == "m_bLocked" then
			entity:SetNW2Bool(key, tobool(value))
			return
		end
	end
end
do
	local TraceLine, Decal = util.TraceLine, util.Decal
	local traceResult = { }
	local trace = {
		output = traceResult
	}
	Jailbreak.BloodSplashes = function(self, damageInfo, death, velocity)
		if not velocity then
			velocity = self:GetVelocity() + damageInfo:GetDamageForce()
		end
		local damagePosition = damageInfo:GetDamagePosition()
		local speed = velocity:Length()
		local fx = EffectData()
		fx:SetNormal(velocity:GetNormalized())
		fx:SetMagnitude(speed / 100)
		fx:SetScale(10)
		fx:SetFlags(3)
		fx:SetColor(0)
		fx:SetOrigin(damagePosition)
		Effect("BloodImpact", fx, true, true)
		trace.start = damagePosition
		trace.filter = self
		if not death then
			trace.endpos = damagePosition + velocity
			TraceLine(trace)
			if not traceResult.Hit then
				return
			end
			Decal("Blood", traceResult.HitPos + traceResult.HitNormal, traceResult.HitPos - traceResult.HitNormal)
			return
		end
		local decal = damageInfo:IsShockDamage() and "FadingScorch" or "Blood"
		for bone = 0, self:GetBoneCount() - 1 do
			local origin = self:GetBonePosition(bone)
			trace.endpos = origin + (origin - damagePosition) * speed
			TraceLine(trace)
			if traceResult.Hit then
				Decal(decal, traceResult.HitPos + traceResult.HitNormal, traceResult.HitPos - traceResult.HitNormal)
			end
		end
	end
end
