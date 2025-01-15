local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SnapItemsToMarkers", function()
    local snapPoints = btk.GetMarkerSnapPoints()

    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        local _, closestSnapPoint = btk.FindClosestNumber(snapPoints, itemInfo.position + itemInfo.snapOffset)
        btk.SetItemInfo(item, {
            position = closestSnapPoint - itemInfo.snapOffset
        })
    end
end)
