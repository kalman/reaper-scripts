local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function selectAllItemsInTrack(track)
    for _, item in ipairs(btk.GetItemsInTrack(track)) do
        reaper.SetMediaItemSelected(item, true)
    end
end

btk.main("ZoomToSelectedItemOrAllOnTrack", function()
    local selectedItems = btk.GetSelectedItems()
    local unselectItems = false

    if #selectedItems == 0 then
        for _, track in ipairs(btk.GetSelectedTracks()) do
            selectAllItemsInTrack(track)
            for _, descTrack in ipairs(btk.GetDescendantTracks(track)) do
                selectAllItemsInTrack(descTrack)
            end
        end

        selectedItems = btk.GetSelectedItems()
        unselectItems = true
    end

    if #selectedItems > 0 then
        rpr.sws_zoom_to_selected_items()
    end

    if unselectItems then
        rpr.item_unselect_all()
    end
end)
