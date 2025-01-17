local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SoloFirstChild", function()
    for _, track in ipairs(btk.GetSelectedTracks()) do
        local childTracks = btk.GetChildTracks(track)
        local unSolo = #childTracks > 1 and btk.GetTrackInfo(childTracks[2]).mute

        for i, childTrack in ipairs(btk.GetChildTracks(track)) do
            btk.SetTrackInfo(childTrack, {
                mute = i > 1 and not unSolo
            })
        end
    end
end)
