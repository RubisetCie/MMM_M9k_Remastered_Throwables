if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Beer"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local effectData = EffectData()
	local damageInfo = DamageInfo()
	damageInfo:SetDamageType(DMG_DIRECT)
	local dmgInfo = DamageInfo()
	dmgInfo:SetDamageType(DMG_BLAST)

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()

		self:SetTrigger(true)
	end

	function ENT:Splat(Decal,Start,End)
		local Pos = self:GetPos()
		effectData:SetOrigin(Pos)

		if Decal then
			for I = 1,3 do
				util.Decal("BeerSplash",Start,End,self)
				util.Effect("GlassImpact",effectData)
			end
		end

		self:EmitSound("physics/glass/glass_bottle_break2.wav",75,math.random(95,105))

		local OwnerCache = self:GetOwner()
		for _,v in ipairs(ents.FindInSphere(Pos,75)) do -- Fire LOVES beer
			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
				util.Effect("HelicopterMegaBomb",effectData)
				self:EmitSound("ambient/fire/gascan_ignite1.wav")

				for _,z in ipairs(ents.FindInSphere(Pos,200)) do -- Damage
					dmgInfo:SetDamage(25) -- For some reason we have to remind the script how much damage to inflict.
					dmgInfo:SetAttacker(OwnerCache)
					dmgInfo:SetInflictor(self)
					z:TakeDamageInfo(dmgInfo)
				end

				self:Remove()
				break
			end
		end

		self:Remove()
	end

	function ENT:PhysicsCollide(Data)
		if Data.DeltaTime > 0.1 then
			self:Splat(true,Data.HitPos + Data.HitNormal * -10,Data.HitPos + Data.HitNormal * 10)
		end
	end

	function ENT:StartTouch(Ent)
		if Ent == self.Owner or (not Ent:IsNPC() and not Ent:IsPlayer()) then return end

		damageInfo:SetAttacker(self.Owner)
		damageInfo:SetInflictor(self)
		damageInfo:SetDamage(20 + self.Phys:GetVelocity():Length()/100)
		Ent:TakeDamageInfo(damageInfo)

		effectData:SetOrigin(self:GetPos())
		for I = 1,3 do
			util.Effect("GlassImpact",effectData)
		end

		self:Splat(false,nil,nil)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end