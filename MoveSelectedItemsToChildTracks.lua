local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

btk.main("MoveSelectedItemsToChildTracks", function()
    local sourceItems = btk.GetSelectedItems()

    if #sourceItems == 0 then
        return
    end

    local savedCursorPosition = reaper.GetCursorPosition()
    local savedSelectedTracks = btk.GetSelectedTracks()

    local firstItem = sourceItems[1]
    local firstItemInfo = btk.GetItemInfo(firstItem)
    local sourceTrack = firstItemInfo.track
    local sourceTrackInfo = btk.GetTrackInfo(sourceTrack)
    local newTracks = {}

    reaper.SetOnlyTrackSelected(sourceTrack)
    local nextTrackIndex = sourceTrackInfo.trackNumber1Based

    for i, item in ipairs(sourceItems) do
        btk.SelectOnlyItem(item)

        reaper.InsertTrackInProject(0, nextTrackIndex, 0)
        local newTrack = reaper.GetTrack(0, nextTrackIndex)

        btk.SetTrackInfo(newTrack, {
            name = sourceTrackInfo.name .. "(" .. i .. ")"
        })

        newTracks[#newTracks + 1] = newTrack
        nextTrackIndex = nextTrackIndex + 1

        reaper.MoveMediaItemToTrack(item, newTrack)
        reaper.SetMediaItemPosition(item, firstItemInfo.position, false)
    end

    btk.SelectOnlyTracks(newTracks)
    reaper.ReorderSelectedTracks(sourceTrackInfo.trackNumber1Based, 1)
    btk.SelectOnlyTracks(savedSelectedTracks)
    reaper.SetEditCurPos(savedCursorPosition, 0, 0)
end)
