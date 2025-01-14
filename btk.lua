local function named_on_command(command_name)
    local command_id = reaper.NamedCommandLookup(command_name)
    reaper.Main_OnCommand(command_id, 0)
end

local function get_all_items()
    local count = reaper.CountMediaItems(0)
    local items = {}
    for i = 0, count - 1 do
        items[i + 1] = reaper.GetMediaItem(0, i)
    end
    return items
end

local function get_selected_items()
    local selectedItems = {}

    for _, item in ipairs(get_all_items()) do
        if reaper.IsMediaItemSelected(item) then
            selectedItems[#selectedItems + 1] = item
        end
    end

    return selectedItems
end

local function select_only_items(items)
    for _, item in ipairs(get_all_items()) do
        reaper.SetMediaItemSelected(item, false)
    end
    for _, item in ipairs(items) do
        reaper.SetMediaItemSelected(item, true)
    end
end

local function get_all_tracks()
    local count = reaper.CountTracks(0)
    local tracks = {}
    for i = 0, count - 1 do
        tracks[i + 1] = reaper.GetTrack(0, i)
    end
    return tracks
end

local function select_only_tracks(tracks)
    for _, track in ipairs(get_all_tracks()) do
        reaper.SetTrackSelected(track, false)
    end
    for _, item in ipairs(tracks) do
        reaper.SetTrackSelected(item, true)
    end
end

local function get_selected_tracks()
    local count = reaper.CountSelectedTracks(0)
    local tracks = {}
    for i = 0, count - 1 do
        tracks[i + 1] = reaper.GetSelectedTrack(0, i)
    end
    return tracks
end

local function main(name, func)
    reaper.Undo_BeginBlock()
    func()
    reaper.Undo_EndBlock(name, -1)
end

local function get_item_take_info(itemTake)
    return {
        -- 0=normal, 1=reverse stereo, 2=downmix, 3=left, 4=right
        channelMode = reaper.GetMediaItemTakeInfo_Value(itemTake, "I_CHANMODE")
    }
end

local function get_item_info(item)
    local currentTake = reaper.GetMediaItemInfo_Value(item, "I_CURTAKE")
    return {
        track = reaper.GetMediaItemInfo_Value(item, "P_TRACK"),
        position = reaper.GetMediaItemInfo_Value(item, "D_POSITION"),
        length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH"),
        currentTake = get_item_take_info(reaper.GetMediaItemTake(item, currentTake))
    }
end

local function get_items_info(items)
    local itemsInfo = {}
    for i, item in ipairs(items) do
        itemsInfo[i] = get_item_info(item)
    end
    return itemsInfo
end

local function get_track_info(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return {
        mute = reaper.GetMediaTrackInfo_Value(track, "B_MUTE"),
        name = name,
        trackNumber1Based = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    }
end

local function get_track_name(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

local function set_track_name(track, name)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
end

local function move_item_to_track(item, track)
    local itemTrack = get_item_info(item).track

    if reaper.GetTrackGUID(itemTrack) ~= reaper.GetTrackGUID(track) then
        local _, itemChunk = reaper.GetItemStateChunk(item, '')
        reaper.DeleteTrackMediaItem(itemTrack, item)
        local newItem = reaper.AddMediaItemToTrack(track)
        reaper.SetItemStateChunk(newItem, itemChunk)
    end
end

local function get_loop_time_range()
    return reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
end

local function set_loop_time_range(loopStart, loopEnd)
    reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, true)
end

local function extend_time_selection(seconds)
    local loopStart, loopEnd = get_loop_time_range()
    set_loop_time_range(loopStart, loopEnd + seconds)
end

local function get_descendant_tracks(track)
    local trackInfo = get_track_info(track)
    local trackDepth = reaper.GetTrackDepth(track)
    local descendantTracks = {}

    for i = trackInfo.trackNumber1Based, reaper.CountTracks(0) do
        local nextTrack = reaper.GetTrack(0, i)
        if reaper.GetTrackDepth(nextTrack) <= trackDepth then
            break
        end
        descendantTracks[#descendantTracks + 1] = nextTrack
    end

    return descendantTracks
end

local function get_items_in_track(track)
    local count = reaper.CountMediaItems(0)
    local items = {}
    for i = 0, count - 1 do
        local item = reaper.GetMediaItem(0, i)
        local itemInfo = get_item_info(item)
        if reaper.GetTrackGUID(itemInfo.track) == reaper.GetTrackGUID(track) then
            items[#items + 1] = item
        end
    end
    return items
end

return {
    named_on_command = named_on_command,
    get_all_items = get_all_items,
    get_selected_items = get_selected_items,
    select_only_items = select_only_items,
    get_selected_tracks = get_selected_tracks,
    select_only_tracks = select_only_tracks,
    main = main,
    get_item_take_info = get_item_take_info,
    get_item_info = get_item_info,
    get_track_info = get_track_info,
    get_items_info = get_items_info,
    get_items_in_track = get_items_in_track,
    get_all_tracks = get_all_tracks,
    get_track_name = get_track_name,
    set_track_name = set_track_name,
    move_item_to_track = move_item_to_track,
    get_loop_time_range = get_loop_time_range,
    set_loop_time_range = set_loop_time_range,
    extend_time_selection = extend_time_selection,
    get_descendant_tracks = get_descendant_tracks
}
