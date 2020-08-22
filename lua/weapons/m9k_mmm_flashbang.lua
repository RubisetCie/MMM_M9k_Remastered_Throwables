if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "Flashbang"

SWEP.Spawnable = true

if not IsMounted("cstrike") then
	function SWEP:Initialize()
		if SERVER then
			timer.Simple(0,function() -- This needs to be delayed by one tick so that self.Owner is valid!
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

	return
end -- Make sure CSS is mounted!

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55

SWEP.Primary.Ammo = "m9k_mmm_flashbang"

if CLIENT then
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER -- We cache this stuff to prevent overrides
	local drawSimpleText = draw.SimpleText
	local VectorCache1 = Vector(350,0,10)
	local VectorCache2 = Vector(0,350,10)
	local VectorCache3 = Vector(-350,0,10)
	local VectorCache4 = Vector(0,-350,10)
	local CachedColor1 = Color(255,235,0)
	local CachedColor2 = Color(255,255,255)

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("P","WeaponIcons_m9k_css",x + wide / 2,y + tall * 0.225,CachedColor1,TEXT_ALIGN_CENTER)
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

	local IsLookingAt = function(TargetVec)
		local me = LocalPlayer()
		local Arg = me:GetAimVector():Dot((TargetVec - me:GetPos() + Vector(me:GetFOV())):GetNormalized())

		return Arg < 1 and Arg > 0, Arg
	end

	net.Receive("M9K_MMM_Flashbang_Flash",function()
		local Pos = net.ReadVector()
		local Ent = net.ReadEntity()

		if isvector(Pos) then
			local me = LocalPlayer()

			if (MMM and me:IsPVP() or Ent == me) or not MMM then -- In an MMM environment, we only want players to be flashed when they're in PVP!
				local mePos = me:GetPos()
				local bVisible = false
				local iStrength = 0
				local tTraceHits = 0

				local bVisibleC, iStrengthC = IsLookingAt(Pos) -- Center
				iStrength = iStrength + iStrengthC
				if not bVisible then bVisible = bVisibleC end
				local tTrace = util.TraceLine({start = Pos,endpos = mePos})
				if tTrace.Entity == LocalPlayer() or tTrace.HitPos == mePos then tTraceHits = tTraceHits + 1 end

				local bVisibleC, iStrengthC = IsLookingAt(Pos + VectorCache1)
				iStrength = iStrength + iStrengthC
				if not bVisible then bVisible = bVisibleC end
				local tTrace = util.TraceLine({start = Pos + VectorCache1,endpos = mePos})
				if tTrace.Entity == LocalPlayer() or tTrace.HitPos == mePos then tTraceHits = tTraceHits + 1 end

				local bVisibleC, iStrengthC = IsLookingAt(Pos + VectorCache2)
				iStrength = iStrength + iStrengthC
				if not bVisible then bVisible = bVisibleC end
				local tTrace = util.TraceLine({start = Pos + VectorCache2,endpos = mePos})
				if tTrace.Entity == LocalPlayer() or tTrace.HitPos == mePos then tTraceHits = tTraceHits + 1 end

				local bVisibleC, iStrengthC = IsLookingAt(Pos + VectorCache3)
				iStrength = iStrength + iStrengthC
				if not bVisible then bVisible = bVisibleC end
				local tTrace = util.TraceLine({start = Pos + VectorCache3,endpos = mePos})
				if tTrace.Entity == LocalPlayer() or tTrace.HitPos == mePos then tTraceHits = tTraceHits + 1 end

				local bVisibleC, iStrengthC = IsLookingAt(Pos + VectorCache4)
				iStrength = iStrength + iStrengthC
				if not bVisible then bVisible = bVisibleC end
				local tTrace = util.TraceLine({start = Pos + VectorCache4,endpos = mePos})
				if tTrace.Entity == LocalPlayer() or tTrace.HitPos == mePos then tTraceHits = tTraceHits + 1 end

				if bVisible and tTraceHits >= 1 then
					local iTime = 1 * ((iStrength/2)*(tTraceHits/2))
					me:ScreenFade(SCREENFADE.IN,CachedColor2,1,iTime)
					me:SetDSP(35,false)

					local UniqueFlashID = math.random(0,2147483647)  -- Hide HUD while flashed!
					hook.Add("HUDShouldDraw","M9K_MMM_Flashbang_" .. UniqueFlashID,function()
						return false
					end)

					timer.Simple(iTime,function()
						hook.Remove("HUDShouldDraw","M9K_MMM_Flashbang_" .. UniqueFlashID)
					end)
				end
			end

			local PhysLight = DynamicLight(math.random(1,255))
			if PhysLight then
				PhysLight.Pos = Pos
				PhysLight.r = 255
				PhysLight.G = 255
				PhysLight.B = 255
				PhysLight.Brightness = 5
				PhysLight.Size = 350
				PhysLight.Decay = 2500
				PhysLight.DieTime = CurTime() + 0.1
			end
		end
	end)
end

if SERVER then
	util.AddNetworkString("M9K_MMM_Flashbang_Flash")

	local CachedColor1 = Color(255,255,255)
	local CachedAngles1 = Angle(0,0,-45)

	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("prop_physics")
		Projectile:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)
		Projectile:Spawn()
		Projectile:PhysWake()

		Projectile.WasDropped = true -- MMM Compatibility

		if MMM then util.SpriteTrail(Projectile,0,CachedColor1,true,15,15,1,1 / ( 15 + 15 ) * 0.5,"trails/laser.vmt") end -- In MMM environments, we want a clear indicator what this nade is!

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		Projectile.NextSound = CurTime()
		Projectile.DetonateTime = CurTime() + 3

		Projectile:CallOnRemove("M9k_RemoveFlashGrenade",function()
			hook.Remove("Tick","M9k_MMM_FlashGrenade_Think_" .. Projectile:EntIndex())
		end)

		Projectile:AddCallback("PhysicsCollide",function(_,data)
			if data.Speed > 100 and data.DeltaTime > 0.1 and Projectile.NextSound < CurTime() then -- Impact sounds
				Projectile:EmitSound("weapons/flashbang/grenade_hit1.wav")
				Projectile.NextSound = CurTime() + 0.5
			end
		end)

		hook.Add("Tick","M9k_MMM_FlashGrenade_Think_" .. Projectile:EntIndex(),function()
			if Projectile.DetonateTime < CurTime() then
				hook.Remove("Tick","M9k_MMM_FlashGrenade_Think_" .. Projectile:EntIndex())
				SafeRemoveEntityDelayed(Projectile,25)

				Projectile:EmitSound("weapons/flashbang/flashbang_explode" .. math.random(1,2) .. ".wav",90)

				net.Start("M9K_MMM_Flashbang_Flash")
					net.WriteVector(Projectile:GetPos())
					net.WriteEntity(Projectile:GetOwner())
				net.Broadcast()

				Projectile:Remove()
			end
		end)

		return Projectile
	end
end