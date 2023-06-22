if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("cstrike") then return end -- Make sure CSS is mounted!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "HE Grenade"
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


	local vCached1 = Vector(0,0,-10)


	local tBlacklist = {
		["predicted_viewmodel"] = true,
		["env_spritetrail"] = true,
		["env_skypaint"] = true,
		["env_sun"] = true,
		["env_fog_controller"] = true,
		["shadow_control"] = true,
		["ambient_generic"] = true,
		["trigger_teleport"] = true,
		["info_teleport_destination"] = true,
		["phys_bone_follower"] = true,
		["prop_dynamic"] = true,
		["func_wall"] = true,
		["logic_auto"] = true,


		-- MMM Compatibility
		["mmm_object_detail"] = true,
		["mmm_vendingmachine"] = true,
		["mmm_firstaids"] = true,
		["mmm_hiddenbutton"] = true,
		["mmm_luascreen"] = true
	}


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self.iLifeTime = CurTime() + 3

	end


	function ENT:PhysicsCollide(obj_Data)

		if self.iNextSound < CurTime() and obj_Data.Speed > 100 and obj_Data.DeltaTime > 0.1 then

			self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
			self.iNextSound = CurTime() + 0.2

		end
	end


	function ENT:Think()

		if self.iLifeTime < CurTime() then

			self.Think = nil -- Safeguard


			self:EmitSound("weapons/hegrenade/explode" .. math.random(3,5) .. ".wav",110)


			local vPos = self:GetPos()


			local obj_EffectData = EffectData()
			obj_EffectData:SetOrigin(vPos)

			util.Effect("HelicopterMegaBomb",obj_EffectData)

			util.Decal("Scorch",vPos,vPos + vCached1,self)


			for _,v in ipairs(ents.FindInSphere(vPos,500)) do

				if v == self or tBlacklist[v:GetClass()] or v:IsWeapon() then
					goto continued
				end


				local vVPos = (v:IsPlayer() and v:GetShootPos() or v:GetPos())

				local iDamage = 5


				local tTrace = util.TraceLine({
					start = vPos,
					endpos = vVPos,
					filter = self
				})


				iDamage = math.Clamp(125 - vVPos:DistToSqr(vPos) / 500 + 50,5,125)


				local obj_DamageInfo = DamageInfo()
				obj_DamageInfo:SetDamageType(DMG_BLAST)
				obj_DamageInfo:SetAttacker(self:GetOwner())
				obj_DamageInfo:SetInflictor(self)


				if tTrace.Entity == v or tTrace.HitPos == vPos then -- It was a direct hit!

					obj_DamageInfo:SetDamage(iDamage)

					v:TakeDamageInfo(obj_DamageInfo)


					goto continued

				end


				 -- There are objects in-between!

				local iAttempts = 0
				local vStart = vVPos


				while iAttempts < 50 do -- We check in 5 unit intervals until we either ran out of attempts or hit our target!

					local tTrace = util.TraceLine({
						start = vStart,
						endpos = (vPos - vStart):GetNormalized() * 5,
						filter = self
					})


					if tTrace.Entity == v or tTrace.HitPos == vvPos then -- We hit the player!

						iDamage = iDamage / (iAttempts / 5) -- The damage is drastically reduced the thicker the wall was!


						obj_DamageInfo:SetDamage(iDamage)

						v:TakeDamageInfo(obj_DamageInfo)


						break

					end


					vStart = vStart + (vPos - vStart):GetNormalized() * 5

					iAttempts = iAttempts + 1


				end


				::continued::

			end


			self:Remove()

		end
	end


	function ENT:OnTakeDamage(obj_DamageInfo) -- Make it explode on taking damage
		self.iLifeTime = 0 -- Automatically prevents all of them exploding in the same tick (Optimizations!)
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end