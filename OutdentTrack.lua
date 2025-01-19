local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function OutdentTrack(track)
    local info = btk.GetTrackInfo(track)

    if info.index == 0 then
        return
    end
    
    local depth = reaper.GetTrackDepth(track)

    if depth == 0 then
        return
    end

    local siblingIndex = info.index - 1

    while reaper.GetTrackDepth(reaper.GetTrack(0, siblingIndex)) ~= depth - 1 do
        if siblingIndex == 0 then
            return
        end
        siblingIndex = siblingIndex - 1
    end

    local sibling = reaper.GetTrack(0, siblingIndex)

    btk.SelectOnlyTrack(track)
    reaper.ReorderSelectedTracks(siblingIndex, 0)
    btk.SelectOnlyTrack(sibling)
    reaper.ReorderSelectedTracks(siblingIndex, 0)

    btk.ShowTrackInFolderHierarchy(track)
end

btk.main("OutdentTrack", function()
    local selectedTracks = btk.GetSelectedTracks()
    
    for _, track in ipairs(selectedTracks) do
        OutdentTrack(track)
    end
    
    btk.SelectOnlyTracks(selectedTracks)
    btk.GenerateMarkerColors()
end)
