local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function SelectAllItemsInTrack(track)
    for _, item in ipairs(btk.GetItemsInTrack(track)) do
        reaper.SetMediaItemSelected(item, true)
    end

    btk.ShowTrackInFolderHierarchy(track)
end

btk.main("ZoomToSelectedItemOrAllOnTrack", function()
    local selectedItems = btk.GetSelectedItems()

    if #selectedItems == 0 then
        for _, track in ipairs(btk.GetSelectedTracks()) do
            SelectAllItemsInTrack(track)

            for _, descTrack in ipairs(btk.GetDescendantTracks(track)) do
                SelectAllItemsInTrack(descTrack)
            end
        end
    else
        for _, selectedItem in ipairs(selectedItems) do
            local itemInfo = btk.GetItemInfo(selectedItem)
            btk.ShowTrackInFolderHierarchy(itemInfo.track)
        end
    end

    rpr.sws_zoom_to_selected_items()
    btk.SelectOnlyItems(selectedItems)
end)
