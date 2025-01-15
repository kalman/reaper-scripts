local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveItemToPreviousMarker", function()
    local snapPoints = btk.GetMarkerSnapPoints()

    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        local snappedPosition = itemInfo.position + itemInfo.snapOffset
        local closestIndex, closestSnapPoint = btk.FindClosestNumber(snapPoints, snappedPosition)
        local setPosition = 0

        if closestIndex == 1 then
            setPosition = snapPoints[closestIndex]
        elseif btk.Approximately(snapPoints[closestIndex], snappedPosition) then
            setPosition = snapPoints[closestIndex - 1]
        elseif snappedPosition > closestSnapPoint then
            setPosition = closestSnapPoint
        else
            setPosition = snapPoints[closestIndex - 1]
        end

        btk.SetItemInfo(item, {
            position = setPosition - itemInfo.snapOffset
        })
    end
end)
