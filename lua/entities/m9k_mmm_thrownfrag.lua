if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("cstrike") then return end -- Make sure CSS is mounted!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "HE Grenade"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	local CachedVector1 = Vector(0,0,-25)
	local VectorCache1 = Vector(0,0,10)
	local effectData = EffectData()
	local dmgInfo = DamageInfo()
	dmgInfo:SetDamageType(DMG_BLAST)

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.WasDropped = true -- MMM Compatibility

		self.NextSound = CurTime()
		self.DetonateTime = CurTime() + 3
	end

	function ENT:PhysicsCollide(Data) -- Impact sounds
		if Data.Speed > 100 and Data.DeltaTime > 0.1 and self.NextSound < CurTime() then
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
				dmgInfo:SetAttacker(self:GetOwner())
				dmgInfo:SetInflictor(self)

				if tTrace.Entity == v or tTrace.HitPos == vPos then -- It was a direct hit!
					dmgInfo:SetDamage(iDamage)
					v:TakeDamageInfo(dmgInfo)
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
							dmgInfo:SetDamage(iDamage)
							v:TakeDamageInfo(dmgInfo)
							break
						end

						lastStart = lastStart + (vPos - lastStart):GetNormalized() * 5
						Tries = Tries + 1
					end
				end
			end

			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end