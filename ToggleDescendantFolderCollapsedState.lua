local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("ToggleDescendantFolderCollapsedState", function()
    local folders = {}

    for _, folder in ipairs(btk.GetSelectedFolders()) do
        folders[#folders + 1] = folder

        for _, descendant in ipairs(btk.GetDescendantTracks(folder)) do
            if btk.GetTrackInfo(descendant).folderDepth == 1 then
                folders[#folders + 1] = descendant
            end
        end
    end

    local toggleFolderCompact = 2

    if btk.AnyCollapsed(folders) then
        toggleFolderCompact = 0
    end

    for _, folder in ipairs(folders) do
        btk.SetTrackInfo(folder, {
            folderCompact = toggleFolderCompact
        })
    end
end)
