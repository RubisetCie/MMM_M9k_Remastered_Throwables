if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("episodic") then return end -- Make sure Hl2 Episode 1 is mounted!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Flare"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPIGetOwner and true or false

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetTrigger(true)

		if not self.BurntOut then
			ParticleEffectAttach("Rocket_Smoke_Trail",PATTACH_ABSORIGIN_FOLLOW,self,0)
		end
	end

	function ENT:StartTouch(Ent)
		if Ent == self.Owner or Ent:GetClass() == "m9k_mmm_thrownflare" then return end

		if CPPIExists and Ent:CPPIGetOwner() == self.Owner or not CPPIExists then
			Ent:Ignite(5)
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end