local function named_on_command(command_name)
    local command_id = reaper.NamedCommandLookup(command_name)
    reaper.Main_OnCommand(command_id, 0)
end

local function GetAllItems()
    local count = reaper.CountMediaItems(0)
    local items = {}
    for i = 0, count - 1 do
        items[i + 1] = reaper.GetMediaItem(0, i)
    end
    return items
end

local function GetSelectedItems()
    local selectedItems = {}

    for _, item in ipairs(GetAllItems()) do
        if reaper.IsMediaItemSelected(item) then
            selectedItems[#selectedItems + 1] = item
        end
    end

    return selectedItems
end

local function SelectOnlyItems(items)
    for _, item in ipairs(GetAllItems()) do
        reaper.SetMediaItemSelected(item, false)
    end
    for _, item in ipairs(items) do
        reaper.SetMediaItemSelected(item, true)
    end
end

local function GetAllTracks()
    local count = reaper.CountTracks(0)
    local tracks = {}
    for i = 0, count - 1 do
        tracks[i + 1] = reaper.GetTrack(0, i)
    end
    return tracks
end

local function SelectOnlyTracks(tracks)
    for _, track in ipairs(GetAllTracks()) do
        reaper.SetTrackSelected(track, false)
    end
    for _, item in ipairs(tracks) do
        reaper.SetTrackSelected(item, true)
    end
end

local function GetSelectedTracks()
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

local function GetItemTakeInfo(itemTake)
    return {
        -- 0=normal, 1=reverse stereo, 2=downmix, 3=left, 4=right
        channelMode = reaper.GetMediaItemTakeInfo_Value(itemTake, "I_CHANMODE")
    }
end

local function GetItemInfo(item)
    local currentTake = reaper.GetMediaItemInfo_Value(item, "I_CURTAKE")
    return {
        track = reaper.GetMediaItemInfo_Value(item, "P_TRACK"),
        position = reaper.GetMediaItemInfo_Value(item, "D_POSITION"),
        length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH"),
        snapOffset = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET"),
        mute = reaper.GetMediaItemInfo_Value(item, "D_MUTE"),
        muteActual = reaper.GetMediaItemInfo_Value(item, "D_MUTE_ACTUAL"),
        currentTake = GetItemTakeInfo(reaper.GetMediaItemTake(item, currentTake))
    }
end

local function GetItemsInfo(items)
    local itemsInfo = {}
    for i, item in ipairs(items) do
        itemsInfo[i] = GetItemInfo(item)
    end
    return itemsInfo
end

local function SetItemInfo(item, info)
    if info.position ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", info.position)
    end
    if info.length ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", info.length)
    end
    if info.mute ~= nil then
        reaper.SetMediaItemInfo_Value(item, "B_MUTE", info.mute)
    end
    if info.snapOffset ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", info.snapOffset)
    end
end

local function GetTrackInfo(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return {
        mute = reaper.GetMediaTrackInfo_Value(track, "B_MUTE"),
        name = name,
        trackNumber1Based = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    }
end

local function GetTrackName(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

local function SetTrackName(track, name)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
end

local function MoveItemToTrack(item, track)
    local itemTrack = GetItemInfo(item).track

    if reaper.GetTrackGUID(itemTrack) ~= reaper.GetTrackGUID(track) then
        local _, itemChunk = reaper.GetItemStateChunk(item, '')
        reaper.DeleteTrackMediaItem(itemTrack, item)
        local newItem = reaper.AddMediaItemToTrack(track)
        reaper.SetItemStateChunk(newItem, itemChunk)
    end
end

local function GetLoopTimeRange()
    return reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
end

local function SetLoopTimeRange(loopStart, loopEnd)
    reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, true)
end

local function ExtendTimeSelection(seconds)
    local loopStart, loopEnd = GetLoopTimeRange()
    SetLoopTimeRange(loopStart, loopEnd + seconds)
end

local function GetDescendantTracks(track)
    local trackInfo = GetTrackInfo(track)
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

local function GetItemsInTrack(track)
    local count = reaper.CountMediaItems(0)
    local items = {}
    for i = 0, count - 1 do
        local item = reaper.GetMediaItem(0, i)
        local itemInfo = GetItemInfo(item)
        if reaper.GetTrackGUID(itemInfo.track) == reaper.GetTrackGUID(track) then
            items[#items + 1] = item
        end
    end
    return items
end

local function GetMaxItemLength(items)
    local maxLength = 0

    for _, item in ipairs(items) do
        local itemInfo = GetItemInfo(item)
        maxLength = math.max(maxLength, itemInfo.length)
    end

    return maxLength
end

local function Approximately(x, y)
    return math.abs(x - y) < 1e-6
end

local function GetMarkerSnapPoints()
    local snapPoints = {0}

    local function insertIfUnique(num)
        if #snapPoints == 0 or not Approximately(num, snapPoints[#snapPoints]) then
            snapPoints[#snapPoints + 1] = num
        end
    end

    local projectMarkersCount = reaper.CountProjectMarkers()

    for i = 0, projectMarkersCount - 1 do
        local _, isRegion, position, regionEnd, _, _, _ = reaper.EnumProjectMarkers3(0, i)
        insertIfUnique(position)
        if isRegion then
            insertIfUnique(regionEnd)
        end
    end

    local loopStart, loopEnd = GetLoopTimeRange()

    if loopStart ~= loopEnd then
        insertIfUnique(loopStart)
    end

    return snapPoints
end

local function FindClosestNumber(numbers, target)
    local closestIndex = 1
    local closestPoint = numbers[1]

    for i, snapPoint in ipairs(numbers) do
        if math.abs(snapPoint - target) < math.abs(closestPoint - target) then
            closestIndex = i
            closestPoint = snapPoint
        end
    end

    return closestIndex, closestPoint
end

return {
    named_on_command = named_on_command,
    GetAllItems = GetAllItems,
    GetSelectedItems = GetSelectedItems,
    SelectOnlyItems = SelectOnlyItems,
    GetSelectedTracks = GetSelectedTracks,
    SelectOnlyTracks = SelectOnlyTracks,
    main = main,
    GetItemTakeInfo = GetItemTakeInfo,
    GetItemInfo = GetItemInfo,
    GetTrackInfo = GetTrackInfo,
    GetItemsInfo = GetItemsInfo,
    GetItemsInTrack = GetItemsInTrack,
    GetAllTracks = GetAllTracks,
    GetTrackName = GetTrackName,
    SetTrackName = SetTrackName,
    MoveItemToTrack = MoveItemToTrack,
    GetLoopTimeRange = GetLoopTimeRange,
    SetLoopTimeRange = SetLoopTimeRange,
    ExtendTimeSelection = ExtendTimeSelection,
    GetDescendantTracks = GetDescendantTracks,
    GetMaxItemLength = GetMaxItemLength,
    SetItemInfo = SetItemInfo,
    GetMarkerSnapPoints = GetMarkerSnapPoints,
    FindClosestNumber = FindClosestNumber,
    Approximately = Approximately
}
