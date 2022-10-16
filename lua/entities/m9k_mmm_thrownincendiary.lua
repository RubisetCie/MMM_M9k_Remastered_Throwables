if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Incendiary"
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

	ENT.iNextSound = 0


	local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed -- Optimization
	local entsFindInSphere = ents.FindInSphere
	local entsCreate = ents.Create
	local VectorRand = VectorRand
	local CurTime = CurTime
	local IsValid = IsValid
	local ipairs = ipairs


	local vCached1 = Vector(0,0,-10)
	local vCached2 = Vector(2,2,2)


	function ENT:Initialize()

		if self.IsMolotov then
			self:PhysicsInit(SOLID_VPHYSICS)
		else
			self:PhysicsInitBox(-vCached2,vCached2) -- Prevent the bad incendiary model from rolling over the floor too much.
		end


		self:SetTrigger(true)


		self.iLifeTime = CurTime() + 3


		self.Phys = self:GetPhysicsObject() -- Cache it.

		if IsValid(self.Phys) then
			self.Phys:SetMaterial("metal") -- Stop it from acting like a bouncy ball
		end

	end


	function ENT:PhysicsCollide(obj_Data)

		if obj_Data.DeltaTime > 0.1 then

			if self.IsMolotov then -- Destroy on impact

				self.bTouched = true
				self.PhysicsCollide = nil -- Don't run twice!

				self:Think() -- Force logic to happen


				return

			end


			if self.iNextSound < CurTime() and obj_Data.Speed > 100 then

				self:EmitSound("weapons/incgrenade/inc_grenade_bounce-1.wav")

				self.iNextSound = CurTime() + 0.2

			end
		end
	end


	function ENT:Think()

		if not self.Touched and self:WaterLevel() == 3 then -- We hit water / are underwater.. explode!

			self.bTouched = true
			self.PhysicsCollide = nil -- Don't run twice!

		end


		if (self.IsMolotov and self.bTouched) or (not self.IsMolotov and self.iLifeTime < CurTime() and IsValid(self.Phys) and self.Phys:GetVelocity():Length() < 50) then

			self.Think = nil -- Safeguard


			if self.IsMolotov then
				self:EmitSound("weapons/molotov/molotov_detonate_1.wav",90)
				self:EmitSound("weapons/molotov/fire_ignite_" .. math.random(5) .. ".wav")
			else
				self:EmitSound("weapons/incgrenade/inc_grenade_detonate_" .. math.random(3) .. ".wav",90)
			end


			local vPos = self:GetPos()


			util.Decal("Scorch",vPos,vPos + vCached1,self)


			local eOwner = self:GetOwner()

			for _,v in ipairs(entsFindInSphere(vPos,200)) do

				if v:IsPlayer() or v:IsWeapon() or v:IsNPC() or v:IsOnFire() then
					goto continued
				end


				if MMM_M9k_CPPIExists and v:CPPIGetOwner() == eOwner or (not MMM_M9k_CPPIExists or (MMM and v:IsPlayer() and (eOwner:IsPVP() and v:IsPVP()))) or v == eOwner then
					v:Ignite(10)
				end


				::continued::

			end


			self:Remove()


			timer.Simple(0,function() -- Prevent 'Changing collision rules within a callback is likely to cause crashes!' error.

				if not IsValid(eOwner) then return end


				for I = 1,20 do

					local eFlame = entsCreate("m9k_mmm_flame")

						SafeRemoveEntityDelayed(eFlame,10)

					if IsValid(eFlame) then

						eFlame:SetPos(vPos)
						eFlame:Spawn()

						eFlame:SetOwner(eOwner)

						if MMM_M9k_CPPIExists then
							eFlame:CPPISetOwner(eOwner)
						end


						local obj_Phys = eFlame:GetPhysicsObject()

						if IsValid(obj_Phys) then
							obj_Phys:SetMass(500)
							obj_Phys:SetVelocity(VectorRand() * 200)
						end
					end
				end
			end)
		end
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end