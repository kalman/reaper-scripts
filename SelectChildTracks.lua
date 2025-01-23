local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("SelectChildTracks", function()
    local selectedTracks = btk.GetSelectedTracks()
    local descendantTracks = {}

    for _, t in ipairs(selectedTracks) do
        descendantTracks = btk.Concat(descendantTracks, btk.GetDescendantTracks(t))
    end

    local selectTracks = btk.Concat(selectedTracks, descendantTracks)
    btk.SelectOnlyTracks(selectTracks)

    for _, t in ipairs(selectTracks) do
        btk.ShowTrackInFolderHierarchy(t)
    end
end)
