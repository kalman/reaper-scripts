local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function run()
    reaper.Undo_BeginBlock()

    local selectedItems = btk.get_selected_items()

    if #selectedItems == 0 then
        rpr.item_select_all_in_track()
        selectedItems = btk.get_selected_items()
    end

    if #selectedItems > 0 then
        btk.named_on_command("_SWS_HZOOMITEMS") -- SWS: Horizontal zoom to selected items
    end

    reaper.Undo_EndBlock("ZoomToSelectedItemOrAllOnTrack", -1)
end

run()
