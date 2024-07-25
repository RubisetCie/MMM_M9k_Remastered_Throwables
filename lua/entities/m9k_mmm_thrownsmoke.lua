if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Smoke Grenade"
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


local sTag = "M9kr_Throwables_SmokeGrenade"


if SERVER then

	util.AddNetworkString(sTag)


	ENT.iNextSound = 0


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)


		self.iLifeTime = CurTime() + 3
		self.iExplodeTimer = 0

	end


	function ENT:PhysicsCollide(obj_Data)

		if self.iNextSound < CurTime() and obj_Data.Speed > 100 and obj_Data.DeltaTime > 0.1 then
			self:EmitSound("weapons/smokegrenade/grenade_hit1.wav")

			self.iNextSound = CurTime() + 0.1
		end
	end


	function ENT:Think()

		if not self.bWentOff then


			self.Phys = self.Phys or self:GetPhysicsObject()

			if IsValid(self.Phys) and self.Phys:GetVelocity():Length() < 10 then
				self.iExplodeTimer = self.iExplodeTimer + 1
			else
				self.iExplodeTimer = 0
			end


			if self.iExplodeTimer >= 5 and self.iLifeTime < CurTime() then

				self.bWentOff = true -- Only trigger once!


				SafeRemoveEntityDelayed(self,25) -- Smoke isn't infinite!


				self.Phys:EnableMotion(false)


				self:EmitSound("weapons/smokegrenade/smoke_emit.wav",90)
				self:EmitSound("weapons/smokegrenade/sg_explode.wav")


				net.Start(sTag)
					net.WriteEntity(self)
				net.Broadcast()

			end
		end


		if self.bWentOff then

			for _,v in ipairs(ents.FindInSphere(self:GetPos(),200)) do

				if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
					if v:GetClass() == "m9k_mmm_flame" then v:Remove() end

					v:Extinguish()
					v:EmitSound("ambient/fire/mtov_flame2.wav",75)
				end
			end
		end
	end
end


if CLIENT then

	local surfaceSetDrawColor = surface.SetDrawColor -- Optimization
	local surfaceDrawRect = surface.DrawRect
	local mathrandom = math.random
	local VectorRand = VectorRand
	local mathClamp = math.Clamp
	local mathRand = math.Rand
	local Color = Color
	local ScrW = ScrW
	local ScrH = ScrH


	local fCreateSmoke = function(eSmoke)

		eSmoke.bWentOff = true


		local vPos = eSmoke:GetPos()

		local eParticleEmitter = ParticleEmitter(vPos)

		for I = 1,20 do

			local vZRand = VectorRand() * 5

				vZRand:SetUnpacked(vZRand.x,vZRand.y,vZRand.z + 32)


			local obj_Particle = eParticleEmitter:Add("particle/smokesprites_000"..mathrandom(9),vPos + vZRand)

			local iGray = math.random(75,125)

			obj_Particle:SetColor(iGray,iGray,iGray)
			obj_Particle:SetStartAlpha(255)
			obj_Particle:SetEndAlpha(0)
			obj_Particle:SetVelocity(VectorRand() * mathRand(350,1000))
			obj_Particle:SetLifeTime(0)
			obj_Particle:SetDieTime(30)
			obj_Particle:SetStartSize(math.random(100,300))
			obj_Particle:SetEndSize(750)
			obj_Particle:SetRoll(math.random(-180,180))
			obj_Particle:SetRollDelta(math.Rand(-0.1,0.1))
			obj_Particle:SetAirResistance(550)
			obj_Particle:SetCollide(true)
			obj_Particle:SetBounce(0.4)
			obj_Particle:SetLighting(false)

		end

		eParticleEmitter:Finish()


		local iSCRw = ScrW()
		local iSCRh = ScrH()


		local sID = sTag .. "_" .. eSmoke:EntIndex()

		hook.Add("HUDPaint",sID,function()

			if not IsValid(eSmoke) then
				hook.Remove("HUDPaint",sID)

				return
			end


			if eSmoke.bWentOff then

				surfaceSetDrawColor(Color(100,100,100, mathClamp(255 - me:GetPos():DistToSqr(eSmoke:GetPos()) / 100 + 50,0,255) ))
				surfaceDrawRect(0,0,iSCRw,iSCRh)

			end
		end)
	end


	net.Receive(sTag,function()

		local eSmoke = net.ReadEntity()
		if not IsValid(eSmoke) then return end

		fCreateSmoke(eSmoke)

	end)


	function ENT:Draw()
		self:DrawModel()
	end
end