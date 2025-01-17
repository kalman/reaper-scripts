local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SoloPreviousChild", function()
    for _, track in ipairs(btk.GetSelectedTracks()) do
        local childTracks = btk.GetChildTracks(track)
        local soloChildIndex = #childTracks

        for i = 2, #childTracks do
            if not btk.GetTrackInfo(childTracks[i]).mute then
                soloChildIndex = i - 1
                break
            end
        end

        for i, childTrack in ipairs(childTracks) do
            btk.SetTrackInfo(childTrack, {
                mute = i ~= soloChildIndex
            })
        end
    end
end)
