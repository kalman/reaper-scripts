local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function main()
    local selectedItems = btk.get_selected_items()

    if #selectedItems == 0 then
        return
    end

    reaper.Undo_BeginBlock()

    rpr.item_duplicate()
    rpr.item_mute()
    btk.select_items(selectedItems)
    rpr.item_glue()

    reaper.Undo_EndBlock("GlueItemsWithBackup", -1)
end

main()