local properties = properties
local Jailbreak = Jailbreak
local IsValid = IsValid
local List = properties.List
if CLIENT then
	hook.Remove("PreventScreenClicks", "PropertiesPreventClicks")
	hook.Remove("PreDrawEffects", "PropertiesUpdateEyePos")
	hook.Remove("GUIMousePressed", "PropertiesClick")
	hook.Remove("PreDrawHalos", "PropertiesHover")
	local CanBeTargeted = properties.CanBeTargeted
	local GetHoveredPanel = vgui.GetHoveredPanel
	local ScreenToVector = gui.ScreenToVector
	local GetCursorPos = input.GetCursorPos
	local TraceLine = util.TraceLine
	local EyePos = EyePos
	local NULL = NULL
	local entity = NULL
	local traceResult = { }
	local trace = {
		output = traceResult
	}
	hook.Add("Think", "Jailbreak::Properties", function(self)
		local panel = GetHoveredPanel()
		if not (panel and panel:IsValid() and panel:IsWorldClicker()) then
			entity = NULL
			return
		end
		trace.start = EyePos()
		trace.endpos = trace.start + ScreenToVector(GetCursorPos()) * 1024
		trace.filter = Jailbreak.ViewEntity
		TraceLine(trace)
		entity = traceResult.Hit and traceResult.Entity or NULL
		if entity:IsValid() and (entity:GetNoDraw() or not CanBeTargeted(entity, Jailbreak.Player)) then
			entity = NULL
		end
	end)
	do
		local SuppressEngineLighting, SetStencilEnable, SetStencilWriteMask, SetStencilTestMask, SetStencilReferenceValue, SetStencilCompareFunction, SetStencilPassOperation, SetStencilFailOperation, SetStencilZFailOperation
		do
			local _obj_0 = render
			SuppressEngineLighting, SetStencilEnable, SetStencilWriteMask, SetStencilTestMask, SetStencilReferenceValue, SetStencilCompareFunction, SetStencilPassOperation, SetStencilFailOperation, SetStencilZFailOperation = _obj_0.SuppressEngineLighting, _obj_0.SetStencilEnable, _obj_0.SetStencilWriteMask, _obj_0.SetStencilTestMask, _obj_0.SetStencilReferenceValue, _obj_0.SetStencilCompareFunction, _obj_0.SetStencilPassOperation, _obj_0.SetStencilFailOperation, _obj_0.SetStencilZFailOperation
		end
		local STENCIL_ALWAYS, STENCIL_KEEP, STENCIL_REPLACE, STENCIL_EQUAL = STENCIL_ALWAYS, STENCIL_KEEP, STENCIL_REPLACE, STENCIL_EQUAL
		local SetDrawColor, DrawRect
		do
			local _obj_0 = surface
			SetDrawColor, DrawRect = _obj_0.SetDrawColor, _obj_0.DrawRect
		end
		local Start2D, End2D
		do
			local _obj_0 = cam
			Start2D, End2D = _obj_0.Start2D, _obj_0.End2D
		end
		local DrawModel = ENTITY.DrawModel
		hook.Add("HUDPaint3D", "Jailbreak::Properties", function()
			if not entity:IsValid() then
				return
			end
			local contextMenu = Jailbreak.ContextMenu
			if not (contextMenu and contextMenu:IsValid() and contextMenu:IsVisible()) then
				return
			end
			SetStencilEnable(true)
			SuppressEngineLighting(true)
			SetStencilWriteMask(1)
			SetStencilTestMask(1)
			SetStencilReferenceValue(1)
			SetStencilCompareFunction(STENCIL_ALWAYS)
			SetStencilPassOperation(STENCIL_REPLACE)
			SetStencilFailOperation(STENCIL_KEEP)
			SetStencilZFailOperation(STENCIL_KEEP)
			DrawModel(entity)
			SetStencilCompareFunction(STENCIL_EQUAL)
			SetStencilPassOperation(STENCIL_KEEP)
			Start2D()
			SetDrawColor(255, 255, 255, 5)
			DrawRect(0, 0, Jailbreak.ScreenWidth, Jailbreak.ScreenHeight)
			End2D()
			SuppressEngineLighting(false)
			SetStencilEnable(false)
			SetStencilTestMask(0)
			SetStencilWriteMask(0)
			return SetStencilReferenceValue(0)
		end)
	end
end
GM.CanProperty = function(self, ply, propertyName, entity)
	if not IsValid(entity) then
		return
	end
	if propertyName == "bonemanipulate" then
		return false
	end
	local allowedTools = entity.m_tblToolsAllowed
	if allowedTools then
		local length = #allowedTools
		for index = 1, length do
			if allowedTools[index] == propertyName then
				break
			end
			if index == length then
				return false
			end
		end
	end
	if entity:IsWeapon() and entity:GetOwner():IsValid() then
		return false
	end
	local func = entity.CanProperty
	if func then
		return func(entity, ply, propertyName)
	end
	return true
end
