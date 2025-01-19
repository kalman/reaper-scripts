local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ToggleFolderCollapsedState1", function()
    btk.ToggleFolderCollapsedStateAtDepth(1)
end)
