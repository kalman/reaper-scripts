local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveItemRightByLength", function()
    local selectedItems = btk.GetSelectedItems()

    if #selectedItems == 0 then
        return
    end

    local maxLength = btk.GetMaxItemLength(selectedItems)

    for i_, item in ipairs(selectedItems) do
        local itemInfo = btk.GetItemInfo(item)
        btk.SetItemInfo(item, {position = itemInfo.position + maxLength})
    end
end)
