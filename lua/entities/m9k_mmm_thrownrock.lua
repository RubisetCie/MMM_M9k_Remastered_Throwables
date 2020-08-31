if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Rock"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local vector_zero = Vector(0,0,0) -- Imagine having MMM
	local damageInfo = DamageInfo()

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()

		self:SetTrigger(true)
		self.NextSound = CurTime()
		self.Touched = { }

		self.CanBePickedUp = CurTime() + 1
	end

	function ENT:Splat(Speed)
		if self.NextSound < CurTime() then
			local Speed = Speed or 100

			if Speed > 200 then
				self:EmitSound("physics/concrete/rock_impact_hard" .. math.random(1,6) .. ".wav")
			else
				self:EmitSound("physics/concrete/rock_impact_soft" .. math.random(1,3) .. ".wav")
			end

			self.NextSound = CurTime() + 0.25
		end

		for _,v in ipairs(ents.FindInSphere(self:GetPos(),25)) do -- Fire does not like rocks
			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
				if v:GetClass() == "m9k_mmm_flame" then v:Remove() end

				v:Extinguish()
				v:EmitSound("ambient/fire/mtov_flame2.wav",75)
			end
		end
	end

	function ENT:PhysicsCollide(Data)
		if Data.Speed > 100 and Data.DeltaTime > 0.1 then
			self:Splat(Data.Speed)
		end
	end

	function ENT:StartTouch(Ent)
		if self.Touched[Ent] or (not Ent:IsNPC() and not Ent:IsPlayer()) then
			return
		elseif Ent == self.Owner then -- The owner should be able to pick a rock back up!
			if self.CanBePickedUp < CurTime() then
				if not IsValid(self.Owner:GetWeapon("m9k_mmm_rock")) then -- If the owner does not have the rock swep anymore, give it to them!
					self.Owner:Give("m9k_mmm_rock",true)
					self.Owner:GetWeapon("m9k_mmm_rock"):SetClip1(1)
				else
					self.Owner:GiveAmmo(1,"m9k_mmm_rocks")
				end

				self:Remove()
			end

			return
		end

		damageInfo:SetDamageType(DMG_DIRECT)
		damageInfo:SetAttacker(self.Owner)
		damageInfo:SetInflictor(self)
		damageInfo:SetDamage(10 + self.Phys:GetVelocity():Length()/100)
		Ent:TakeDamageInfo(damageInfo)

		if Ent:IsPlayer() then -- After we collided with a player we become no-collided so it does not make them get stuck!
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		end

		self.Phys:SetVelocity(vector_zero)
		self:Splat()

		if MMM and Ent:IsPlayer() then Ent:Scream() end -- Getting hit by a rock will always make you scream!

		self.Touched[Ent] = true -- Prevent an entity from being hit twice!
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end