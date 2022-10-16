if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if game.SinglePlayer() and not IsMounted("episodic") then return end -- In singleplayer we do not even want this to be loaded in the first place!
if SERVER and not IsMounted("episodic") then
	SWEP.Base = "meteors_notmounted_base"

	return
end -- Make sure Hl2 Episode 1 is mounted!

SWEP.Base = "meteors_grenade_base_model"
SWEP.Category = "M9kR: Throwables"
SWEP.PrintName = "Flare"

SWEP.Spawnable = true

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props_junk/flare.mdl"

SWEP.Primary.Ammo = "m9k_mmm_flaregrenade"

SWEP.ModelWorldForwardMult = 3.25
SWEP.ModelWorldRightMult = 2
SWEP.ModelWorldAngForward = 10
SWEP.ModelWorldAngRight = 180

SWEP.ViewModelScale = Vector(0.6,0.6,0.6)
SWEP.ModelViewForwardMult = 3.5
SWEP.ModelViewRightMult = 1.65
SWEP.ModelViewAngForward = -15
SWEP.ModelViewAngRight = 180
SWEP.ModelViewBlacklistedBones = {
	["v_weapon.Flashbang_Parent"] = true,
	["v_weapon.strike_lever"] = true,
	["v_weapon.safety_pin"] = true,
	["v_weapon.pull_ring"] = true
}

SWEP.GrenadeClassEnt = "m9k_mmm_thrownflare"
SWEP.GrenadeModelStr = "models/props_junk/flare.mdl"
SWEP.GrenadeThrowAng = Angle(0,0,-45)

if CLIENT then

	local drawSimpleText = draw.SimpleText
	local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

	local cCached1 = Color(255,235,0)


	function SWEP:DrawWeaponSelection(x,y,wide,tall)
		drawSimpleText("J","WeaponIcons_m9k_css",x + wide / 2 * 1.055,y + tall * 0.275,cCached1,TEXT_ALIGN_CENTER)
	end
end

if SERVER then

	local aCached1 = Angle(0,45,0)
	local vCached1 = Vector(2,-2,4)


	function SWEP:ResetInternalVarsHooked()
		if IsValid(self.eFlare) then
			self.eFlare:Remove()
		end
	end


	function SWEP:PrimaryAttackHooked()

		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then

			local fTimerFunc = function()

				if not IsValid(self) or not IsValid(self.Owner) or self.Owner:GetActiveWeapon() ~= self then return end


				self.eFlare = ents.Create("env_flare")
				local eFlare = self.eFlare -- Optimization but also required

					SafeRemoveEntityDelayed(eFlare,28)

				if IsValid(eFlare) then

					eFlare:SetPos(self.Owner:GetPos())
					eFlare:SetParent(self.Owner)

					eFlare:SetKeyValue("scale",5)
					eFlare:SetKeyValue("duration",600)


					local bone_RHand = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
					local sAttachment = ""

					for _,v in pairs(self.Owner:GetAttachments()) do

						if v.name == "anim_attachment_RH" then

							sAttachment = "anim_attachment_RH"
							break

						elseif v.name == "Blood_Right" then

							if bone_RHand then
								self.Owner:ManipulateBoneAngles(bone_RHand,aCached1)
								self.Owner:ManipulateBonePosition(bone_RHand,vCached1)
							end

							sAttachment = "Blood_Right"
							break

						end
					end

					eFlare:Fire("setparentattachment",sAttachment,0)


					eFlare:Spawn()


					ParticleEffectAttach("Rocket_Smoke_Trail",PATTACH_ABSORIGIN_FOLLOW,eFlare,0)


					eFlare:Use(self,self,USE_SET,1) -- Activate flare


					eFlare:CallOnRemove("M9kr_StopSound",function()
						eFlare:StopSound("weapons/flaregun/burn.wav") -- STOP!!
					end)


					eFlare:EmitSound("weapons/flaregun/burn.wav",75)


					timer.Simple(28,function() -- Eventually it's depleted.

						if not IsValid(eFlare) then return end

						eFlare:StopSound("weapons/flaregun/burn.wav") -- STOP!!


						if not IsValid(self) then return end

						self.BurntOut = true

					end)
				end
			end


			if not self.Owner.MMM_HasOPWeapons then -- MMM Compatibility
				timer.Simple((vm:SequenceDuration() + 0.2) - (game.SinglePlayer() and 0.3 or 0.5),fTimerFunc)
			else
				fTimerFunc()
			end

		end
	end


	function SWEP:ProjectileModifications(ent_Projectile)

		if self.BurntOut then
			ent_Projectile.BurntOut = true
		end


		if IsValid(self.eFlare) then

			self.eFlare:SetParent()

			self.eFlare:SetPos(ent_Projectile:GetPos())
			self.eFlare:SetParent(ent_Projectile)

			self.eFlare = nil -- Make sure the FX doesn't get removed after swapping weapons! (After it was thrown)

		end
	end
end