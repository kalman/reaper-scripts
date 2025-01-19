local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ReorderSelectedTracksToPrevious", function()
    local selectedTracks = btk.GetSelectedTracks();

    if #selectedTracks == 0 then
        return
    end

    for _, track in ipairs(selectedTracks) do
        reaper.SetOnlyTrackSelected(track)
        local trackIndex = btk.GetTrackInfo(track).index
        if trackIndex > 0 then
            reaper.ReorderSelectedTracks(trackIndex - 1, 0)
        end
        btk.ShowTrackInFolderHierarchy(track)
    end

    btk.SelectOnlyTracks(selectedTracks)
    btk.GenerateMarkerColors()
end)
