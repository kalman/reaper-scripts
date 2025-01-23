local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function UnbakeTrackVariations(track)
    local trackInfo = btk.GetTrackInfo(track)
    local originalPrefix = "ORIGINAL - "
    local originalTrack = nil

    for _, childTrack in ipairs(btk.GetChildTracks(track)) do
        if string.sub(btk.GetTrackInfo(childTrack).name, 1, #originalPrefix) == originalPrefix then
            originalTrack = childTrack
            break
        end
    end

    if originalTrack == nil then
        reaper.ShowConsoleMsg("error: cannot unbake, original track not found")
        return nil
    end

    btk.SelectOnlyTrack(originalTrack)
    reaper.ReorderSelectedTracks(trackInfo.index, 0)

    local trackChildren = btk.GetChildTracks(track)
    local originalTrackChildren = btk.GetChildTracks(originalTrack)

    for i, trackChild in ipairs(trackChildren) do
        if i <= #originalTrackChildren then
            local originalTrackChild = originalTrackChildren[i]
            btk.CopyTrackRegionRenderMatrix(trackChild, originalTrackChild)
            btk.SetTrackInfo(originalTrackChild, {
                mute = btk.GetTrackInfo(trackChild).mute
            })
        end
    end

    btk.SetTrackInfo(originalTrack, {
        name = trackInfo.name,
        mute = trackInfo.mute,
        folderCompact = trackInfo.folderCompact
    })

    btk.DeleteTrackRecursive(track)

    return originalTrack
end

btk.main("UnbakeVariations", function()
    local originalTracks = {}

    for _, track in ipairs(btk.GetSelectedTracks()) do
        local originalTrack = UnbakeTrackVariations(track)
        if originalTrack ~= nil then
            originalTracks[#originalTracks + 1] = originalTrack
        end
    end

    btk.SelectOnlyTracks(originalTracks)
    btk.GenerateMarkerColors()
end)
