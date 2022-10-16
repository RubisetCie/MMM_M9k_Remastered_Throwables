if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("cstrike") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("cstrike") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- Make sure CSS is mounted!

SWEP.Base = "meteors_grenade_base"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Smoke Grenade"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"
SWEP.UseHands = true

SWEP.Primary.Ammo = "m9k_mmm_smokegrenade"

SWEP.GrenadeClassEnt = "m9k_mmm_thrownsmoke"
SWEP.GrenadeModelStr = "models/weapons/w_eq_smokegrenade_thrown.mdl"
SWEP.GrenadeThrowAng = Angle(0,0,-45)
SWEP.GrenadeTrailCol = Color(125,125,125)

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("Q","WeaponIcons_m9k_css",x + wide / 2,y + tall * 0.225,cCached1,TEXT_ALIGN_CENTER)
	end
end