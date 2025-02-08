local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("CopyItemNameToTrack", function()
    for _, item in ipairs(btk.GetSelectedItems()) do
        local info = btk.GetItemInfo(item)
        btk.SetTrackInfo(info.track, {
            name = info.takeInfo.name
        })
    end
end)
