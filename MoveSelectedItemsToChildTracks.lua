--[[
 * ReaScript Name: MoveSelectedItemsToChildTracks.lua
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
        items[i + 1] = reaper.GetSelectedMediaItem(0, i)
    end
    return items
end

local function get_track_index(track)
    local count = reaper.CountTracks(0)
    for i = 0, count - 1 do
        if reaper.GetTrack(0, i) == track then
            return i
        end
    end
    return count
end

local function get_track_name(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

local function set_track_name(track, name)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
end

local function first(array)
    for _, item in ipairs(array) do
        return item
    end
    return nil
end

local function last(array)
    local lastItem = nil
    for _, item in ipairs(array) do
        lastItem = item
    end
    return lastItem
end

local function run()
    reaper.Undo_BeginBlock()
    reaper.Main_OnCommand(41119, 0) -- Disable auto-crossfades

    local sourceItems = selected_media_items()

    if #sourceItems == 0 then
        return
    end

    local startCursorPosition = reaper.GetCursorPosition()
    local sourceTrack = get_item_track(first(sourceItems))
    local sourceTrackIndex = get_track_index(sourceTrack)
    local sourceTrackName = get_track_name(sourceTrack)
    local firstItemPosition = get_item_position(first(sourceItems))
    local newTracks = {}

    reaper.SetOnlyTrackSelected(sourceTrack)
    local nextTrackIndex = sourceTrackIndex + 1

    for _, item in ipairs(sourceItems) do
        reaper.Main_OnCommand(40289, 0) -- Unselected all items
        reaper.SetMediaItemSelected(item, 1)
        reaper.Main_OnCommand(41295, 0) -- Duplicate items (new item will be selected)
        local newItem = first(selected_media_items())

        reaper.InsertTrackInProject(0, nextTrackIndex, 0)
        local newTrack = reaper.GetTrack(0, nextTrackIndex)
        set_track_name(newTrack, sourceTrackName)
        newTracks[#newTracks + 1] = newTrack
        nextTrackIndex = nextTrackIndex + 1

        reaper.MoveMediaItemToTrack(newItem, newTrack)
        reaper.SetMediaItemPosition(newItem, firstItemPosition, false)
    end

    for _, item in ipairs(sourceItems) do
        reaper.SetMediaItemInfo_Value(item, "B_MUTE_ACTUAL", 1)
    end

    reaper.SetOnlyTrackSelected(first(newTracks))

    for _, newTrack in ipairs(newTracks) do
        reaper.SetTrackSelected(newTrack, 1)
    end

    reaper.ReorderSelectedTracks(get_track_index(last(newTracks)) + 1, 1)
    reaper.SetOnlyTrackSelected(sourceTrack)
    reaper.SetEditCurPos(startCursorPosition, 0, 0)

    reaper.Main_OnCommand(41118, 0) -- Enable auto-crossfades
    reaper.Undo_EndBlock("MoveSelectedItemsToChildTracks", -1)
end

run()
