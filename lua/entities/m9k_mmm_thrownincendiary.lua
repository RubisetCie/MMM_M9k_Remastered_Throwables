if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Incendiary"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPIGetOwner and true or false
	local CachedVector1 = Vector(0,0,-25)

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()

		self:SetTrigger(true)

		self.Timer = CurTime() + 3
		self.NextSound = CurTime()
	end

	function ENT:PhysicsCollide(Data)
		if not self.IsMolotov and Data.Speed > 100 and Data.DeltaTime > 0.1 and self.NextSound < CurTime() then -- Impact sounds
			self:EmitSound("weapons/incgrenade/inc_grenade_bounce-1.wav")
			self.NextSound = CurTime() + 0.5
		elseif self.IsMolotov and Data.DeltaTime > 0.1 then
			self.Touched = true
			self:Think()
			self.PhysicsCollide = nil -- Don't run twice!
		end
	end

	function ENT:Think()
		if not self.Touched and self:WaterLevel() == 3 then -- As soon as we are submerged we want to break!
			self.Touched = true
			self:Think()
			self.PhysicsCollide = nil -- Don't run twice!
			return
		end

		if (self.IsMolotov and self.Touched) or (not self.IsMolotov and self.Timer < CurTime() and IsValid(self.Phys) and self.Phys:GetVelocity():Length() < 50) then
			if self.IsMolotov then
				self:EmitSound(")weapons/molotov/molotov_detonate_1.wav",90)
				self:EmitSound(")weapons/molotov/fire_ignite_" .. math.random(1,5) .. ".wav",75)
			else
				self:EmitSound(")weapons/incgrenade/inc_grenade_detonate_" .. math.random(1,3) .. ".wav",90)
			end

			local CachedPos = self:GetPos()
			util.Decal("Scorch",CachedPos,CachedPos + CachedVector1,self)

			local CachedOwner = self:GetOwner()
			for _,v in ipairs(ents.FindInSphere(CachedPos,200)) do
				if v:IsPlayer() or v:IsWeapon() or v:IsNPC() or v:IsOnFire() then continue end

				if CPPIExists and v:CPPIGetOwner() == CachedOwner or (not CPPIExists or (MMM and v:IsPlayer() and (CachedOwner:IsPVP() and v:IsPVP()))) or v == CachedOwner then
					v:Ignite(10)
				end
			end

			-- Ugly hack. We need to delay the entity creation by one tick to prevent the 'Changing collision rules within a callback is likely to cause crashes!' -
			-- error which is caused by calling Think() in the same call as in PhysicsCollide. Like I said, ugly, but the most effective method I could think of

			timer.Simple(0,function()
				for I = 0,20 do
					local Ent = ents.Create("m9k_mmm_flame")
					Ent:SetPos(CachedPos)
					Ent:Spawn()

					Ent:SetOwner(CachedOwner)

					if CPPIExists then
						Ent:CPPISetOwner(CachedOwner)
					end

					if IsValid(Ent.Phys) then
						Ent.Phys:SetMass(500) -- We do this so it can't be picked up with the gravity gun!
						Ent.Phys:SetVelocity(VectorRand(-200,200))
					end

					SafeRemoveEntityDelayed(Ent,10)
				end
			end)

			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end