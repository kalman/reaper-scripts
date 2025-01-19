local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function IndentTrack(track)
    local info = btk.GetTrackInfo(track)

    if info.index == 0 then
        return
    end

    local prevTrack = reaper.GetTrack(0, info.index - 1)
    local depth = reaper.GetTrackDepth(track)
    local prevDepth = reaper.GetTrackDepth(prevTrack)

    if depth > prevDepth then
        -- Track is already a child of previous track.
        return
    end

    if depth == prevDepth then
        -- Same level, create new folder.
        reaper.ReorderSelectedTracks(info.index, 1)
    else
        -- Step back through tracks to find the one at the next depth. This will be the sibling.
        local siblingIndex = info.index - 1

        while reaper.GetTrackDepth(reaper.GetTrack(0, siblingIndex)) ~= depth + 1 do
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
    end

    btk.ShowTrackInFolderHierarchy(track)
end

btk.main("IndentTrack", function()
    local selectedTracks = btk.GetSelectedTracks()

    for _, track in ipairs(selectedTracks) do
        IndentTrack(track)
    end

    btk.SelectOnlyTracks(selectedTracks)
    btk.GenerateMarkerColors()
end)
