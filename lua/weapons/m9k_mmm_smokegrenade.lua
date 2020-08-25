if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "Smoke Grenade"

SWEP.Spawnable = true

if not IsMounted("cstrike") then
	function SWEP:Initialize()
		if SERVER then
			timer.Simple(0,function() -- This needs to be delayed by one tick so that self.Owner is valid!
				if not IsValid(self:GetCreator()) and IsValid(self) then -- When the weapon is spawned through other ways such as the Creator tool
					self:Remove()
					return -- We need to return so when someone clicks another player with the Creator, they do not receive the ChatPrint!
				end

				if not IsValid(self) or not IsValid(self.Owner) then return end
				self.Owner:ChatPrint("Sorry, that weapon is unavailable!")
				self.Owner:StripWeapon(self:GetClass())
				self:Remove()
			end)
		end
	end

	function SWEP:Holster()
		return true
	end

	function SWEP:Deploy()

	end

	function SWEP:DrawWorldModel()
		return false
	end

	function SWEP:ViewModelDrawn()
		return false
	end

	return
end -- Make sure CSS is mounted!

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55

SWEP.Primary.Ammo = "m9k_mmm_smokegrenade"

if CLIENT then
	local surfaceSetDrawColor = surface.SetDrawColor -- We cache this stuff to prevent overrides.
	local surfaceDrawRect = surface.DrawRect
	local ParticleEmitter = ParticleEmitter
	local drawSimpleText = draw.SimpleText
	local netReadEntity = net.ReadEntity
	local hookRemove = hook.Remove
	local mathrandom = math.random
	local VectorRand = VectorRand
	local mathClamp = math.Clamp
	local mathRand = math.Rand
	local hookAdd = hook.Add
	local IsValid = IsValid
	local Color = Color
	local ScrW = ScrW
	local ScrH = ScrH
	local CachedColor1 = Color(255,235,0)
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("Q","WeaponIcons_m9k_css",x + wide / 2,y + tall * 0.225,CachedColor1,TEXT_ALIGN_CENTER)
	end

	function SWEP:Initialize() -- We define this here so it does not try to load the VGUI selection material
		self:SetHoldType(self.HoldType)
		self.OurIndex = self:EntIndex()

		if self.Owner == LocalPlayer() then
			self:SendWeaponAnim(ACT_VM_IDLE)

			if self.Owner:GetActiveWeapon() == self then -- Compat/Bugfix
				self:Equip()
				self:Deploy()
			end
		end
	end

	local CreateSmoke = function(Ent)
		local Pos = Ent:GetPos()
		local Emitter = ParticleEmitter(Pos)

		for I = 1,20 do
			local prpos = VectorRand() * 5
			prpos.z = prpos.z + 32

			local p = Emitter:Add("particle/smokesprites_000"..mathrandom(1,9),Pos + prpos)
			local gray = math.random(75,125)
			p:SetColor(gray,gray,gray)
			p:SetStartAlpha(255)
			p:SetEndAlpha(0)
			p:SetVelocity(VectorRand() * mathRand(350,1000))
			p:SetLifeTime(0)
			p:SetDieTime(30)
			p:SetStartSize(math.random(100,300))
			p:SetEndSize(750)
			p:SetRoll(math.random(-180,180))
			p:SetRollDelta(math.Rand(-0.1,0.1))
			p:SetAirResistance(550)
			p:SetCollide(true)
			p:SetBounce(0.4)
			p:SetLighting(false)
		end

		Emitter:Finish()

		local me = LocalPlayer()
		local sCrW = ScrW()
		local sCrH = ScrH()

		local HookName = "M9k_Smokescreen_" .. Ent:EntIndex()
		hookAdd("HUDPaint",HookName,function()
			if not IsValid(Ent) then
				hookRemove("HUDPaint",HookName)
				return
			end

			local Alpha = mathClamp(255 - me:GetPos():DistToSqr(Ent:GetPos())/100 + 50,0,255)
			surfaceSetDrawColor(Color(100,100,100,Alpha))
			surfaceDrawRect(0,0,sCrW,sCrH)
		end)
	end

	net.Receive("M9k_Smokegrenade",function()
		local eSmokeGrenade = netReadEntity()
		if IsValid(eSmokeGrenade) then
			CreateSmoke(eSmokeGrenade)
		end
	end)
end

if SERVER then
	util.AddNetworkString("M9k_Smokegrenade")

	local CachedColor1 = Color(125,125,125)
	local CachedAngles1 = Angle(0,0,-45)

	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("prop_physics")
		Projectile:SetModel("models/weapons/w_eq_smokegrenade_thrown.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)
		Projectile:Spawn()
		Projectile:PhysWake()

		Projectile.WasDropped = true -- MMM Compatibility

		if MMM then util.SpriteTrail(Projectile,0,CachedColor1,true,15,15,1,1 / (15 + 15) * 0.5,"trails/laser.vmt") end -- In MMM environments, we want a clear indicator what this nade is!

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		Projectile.NextSound = CurTime()
		Projectile.DetonateTime = CurTime() + 3

		Projectile:CallOnRemove("M9k_RemoveSmokeGrenade",function()
			hook.Remove("Tick","M9k_MMM_SmokeGrenade_Think_" .. Projectile:EntIndex())
		end)

		Projectile:AddCallback("PhysicsCollide",function(_,data)
			if data.Speed > 100 and data.DeltaTime > 0.1 and Projectile.NextSound < CurTime() then -- Impact sounds.
				Projectile:EmitSound("weapons/smokegrenade/grenade_hit1.wav")
				Projectile.NextSound = CurTime() + 0.5
			end
		end)

		hook.Add("Tick","M9k_MMM_SmokeGrenade_Think_" .. Projectile:EntIndex(),function()
			local Phys = Projectile:GetPhysicsObject()

			if Projectile.DetonateTime < CurTime() and IsValid(Phys) and Phys:GetVelocity():Length() < 10 then
				hook.Remove("Tick","M9k_MMM_SmokeGrenade_Think_" .. Projectile:EntIndex())
				SafeRemoveEntityDelayed(Projectile,25)

				Projectile:EmitSound("weapons/smokegrenade/smoke_emit.wav",90)
				Projectile:EmitSound("weapons/smokegrenade/sg_explode.wav")

				net.Start("M9k_Smokegrenade")
					net.WriteEntity(Projectile)
				net.Broadcast()

				for _,v in ipairs(ents.FindInSphere(Projectile:GetPos(),200)) do -- Fire needs fuel, smoke is not fuel
					if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
						if v:GetClass() == "m9k_mmm_flame" then v:Remove() end

						v:Extinguish()
						v:EmitSound("ambient/fire/mtov_flame2.wav",75)
					end
				end

				Phys:EnableMotion(false)
			end
		end)

		return Projectile
	end
end