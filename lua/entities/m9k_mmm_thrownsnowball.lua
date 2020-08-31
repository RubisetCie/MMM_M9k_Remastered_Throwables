if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!
if SERVER and not IsMounted("csgo") then return end -- Make sure CS:GO is mounted!
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Snowball"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

function ENT:CanTool() return false end

if SERVER then
	util.AddNetworkString("M9k_MMM_Snowball_Overlay")
	local damageInfo = DamageInfo()

	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self.Phys = self:GetPhysicsObject()

		self:SetTrigger(true)
	end

	function ENT:Splat(Decal,Start,End)
		if Decal then util.Decal("Splash.Large",Start,End,self) end
		self:EmitSound("player/winter/snowball_hit_0" .. math.random(1,4) .. ".wav")

		for _,v in ipairs(ents.FindInSphere(self:GetPos(),50)) do -- Fire does not like water
			if v:IsOnFire() or v:GetClass() == "m9k_mmm_flame" then
				if v:GetClass() == "m9k_mmm_flame" then v:Remove() end

				v:Extinguish()
				v:EmitSound("ambient/fire/mtov_flame2.wav",75)
			end
		end

		self:Remove()
	end

	function ENT:PhysicsCollide(Data)
		if Data.DeltaTime > 0.1 then
			self:Splat(true,Data.HitPos + Data.HitNormal * -10,Data.HitPos + Data.HitNormal * 10)
		end
	end

	function ENT:StartTouch(Ent)
		if Ent == self.Owner or (not Ent:IsNPC() and not Ent:IsPlayer()) then return end

		damageInfo:SetDamageType(DMG_DIRECT)
		damageInfo:SetAttacker(self.Owner)
		damageInfo:SetInflictor(self)
		damageInfo:SetDamage(5 + self.Phys:GetVelocity():Length()/100)
		Ent:TakeDamageInfo(damageInfo)

		if Ent:IsPlayer() and (MMM and self.Owner:IsPVP() and Ent:IsPVP() or not MMM and true) then
			net.Start("M9k_MMM_Snowball_Overlay")
			net.Send(Ent)
		end

		self:Splat(false,nil,nil)
	end
end

if CLIENT then
	local Mat = CreateMaterial("SnowOverlay","UnlitGeneric",{ -- We need to create a new Material since the original does not support alpha.
		["$basetexture"] = "nature/snowfloor001a",
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	})

	local SnowballOverlay = function()
		local Alpha = 0
		local scrW = ScrW()
		local scrH = ScrH()
		local StartTime = CurTime()
		local TimeSince = 0

		hook.Add("HUDPaint","Snowball_Overlay",function()
			TimeSince = CurTime() - StartTime

			surface.SetDrawColor(255,255,255,255 - Alpha)
			surface.SetMaterial(Mat)
			surface.DrawTexturedRect(0,0,scrW,scrH + Alpha)

			if Alpha < 255 then
				Alpha = (TimeSince/1) * 255
			else
				hook.Remove("HUDPaint","Snowball_Overlay")
			end
		end)
	end

	net.Receive("M9k_MMM_Snowball_Overlay",SnowballOverlay)

	function ENT:Draw()
		self:DrawModel()
	end
end