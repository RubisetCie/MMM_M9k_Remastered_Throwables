if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("episodic") then return end -- Make sure Hl2 Episode 1 is mounted!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Flare"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true


local fReturnFalse = function() -- Save some ram
	return false
end

ENT.CanTool = fReturnFalse -- Restrict certain things
ENT.CanProperty = fReturnFalse
ENT.PhysgunPickup = fReturnFalse


if SERVER then

	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)


		if not self.BurntOut then
			ParticleEffectAttach("Rocket_Smoke_Trail",PATTACH_ABSORIGIN_FOLLOW,self,0)
		end

	end


	function ENT:StartTouch(eTouched)
		if eTouched == self.Owner or eTouched:GetClass() == "m9k_mmm_thrownflare" then return end

		if not self.BurntOut and (MMM_M9k_CPPIExists and eTouched:CPPIGetOwner() == self.Owner or not MMM_M9k_CPPIExists or eTouched:IsNPC()) then
			eTouched:Ignite(5)
		end
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end