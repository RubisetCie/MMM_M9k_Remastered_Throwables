if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Flashbang"
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


local sTag = "M9kr_Throwables_FlashGrenade"


if SERVER then

	util.AddNetworkString(sTag)


	ENT.GravGunPickupAllowed = fReturnFalse -- This is Serverside only


	ENT.iNextSound = 0


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)


		self.iLifeTime = CurTime() + 3

	end


	function ENT:PhysicsCollide(obj_Data)

		if self.iNextSound < CurTime() and obj_Data.Speed > 100 and obj_Data.DeltaTime > 0.1 then
			self:EmitSound("weapons/flashbang/grenade_hit1.wav")

			self.iNextSound = CurTime() + 0.1
		end
	end


	function ENT:Think()

		if self.iLifeTime < CurTime() then

			local obj_Phys = self:GetPhysicsObject()


			if IsValid(obj_Phys) and obj_Phys:GetVelocity():Length() < 10 then

				self.Think = nil -- Safeguard


				self:EmitSound("weapons/flashbang/flashbang_explode" .. math.random(2) .. ".wav",90)


				net.Start(sTag)
					net.WriteEntity(self)
				net.Broadcast()


				self:Remove()

			end
		end
	end
end


if CLIENT then

	local cCached1 = Color(255,255,255)


	local fVisible = function(vTarget)

		local me = LocalPlayer()

		local vDiff = (vTarget - me:GetShootPos())
		local iIntensity = (me:EyeAngles():Forward():Dot(vDiff) / vDiff:Length())


		return iIntensity > 0.499, iIntensity * 3

	end


	net.Receive(sTag,function()

		local eFlash = net.ReadEntity()
		if not IsValid(eFlash) then return end


		local vPos = eFlash:GetPos()


		local obj_PhysLight = DynamicLight(math.random(255))

		if obj_PhysLight then

			obj_PhysLight.Pos = vPos
			obj_PhysLight.R = 255
			obj_PhysLight.G = 255
			obj_PhysLight.B = 255
			obj_PhysLight.Brightness = 5
			obj_PhysLight.Size = 350
			obj_PhysLight.Decay = 2500
			obj_PhysLight.DieTime = CurTime() + 0.1

		end


		local me = LocalPlayer() -- Optimization

		if not MMM or (MMM and (me:IsPVP() and eFlash.Owner:IsPVP()) or eFlash.Owner == me) then -- In an MMM environment, we only want players to be flashed when they're in PVP!

			local bVisible, iStrength = fVisible(vPos)


			local vShoot =  me:GetShootPos()


			local tTrace = util.TraceLine({
				start = vPos,
				endpos = vShoot,
				filter = eFlash
			})


			if bVisible and (tTrace.HitPos == vShoot or tTrace.Entity == me) then

				local iTime = (1 * iStrength)

				me:ScreenFade(SCREENFADE.IN,cCached1,1,iTime)

				me:SetDSP(35,false)


				local sID = sTag .. "_" .. math.random(2147483647)  -- Hide HUD while flashed!

				hook.Add("HUDShouldDraw",sID,function()
					return false
				end)


				timer.Simple(iTime,function()
					hook.Remove("HUDShouldDraw",sID)
				end)

			end
		end
	end)


	function ENT:Draw()
		self:DrawModel()
	end
end
