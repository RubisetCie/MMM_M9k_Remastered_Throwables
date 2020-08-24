if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "HE Grenade"

SWEP.Spawnable = true

if not IsMounted("cstrike") then
	function SWEP:Initialize()
		if SERVER then
			timer.Simple(0,function() -- This needs to be delayed by one tick so that self.Owner is valid!
				if not IsValid(self) or not IsValid(self.Owner) then return end
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

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55

SWEP.Primary.Ammo = "m9k_mmm_grenade"

if CLIENT then
	local drawSimpleText = draw.SimpleText -- We cache this stuff to prevent overrides.
	local CachedColor1 = Color(255,235,0)
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("O","WeaponIcons_m9k_css",x + wide / 2 * 1.065,y + tall * 0.225,CachedColor1,TEXT_ALIGN_CENTER)
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
end

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false
	local CachedColor1 = Color(225,0,0)
	local CachedAngles1 = Angle(0,0,-45)

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("m9k_mmm_thrownfrag")
			SafeRemoveEntityDelayed(Projectile,30)

		Projectile:SetModel("models/weapons/w_eq_fraggrenade_thrown.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)
		Projectile:Spawn()
		Projectile:PhysWake()

		Projectile.WasDropped = true -- MMM Compatibility

		if MMM then util.SpriteTrail(Projectile,0,CachedColor1,true,5,5,1,1 / ( 5 + 5 ) * 0.5,"trails/laser.vmt") end -- In MMM environments, we want a clear indicator what this nade is!

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		return Projectile
	end
end