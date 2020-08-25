if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "Decoy"

SWEP.Spawnable = true

if not IsMounted("csgo") then
	function SWEP:Initialize()
		if SERVER then
			timer.Simple(0,function() -- This needs to be delayed by one tick so that self.Owner is valid!
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

	return
end -- Make sure CS:GO is mounted!

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_decoy.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55

SWEP.Primary.Ammo = "m9k_mmm_decoy"

SWEP.WorldModelScale = Vector(1,1,1)
SWEP.ModelWorldForwardMult = -1.5
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -2
SWEP.ModelWorldAngForward = 0
SWEP.ModelWorldAngRight = 190
SWEP.ModelWorldAngUp = -180

SWEP.ViewModelScale = Vector(0.75,0.75,0.75)
SWEP.ModelViewForwardMult = 0.5
SWEP.ModelViewRightMult = 0
SWEP.ModelViewUpMult = -2
SWEP.ModelViewAngForward = -15
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = -140
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

if CLIENT then
	local drawSimpleText = draw.SimpleText -- We cache this stuff to prevent overrides
	local CachedColor1 = Color(255,235,0)
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("P","WeaponIcons_m9k_css",x + wide / 2 * 1,y + tall * 0.25,CachedColor1,TEXT_ALIGN_CENTER)
	end

	function SWEP:Initialize() -- We define this here so it does not try to load the VGUI selection material
		self:SetHoldType(self.HoldType)
		self.OurIndex = self:EntIndex()

		self.ShouldDraw = true
		self.LastViewEntity = NULL

		self:CreateWorldModel()

		if self.Owner == LocalPlayer() then
			self:SendWeaponAnim(ACT_VM_IDLE)

			self:CreateViewModel()

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
	local CachedAngles1 = Angle(0,0,-45)

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("m9k_mmm_throwndecoy")
			SafeRemoveEntityDelayed(Projectile,30)

		Projectile:SetModel("models/weapons/w_eq_decoy_thrown.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_NONE)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)
		Projectile:Spawn()
		Projectile:PhysWake()

		Projectile.WasDropped = true -- MMM Compatibility

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		return Projectile
	end
end