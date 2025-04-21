local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SetItemBoundsToMinLength", function()
    local minLength = -1

    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        if minLength == -1 or itemInfo.length < minLength then
            minLength = itemInfo.length
        end
    end

    for _, item in ipairs(btk.GetSelectedItems()) do
        btk.SetItemInfo(item, {
            length = minLength
        })
    end
end)
