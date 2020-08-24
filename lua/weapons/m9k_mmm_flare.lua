if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9K Throwables"
SWEP.PrintName = "Flare"

SWEP.Spawnable = true

if not IsMounted("episodic") then
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
end -- Make sure Hl2 Episode 1 is mounted!

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props_junk/flare.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55

SWEP.Primary.Ammo = "m9k_mmm_flaregrenade"

SWEP.WorldModelScale = Vector(1,1,1)
SWEP.ModelWorldForwardMult = 3.25
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldUpMult = 0
SWEP.ModelWorldAngForward = 10
SWEP.ModelWorldAngRight = 180
SWEP.ModelWorldAngUp = 0

SWEP.ViewModelScale = Vector(0.6,0.6,0.6)
SWEP.ModelViewForwardMult = 3.5
SWEP.ModelViewRightMult = 1.65
SWEP.ModelViewUpMult = 0
SWEP.ModelViewAngForward = -15
SWEP.ModelViewAngRight = 180
SWEP.ModelViewAngUp = 0
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

local SharedCachedAngles1 = Angle(0,45,0)
local SharedCachedVector1 = Vector(2,-2,4)

if CLIENT then
	local drawSimpleText = draw.SimpleText -- We cache this stuff to prevent overrides
	local CachedColor1 = Color(255,235,0)
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("J","WeaponIcons_m9k_css",x + wide / 2 * 1.055,y + tall * 0.275,CachedColor1,TEXT_ALIGN_CENTER)
	end

	function SWEP:Initialize() -- We define this here so it does not try to load the VGUI selection material
		self:SetHoldType(self.HoldType)
		self.OurIndex = self:EntIndex()
		self:SetNWBool("ShouldDraw",true)

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

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() and self.CanPullPin and self:GetNextPrimaryFire() < CurTime() then
		self:SetNextPrimaryFire(CurTime() + 2)
		self.CanPullPin = false

		self:SendWeaponAnim(ACT_VM_PULLPIN)

		local vm = self.Owner:GetViewModel()
		if SERVER or IsValid(vm) then -- SERVER or the CLIENT throwing the grenade
			if not IsFirstTimePredicted() then return end -- Fixes weird prediction bugs.
			local Dur = vm:SequenceDuration() + 0.2

			timer.Create("M9k_MMM_Grenade_Pullpin" .. self.OurIndex,Dur,1,function()
				if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon():GetClass() ~= self:GetClass() then return end
				self.PinPulled = true
			end)

			if SERVER then
				timer.Create("M9k_MMM_Grenade_Pullpin_Flare" .. self.OurIndex,Dur - (game.SinglePlayer() and 0.3 or 0.5),1,function()
					if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon():GetClass() ~= self:GetClass() then return end

					self.burnFX = ents.Create("env_flare")
					self.burnFX:SetPos(self.Owner:GetPos())
					self.burnFX:SetKeyValue("scale",5)
					self.burnFX:SetKeyValue("duration",600)

					local RHand = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")

					self.burnFX:SetParent(self.Owner)

					local AttachmentType = ""
					for _,v in pairs(self.Owner:GetAttachments()) do
						if v.name == "anim_attachment_RH" then
							AttachmentType = "anim_attachment_RH"
							break
						elseif v.name == "Blood_Right" then
							if RHand then
								self.Owner:ManipulateBoneAngles(RHand,SharedCachedAngles1)
								self.Owner:ManipulateBonePosition(RHand,SharedCachedVector1)
							end

							AttachmentType = "Blood_Right"
							break
						end
					end

					self.burnFX:Fire("setparentattachment",AttachmentType,0)
					self.burnFX:Spawn()

					ParticleEffectAttach("Rocket_Smoke_Trail",PATTACH_ABSORIGIN_FOLLOW,self.burnFX,0)

					self.burnFX:Use(self,self,USE_SET,1)
					local sSound = CreateSound(self.burnFX,"weapons/flaregun/burn.wav")
					sSound:Play()

					timer.Simple(28,function()
						if sSound then
							sSound:Stop()

							if IsValid(self) then
								self.BurntOut = true
							end
						end
					end)

					self.sSwapSound = sSound

					SafeRemoveEntityDelayed(self.burnFX,28)
				end)
			end
		end
	end
end

function SWEP:Think()
	if CLIENT then -- Hide base viewmodel when cameras changed
		local View = self.Owner:GetViewEntity()

		if View ~= self.LastViewEntity then
			self:HideBaseViewModel()
		end

		self.LastViewEntity = View
	end

	if self.PinPulled and not self.Owner:KeyDown(IN_ATTACK) then
		self:SendWeaponAnim(ACT_VM_THROW)
		self:AttackAnimation()

		self:SetNWBool("ShouldDraw",false)

		if SERVER and IsValid(self) and IsValid(self.Owner) and IsValid(self.burnFX) and self.Owner:GetViewEntity() == self.Owner then
			self.Owner:SendLua("local Ent = Entity(" .. self.burnFX:EntIndex() .. "); if IsValid(Ent) then Ent:SetNoDraw(true) end")
		end

		local vm = self.Owner:GetViewModel()
		if SERVER or IsValid(vm) then -- SERVER or the CLIENT throwing the grenade
			local Dur = vm:SequenceDuration() - 0.5

			timer.Create("M9k_MMM_Grenade_Grenadethrow" .. self.OurIndex,Dur,1,function()
				if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon():GetClass() ~= self:GetClass() then return end

				if SERVER then
					self:TakePrimaryAmmo(1)

					local Ang = self.Owner:EyeAngles() -- Taken from TTT base grenade since it is quite good in my opinion
					local Src = self.Owner:GetPos() + (self.Owner:Crouching() and self.Owner:GetViewOffsetDucked() or self.Owner:GetViewOffset()) + (Ang:Forward() * 8) + (Ang:Right() * 10)
					local Target = self.Owner:GetEyeTraceNoCursor().HitPos
					local TAng = (Target - Src):Angle()

					if TAng.p < 90 then
						TAng.p = -10 + TAng.p * ((90 + 10) / 90)
					else
						TAng.p = 360 - TAng.p
						TAng.p = -10 + TAng.p * -((90 + 10) / 90)
					end

					TAng.p = math.Clamp(TAng.p,-90,90)
					local Vel = math.min(800,(90 - TAng.p) * 6)
					local Thr = TAng:Forward() * Vel + self.Owner:GetVelocity()

					local Projectile = self:CreateGrenadeProjectile(Src)

					if IsValid(Projectile) then
						local Phys = Projectile:GetPhysicsObject()

						if IsValid(Phys) then
							Phys:SetVelocity(Thr)
							Phys:AddAngleVelocity(Vector(600,math.random(-1200,1200),0))
						end
					end
				end

				timer.Create("M9k_MMM_Grenade_Grenadethrow" .. self.OurIndex,0.3,1,function()
					if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon():GetClass() ~= self:GetClass() then return end

					if (self:Clip1() <= 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
						if SERVER then
							self.CanPullPin = true -- Needs to be set so the last grenade throw does not call the OnDrop 'death' function
							self.Owner:StripWeapon(self:GetClass())
						end
					else
						self:Deploy()
						self.Owner:RemoveAmmo(1,self.Primary.Ammo)
						self:SetClip1(1)
					end

					self:SetNWBool("ShouldDraw",true)
				end)
			end)
		end

		self.PinPulled = false
	end
end

if SERVER then
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false
	local CachedAngles1 = Angle(0,0,-45)

	function SWEP:CreateGrenadeProjectile(Pos)
		local Projectile = ents.Create("m9k_mmm_thrownflare")
			SafeRemoveEntityDelayed(Projectile,28)

		Projectile:SetModel("models/props_junk/flare.mdl")
		Projectile:SetPos(Pos)
		Projectile:SetAngles(self.Owner:EyeAngles() + CachedAngles1)
		Projectile:SetCollisionGroup(COLLISION_GROUP_NONE)
		Projectile:SetGravity(0.4)
		Projectile:SetFriction(0.2)
		Projectile:SetElasticity(0.45)

		Projectile.WasDropped = true -- MMM Compatibility

		Projectile:SetOwner(self.Owner)

		if CPPIExists then
			Projectile:CPPISetOwner(self.Owner)
		end

		if self.BurntOut then
			Projectile.BurntOut = true
		end

		Projectile:Spawn()

		if IsValid(self.burnFX) then
			self.burnFX:SetParent()
			self.burnFX:SetPos(Projectile:GetPos())
			self.burnFX:SetParent(Projectile)

			self.Owner:SendLua("local Ent = Entity(" .. self.burnFX:EntIndex() .. "); if IsValid(Ent) then Ent:SetNoDraw(false) end")

			self.burnFX = nil -- Make sure the FX doesn't get removed after swapping weapons! (After it was thrown)
			self.sSwapSound = nil -- Make sure the sound doesn't get removed after swapping weapons! (After it was thrown)
		end

		Projectile:PhysWake()

		return Projectile
	end

	function SWEP:Holster()
		if not SERVER and self.Owner ~= LocalPlayer() then return end

		timer.Remove("M9k_MMM_Grenade_Pullpin" .. self.OurIndex)
		timer.Remove("M9k_MMM_Grenade_Pullpin_Flare" .. self.OurIndex)
		timer.Remove("M9k_MMM_Grenade_Grenadethrow" .. self.OurIndex)

		self.CanPullPin = true
		self.PinPulled = false

		if SERVER and IsValid(self.Owner) then
			if (self:Clip1() <= 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then -- Remove the grenade when its 'empty'
				self.Owner:StripWeapon(self:GetClass())
			elseif self:Clip1() <= 0 then -- Unless we still have some left in which case we refill the 'magazine'
				self:SetClip1(1)
				self.Owner:RemoveAmmo(1,self.Primary.Ammo)
			end
		end

		if IsValid(self.burnFX) then
			self.burnFX:Remove()
		end

		if self.sSwapSound then
			self.sSwapSound:Stop()
		end

		return true
	end
end