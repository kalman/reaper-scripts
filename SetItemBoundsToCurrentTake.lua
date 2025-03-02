local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SetItemBoundsToCurrentTake", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        btk.SetItemInfo(item, {
            length = itemInfo.takeInfo.length * itemInfo.takeInfo.playrate,
        })
        btk.SetItemTakeInfo(itemInfo.take, {
            startOffset = 0,
        })
    end
end)
