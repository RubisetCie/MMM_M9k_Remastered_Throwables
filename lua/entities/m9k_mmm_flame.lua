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

function ENT:CanTool() return false end

if CLIENT then
	function ENT:Initialize() -- For some reason not creating these Clientside causes them to go invisible sometimes
		ParticleEffectAttach("fire_medium_02_nosmoke",PATTACH_ABSORIGIN_FOLLOW,self,0)
		ParticleEffectAttach("fire_medium_heatwave",PATTACH_ABSORIGIN_FOLLOW,self,0)
		ParticleEffectAttach("smoke_small_01b",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPIGetOwner and true or false
	local CachedColor1 = Color(255,255,255,1)
	local angle_zero = Angle(0,0,0) -- Better safe than sorry!
	local dmgInfo = DamageInfo()
	dmgInfo:SetDamageType(DMG_BURN)

	function ENT:Initialize()
		self:SetModel("models/hunter/plates/plate.mdl")
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetRenderMode(RENDERGROUP_TRANSLUCENT)
		self:SetColor(CachedColor1)
		self:DrawShadow(false)

		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()
		self.Phys:SetMaterial("Wood") -- This needs to float
		self.Scorches = 0

		self.sSound = CreateSound(self,"ambient/fire/fire_med_loop1.wav")
		self.sSound:Play()
	end

	function ENT:PhysicsCollide(Data)
		if Data.DeltaTime > 0.1 and self.Scorches < 3 then
			util.Decal("Scorch",Data.HitPos + Data.HitNormal * -10,Data.HitPos + Data.HitNormal * 10,self)
			self.Scorches = self.Scorches + 1

			if Data.Speed > 100 then
				self:SetAngles(angle_zero) -- Dampen fall and make flames face up!
			end
		end
	end

	function ENT:OnRemove()
		if self.sSound then
			self.sSound:Stop()
		end
	end

	function ENT:Think()
		if self:IsOnFire() then self:Extinguish() end

		local CachedOwner = self:GetOwner()
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),75)) do
			if v:GetClass() == "m9k_mmm_flame" then continue end
			v.LastFireTickDamage = v.LastFireTickDamage or 0

			if v.LastFireTickDamage < CurTime() and (CPPIExists and v:CPPIGetOwner() == CachedOwner or (not CPPIExists or (MMM and v:IsPlayer() and (CachedOwner:IsPVP() and v:IsPVP()))) or v == CachedOwner) then
				dmgInfo:SetDamage(13 + math.random(1,7)) -- For some reason we have to remind the script how much damage to inflict.
				dmgInfo:SetAttacker(CachedOwner)
				dmgInfo:SetInflictor(self)
				v:TakeDamageInfo(dmgInfo)

				v.LastFireTickDamage = CurTime() + 0.25

				if not v:IsPlayer() and not v:IsWeapon() and not v:IsNPC() and not v:IsOnFire() then v:Ignite(5) end
			end
		end

		self:NextThink(CurTime() + 0.5)
		return true
	end
end

if CLIENT then
	local CreateLight = function(Entity,R,G,B,Brightness,Size)
		local PhysLight = DynamicLight(math.random(1,255))

		if PhysLight then
			PhysLight.Pos = Entity:GetPos()
			PhysLight.r = R
			PhysLight.G = G
			PhysLight.B = B
			PhysLight.Brightness = Brightness
			PhysLight.Size = Size
			PhysLight.Decay = 2500
			PhysLight.DieTime = CurTime() + 0.1
		end
	end

	function ENT:Draw()
		self:DrawModel()
		CreateLight(self,255,54,0,2,250)
	end
end