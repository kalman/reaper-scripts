local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'
local impl = require 'BakeVariationsImpl'

btk.main("BakeVariationsMono", function()
    impl.Run(false)
end)
