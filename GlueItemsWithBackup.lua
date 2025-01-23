local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("GlueItemsWithBackup", function()
    local selectedItems = btk.GetSelectedItems()

    if #selectedItems == 0 then
        return
    end

    rpr.item_duplicate()
    rpr.item_mute()
    btk.SelectOnlyItems(selectedItems)
    rpr.item_glue()
end)