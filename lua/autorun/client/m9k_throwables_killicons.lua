hook.Add("Initialize","MMM_M9k_throwables_Initkillicons",function()
	if CLIENT and MMM_M9k_IsBaseInstalled then
		local icol = Color(255,255,255)

		killicon.Add("m9k_mmm_thrownbeer","vgui/hud/m9k_mmm_thrownbeer",icol)
		killicon.Add("m9k_mmm_thrownfrag","vgui/hud/m9k_mmm_thrownfrag",icol)
		killicon.Add("m9k_mmm_flame","vgui/hud/m9k_mmm_flame",icol)
		killicon.Add("m9k_mmm_thrownpipebomb","vgui/hud/m9k_mmm_thrownpipebomb",icol)
		killicon.Add("m9k_mmm_thrownrock","vgui/hud/m9k_mmm_thrownrock",icol)
		killicon.Add("m9k_mmm_thrownsnowball","vgui/hud/m9k_mmm_thrownsnowball",icol)
	end
end)