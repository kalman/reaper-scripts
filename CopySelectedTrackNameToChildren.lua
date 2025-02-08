local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("CopySelectedTrackNameToChildren", function()
    for selectedTrack in btk.IterSelectedTracks() do
        local ok, name = reaper.GetTrackName(selectedTrack)
        for i, childTrack in ipairs(btk.GetChildTracks(selectedTrack)) do
            btk.SetTrackInfo(childTrack, {
                name = name .. "(" .. i .. ")"
            })
        end
    end
end)
