local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("InsertNewTrackInFolder", function()
    local mediaTracksCount = reaper.CountTracks()

    if mediaTracksCount <= 1 then
        rpr.track_insert_new()
        return
    end

    local selectedTracks = btk.GetSelectedTracks()

    if #selectedTracks == 0 then
        rpr.track_insert_new()
        return
    end

    local sel = selectedTracks[#selectedTracks]
    local selTrackIndex = reaper.GetMediaTrackInfo_Value(sel, "IP_TRACKNUMBER") - 1

    local selIsLastTrackInFolder = (
        selTrackIndex == reaper.CountTracks() - 1 or
        reaper.GetTrackDepth(sel) > reaper.GetTrackDepth(reaper.GetTrack(0, selTrackIndex + 1))
    )

    if selIsLastTrackInFolder then
        reaper.InsertTrackInProject(0, selTrackIndex, 0)
        reaper.ReorderSelectedTracks(selTrackIndex, 0)
        reaper.SetOnlyTrackSelected(reaper.GetTrack(0, selTrackIndex + 1))
    else
        rpr.track_insert_new()
    end
end)