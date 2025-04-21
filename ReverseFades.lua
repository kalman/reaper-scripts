local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ReverseFades", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemInfo = btk.GetItemInfo(item)
        btk.SetItemInfo(item, {
            fadeInLength = itemInfo.fadeOutLength,
            fadeInShape = itemInfo.fadeOutShape,
            fadeInCurvature = -itemInfo.fadeOutCurvature,
            fadeOutLength = itemInfo.fadeInLength,
            fadeOutShape = itemInfo.fadeInShape,
            fadeOutCurvature = -itemInfo.fadeInCurvature
        })
    end
end)
