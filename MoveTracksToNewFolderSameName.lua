local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveTracksToNewFolderSameName", function()
    local selectedTracks = btk.GetSelectedTracks()

    if #selectedTracks == 0 then
        return
    end

    rpr.track_move_tracks_to_new_folder()

    local newFolder = reaper.GetLastTouchedTrack()

    btk.SetTrackInfo(newFolder, {
        name = btk.GetTrackInfo(selectedTracks[1]).name
    })

    -- reaper.SetTrackColor(newFolder, reaper.GetTrackColor(selectedTracks[1]))

    btk.GenerateMarkerColors()
    rpr.track_rename_last_touched()
end)
