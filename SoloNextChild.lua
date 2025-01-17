local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SoloNextChild", function()
    for _, track in ipairs(btk.GetSelectedTracks()) do
        local childTracks = btk.GetChildTracks(track)
        local soloChildIndex = 1

        for i = 1, #childTracks - 1 do
            if not btk.GetTrackInfo(childTracks[i]).mute then
                soloChildIndex = i + 1
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
