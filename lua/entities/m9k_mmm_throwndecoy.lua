if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("cstrike") then return end -- Make sure CSS is mounted!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Decoy"
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

	ENT.GravGunPickupAllowed = fReturnFalse -- This is Serverside only
	-- We don't allow picking up a decoy with the gravity gun as it can otherwise float when it goes off.


	local mathrandom = math.random -- Optimization
	local utilEffect = util.Effect
	local CurTime = CurTime
	local IsValid = IsValid


	local vCached1 = Vector(0,0,-25)
	local aCached1 = Angle(-90,0,0)
	local cCached1 = Color(235,0,0)


	local tSounds = {
		"weapons/ak47/ak47-1.wav",
		"weapons/aug/aug-1.wav",
		"weapons/awp/awp1.wav",
		"weapons/deagle/deagle-1.wav",
		"weapons/elite/elite-1.wav",
		"weapons/famas/famas-1.wav",
		"weapons/fiveseven/fiveseven-1.wav",
		"weapons/g3sg1/g3sg1-1.wav",
		"weapons/galil/galil-1.wav",
		"weapons/glock/glock18-1.wav",
		"weapons/m249/m249-1.wav",
		"weapons/m3/m3-1.wav",
		"weapons/m4a1/m4a1_unsil-1.wav",
		"weapons/m4a1/m4a1-1.wav",
		"weapons/mac10/mac10-1.wav",
		"weapons/mp5navy/mp5-1.wav",
		"weapons/p228/p228-1.wav",
		"weapons/p90/p90-1.wav",
		"weapons/scout/scout_fire-1.wav",
		"weapons/sg550/sg550-1.wav",
		"weapons/sg552/sg552-1.wav",
		"weapons/tmp/tmp-1.wav",
		"weapons/ump45/ump45-1.wav",
		"weapons/usp/usp1.wav",
		"weapons/xm1014/xm1014-1.wav",
	}


	ENT.iNextSound = 0
	ENT.iNextSplode = 0


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)


		self.Phys = self:GetPhysicsObject() -- Cache it.


		self.iLifeTime = CurTime() + 3

		self.sSoundStr = tSounds[math.random(#tSounds)] -- What sound to spam


		self:SetColor(cCached1)

	end


	function ENT:PhysicsCollide(obj_Data)

		if self.iNextSound < CurTime() and obj_Data.Speed > 100 and obj_Data.DeltaTime > 0.1 then

			self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
			self.iNextSound = CurTime() + 0.2

		end
	end


	function ENT:Think()

		if not self.bDecoy then

			if self.iLifeTime < CurTime() and IsValid(self.Phys) and self.Phys:GetVelocity():Length() < 10 then

				self.bDecoy = true
				self.iWhenSplode = CurTime() + 15


				ParticleEffectAttach("Rocket_Smoke",PATTACH_ABSORIGIN_FOLLOW,self,0)


				self.Phys:EnableMotion(false)

			end


			return

		else


			local obj_EffectData = EffectData()
			obj_EffectData:SetAngles(aCached1)
			obj_EffectData:SetEntity(self)
			obj_EffectData:SetScale(1) -- These need to be defined
			obj_EffectData:SetMagnitude(1)


			if self.iWhenSplode < CurTime() then

				self.Think = nil -- Safeguard


				obj_EffectData:SetOrigin(self:GetPos())


				local vPos = self:GetPos()


				util.Decal("Scorch",vPos,vPos + vCached1,self)

				utilEffect("HelicopterMegaBomb",obj_EffectData)


				self:EmitSound("weapons/hegrenade/explode3.wav",100)


				self:Remove()


			elseif self.iNextSplode < CurTime() then


				self.iNextSplode = CurTime() + math.Rand(0.2,1.2)


				obj_EffectData:SetOrigin(self:GetPos())


				if mathrandom(100) > 70 then -- Burst!

					for I = 0,mathrandom(2,5) do

						timer.Simple(0.05 + (I/10),function()
							if not IsValid(self) then return end

							if self.sSound then self.sSound:Stop() end -- Stop the last sound so we don't overlap!


							self.sSound = CreateSound(self,self.sSoundStr)
							self.sSound:SetSoundLevel(100)
							self.sSound:Play()


							utilEffect("StunstickImpact",obj_EffectData)
							utilEffect("MuzzleEffect",obj_EffectData)

						end)
					end

				else

					self:EmitSound(self.sSoundStr,100)

					utilEffect("StunstickImpact",obj_EffectData)
					utilEffect("MuzzleEffect",obj_EffectData)

				end
			end
		end
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end