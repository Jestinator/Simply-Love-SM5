local player = ...
local pn = ToEnumShortString(player)

if SL.Global.GameMode == "Casual" then return end

-- We only want to count it if the user didn't fail
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player) 
if stats:GetFailed() then return end

local itg = SL[ToEnumShortString(player)].CurrentSongJudgments.ITG
local ex = SL[ToEnumShortString(player)].CurrentSongJudgments.EX

-- Takes the Ghost Data loaded in memory and writes it to the local profile.
WriteGhostData = function(player, songHash)
	local pn = ToEnumShortString(player)

        local itg = SL[ToEnumShortString(player)].CurrentSongJudgments.ITG
        local ex = SL[ToEnumShortString(player)].CurrentSongJudgments.EX

	-- set initial array of dance points to write
	local array = {}
	array["itg"] = itg
	array["ex"] = ex
-- Add this line to fetch our live offset table:
--        array["offsets"] = SL[pn].CurrentSongJudgments.Offsets

	currITG = itg[#itg] or 0
	currEX = ex[#ex] or 0

	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	-- We require an explicit profile to be loaded.
	if not dir or #dir == 0 then return end

	-- Individual file per song so we don't load entire play history in memory
	local path = dir .. "GhostData/" .. songHash .. ".json"

	-- set flag to update
	local updateitg = true
	local updateex = true

	-- Read current record
	local f = RageFileUtil:CreateRageFile()
	if FILEMAN:DoesFileExist(path) then
		if f:Open(path, 1) then		
			local old = f:Read()
			old = JsonDecode(old)
			oldITG = old["itg"][#old["itg"]]
			oldEX = old["ex"][#old["ex"]]			
			if oldITG >= currITG then 
				array["itg"] = old["itg"] 
				updateitg = false
			end
			if oldEX >= currEX then 
				array["ex"] = old["ex"]
				updateex = false 
			end
			f:Close()
		end
		f:destroy()
	end
	
	local f = RageFileUtil:CreateRageFile()
	if updateitg or updateex then
		if f:Open(path, 2) then		
			f:Write(JsonEncode(array))
			f:Close()		
		end
		f:destroy()
	end
end

return Def.Actor{
        OnCommand=function(self)
                -- get song hash
                local hash = SL[pn].Streams.Hash
                WriteGhostData(player,hash)

                -- ====================================================
                -- STANDALONE MULTIDIMENSIONAL CSV FILE EXPORTER
                -- ====================================================
                local raw_offsets = SL[pn].CurrentSongJudgments.Offsets
                if raw_offsets and #raw_offsets > 0 then
                        local song = GAMESTATE:GetCurrentSong()
                        local song_title = song and song:GetDisplayMainTitle() or "Unknown_Song"
                        
                        -- Extract chart difficulty metrics natively
                        local steps = GAMESTATE:GetCurrentSteps(player)
                        local difficulty = steps and ToEnumShortString(steps:GetDifficulty()) or "Unknown_Diff"
                        local meter = steps and steps:GetMeter() or 0
                        
                        local logFile = RageFileUtil:CreateRageFile()
                        -- Mode 8 tells StepMania to open in Append mode (adds to the bottom of the file)
                        if logFile:Open("./ITG_Raw_Timeline_Log.csv", 8) then
                                -- Write Metadata Block Header
                                logFile:Write(string.format("# SONG: %s\n", song_title))
                                logFile:Write(string.format("# CHART: %s (Block Level %d)\n", difficulty, meter))
                                logFile:Write(string.format("# TIMESTAMP: %s\n", os.date("%Y-%m-%d %H:%M:%S")))
                                
                                -- Write CSV Columns Layout
                                logFile:Write("Lane_Column,Offset_Seconds,Song_Time_Sec,Live_BPM\n")
                                
                                -- Stream every recorded step line out
                                for i = 1, #raw_offsets do
                                        logFile:Write(raw_offsets[i] .. "\n")
                                end
                                
                                logFile:Write("# END OF CHART RECORD\n\n")
                                logFile:Close()
                        end
                        logFile:destroy()
                end
                -- ====================================================

        end
}
