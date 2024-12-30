local af = Def.ActorFrame{}

local holdingCtrl = false
local holdingShift = false

local InputHandler = function( event )

	-- if (somehow) there's no event, bail
	if not event then return end

	if event.type == "InputEventType_FirstPress" then
		

--SM(event.DeviceInput.button)

			if event.DeviceInput.button == "DeviceButton_B22" then
				--SCREENMAN:SetNewScreen("ScreenGameplay");
				SCREENMAN:GetTopScreen():SetPrevScreenName("ScreenGameplay"):SetNextScreenName("ScreenGameplay"):begin_backing_out()
			end

		end
		


end

af[#af+1] = Def.Actor {
	OnCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		screen:AddInputCallback( InputHandler )
	end
}

return af


