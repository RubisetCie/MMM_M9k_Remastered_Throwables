if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base_model_instant"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "Pipebomb"

SWEP.Spawnable = true

if not IsMounted("left4dead") and not IsMounted("left4dead2") then
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
end -- We make sure that either Left4Dead or Left4Dead2 is installed since the models are identical.

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_pipebomb.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55
SWEP.UseHands = true

SWEP.Primary.Ammo = "m9k_mmm_pipebomb"

SWEP.WorldModelScale = Vector(1,1,1)
SWEP.ModelWorldForwardMult = 3
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -1
SWEP.ModelWorldAngForward = 10
SWEP.ModelWorldAngRight = 195
SWEP.ModelWorldAngUp = -150

SWEP.ViewModelScale = Vector(0.75,0.75,0.75)
SWEP.ModelViewForwardMult = 3.5
SWEP.ModelViewRightMult = 2
SWEP.ModelViewUpMult = -1
SWEP.ModelViewAngForward = -5
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = -150
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.AttacksoundPrimary = "weapons/iceaxe/iceaxe_swing1.wav"

if CLIENT then
	local drawSimpleText = draw.SimpleText -- We cache this stuff to prevent overrides
	local CachedColor1 = Color(255,235,0)
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("O","WeaponIcons_m9k_css",x + wide / 2 * 1.055,y + tall * 0.275,CachedColor1,TEXT_ALIGN_CENTER)
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
	local CachedColor1 = Color(255,93,0)
	local CachedAngles1 = Angle(0,0,-45)

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("m9k_mmm_thrownpipebomb")
			SafeRemoveEntityDelayed(Projectile,30)

		Projectile:SetModel("models/w_models/weapons/w_eq_pipebomb.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_NONE)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)
		Projectile:Spawn()
		Projectile:PhysWake()

		Projectile.WasDropped = true -- MMM Compatibility

		util.SpriteTrail(Projectile,0,CachedColor1,true,5,5,1,1 / ( 5 + 5 ) * 0.5,"trails/laser.vmt")

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		return Projectile
	end
end