if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("csgo") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("csgo") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- Make sure CS:GO is mounted!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Decoy"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_decoy_thrown.mdl" -- Higher quality for dropped ones.

SWEP.Primary.Ammo = "m9k_mmm_decoy"

SWEP.WorldModelStr = "models/weapons/w_eq_decoy.mdl"
SWEP.ViewModelStr = "models/weapons/w_eq_decoy.mdl"

SWEP.ModelWorldForwardMult = -1.5
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = -2
SWEP.ModelWorldAngForward = 0
SWEP.ModelWorldAngRight = 190
SWEP.ModelWorldAngUp = -180

SWEP.ModelViewForwardMult = 0.5
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

SWEP.GrenadeClassEnt = "m9k_mmm_throwndecoy"
SWEP.GrenadeModelStr = "models/weapons/w_eq_decoy_thrown.mdl"

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("P","WeaponIcons_m9k_css",x + wide / 2 * 1,y + tall * 0.25,cCached1,TEXT_ALIGN_CENTER)
	end
end