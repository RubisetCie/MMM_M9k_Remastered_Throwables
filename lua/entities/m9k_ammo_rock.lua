if not MMM_M9k_IsBaseInstalled then return end -- Make sure the base is installed!

AddCSLuaFile()

ENT.Base = "m9kr_base_ammo"
ENT.Category = "M9kR: Ammunition"
ENT.PrintName = "[T] Rocks"
ENT.Spawnable = true

ENT.AmmoClass		= "m9k_mmm_rocks"
ENT.AmmoWeapon		= "m9k_mmm_rock"
ENT.AmmoModel		= "models/items/item_item_crate.mdl"
ENT.AmmoCount		= 16
ENT.ImpactSound		= "Default.ImpactSoft"

ENT.bDrawText		= true
ENT.bDropOnDestroy	= true
ENT.DropClass		= "m9k_mmm_rock"

ENT.Text 			= "Rocks"
ENT.TextPos			= Vector(0,90,90)
ENT.TextColor		= Color(230,45,45)
ENT.TextScale		= 0.25

ENT.OffsetUp		= 12
ENT.OffsetRight		= 1
ENT.OffsetForward	= 18