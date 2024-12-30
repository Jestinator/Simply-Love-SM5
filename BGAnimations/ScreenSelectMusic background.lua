return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( Color.Black ) end
	},

	LoadActor( THEME:GetPathB("", "_shared background") ),

	Def.Quad{
		InitCommand=function(self)
			self:diffuse((ThemePrefs.Get("VisualStyle") == "SRPG6") and Color.Black or Color.Black)
				:Center()
				:FullScreen()
				:sleep(0.0):linear(0.5):diffusealpha(0)
				:queuecommand("Hide")
		end,
		HideCommand=function(self) self:visible(false) end
	}
}
