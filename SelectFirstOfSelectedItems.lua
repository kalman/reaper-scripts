local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SelectFirstOfSelectedItems", function()
    local selectedItems = btk.GetSelectedItems()
    if #selectedItems > 1 then
        btk.SelectOnlyItem(selectedItems[1])
    end
end)
