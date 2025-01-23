local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("GlueItemsPreserveFade", function()
    local selectedItems = btk.GetSelectedItems()
    local selectedItemsByTrack = btk.SplitItemsByTrack(selectedItems)
    local gluedItems = {}

    for _, items in ipairs(selectedItemsByTrack) do
        gluedItems[#gluedItems + 1] = btk.GlueItemsPreserveFade(items)
    end

    btk.SelectOnlyItems(gluedItems)
end)
