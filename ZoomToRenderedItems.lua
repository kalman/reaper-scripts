local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ZoomToSelectedItemOrAllOnTrack", function()
    local selectedTracks = btk.GetSelectedTracks()

    if #selectedTracks == 0 then
        return
    end

    local selectedTrack = selectedTracks[1]
    local _, renderedTrackGUIDSet = btk.GetRenderedTracks()

    local renderedTracks = {}
    local renderedItems = {}

    for _, descTrack in ipairs(btk.GetDescendantTracks(selectedTrack)) do
        local descTrackGUID = reaper.GetTrackGUID(descTrack)
        if renderedTrackGUIDSet[descTrackGUID] ~= nil then
            renderedTracks[#renderedTracks + 1] = descTrack
            -- Ideally it would be better to only add items within the region bounds
            renderedItems = btk.Concat(renderedItems, btk.GetItemsInTrack(descTrack))
        end
    end

    if #renderedItems == 0 then
        return
    end

    btk.ShowTracksInFolderHierarchy(renderedTracks)

    btk.SelectOnlyItems(renderedItems)
    rpr.sws_zoom_to_selected_items()

    btk.SelectOnlyTrack(selectedTrack)
    rpr.view_expand_selected_track_height()

    local curPosition = btk.FirstItemPosition(renderedItems)
    btk.SetLoopTimeRangeAndCursor(curPosition, curPosition)
end)
