local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'

btk.main("SetSnapOffsetToEnd", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", itemLength)
    end
end)
