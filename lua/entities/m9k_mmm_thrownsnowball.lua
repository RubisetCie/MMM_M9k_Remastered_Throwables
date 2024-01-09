if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("cstrike") then return end -- Make sure CS:GO is mounted!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Snowball"
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


local sTag = "M9kR_Throwables_Snowball"


if SERVER then

	util.AddNetworkString(sTag)


	local fSplat = function(self,bDecal,iStart,iEnd)

		if bDecal then
			util.Decal("Splash.Large",iStart,iEnd,self)
		end


		self:EmitSound("physics/surfaces/sand_impact_bullet" .. math.random(4) .. ".wav")


		for _,v in ipairs(ents.FindInSphere(self:GetPos(),50)) do -- Fire does not like water

			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
				if v:GetClass() == "m9k_mmm_flame" then v:Remove() end


				v:Extinguish()
				v:EmitSound("ambient/fire/mtov_flame2.wav",75)

				break -- Only enough water for one fire source!

			end
		end


		self:Remove()

	end


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)


		self.Phys = self:GetPhysicsObject() -- Cache it.

	end


	function ENT:PhysicsCollide(obj_Data)
		if obj_Data.DeltaTime < 0.1 then return end

		fSplat(self,true,obj_Data.HitPos + obj_Data.HitNormal * -1,obj_Data.HitPos + obj_Data.HitNormal * 1)
	end


	function ENT:StartTouch(eTouched)
		if eTouched == self.Owner or (not eTouched:IsPlayer() and not eTouched:IsNPC()) then return end


		local obj_DamageInfo = DamageInfo()
		obj_DamageInfo:SetDamageType(DMG_DIRECT)
		obj_DamageInfo:SetAttacker(IsValid(self.Owner) and self.Owner or self)
		obj_DamageInfo:SetInflictor(self)
		obj_DamageInfo:SetDamage(5 + (IsValid(self.Phys) and self.Phys:GetVelocity():Length() / 100 or 0))

		eTouched:TakeDamageInfo(obj_DamageInfo)


		if eTouched:IsPlayer() and ((MMM and self.Owner:IsPVP() and eTouched:IsPVP()) or not MMM) then

			net.Start(sTag)
			net.Send(eTouched)

		end


		fSplat(self,false)

	end
end


if CLIENT then

	local surfaceDrawTexturedRect = surface.DrawTexturedRect -- Optimization
	local surfaceSetDrawColor = surface.SetDrawColor
	local surfaceSetMaterial = surface.SetMaterial
	local hookRemove = hook.Remove
	local hookAdd = hook.Add
	local CurTime = CurTime
	local ScrW = ScrW
	local ScrH = ScrH


	local obj_Material = CreateMaterial("SnowOverlay","UnlitGeneric",{ -- We need to create a new Material since the original does not support alpha.
		["$basetexture"] = "nature/snowfloor001a",
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	})


	local fSnowballed = function()

		local iAlpha = 0
		local iScrW = ScrW()
		local iScrH = ScrH()
		local iStart = CurTime()
		local iTimeSince = 0


		hookAdd("HUDPaint",sTag,function()

			iTimeSince = CurTime() - iStart


			surfaceSetDrawColor(255,255,255,255 - iAlpha)
			surfaceSetMaterial(obj_Material)
			surfaceDrawTexturedRect(0,0,iScrW,iScrH + iAlpha)


			if iAlpha < 255 then
				iAlpha = (iTimeSince / 1) * 255
			else
				hookRemove("HUDPaint",sTag)
			end
		end)

	end


	net.Receive(sTag,fSnowballed)


	function ENT:Draw()
		if not self._MMMScaled then
			self:SetModelScale(0.5)
			self._MMMScaled = true
		end

		self:DrawModel()
	end
end