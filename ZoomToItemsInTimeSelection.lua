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

btk.main("ZoomToItemsInTimeSelection", function()
    local savedSelectedItems = btk.GetSelectedItems()
    local loopStart, loopEnd = btk.GetLoopTimeRange()

    if loopStart == loopEnd then
        rpr.item_select_all()
    else
        rpr.item_select_all_in_time_selection()
    end

    rpr.sws_zoom_to_selected_items()
    btk.SelectOnlyItems(savedSelectedItems)
end)
