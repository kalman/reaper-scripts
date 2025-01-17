local function bool2num(bool)
    if bool then
        return 1
    else
        return 0
    end
end

local function num2bool(number)
    if number == 0 then
        return false
    else
        return true
    end
end

local function NamedCommand(command_name)
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

local function GetProjectMarkers()
    local projectMarkers = {}
    local projectMarkersCount = reaper.CountProjectMarkers()

    for i = 0, projectMarkersCount - 1 do
        local _, isRegion, position, regionEnd, name, regionNumber, color = reaper.EnumProjectMarkers3(0, i)
        projectMarkers[#projectMarkers + 1] = {
            regionIndex = i,
            regionNumber = regionNumber,
            position = position,
            isRegion = isRegion,
            regionEnd = regionEnd,
            name = name,
            color = color
        }
    end

    return projectMarkers
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

local function SelectOnlyItem(item)
    SelectOnlyItems({item})
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
        mute = num2bool(reaper.GetMediaItemInfo_Value(item, "B_MUTE")),
        muteActual = num2bool(reaper.GetMediaItemInfo_Value(item, "B_MUTE_ACTUAL")),
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
        reaper.SetMediaItemInfo_Value(item, "B_MUTE", bool2num(info.mute))
    end
    if info.snapOffset ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", info.snapOffset)
    end
end

local function GetTrackInfo(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return {
        mute = num2bool(reaper.GetMediaTrackInfo_Value(track, "B_MUTE")),
        name = name,
        trackNumber1Based = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    }
end

local function SetTrackInfo(track, info)
    if info.mute ~= nil then
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", bool2num(info.mute))
    end
    if info.name ~= nil then
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", info.name, true)
    end
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

local function GetChildTracks(track)
    local trackInfo = GetTrackInfo(track)
    local trackDepth = reaper.GetTrackDepth(track)
    local childTracks = {}

    for i = trackInfo.trackNumber1Based, reaper.CountTracks(0) do
        local nextTrack = reaper.GetTrack(0, i)
        local nextTrackDepth = reaper.GetTrackDepth(nextTrack)
        if nextTrackDepth <= trackDepth then
            break
        end
        if nextTrackDepth == trackDepth + 1 then
            childTracks[#childTracks + 1] = nextTrack
        end
    end

    return childTracks
end

local function GetDescendantTracks(track)
    local trackInfo = GetTrackInfo(track)
    local trackDepth = reaper.GetTrackDepth(track)
    local descendantTracks = {}

    for i = trackInfo.trackNumber1Based, reaper.CountTracks(0) - 1 do
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

    for _, marker in ipairs(GetProjectMarkers()) do
        insertIfUnique(marker.position)
    end

    local loopStart, loopEnd = GetLoopTimeRange()

    if loopStart ~= loopEnd then
        insertIfUnique(loopStart)
    end

    table.sort(snapPoints)
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

local function RGB(r, g, b)
    return reaper.ColorToNative(math.ceil(r), math.ceil(g), math.ceil(b)) | 0x1000000
end

local function Clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

local function HSL(h, s, l)
    -- From https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua
    h = Clamp(h, 0, 360) / 360
    s = Clamp(s, 0, 1)
    l = Clamp(l, 0, 1)

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then
                t = t + 1
            end
            if t > 1 then
                t = t - 1
            end
            if t < 1 / 6 then
                return p + (q - p) * 6 * t
            end
            if t < 1 / 2 then
                return q
            end
            if t < 2 / 3 then
                return p + (q - p) * (2 / 3 - t) * 6
            end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    return RGB(r * 255, g * 255, b * 255)
end

local function Avg(values)
    if #values == 0 then
        reaper.ShowConsoleMsg("Error: no values to calculate average")
    end
    local total = 0
    for _, value in ipairs(values) do
        total = total + value
    end
    return total / #values
end

local function Contains(values, containsValue)
    for _, value in ipairs(values) do
        if value == containsValue then
            return true
        end
    end
    return false
end

local function GenerateMarkerColors(regenerate)
    local function randomHue(prevHue)
        local hue = math.random(40, 300)
        while math.abs(hue - prevHue) < 50 do
            hue = math.random(40, 300)
        end
        return hue
    end

    local markers = GetProjectMarkers()
    local hue = randomHue(0)
    local darkGrey = RGB(40, 40, 40)
    local lightGrey = RGB(140, 140, 140)

    for _, track in ipairs(GetAllTracks()) do
        reaper.SetTrackColor(track, darkGrey)
    end

    for _, marker in ipairs(markers) do
        local markerColor = marker.color

        if regenerate or markerColor == 0 then
            markerColor = HSL(hue, 1, 0.35)
            reaper.SetProjectMarker4(0, marker.regionNumber, marker.isRegion, marker.position, marker.regionEnd, "",
                markerColor, 0)
            hue = randomHue(hue, 50)
        end

        if marker.isRegion then
            for i = 0, 100 do
                local track = reaper.EnumRegionRenderMatrix(0, marker.regionIndex, i)
                if track == nil then
                    break
                end

                reaper.SetTrackColor(track, markerColor)

                if reaper.GetTrackDepth(track) > 0 then
                    local parentTrack = reaper.GetParentTrack(track)
                    if reaper.GetTrackColor(parentTrack) == darkGrey then
                        reaper.SetTrackColor(parentTrack, lightGrey)
                    end
                end
            end
        end
    end
end

return {
    NamedCommand = NamedCommand,
    GetAllItems = GetAllItems,
    GetSelectedItems = GetSelectedItems,
    SelectOnlyItem = SelectOnlyItem,
    SelectOnlyItems = SelectOnlyItems,
    GetSelectedTracks = GetSelectedTracks,
    SelectOnlyTracks = SelectOnlyTracks,
    main = main,
    GetItemTakeInfo = GetItemTakeInfo,
    GetItemInfo = GetItemInfo,
    GetTrackInfo = GetTrackInfo,
    SetTrackInfo = SetTrackInfo,
    GetItemsInfo = GetItemsInfo,
    GetItemsInTrack = GetItemsInTrack,
    GetAllTracks = GetAllTracks,
    MoveItemToTrack = MoveItemToTrack,
    GetLoopTimeRange = GetLoopTimeRange,
    SetLoopTimeRange = SetLoopTimeRange,
    ExtendTimeSelection = ExtendTimeSelection,
    GetChildTracks = GetChildTracks,
    GetDescendantTracks = GetDescendantTracks,
    GetMaxItemLength = GetMaxItemLength,
    SetItemInfo = SetItemInfo,
    GetMarkerSnapPoints = GetMarkerSnapPoints,
    FindClosestNumber = FindClosestNumber,
    Approximately = Approximately,
    GetProjectMarkers = GetProjectMarkers,
    Clamp = Clamp,
    RGB = RGB,
    HSL = HSL,
    Avg = Avg,
    Contains = Contains,
    GenerateMarkerColors = GenerateMarkerColors,
    bool2num = bool2num,
    num2bool = num2bool
}
