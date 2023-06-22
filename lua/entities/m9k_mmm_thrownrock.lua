if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Rock"
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

	local entsFindInSphere = ents.FindInSphere
	local DamageInfo = DamageInfo
	local CurTime = CurTime
	local IsValid = IsValid
	local ipairs = ipairs


	ENT.iNextSound = 0
	ENT.tTouched = {}


	local vector_zero = Vector(0,0,0)


	local fSplat = function(self,iSpeed)

		if self.iNextSound < CurTime() then

			iSpeed = iSpeed or 100

			if iSpeed > 200 then
				self:EmitSound("physics/concrete/rock_impact_hard" .. math.random(6) .. ".wav")
			else
				self:EmitSound("physics/concrete/rock_impact_soft" .. math.random(3) .. ".wav")
			end


			self.iNextSound = CurTime() + 0.25

		end


		for _,v in ipairs(ents.FindInSphere(self:GetPos(),25)) do -- Fire does not like rocks

			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
				if v:GetClass() == "m9k_mmm_flame" then v:Remove() end


				v:Extinguish()
				v:EmitSound("ambient/fire/mtov_flame2.wav",75)

			end
		end
	end


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)


		local obj_Phys = self:GetPhysicsObject()

		if IsValid(obj_Phys) then
			obj_Phys:SetMass(50)
		end


		self.iPickupTime = CurTime() + 1

	end


	function ENT:Think()

		if not IsValid(self.Owner) then return end


		if self.iPickupTime < CurTime() then

			for _,v in ipairs(entsFindInSphere(self:GetPos(),25)) do

				if v == self.Owner then

					if not IsValid(self.Owner:GetWeapon("m9k_mmm_rock")) then -- If the owner does not have the rock swep anymore, give it to them!
						self.Owner:Give("m9k_mmm_rock",true)
						self.Owner:GetWeapon("m9k_mmm_rock"):SetClip1(1)
					else
						self.Owner:GiveAmmo(1,"m9k_mmm_rocks")
					end


					self:Remove()
					break

				end
			end
		end


		self:NextThink(CurTime() + 0.2)
		return true
	end


	function ENT:PhysicsCollide(obj_Data)
		if obj_Data.Speed < 100 or obj_Data.DeltaTime < 0.1 then return end

		fSplat(self,obj_Data.Speed)
	end


	function ENT:StartTouch(eTouched)
		if self.tTouched[eTouched] or (not eTouched:IsPlayer() and not eTouched:IsNPC()) or eTouched == self.Owner then return end

		self.tTouched[eTouched] = true -- Prevent an entity from being hit twice!


		local obj_Phys = self:GetPhysicsObject()

		if IsValid(obj_Phys) and obj_Phys:GetVelocity():Length() > 100 then


			local obj_DamageInfo = DamageInfo()
			obj_DamageInfo:SetDamageType(DMG_DIRECT)
			obj_DamageInfo:SetAttacker(IsValid(self.Owner) and self.Owner or self)
			obj_DamageInfo:SetInflictor(self)
			obj_DamageInfo:SetDamage(10 + obj_Phys:GetVelocity():Length() / 100)

			eTouched:TakeDamageInfo(obj_DamageInfo)


			if eTouched:IsPlayer() then -- Make it so that the rock doesn't make things get stuck in it
				self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			end


			obj_Phys:SetVelocity(vector_zero)


			fSplat(self)


			-- Getting hit by a rock will always make you scream!

			if MMM and eTouched:IsPlayer() then
				eTouched:Scream()
			end
		end
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end