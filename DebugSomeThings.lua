local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'

btk.main("DebugSomeThings", function()
    local selectedItems = btk.GetSelectedItems()
    local selectedTracks = btk.GetSelectedTracks()

    if #selectedItems == 0 then
        reaper.ShowConsoleMsg("Items: none selected\n")
    else
        reaper.ShowConsoleMsg("Items: " .. #selectedItems .. " selected:\n")
        for i, item in ipairs(selectedItems) do
            local info = btk.GetItemInfo(item)
            local trackInfo = btk.GetTrackInfo(info.track)
            reaper.ShowConsoleMsg(" item#" .. i .. ": " .. info.takeInfo.name .. " (track: " .. trackInfo.name .. ")\n")
        end
    end

    reaper.ShowConsoleMsg("\n")

    if #selectedTracks == 0 then
        reaper.ShowConsoleMsg("Tracks: none selected\n")
    else
        reaper.ShowConsoleMsg("Tracks: " .. #selectedTracks .. " selected:\n")
        for i, track in ipairs(selectedTracks) do
            local info = btk.GetTrackInfo(track)
            reaper.ShowConsoleMsg(" track#" .. i .. ": " .. info.name .. "\n")
        end

        reaper.ShowConsoleMsg("\n")

        local firstSelectedTrack = selectedTracks[1]
        local folderHierarchy = btk.GetTrackFolderHierarchy(firstSelectedTrack)
        if #folderHierarchy == 0 then
            reaper.ShowConsoleMsg("Track#1 hierarchy: is top level\n")
        else
            reaper.ShowConsoleMsg("Track#1 hierarchy: " .. #folderHierarchy .. " ancestors:\n")
            for i, track in ipairs(folderHierarchy) do
                local info = btk.GetTrackInfo(track)
                reaper.ShowConsoleMsg(" track#1#" .. i .. ": " .. info.name .. "\n")
            end
        end
    end
end)
