local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("InsertRegionPerSelectedItemAndAddToMatrix", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        btk.InsertRegionForItemsAndAddToMatrix({item})
    end
    btk.GenerateMarkerColors()
end)
