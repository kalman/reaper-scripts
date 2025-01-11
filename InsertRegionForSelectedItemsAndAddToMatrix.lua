local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("InsertRegionForSelectedItemsAndAddToMatrix", function()
    local selectedItems = btk.get_selected_items()

    if #selectedItems == 0 then
        return
    end

    local itemsInfo = btk.get_items_info(selectedItems)
    local startPosition = -1
    local endPosition = -1

    for _, info in ipairs(itemsInfo) do
        if startPosition == -1 or info.position < startPosition then
            startPosition = info.position
        end
        if endPosition == -1 or info.position + info.length > endPosition then
            endPosition = info.position + info.length
        end
    end

    local _, regionName = reaper.GetUserInputs("Region name (or empty)?", 1, "", "")

    if regionName == "" then
        regionName = btk.get_track_name(itemsInfo[1].track)
    end

    local regionIndex = reaper.AddProjectMarker(0, true, startPosition, endPosition, regionName, -1)

    for _, info in ipairs(itemsInfo) do
        reaper.SetRegionRenderMatrix(0, regionIndex, info.track, 1)
    end
end)
