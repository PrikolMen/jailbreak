local addonName = "Unknown Ghost"
local IsValid, GetPos, SetPos, GetAngles, SetAngles, FrameAdvance, GetSequence, SetSequence, SetPoseParameter, InvalidateBoneCache, DrawModel, LookupAttachment, GetAttachment, LookupBone, GetBonePosition, GetNoDraw, SetNoDraw, GetCycle, SetCycle
do
	local _obj_0 = FindMetaTable("Entity")
	IsValid, GetPos, SetPos, GetAngles, SetAngles, FrameAdvance, GetSequence, SetSequence, SetPoseParameter, InvalidateBoneCache, DrawModel, LookupAttachment, GetAttachment, LookupBone, GetBonePosition, GetNoDraw, SetNoDraw, GetCycle, SetCycle = _obj_0.IsValid, _obj_0.GetPos, _obj_0.SetPos, _obj_0.GetAngles, _obj_0.SetAngles, _obj_0.FrameAdvance, _obj_0.GetSequence, _obj_0.SetSequence, _obj_0.SetPoseParameter, _obj_0.InvalidateBoneCache, _obj_0.DrawModel, _obj_0.LookupAttachment, _obj_0.GetAttachment, _obj_0.LookupBone, _obj_0.GetBonePosition, _obj_0.GetNoDraw, _obj_0.SetNoDraw, _obj_0.GetCycle, _obj_0.SetCycle
end
local DistToSqr, Normalize, Dot, Angle
do
	local _obj_0 = FindMetaTable("Vector")
	DistToSqr, Normalize, Dot, Angle = _obj_0.DistToSqr, _obj_0.Normalize, _obj_0.Dot, _obj_0.Angle
end
local random, Clamp, NormalizeAngle, Remap = math.random, math.Clamp, math.NormalizeAngle, math.Remap
local Forward
do
	local _obj_0 = FindMetaTable("Angle")
	Forward = _obj_0.Forward
end
local CreateClientside = ents.CreateClientside
local Exists = file.Exists
local isfunction = isfunction
local FrameTime = FrameTime
local isstring = isstring
local isnumber = isnumber
local isvector = isvector
local isangle = isangle
local CurTime = CurTime
local EyePos = EyePos
local tobool = tobool
local pairs = pairs
local Lerp = Lerp
local developer = cvars.Number("developer") > 2
cvars.AddChangeCallback("developer", function(_, __, value)
	developer = tonumber(value) > 2
end, addonName)
local ghosts = _G[addonName]
if not ghosts then
	ghosts = { }
	_G[addonName] = ghosts
end
local ghostCount = #ghosts
local modelsCache = setmetatable({ }, {
	__index = function(self, modelPath)
		util.PrecacheModel(modelPath)
		rawset(self, modelPath, modelPath)
		return modelPath
	end
})
local defaultModel = modelsCache["models/player/kleiner.mdl"]
scripted_ents.Register({
	AutomaticFrameAdvance = true,
	WantsTranslucency = true,
	Type = "anim",
	Initialize = function(self)
		self:SetModel(defaultModel)
		self:DrawShadow(true)
		self:SetIK(true)
		return
	end,
	Think = function(self)
		local data = self.data
		if not (data and data.visible) then
			if not GetNoDraw(self) then
				SetNoDraw(self, true)
			end
			return
		end
		if GetNoDraw(self) then
			SetNoDraw(self, false)
		end
		FrameAdvance(self)
		if GetPos(self) ~= data.origin then
			SetPos(self, data.origin)
		end
		if GetAngles(self) ~= data.angles then
			SetAngles(self, data.angles)
		end
		if data.act then
			local id = self:SelectWeightedSequence(data.act)
			if id >= 0 then
				data.sequence = id
			end
			data.act = nil
		end
		local sequence = data.sequence
		if not isnumber(sequence) then
			if isstring(sequence) then
				local id = self:LookupSequence(sequence)
				if id >= 0 then
					sequence = id
				end
			end
			if not sequence then
				local id = self:SelectWeightedSequence(ACT_HL2MP_IDLE)
				sequence = (id >= 0) and id or "idle"
			end
			data.sequence = sequence
		end
		if sequence == "idle" or GetSequence(self) ~= sequence then
			SetSequence(self, sequence)
		end
		if data.cycle_end and GetCycle(self) > data.cycle_end then
			SetCycle(self, data.cycle_start or data.cycle_end)
		end
		if data.spectate then
			SetPoseParameter(self, "head_pitch", data.head_pitch)
			SetPoseParameter(self, "head_yaw", data.head_yaw)
			InvalidateBoneCache(self)
		end
		return
	end,
	DrawTranslucent = DrawModel,
	Draw = DrawModel,
	SetupModel = function(self, data)
		if Exists(data.modelpath, "GAME") then
			self:SetModel(modelsCache[data.modelpath])
			self:SetBodyGroups(data.bodygroups)
			self:SetModelScale(data.scale)
			self:SetColor(data.color)
			self:SetSkin(data.skin)
			self:SetupBones()
			if isfunction(self.SetPlayerColor) then
				self:SetPlayerColor(data.player_color)
			end
			data.head_pitch, data.head_pitch_min, data.head_pitch_max = self:GetPoseInfo("head_pitch")
			data.head_yaw, data.head_yaw_min, data.head_yaw_max = self:GetPoseInfo("head_yaw")
			return
		end
	end,
	GetPoseInfo = function(self, name)
		local min, max = self:GetPoseParameterRange(self:LookupPoseParameter(name))
		return Remap(self:GetPoseParameter(name), 0, 1, min, max), min, max
	end
}, "unknown_ghost")
local performNames
performNames = function()
	for i = 1, ghostCount do
		local data = ghosts[i]
		if not (data and data.enabled and data.name) then
			goto _continue_0
		end
		local name = data.name
		for j = 1, ghostCount do
			if j == i then
				goto _continue_1
			end
			local data2 = ghosts[j]
			if not (data2 and data2.enabled) then
				goto _continue_1
			end
			if data2.name == name then
				data2.enabled = false
			end
			::_continue_1::
		end
		::_continue_0::
	end
end
hook.Add("PostCleanupMap", addonName, function()
	for i = 1, ghostCount do
		local data = ghosts[i]
		if data then
			if data.chance then
				data.enabled = random(1, 100) <= Clamp(data.chance, 0, 100)
			else
				data.enabled = true
			end
		end
	end
	performNames()
	return
end)
local downloadAddon = nil
do
	local downloading = { }
	downloadAddon = function(wsid)
		local state = downloading[wsid]
		if state and (state == true or (CurTime() - state) > 60) then
			return
		end
		downloading[wsid] = true
		return steamworks.DownloadUGC(wsid, function(filePath)
			if not game.MountGMA(filePath) then
				downloading[wsid] = CurTime()
				return
			end
			for i = 1, ghostCount do
				local data = ghosts[i]
				if not (data and data.wsid == wsid) then
					goto _continue_0
				end
				local entity = data.entity
				if not (entity and IsValid(entity)) then
					goto _continue_0
				end
				entity:SetupModel(data)
				::_continue_0::
			end
		end)
	end
end
timer.Create(addonName .. "::Perform", 0.25, 0, function()
	if ghostCount == 0 then
		return
	end
	local eyePos = EyePos()
	for i = 1, ghostCount do
		local data = ghosts[i]
		if not data then
			goto _continue_0
		end
		if not data.enabled then
			if data.visible then
				data.visible = false
			end
			local entity = data.entity
			if entity and IsValid(entity) then
				entity:Remove()
			end
			goto _continue_0
		end
		if data.max_distance ~= -1 and DistToSqr(eyePos, data.origin) > data.max_distance then
			if data.visible then
				data.visible = false
			end
			goto _continue_0
		end
		if not Exists(data.modelpath, "GAME") then
			downloadAddon(data.wsid)
			goto _continue_0
		end
		if not data.visible then
			data.visible = true
		end
		local entity = data.entity
		if not (entity and IsValid(entity)) then
			entity = CreateClientside("unknown_ghost")
			data.entity = entity
			entity:Spawn()
			entity:SetupModel(data)
			entity.data = data
			entity.GetPlayerColor = function()
				return data.player_color
			end
		end
		::_continue_0::
	end
end)
hook.Add("Think", addonName .. "::Spectate", function()
	if ghostCount == 0 then
		return
	end
	local eyePos, fraction = EyePos(), FrameTime() * 2.5
	for i = 1, ghostCount do
		local data = ghosts[i]
		if not (data and data.visible and data.spectate) then
			goto _continue_0
		end
		local entity = data.entity
		if not (entity and IsValid(entity)) then
			goto _continue_0
		end
		local origin = nil
		local attachment = LookupAttachment(entity, "eyes")
		if attachment and attachment > 0 then
			origin = GetAttachment(entity, attachment).Pos
		else
			local bone = LookupBone(entity, "ValveBiped.Bip01_Head1")
			if bone and bone >= 0 then
				origin = GetBonePosition(entity, bone)
			else
				origin = entity:EyePos()
			end
		end
		local dir = (eyePos - origin)
		Normalize(dir)
		if Dot(dir, Forward(data.angles)) < -0.25 then
			data.head_yaw = Lerp(fraction, data.head_yaw, 0)
			return
		end
		dir = Angle(dir) - data.angles
		data.head_yaw = Lerp(fraction, data.head_yaw, Clamp(NormalizeAngle(dir[2]), data.head_yaw_min, data.head_yaw_max))
		data.head_pitch = Lerp(fraction, data.head_pitch, Clamp(NormalizeAngle(dir[1]), data.head_pitch_min, data.head_pitch_max))
		::_continue_0::
	end
end)
local defaultMaxDistance = 4096 ^ 2
local vector_origin = vector_origin
local angle_zero = angle_zero
local parameters = {
	method = "GET",
	failed = function(reason)
		if developer then
			ErrorNoHaltWithStack("Request failed: " .. reason)
		end
		return
	end,
	success = function(code, json)
		if code ~= 200 then
			if developer then
				ErrorNoHaltWithStack("Request failed with code: " .. code)
			end
			return
		end
		local data = util.JSONToTable(json)
		if not data then
			if developer then
				ErrorNoHaltWithStack("JSON parse failed")
			end
			return
		end
		if not istable(data.ghosts) then
			if developer then
				ErrorNoHaltWithStack("Invalid unknown ghost data")
			end
			return
		end
		if developer then
			print("Unknown ghost data received successfully.")
		end
		local groups = data.groups or { }
		for i = 1, ghostCount do
			local ghostData = ghosts[i]
			if not ghostData then
				goto _continue_0
			end
			local entity = ghostData.entity
			if entity and IsValid(entity) then
				entity:Remove()
			end
			ghosts[i] = nil
			::_continue_0::
		end
		ghostCount = 0
		local _list_0 = data.ghosts
		for _index_0 = 1, #_list_0 do
			local ghostData = _list_0[_index_0]
			if istable(ghostData.groups) then
				local _list_1 = ghostData.groups
				for _index_1 = 1, #_list_1 do
					local groupName = _list_1[_index_1]
					if not (isstring(groupName) and istable(groups[groupName])) then
						goto _continue_2
					end
					for key, value in pairs(groups[groupName]) do
						if ghostData[key] == nil then
							ghostData[key] = value
						end
					end
					::_continue_2::
				end
			end
			ghostData.groups = nil
			if isstring(ghostData.group) then
				local tbl = groups[ghostData.group]
				if istable(tbl) then
					for key, value in pairs(tbl) do
						if ghostData[key] == nil then
							ghostData[key] = value
						end
					end
				end
			end
			ghostData.group = nil
			local modelPath = ghostData.modelpath
			if not isstring(modelPath) then
				if developer then
					ErrorNoHaltWithStack("Invalid unknown ghost modelpath")
				end
				goto _continue_1
			end
			if not isstring(ghostData.wsid) then
				ghostData.wsid = nil
			end
			if not (Exists(modelPath, "GAME") or ghostData.wsid) then
				if developer then
					ErrorNoHaltWithStack("Unknown ghost model not found: " .. modelPath)
				end
				goto _continue_1
			end
			if not isvector(ghostData.origin) then
				if developer then
					ErrorNoHaltWithStack("Invalid unknown ghost origin")
				end
				goto _continue_1
			end
			if not isangle(ghostData.angles) then
				ghostData.angles = angle_zero
			end
			if not isnumber(ghostData.skin) then
				ghostData.skin = 0
			end
			if not isstring(ghostData.bodygroups) then
				ghostData.bodygroups = ""
			end
			ghostData.color = isvector(ghostData.color) and ghostData.color:ToColor() or color_white
			if not isvector(ghostData.player_color) then
				ghostData.player_color = vector_origin
			end
			if not isnumber(ghostData.scale) then
				ghostData.scale = 1
			end
			local maxDistance = ghostData.max_distance
			if not isnumber(maxDistance) then
				maxDistance = 0
			end
			if maxDistance == 0 then
				ghostData.max_distance = defaultMaxDistance
			elseif maxDistance < 0 then
				ghostData.max_distance = -1
			else
				ghostData.max_distance = maxDistance ^ 2
			end
			ghostData.spectate = tobool(ghostData.spectate)
			if not isnumber(ghostData.act) then
				ghostData.act = nil
			end
			if not isstring(ghostData.sequence) then
				ghostData.sequence = nil
			end
			if not isnumber(ghostData.cycle_end) then
				ghostData.cycle_end = nil
			end
			if not isnumber(ghostData.cycle_start) then
				ghostData.cycle_start = nil
			end
			if not isstring(ghostData.name) then
				ghostData.name = nil
			end
			if isnumber(ghostData.chance) then
				ghostData.enabled = random(1, 100) <= Clamp(ghostData.chance, 0, 100)
			else
				ghostData.enabled = true
				ghostData.chance = nil
			end
			ghostData.visible = false
			ghostData.head_pitch_min = -60
			ghostData.head_pitch_max = 60
			ghostData.head_pitch = 0
			ghostData.head_yaw_min = -75
			ghostData.head_yaw_max = 75
			ghostData.head_yaw = 0
			ghostCount = ghostCount + 1
			ghosts[ghostCount] = ghostData
			::_continue_1::
		end
		return performNames()
	end
}
local cl_unknown_ghost_source = CreateClientConVar("cl_unknown_ghost_source", "https://raw.githubusercontent.com/PrikolMen/unknown-ghosts/main/%s.json", true, false)
local requestData
requestData = function(isCustomURL)
	parameters.url = string.format(isCustomURL and cl_unknown_ghost_source:GetString() or cl_unknown_ghost_source:GetDefault(), game.GetMap())
	HTTP(parameters)
	return
end
hook.Add("InitPostEntity", addonName, requestData)
concommand.Add("cl_unknown_ghost_reload", function(ply)
	if ply:IsSuperAdmin() or ply:IsListenServerHost() then
		requestData(true)
		return
	end
end)
return concommand.Add("cl_unknown_ghost_position", function(ply)
	local angles = ply:EyeAngles()
	angles:SetUnpacked(0, math.floor(angles[2]), 0)
	local origin = ply:GetPos()
	origin:SetUnpacked(math.floor(origin[1]), math.floor(origin[2]), math.floor(origin[3]))
	return print(util.TableToJSON({
		modelpath = ply:GetModel(),
		spectate = true,
		angles = angles,
		origin = origin
	}, true))
end)
