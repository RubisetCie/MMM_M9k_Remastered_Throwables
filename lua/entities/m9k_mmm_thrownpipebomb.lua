if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and (not IsMounted("left4dead") and not IsMounted("left4dead2")) then return end -- We make sure that either Left4Dead or Left4Dead2 is installed since the models are identical.
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Pipebomb"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local CachedVector1 = Vector(0,0,-25)
	local VectorCache1 = Vector(0,0,10)
	local angle_zero = Angle(0,0,0) -- Better safe than sorry
	local damageInfo = DamageInfo()
	local effectData = EffectData()

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()
		self.WasDropped = true -- MMM Compatibility

		self.NextSound = CurTime()
		self.DetonateTime = CurTime() + 10
		self.NextTick = 1.4
	end

	function ENT:PhysicsCollide(data) -- Impact sounds
		if data.Speed > 100 and data.DeltaTime > 0.1 and self.NextSound < CurTime() then
			self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
			self.NextSound = CurTime() + 0.5
		end
	end

	function ENT:Think()
		if self.DetonateTime < CurTime() then
			SafeRemoveEntityDelayed(self,25)

			self:EmitSound(")weapons/hegrenade/explode" .. math.random(3,5) .. ".wav",120)

			local Pos = self:GetPos()
			effectData:SetOrigin(Pos)
			util.Effect("HelicopterMegaBomb",effectData)

			util.Decal("Scorch",Pos,Pos + CachedVector1,self)
			ParticleEffect("explosion_huge_k",Pos,angle_zero)

			local OurPos = self:GetPos()
			for _,v in ipairs(ents.FindInSphere(OurPos,500)) do
				local vPos = v:GetPos() + VectorCache1
				local iDamage = 5

				local tTrace = util.TraceLine({
					start = OurPos + VectorCache1,
					endpos = vPos,
					filter = self
				})

				iDamage = math.Clamp(125 - OurPos:DistToSqr(vPos)/500 + 50,5,125)
				damageInfo:SetDamageType(DMG_BLAST)
				damageInfo:SetAttacker(self:GetOwner())
				damageInfo:SetInflictor(self)

				if tTrace.Entity == v or tTrace.HitPos == vPos then -- It was a direct hit!
					damageInfo:SetDamage(iDamage)
					v:TakeDamageInfo(damageInfo)
				else -- There are objects in-between!
					local Tries = 0
					local lastStart = OurPos + VectorCache1

					while Tries < 50 do -- We check in 5 unit intervals until we either ran out of attempts or hit our target!
						local tTrace = util.TraceLine({
							start = lastStart,
							endpos = (vPos - lastStart):GetNormalized() * 5,
							filter = self
						})

						if tTrace.Entity == v then -- We hit the player!
							iDamage = iDamage / (Tries/5) -- The damage is drastically reduced the thicker the wall was!
							damageInfo:SetDamage(iDamage)
							v:TakeDamageInfo(damageInfo)
							break
						end

						lastStart = lastStart + (vPos - lastStart):GetNormalized() * 5
						Tries = Tries + 1
					end
				end
			end

			self:Remove()
		else
			if self.NextTick >= 0.2 then -- Only beep when we didn't detonate!
				self.NextTick = self.NextTick - 0.1
			end

			self:NextThink(CurTime() + self.NextTick)
		end

		return true
	end
end

if CLIENT then
	local Mat = Material("sprites/ledglow")

	function ENT:Initialize()
		self.DetonateTime = CurTime() + 10
		self.NextTick = 1.4
		self.OurIndex = self:EntIndex()
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
		if self.DetonateTime > CurTime() then
			if self.NextTick >= 0.2 then -- Only beep when we didn't detonate!
				self.NextTick = self.NextTick - 0.1
			end

			local eyePos = LocalPlayer():EyePos()
			local tIsVisible = util.TraceLine({
				start = self:GetPos(),
				endpos = eyePos,
				filter = self
			})

			if tIsVisible.Entity == LocalPlayer() or tIsVisible.HitPos == eyePos then -- Only draw the glow sprite when its in sight!
				local HookName = "M9k_Pipebomb_LEDDraw_" .. self.OurIndex
				hook.Add("HUDPaint",HookName,function()
					if not IsValid(self) then
						hook.Remove("HUDPaint",HookName)
					end

					cam.Start3D()
						render.SetMaterial(Mat)
						render.OverrideBlend(true,BLEND_SRC_COLOR,BLEND_SRC_ALPHA,BLENDFUNC_ADD,BLEND_ONE,BLEND_ZERO,BLENDFUNC_ADD)
						render.DrawSprite(self:GetPos(),64,64,color_white)
						render.OverrideBlend(false)
					cam.End3D()
				end)

				timer.Simple(0.1,function()
					hook.Remove("HUDPaint",HookName)
				end)
			end

			self:EmitSound("weapons/hegrenade/beep.wav",90)
			self:SetNextClientThink(CurTime() + self.NextTick)
		end
	end

	function ENT:OnRemove()
		hook.Remove("HUDPaint","M9k_Pipebomb_LEDDraw_" .. self.OurIndex)
	end
end