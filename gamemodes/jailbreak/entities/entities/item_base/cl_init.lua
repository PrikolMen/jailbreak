ENT.Type = "anim"
ENT.Think = function(self)
	self:FrameAdvance()
	self:NextThink(CurTime() + 0.5)
	return true
end
