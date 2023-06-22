if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()


ENT.Type = "anim"
ENT.PrintName = "Beer"
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

	local entsFindInSphere = ents.FindInSphere -- Optimization
	local utilEffect = util.Effect
	local DamageInfo = DamageInfo
	local EffectData = EffectData
	local ipairs = ipairs


	function ENT:Initialize()

		self:PhysicsInit(SOLID_VPHYSICS)

		self:SetTrigger(true)

	end


	local fExplode = function(self,bDecal,vStart,vEnd)

		local vPos = self:GetPos()


		local obj_EffectData = EffectData()
		obj_EffectData:SetOrigin(vPos)


		if bDecal then

			for I = 1,3 do

				util.Decal("BeerSplash",vStart,vEnd,self)

				utilEffect("GlassImpact",obj_EffectData)

			end
		end


		self:EmitSound("physics/glass/glass_bottle_break2.wav",75,math.random(95,105))


		local eOwner = self:GetOwner()

		for _,v in ipairs(entsFindInSphere(vPos,75)) do -- Fire LOVES beer

			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then


				utilEffect("HelicopterMegaBomb",obj_EffectData)


				self:EmitSound("ambient/fire/gascan_ignite1.wav")


				for _,b in ipairs(entsFindInSphere(vPos,200)) do

					local obj_DamageInfo = DamageInfo()
					obj_DamageInfo:SetDamageType(DMG_BLAST)
					obj_DamageInfo:SetDamage(25)
					obj_DamageInfo:SetAttacker(eOwner)
					obj_DamageInfo:SetInflictor(self)

					b:TakeDamageInfo(obj_DamageInfo)

				end


				self:Remove()
				break

			end
		end


		self:Remove()

	end


	function ENT:PhysicsCollide(obj_Data)
		if obj_Data.DeltaTime < 0.1 then return end

		fExplode(self,true,obj_Data.HitPos + obj_Data.HitNormal * -1,obj_Data.HitPos + obj_Data.HitNormal * 1)

	end


	function ENT:StartTouch(eTouched)

		if eTouched == self.Owner or (not eTouched:IsPlayer() and not eTouched:IsNPC()) then return end


		local obj_DamageInfo = DamageInfo()
		obj_DamageInfo:SetDamageType(DMG_DIRECT)
		obj_DamageInfo:SetAttacker(IsValid(self.Owner) and self.Owner or self)
		obj_DamageInfo:SetInflictor(self)
		obj_DamageInfo:SetDamage(20 + (IsValid(self.Phys) and self.Phys:GetVelocity():Length() / 100 or 0))

		eTouched:TakeDamageInfo(obj_DamageInfo)


		local obj_EffectData = EffectData()
		obj_EffectData:SetOrigin(self:GetPos())

		for I = 1,3 do
			utilEffect("GlassImpact",obj_EffectData)
		end


		fExplode(self,false,nil,nil)

	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end