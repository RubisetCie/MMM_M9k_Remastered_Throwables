if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Fire"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true


game.AddParticles("particles/fire_01.pcf")

PrecacheParticleSystem("fire_medium_02_nosmoke")
PrecacheParticleSystem("fire_medium_heatwave")
PrecacheParticleSystem("smoke_small_01b")


local fReturnFalse = function() -- Save some ram
	return false
end

ENT.CanTool = fReturnFalse -- Restrict certain things
ENT.CanProperty = fReturnFalse
ENT.PhysgunPickup = fReturnFalse


if SERVER then

	ENT.GravGunPickupAllowed = fReturnFalse -- This is Serverside only


	local angle_zero = Angle(0,0,0) -- Better safe than sorry!
	local cCached1 = Color(255,255,255,0)

	local tWhitelistedEntities = { -- MMM Compatibility
		["mmm_npc_trader"] = true
	}


	function ENT:Initialize()

		self:SetModel("models/hunter/plates/plate.mdl")
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetColor(cCached1)
		self:DrawShadow(false)

		self:PhysicsInit(SOLID_VPHYSICS)


		local obj_Phys = self:GetPhysicsObject()

		if IsValid(obj_Phys) then
			obj_Phys:SetMaterial("Wood") -- This needs to float
		end


		self:EmitSound("ambient/fire/fire_med_loop1.wav")


		self.iScorchCount = 0

	end


	function ENT:PhysicsCollide(obj_Data)
		if obj_Data.DeltaTime > 0.1 then

			if self.iScorchCount < 3 then
				util.Decal("Scorch",obj_Data.HitPos + obj_Data.HitNormal * -1,obj_Data.HitPos + obj_Data.HitNormal * 1,self)

				self.iScorchCount = self.iScorchCount + 1
			end


			if obj_Data.Speed > 100 then
				self:SetAngles(angle_zero) -- Dampen fall and make flames face up!
			end

		end
	end


	function ENT:OnRemove()
		self:StopSound("ambient/fire/fire_med_loop1.wav")
	end


	function ENT:Think()

		if self:IsOnFire() then
			self:Extinguish()
		end


		local eOwner = self:GetOwner()

		for _,v in ipairs(ents.FindInSphere(self:GetPos(),75)) do


			if v:GetClass() == "m9k_mmm_flame" then
				goto continued
			end


			v.M9kr_Throwables_LastFireDamage = v.M9kr_Throwables_LastFireDamage or 0 -- The if statement below is a nightmare. But hey, it works! wow!

			if v.M9kr_Throwables_LastFireDamage < CurTime() and ((MMM_M9k_CPPIExists and v:CPPIGetOwner() == eOwner) or not MMM_M9k_CPPIExists or (MMM and (v:IsPlayer() and (eOwner:IsPVP() and v:IsPVP())) or tWhitelistedEntities[v:GetClass()]) or v == eOwner) then

				local obj_DamageInfo = DamageInfo()
				obj_DamageInfo:SetDamageType(DMG_BURN)
				obj_DamageInfo:SetAttacker(eOwner)
				obj_DamageInfo:SetInflictor(self)
				obj_DamageInfo:SetDamage(13 + math.random(7))

				v:TakeDamageInfo(obj_DamageInfo)


				v.M9kr_Throwables_LastFireDamage = CurTime() + 0.25


				if not v:IsOnFire() and not v:IsPlayer() and not v:IsWeapon() and not v:IsNPC() then
					v:Ignite(5)
				end
			end


			::continued::

		end


		self:NextThink(CurTime() + 0.5)
		return true
	end
end


if CLIENT then

	local DynamicLight = DynamicLight -- Optimization
	local mathrandom = math.random
	local CurTime = CurTime


	function ENT:Initialize() -- For some reason not creating these Clientside causes them to go invisible sometimes
		ParticleEffectAttach("fire_medium_02_nosmoke",PATTACH_ABSORIGIN_FOLLOW,self,0)
		ParticleEffectAttach("fire_medium_heatwave",PATTACH_ABSORIGIN_FOLLOW,self,0)
		ParticleEffectAttach("smoke_small_01b",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end


	function ENT:Draw()

		self:DrawModel()


		local obj_PhysLight = DynamicLight(mathrandom(255))

		if obj_PhysLight then

			obj_PhysLight.Pos = self:GetPos()
			obj_PhysLight.R = 255
			obj_PhysLight.G = 54
			obj_PhysLight.B = 0
			obj_PhysLight.Brightness = 5
			obj_PhysLight.Size = 250
			obj_PhysLight.Decay = 2500
			obj_PhysLight.DieTime = CurTime() + 0.1

		end
	end
end