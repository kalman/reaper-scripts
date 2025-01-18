local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SelectItemsInRange", function()
    local loopStart, loopEnd = btk.GetLoopTimeRangeOrCursor()
    local minLoopStart, maxLoopEnd = loopStart, loopEnd
    local itemsInRange = btk.GetAllItemsInRange(loopStart, loopEnd)

    for _, item in ipairs(itemsInRange) do
        local info = btk.GetItemInfo(item)
        minLoopStart = math.min(minLoopStart, info.position)
        maxLoopEnd = math.max(maxLoopEnd, info.position + info.length)
    end

    btk.SetLoopTimeRange(minLoopStart, maxLoopEnd)
    btk.SelectOnlyItems(itemsInRange)
end)
