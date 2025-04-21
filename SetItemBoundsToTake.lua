local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SetItemBoundsToTake", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        btk.SetItemInfo(item, {
            length = itemInfo.takeInfo.length
        })
        btk.SetItemTakeInfo(itemInfo.take, {
            startOffset = 0
        })
    end

    btk.Redraw()
end)
