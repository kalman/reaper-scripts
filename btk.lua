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

local function select_items(items)
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

local function get_item_info(item)
    return {
        track = reaper.GetMediaItemInfo_Value(item, "P_TRACK"),
        position = reaper.GetMediaItemInfo_Value(item, "D_POSITION"),
        length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH"),
    }
end

local function get_items_info(items)
    local itemsInfo = {}
    for i, item in ipairs(items) do
        itemsInfo[i] = get_item_info(item)
    end
    return itemsInfo
end

local function get_track_name(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

local function set_track_name(track, name)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
end

return {
    named_on_command = named_on_command,
    get_all_items = get_all_items,
    get_selected_items = get_selected_items,
    select_items = select_items,
    get_selected_tracks = get_selected_tracks,
    main = main,
    get_item_info = get_item_info,
    get_items_info = get_items_info,
    get_all_tracks = get_all_tracks,
    get_track_name = get_track_name,
    set_track_name = set_track_name,
}
