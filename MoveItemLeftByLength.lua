local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveItemLeftByLength", function()
    local selectedItems = btk.get_selected_items()

    if #selectedItems == 0 then
        return
    end

    local maxLength = btk.get_max_item_length(selectedItems)

    for i_, item in ipairs(selectedItems) do
        local itemInfo = btk.get_item_info(item)
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", math.max(0, itemInfo.position - maxLength))
    end
end)
