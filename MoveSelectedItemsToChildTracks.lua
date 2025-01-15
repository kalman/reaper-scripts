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

local function GetTrackName(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

local function SetTrackName(track, name)
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

    local sourceItems = selected_media_items()

    if #sourceItems == 0 then
        return
    end

    local startCursorPosition = reaper.GetCursorPosition()
    local sourceTrack = get_item_track(first(sourceItems))
    local sourceTrackIndex = get_track_index(sourceTrack)
    local sourceTrackName = GetTrackName(sourceTrack)
    local firstItemPosition = get_item_position(first(sourceItems))
    local newTracks = {}

    reaper.SetOnlyTrackSelected(sourceTrack) 
    local nextTrackIndex = sourceTrackIndex + 1

    for _, item in ipairs(sourceItems) do
        reaper.Main_OnCommand(40289, 0) -- Item: Unselect (clear selection of) all items
        reaper.SetMediaItemSelected(item, 1)

        reaper.InsertTrackInProject(0, nextTrackIndex, 0)
        local newTrack = reaper.GetTrack(0, nextTrackIndex)
        SetTrackName(newTrack, sourceTrackName)
        newTracks[#newTracks + 1] = newTrack
        nextTrackIndex = nextTrackIndex + 1
        reaper.MoveMediaItemToTrack(item, newTrack)
        reaper.SetMediaItemPosition(item, firstItemPosition, false)
    end

    reaper.ReorderSelectedTracks(get_track_index(last(newTracks)) + 1, 1)
    reaper.SetOnlyTrackSelected(sourceTrack)
    reaper.SetEditCurPos(startCursorPosition, 0, 0)

    reaper.Undo_EndBlock("MoveSelectedItemsToChildTracks", -1)
end

run()
