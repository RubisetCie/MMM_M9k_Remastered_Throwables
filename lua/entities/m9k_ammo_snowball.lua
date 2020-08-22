if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Snowballs"
ENT.Category = "M9K Ammunition (Throwables)"
ENT.Spawnable = true
ENT.AdminOnly = false

if CLIENT then
	local LEDColor = Color(230,45,45)
	local VectorCache1 = Vector(0,90,90)
	local Text = "Snowballs"

	function ENT:Draw()
		self:DrawModel()

		local FixAngles = self:GetAngles()
		FixAngles:RotateAroundAxis(FixAngles:Right(),VectorCache1.x)
		FixAngles:RotateAroundAxis(FixAngles:Up(),VectorCache1.y)
		FixAngles:RotateAroundAxis(FixAngles:Forward(),VectorCache1.z)

		cam.Start3D2D(self:GetPos() + (self:GetUp() * 9) + (self:GetRight() * 6) + (self:GetForward() * 17),FixAngles,0.16)
			draw.SimpleText(Text,"DermaLarge",31,-22,LEDColor,1,1)
		cam.End3D2D()
	end
end

if not IsMounted("csgo") then
	function ENT:Initialize()
		if SERVER then
			self:Remove()
		end
	end

	return
elseif SERVER then -- Make sure CS:GO is mounted!
	local MetaE = FindMetaTable("Entity")
	local CPPIExists = MetaE.CPPISetOwner and true or false
	local VectorCache1 = Vector(0,0,10)
	local effectdata = EffectData()
	effectdata:SetMagnitude(18)
	effectdata:SetScale(1.3)

	function ENT:Initialize()
		self.Owner = self:GetCreator()

		if IsValid(self.Owner) then -- We NEED to have an owner, otherwise we cannot 'splode
			self.CanSplode = true
		end

		self:SetModel("models/items/item_item_crate.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:PhysWake()
		self:SetUseType(SIMPLE_USE)

		timer.Simple(0,function()
			if not IsValid(self) then return end
			self:SetPos(self:GetPos() + VectorCache1)
			self:DropToFloor()
		end)

		self.iHealth = 100
	end

	function ENT:PhysicsCollide(Data)
		if Data.Speed > 80 and Data.DeltaTime > 0.2 then
			self:EmitSound("Wood.ImpactHard")

			if Data.Speed > 350 then
				self.iHealth = self.iHealth - math.Clamp(Data.Speed/20,0,100)
				self:Splode() -- Check if we should 'splode
			end
		end
	end

	function ENT:Use(Activator)
		if Activator:IsPlayer() then
			if Activator:GetWeapon("m9k_mmm_snowball") == NULL then
				Activator:Give("m9k_mmm_snowball")
				Activator:GiveAmmo(14,"m9k_mmm_snowball")
			else
				Activator:GiveAmmo(15,"m9k_mmm_snowball")
			end

			self:Remove()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		local dmg = dmginfo:GetDamage()

		if isnumber(dmg) then
			self.iHealth = self.iHealth - dmg
			self:Splode() -- Check if we should 'splode
		end
	end

	function ENT:Splode()
		if not self.CanSplode then return end

		if self.iHealth <= 0 and not self.Sploded then
			self.Sploded = true -- Safeguard
			local Pos = self:GetPos()

			self:EmitSound("physics/wood/wood_plank_break" .. math.random(2,4) .. ".wav")

			for I = 1,15 do
				local DroppedEnt = ents.Create("m9k_mmm_snowball")
				timer.Simple(10,function() -- We cannot use SafeRemoveEntityDelayed as it would otherwise delete the weapon a player is holding
					if IsValid(DroppedEnt) and not IsValid(DroppedEnt.Owner) then
						DroppedEnt:Remove()
					end
				end)

				DroppedEnt:SetPos(Pos + VectorCache1)
				DroppedEnt:SetAngles(AngleRand())
				DroppedEnt:Spawn()
				DroppedEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

				if CPPIExists and IsValid(self.Owner) then
					DroppedEnt:CPPISetOwner(self.Owner)
				end

				local Phys = DroppedEnt:GetPhysicsObject()
				if IsValid(Phys) then
					Phys:SetVelocity(VectorRand(-250,250))
					Phys:AddAngleVelocity(VectorRand(-500,500))
				end
			end

			self:Remove()
		end
	end
end