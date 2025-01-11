local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveTracksToNewFolderSameName", function()
    local selectedTracks = btk.get_selected_tracks()

    if #selectedTracks == 0 then
        return
    end

    rpr.track_move_tracks_to_new_folder()

    local newFolder = reaper.GetLastTouchedTrack()
    btk.set_track_name(newFolder, btk.get_track_name(selectedTracks[1]))
    reaper.SetTrackColor(newFolder, reaper.GetTrackColor(selectedTracks[1]))

    rpr.track_rename_last_touched()
end)
