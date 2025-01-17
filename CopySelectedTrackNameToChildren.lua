local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("CopySelectedTrackNameToChildren", function()
    for i = 0, reaper.CountSelectedTracks(0) - 1 do
        local selectedTrack = reaper.GetSelectedTrack(0, i)

        for j = 0, reaper.CountTracks(0) - 1 do
            local track = reaper.GetTrack(0, j)

            if reaper.GetParentTrack(track) == selectedTrack then
                local ok, name = reaper.GetTrackName(selectedTrack)
                reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
            end
        end
    end
end)
