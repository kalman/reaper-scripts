local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function TrimItem(item)
    local info = btk.GetItemInfo(item)
    local position = info.position

    btk.SelectOnlyItem(item)
    btk.SetLoopTimeRangeAndCursor(position, position)
end

btk.main("SelectFirstOfSelectedItems", function()
    local selectedItems = btk.GetSelectedItems()

    for _, item in ipairs(selectedItems) do
        TrimItem(item)
    end

    btk.SelectOnlyItem(selectedItems)
end)
