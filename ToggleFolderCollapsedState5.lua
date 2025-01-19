local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ToggleFolderCollapsedState5", function()
    btk.ToggleFolderCollapsedStateAtDepth(5)
end)
