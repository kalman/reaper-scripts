local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("InsertRegionForSelectedItemsAndAddToMatrix", function()
    local selectedItems = btk.GetSelectedItems()

    if #selectedItems == 0 then
        return
    end

    local itemsInfo = btk.GetItemsInfo(selectedItems)
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

    local defaultName = btk.GetTrackInfo(itemsInfo[1].track).name
    local _, regionName = reaper.GetUserInputs("Region name [" .. defaultName .. "]", 1, "", "")

    if regionName == "" then
        regionName = defaultName
    end

    local regionIndex = reaper.AddProjectMarker(0, true, startPosition, endPosition, regionName, -1)

    for _, info in ipairs(itemsInfo) do
        reaper.SetRegionRenderMatrix(0, regionIndex, info.track, 1)
    end

    btk.GenerateMarkerColors()
end)
