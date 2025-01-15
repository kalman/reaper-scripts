--[[
 * ReaScript Name: ReorderSelectedTracksToPrevious.lua
 * Author: Ben Kalman
--]]
local function named_on_command(command_name)
    local command_id = reaper.NamedCommandLookup(command_name)
    reaper.Main_OnCommand(command_id, 0)
end

local function GetSelectedTracks()
    local count = reaper.CountSelectedTracks(0)
    local tracks = {}
    for i = 0, count - 1 do
        tracks[i + 1] = reaper.GetSelectedTrack(0, i)
    end
    return tracks
end

local function get_track_index(track)
    local count = reaper.CountTracks(0)
    for i = 0, count - 1 do
        if reaper.GetTrack(0, i) == track then
            return i
        end
    end
    return count
end

local function run()
    reaper.Undo_BeginBlock()
    named_on_command("_SWS_SAVESEL") -- SWS: Save current track selection

    local selectedTracks = GetSelectedTracks();

    if #selectedTracks == 0 then
        return
    end

    for i = 1, #selectedTracks do
        local selectedTrack = selectedTracks[i]
        reaper.SetOnlyTrackSelected(selectedTrack)
        local track_index = get_track_index(selectedTrack)
        if track_index > 0 then
            reaper.ReorderSelectedTracks(track_index - 1, 0)
        end
    end

    named_on_command("_SWS_RESTORESEL") -- SWS: Restore saved track selection
    reaper.Undo_EndBlock("ReorderSelectedTracksToPrevious", -1)
end

run()
