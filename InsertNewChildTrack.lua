local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("InsertNewChildTrack", function()
    local selectedTracks = btk.get_selected_tracks()

    if #selectedTracks == 0 then
        rpr.track_insert_new()
        return
    end

    local sel = selectedTracks[#selectedTracks]
    local selTrackIndex = reaper.GetMediaTrackInfo_Value(sel, "IP_TRACKNUMBER") - 1

    reaper.SetOnlyTrackSelected(sel)
    rpr.track_insert_new()
    reaper.ReorderSelectedTracks(selTrackIndex + 1, 1)
end)
