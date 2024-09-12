--[[
 * ReaScript Name: MoveSelectedRegionsToDuplicateTracks.lua
 * Author: Ben Kalman
--]]

local function get_item_track(item)
    return reaper.GetMediaItemInfo_Value(item, "P_TRACK")
end

local function get_item_position(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end

local function selected_media_items()
    local count = reaper.CountSelectedMediaItems(0)
    local items = {}
    for i = 0, count - 1 do
        items[i + 1] = reaper.GetSelectedMediaItem(0, count - i - 1)
    end
    return items
end

local function run()
    reaper.Undo_BeginBlock()

    local selectedItems = selected_media_items()

    if #selectedItems == 0 then
        return
    end

    local firstSelectedItem = reaper.GetSelectedMediaItem(0, 0)
    local track = get_item_track(firstSelectedItem)

    reaper.SetOnlyTrackSelected(track)

    for _, item in ipairs(selectedItems) do
        local itemPosition = get_item_position(item)

        if get_item_track(item) == track then
            reaper.Main_OnCommand(40062, 0)
            local newTrack = reaper.GetSelectedTrack(0, 0)

            for _, newItem in ipairs(selected_media_items()) do
                if get_item_track(newItem) == newTrack then
                    if get_item_position(newItem) == itemPosition then
                        reaper.SetMediaItemPosition(newItem, get_item_position(firstSelectedItem), false)
                    else
                        reaper.DeleteTrackMediaItem(newTrack, newItem)
                    end
                end
            end
        end

        reaper.SetOnlyTrackSelected(track)
    end

    reaper.SetTrackUIMute(track, 1, 0)
    reaper.Undo_EndBlock("MoveSelectedRegionsToDuplicateTracks", -1)
end

run()
