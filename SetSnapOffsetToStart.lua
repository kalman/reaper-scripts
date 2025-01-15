local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'

btk.main("SetSnapOffsetToStart", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", 0)
    end
end)