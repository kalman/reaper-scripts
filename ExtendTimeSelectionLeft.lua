local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ExtendTimeSelectionRight", function()
    local loopStart, loopEnd = btk.GetLoopTimeRangeOrCursor()
    btk.SetLoopTimeRange(loopStart, math.max(loopStart, loopEnd - 1))
end)
