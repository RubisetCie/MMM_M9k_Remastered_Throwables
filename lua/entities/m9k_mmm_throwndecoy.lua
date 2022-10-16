if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("csgo") then return end -- Make sure CS:GO is mounted!

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


	local tSounds = {
		"weapons/357/357_fire2.wav",
		"weapons/357/357_fire3.wav",
		"weapons/ar2/fire1.wav",
		"weapons/flaregun/fire.wav",
		"weapons/pistol/pistol_fire2.wav",
		"weapons/pistol/pistol_fire3.wav",
		"weapons/shotgun/shotgun_fire7.wav",
		"weapons/smg1/smg1_fire1.wav",
		"weapons/ak47/ak47-1.wav",
		"weapons/ak47/ak47_01.wav",
		"weapons/aug/aug-1.wav",
		"weapons/aug/aug_01.wav",
		"weapons/aug/aug_02.wav",
		"weapons/aug/aug_03.wav",
		"weapons/aug/aug_04.wav",
		"weapons/awp/awp1.wav",
		"weapons/awp/awp_01.wav",
		"weapons/awp/awp_02.wav",
		"weapons/bizon/bizon-1.wav",
		"weapons/bizon/bizon_01.wav",
		"weapons/bizon/bizon_02.wav",
		"weapons/cz75a/cz75a-1.wav",
		"weapons/cz75a/cz75_01.wav",
		"weapons/cz75a/cz75_02.wav",
		"weapons/cz75a/cz75_03.wav",
		"weapons/deagle/deagle-1.wav",
		"weapons/deagle/deagle_01.wav",
		"weapons/deagle/deagle_02.wav",
		"weapons/elite/elite-1.wav",
		"weapons/elite/elites_01.wav",
		"weapons/elite/elites_02.wav",
		"weapons/elite/elites_03.wav",
		"weapons/elite/elites_04.wav",
		"weapons/famas/famas-1.wav",
		"weapons/famas/famas_01.wav",
		"weapons/famas/famas_02.wav",
		"weapons/famas/famas_03.wav",
		"weapons/famas/famas_04.wav",
		"weapons/fiveseven/fiveseven-1.wav",
		"weapons/fiveseven/fiveseven_01.wav",
		"weapons/g3sg1/g3sg1-1.wav",
		"weapons/g3sg1/g3sg1_01.wav",
		"weapons/g3sg1/g3sg1_02.wav",
		"weapons/g3sg1/g3sg1_03.wav",
		"weapons/galilar/galil-1.wav",
		"weapons/galilar/galil_01.wav",
		"weapons/galilar/galil_02.wav",
		"weapons/galilar/galil_03.wav",
		"weapons/galilar/galil_04.wav",
		"weapons/glock18/glock18-1.wav",
		"weapons/glock18/glock_01.wav",
		"weapons/glock18/glock_02.wav",
		"weapons/hkp2000/hkp2000-1.wav",
		"weapons/hkp2000/hkp2000_01.wav",
		"weapons/hkp2000/hkp2000_02.wav",
		"weapons/hkp2000/hkp2000_03.wav",
		"weapons/m249/m249-1.wav",
		"weapons/m4a1/m4a1-1-single.wav",
		"weapons/m4a1/m4a1_01.wav",
		"weapons/m4a1/m4a1_02.wav",
		"weapons/m4a1/m4a1_03.wav",
		"weapons/m4a1/m4a1_04.wav",
		"weapons/m4a1/m4a1_unsil-1.wav",
		"weapons/m4a1/m4a1_us_01.wav",
		"weapons/m4a1/m4a1_us_02.wav",
		"weapons/m4a1/m4a1_us_03.wav",
		"weapons/m4a1/m4a1_us_04.wav",
		"weapons/mac10/mac10-1.wav",
		"weapons/mac10/mac10_01.wav",
		"weapons/mac10/mac10_02.wav",
		"weapons/mac10/mac10_03.wav",
		"weapons/mag7/mag7-1.wav",
		"weapons/mag7/mag7_01.wav",
		"weapons/mag7/mag7_02.wav",
		"weapons/mp5/mp5_01.wav",
		"weapons/mp7/mp7-1.wav",
		"weapons/mp7/mp7_01.wav",
		"weapons/mp7/mp7_02.wav",
		"weapons/mp7/mp7_03.wav",
		"weapons/mp7/mp7_04.wav",
		"weapons/mp9/mp9-1.wav",
		"weapons/mp9/mp9_01.wav",
		"weapons/mp9/mp9_02.wav",
		"weapons/mp9/mp9_03.wav",
		"weapons/mp9/mp9_04.wav",
		"weapons/negev/negev-1.wav",
		"weapons/negev/negev_01.wav",
		"weapons/negev/negev_02.wav",
		"weapons/negev/negev_03.wav",
		"weapons/negev/negev_04.wav",
		"weapons/negev/negev_05.wav",
		"weapons/nova/nova-1.wav",
		"weapons/p250/p250-1.wav",
		"weapons/p250/p250_01.wav",
		"weapons/p90/p90-1.wav",
		"weapons/p90/p90_01.wav",
		"weapons/p90/p90_02.wav",
		"weapons/p90/p90_03.wav",
		"weapons/revolver/revolver-1_01.wav",
		"weapons/sawedoff/sawedoff-1.wav",
		"weapons/scar20/scar20_01.wav",
		"weapons/scar20/scar20_02.wav",
		"weapons/scar20/scar20_03.wav",
		"weapons/sg556/sg556-1.wav",
		"weapons/sg556/sg556_01.wav",
		"weapons/sg556/sg556_02.wav",
		"weapons/sg556/sg556_03.wav",
		"weapons/sg556/sg556_04.wav",
		"weapons/ssg08/ssg08-1.wav",
		"weapons/ssg08/ssg08_01.wav",
		"weapons/tec9/tec9-1.wav",
		"weapons/tec9/tec9_02.wav",
		"weapons/ump45/ump45-1.wav",
		"weapons/ump45/ump45_02.wav",
		"weapons/ump45/ump45_04.wav",
		"weapons/usp/usp2.wav",
		"weapons/usp/usp3.wav",
		"weapons/usp/usp_01.wav",
		"weapons/usp/usp_02.wav",
		"weapons/usp/usp_03.wav",
		"weapons/usp/usp_unsil-1.wav",
		"weapons/usp/usp_unsilenced_01.wav",
		"weapons/usp/usp_unsilenced_02.wav",
		"weapons/usp/usp_unsilenced_03.wav",
		"weapons/xm1014/xm1014-1.wav"
	}


	ENT.iNextSound = 0
	ENT.iNextSplode = 0


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)


		self.Phys = self:GetPhysicsObject() -- Cache it.


		self.iLifeTime = CurTime() + 3

		self.sSoundStr = table.Random(tSounds) -- What sound to spam

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


				self:EmitSound("weapons/hegrenade/hegrenade_detonate_0" .. mathrandom(3) .. ".wav",100)


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