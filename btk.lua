local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local rpr = require 'rpr'

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
    for _, track in ipairs(tracks) do
        reaper.SetTrackSelected(track, true)
    end
end

local function SelectOnlyTrack(track)
    SelectOnlyTracks({track})
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
    local _, name = reaper.GetSetMediaItemTakeInfo_String(itemTake, "P_NAME", "", false)
    return {
        -- 0=normal, 1=reverse stereo, 2=downmix, 3=left, 4=right
        channelMode = reaper.GetMediaItemTakeInfo_Value(itemTake, "I_CHANMODE"),
        name = name
    }
end

local function GetItemInfo(item)
    local track = reaper.GetMediaItemInfo_Value(item, "P_TRACK")
    local currentTake = reaper.GetMediaItemInfo_Value(item, "I_CURTAKE")
    return {
        track = track,
        trackGUID = reaper.GetTrackGUID(track),
        position = reaper.GetMediaItemInfo_Value(item, "D_POSITION"),
        length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH"),
        snapOffset = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET"),
        mute = num2bool(reaper.GetMediaItemInfo_Value(item, "B_MUTE")),
        muteActual = num2bool(reaper.GetMediaItemInfo_Value(item, "B_MUTE_ACTUAL")),
        currentTake = GetItemTakeInfo(reaper.GetMediaItemTake(item, currentTake)),
        fadeInLength = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN"),
        fadeOutLength = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN"),
        fadeInCurvature = reaper.GetMediaItemInfo_Value(item, "D_FADEINDIR"),
        fadeOutCurvature = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTDIR"),
        fadeInShape = reaper.GetMediaItemInfo_Value(item, "C_FADEINSHAPE"),
        fadeOutShape = reaper.GetMediaItemInfo_Value(item, "C_FADEOUTSHAPE")
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
    if info.fadeInLength ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", info.fadeInLength)
    end
    if info.fadeOutLength ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", info.fadeOutLength)
    end
    if info.fadeInCurvature ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_FADEINDIR", info.fadeInCurvature)
    end
    if info.fadeOutCurvature ~= nil then
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTDIR", info.fadeOutCurvature)
    end
    if info.fadeInShape ~= nil then
        reaper.SetMediaItemInfo_Value(item, "C_FADEINSHAPE", info.fadeInShape)
    end
    if info.fadeOutShape ~= nil then
        reaper.SetMediaItemInfo_Value(item, "C_FADEOUTSHAPE", info.fadeOutShape)
    end
end

local function GetTrackInfo(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    local trackNumber = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    return {
        mute = num2bool(reaper.GetMediaTrackInfo_Value(track, "B_MUTE")),
        name = name,
        trackNumber1Based = trackNumber,
        index = trackNumber - 1,
        folderCompact = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT"),
        folderDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    }
end

local function SetTrackInfo(track, info)
    if info.mute ~= nil then
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", bool2num(info.mute))
    end
    if info.name ~= nil then
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", info.name, true)
    end
    if info.folderCompact ~= nil then
        reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", info.folderCompact)
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

local function HasLoopTimeRange()
    local loopStart, loopEnd = GetLoopTimeRange()
    return loopStart ~= loopEnd
end

local function GetLoopTimeRangeOrCursor()
    local loopStart, loopEnd = GetLoopTimeRange()

    if loopStart == loopEnd then
        loopStart = reaper.GetCursorPosition()
        loopEnd = loopStart
    end

    return loopStart, loopEnd
end

local function SetLoopTimeRange(loopStart, loopEnd)
    reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, true)
end

local function SetLoopTimeRangeAndCursor(loopStart, loopEnd)
    reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, true)
    local cursor = reaper.GetCursorPosition()
    reaper.MoveEditCursor(loopEnd - cursor, false)
end

local function ExtendTimeSelection(seconds)
    local loopStart, loopEnd = GetLoopTimeRange()
    SetLoopTimeRange(loopStart, math.max(loopStart, loopEnd + seconds))
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
    local markers = GetProjectMarkers()
    local foundRegionMatrixEntry = false

    for _, marker in ipairs(markers) do
        if marker.isRegion and reaper.EnumRegionRenderMatrix(0, marker.regionIndex, 0) == nil then
            foundRegionMatrixEntry = true
            break
        end
    end

    if not foundRegionMatrixEntry then
        return
    end

    local function RandomHue(prevHue)
        local hue = math.random(40, 300)
        while math.abs(hue - prevHue) < 50 do
            hue = math.random(40, 300)
        end
        return hue
    end

    local function BlackTint(tint)
        local r, g, b = reaper.ColorFromNative(tint)
        return reaper.ColorToNative(math.ceil(r / 8), math.ceil(g / 8), math.ceil(b / 8))
    end

    local hue = RandomHue(0)
    local regionedTracks = {}
    local defaultColor = RGB(255, 0, 0)

    for _, track in ipairs(GetAllTracks()) do
        reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", 0)
        defaultColor = reaper.GetTrackColor(track)
    end

    for _, marker in ipairs(markers) do
        local markerColor = marker.color

        if regenerate or markerColor == 0 then
            markerColor = HSL(hue, 1, 0.5)
            reaper.SetProjectMarker4(0, marker.regionNumber, marker.isRegion, marker.position, marker.regionEnd, "",
                markerColor, 0)
            hue = RandomHue(hue, 50)
        end

        if marker.isRegion then
            for i = 0, 100 do
                local track = reaper.EnumRegionRenderMatrix(0, marker.regionIndex, i)
                if track == nil then
                    break
                end

                reaper.SetTrackColor(track, markerColor)

                local trackGUID = reaper.GetTrackGUID(track)
                regionedTracks[trackGUID] = true

                if reaper.GetTrackDepth(track) > 0 then
                    local parentTrack = reaper.GetParentTrack(track)
                    local parentGUID = reaper.GetTrackGUID(parentTrack)

                    if regionedTracks[parentGUID] ~= true then
                        reaper.SetTrackColor(parentTrack, BlackTint(markerColor))
                    end
                end
            end
        end
    end
end

local function CopyTrackRegionRenderMatrix(fromTrack, toTrack)
    for _, marker in ipairs(GetProjectMarkers()) do
        if marker.isRegion then
            for i = 0, 100 do
                local track = reaper.EnumRegionRenderMatrix(0, marker.regionIndex, i)
                if track == nil then
                    break
                elseif track == fromTrack then
                    reaper.SetRegionRenderMatrix(0, marker.regionIndex, toTrack, 1)
                end
            end
        end
    end
end

local function GetAllItemsInRange(rangeStart, rangeEnd)
    local itemsInRange = {}

    for _, item in ipairs(GetAllItems()) do
        local info = GetItemInfo(item)
        if info.position < rangeEnd and info.position + info.length > rangeStart then
            itemsInRange[#itemsInRange + 1] = item
        end
    end

    return itemsInRange
end

local function GetTrackFolderHierarchy(track)
    local info = GetTrackInfo(track)
    local hierarchy = {}
    local trackCursor = track

    while true do
        local cursorDepth = reaper.GetTrackDepth(trackCursor)

        if cursorDepth == 0 then
            break
        end

        while reaper.GetTrackDepth(trackCursor) >= cursorDepth do
            trackCursor = reaper.GetTrack(0, GetTrackInfo(trackCursor).index - 1)
        end

        hierarchy[#hierarchy + 1] = trackCursor
    end

    return hierarchy
end

local function ShowTrackInFolderHierarchy(track)
    local hierarchy = GetTrackFolderHierarchy(track)
    for _, folder in ipairs(hierarchy) do
        SetTrackInfo(folder, {
            folderCompact = 0
        })
    end
end

local function Reverse(list)
    for i = 1, math.floor(#list / 2) do
        local t = list[i]
        list[i] = list[#list - i + 1]
        list[#list - i + 1] = t
    end
end

local function AnyCollapsed(folders)
    for _, folder in ipairs(folders) do
        if GetTrackInfo(folder).folderCompact ~= 0 then
            return true
        end
    end

    return false
end

local function GetAllFolders()
    local allFolders = {}

    for _, track in ipairs(GetAllTracks()) do
        if GetTrackInfo(track).folderDepth == 1 then
            allFolders[#allFolders + 1] = track
        end
    end

    return allFolders
end

local function GetSelectedFolders()
    local selectedFolders = {}

    for _, track in ipairs(GetSelectedTracks()) do
        if GetTrackInfo(track).folderDepth == 1 then
            selectedFolders[#selectedFolders + 1] = track
        end
    end

    return selectedFolders
end

local function ToggleFolderCollapsedStateAtDepth(depth)
    local allFolders = GetAllFolders()
    local folders1 = {}

    for _, folder in ipairs(allFolders) do
        if reaper.GetTrackDepth(folder) < depth then
            folders1[#folders1 + 1] = folder
        end
    end

    for _, folder in ipairs(allFolders) do
        SetTrackInfo(folder, {
            folderCompact = 2
        })
    end

    for _, folder in ipairs(folders1) do
        SetTrackInfo(folder, {
            folderCompact = 0
        })
    end
end

local function Concat(l, r)
    local result = {}
    for _, v in ipairs(l) do
        result[#result + 1] = v
    end
    for _, v in ipairs(r) do
        result[#result + 1] = v
    end
    return result
end

local function RenderSelectionOrSelectedItems(stereo, intoPreviousTrack, intoSelf)
    local selectedTracks = GetSelectedTracks()

    if #selectedTracks == 0 then
        return
    end

    local track = selectedTracks[1]
    reaper.SetOnlyTrackSelected(selectedTracks[1])
    local trackInfo = GetTrackInfo(track)
    local loopStart, loopEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
    local loopItems = nil

    if loopStart == loopEnd then
        loopItems = GetSelectedItems()
        if #loopItems == 0 then
            return
        end
        rpr.sws_save_edit_cursor()
        rpr.time_selection_set_to_items()
        ExtendTimeSelection(1)
    end

    if stereo then
        rpr.track_render_selected_area_to_stereo()
    else
        rpr.track_render_selected_area_to_mono()
    end

    local renderedTrack = GetSelectedTracks()[1]

    if intoPreviousTrack and trackInfo.trackNumber1Based > 1 then
        -- GetTrack is 0-based, trackNumber1Based is 1-based.
        local originalPreviousTrack = reaper.GetTrack(0, trackInfo.trackNumber1Based - 2)
        for _, item in ipairs(GetItemsInTrack(renderedTrack)) do
            MoveItemToTrack(item, originalPreviousTrack)
        end
        reaper.DeleteTrack(renderedTrack)
    elseif intoSelf then
        reaper.SetOnlyTrackSelected(track)
        rpr.item_select_all_in_track()
        rpr.item_remove()
        for _, item in ipairs(GetItemsInTrack(renderedTrack)) do
            MoveItemToTrack(item, track)
        end
        reaper.DeleteTrack(renderedTrack)
    end

    if loopItems then
        for _, item in ipairs(loopItems) do
            reaper.SetMediaItemInfo_Value(item, "B_MUTE", 1)
        end
    end

    if loopStart == loopEnd then
        reaper.GetSet_LoopTimeRange2(0, true, true, loopStart, loopEnd, false)
        rpr.sws_restore_edit_cursor()

    end

    SetTrackInfo(track, {
        mute = trackInfo.mute
    })

    SelectOnlyTracks(selectedTracks)
end

local function DeleteTrackRecursive(track)
    local selectedTracks = GetSelectedTracks()

    local function Inner(deleteTrack)
        for _, child in ipairs(GetChildTracks(deleteTrack)) do
            Inner(child)
        end

        SelectOnlyTrack(deleteTrack)
        reaper.ReorderSelectedTracks(1, 0)
        reaper.DeleteTrack(deleteTrack)
    end

    Inner(track)
    SelectOnlyTracks(selectedTracks)
end

local function SplitItemsByTrack(items)
    local itemsByTrack = {}
    local splitItems = {}

    for _, item in ipairs(items) do
        local trackGUID = GetItemInfo(item).trackGUID
        local trackItems = itemsByTrack[trackGUID]
        if trackItems == nil then
            trackItems = {}
            itemsByTrack[trackGUID] = trackItems
            splitItems[#splitItems + 1] = trackItems
        end
        trackItems[#trackItems + 1] = item
    end

    return splitItems
end

local function GlueItemsPreserveFade(items)
    local firstItem = items[1]
    local firstItemInfo = GetItemInfo(firstItem)
    local lastItem = firstItem
    local lastItemInfo = firstItemInfo

    for i = 2, #items do
        local item = items[i]
        local itemInfo = GetItemInfo(item)

        if itemInfo.position < firstItemInfo.position then
            firstItem = item
            firstItemInfo = itemInfo
        end

        if itemInfo.position + itemInfo.length > lastItemInfo.position + lastItemInfo.length then
            lastItem = item
            lastItemInfo = itemInfo
        end
    end

    SetItemInfo(firstItem, {
        fadeInLength = 0
    })
    SetItemInfo(lastItem, {
        fadeOutLength = 0
    })

    SelectOnlyItems(items)
    rpr.item_glue()
    local gluedItem = GetSelectedItems()[1]

    SetItemInfo(gluedItem, {
        fadeInLength = firstItemInfo.fadeInLength,
        fadeInShape = firstItemInfo.fadeInShape,
        fadeInCurvature = firstItemInfo.fadeInCurvature,
        fadeOutLength = lastItemInfo.fadeOutLength,
        fadeOutShape = lastItemInfo.fadeOutShape,
        fadeOutCurvature = lastItemInfo.fadeOutCurvature
    })

    return gluedItem
end

return {
    AnyCollapsed = AnyCollapsed,
    Approximately = Approximately,
    Avg = Avg,
    bool2num = bool2num,
    Clamp = Clamp,
    Concat = Concat,
    Contains = Contains,
    CopyTrackRegionRenderMatrix = CopyTrackRegionRenderMatrix,
    DeleteTrackRecursive = DeleteTrackRecursive,
    ExtendTimeSelection = ExtendTimeSelection,
    FindClosestNumber = FindClosestNumber,
    GenerateMarkerColors = GenerateMarkerColors,
    GetAllFolders = GetAllFolders,
    GetAllItems = GetAllItems,
    GetAllItemsInRange = GetAllItemsInRange,
    GetAllTracks = GetAllTracks,
    GetChildTracks = GetChildTracks,
    GetDescendantTracks = GetDescendantTracks,
    GetItemInfo = GetItemInfo,
    GetItemsInfo = GetItemsInfo,
    GetItemsInTrack = GetItemsInTrack,
    GetItemTakeInfo = GetItemTakeInfo,
    GetLoopTimeRange = GetLoopTimeRange,
    GetLoopTimeRangeOrCursor = GetLoopTimeRangeOrCursor,
    GetMarkerSnapPoints = GetMarkerSnapPoints,
    GetMaxItemLength = GetMaxItemLength,
    GetProjectMarkers = GetProjectMarkers,
    GetSelectedFolders = GetSelectedFolders,
    GetSelectedItems = GetSelectedItems,
    GetSelectedTracks = GetSelectedTracks,
    GetTrackFolderHierarchy = GetTrackFolderHierarchy,
    GetTrackInfo = GetTrackInfo,
    GlueItemsPreserveFade = GlueItemsPreserveFade,
    HasLoopTimeRange = HasLoopTimeRange,
    HSL = HSL,
    main = main,
    MoveItemToTrack = MoveItemToTrack,
    num2bool = num2bool,
    RenderSelectionOrSelectedItems = RenderSelectionOrSelectedItems,
    Reverse = Reverse,
    RGB = RGB,
    SelectOnlyItem = SelectOnlyItem,
    SelectOnlyItems = SelectOnlyItems,
    SelectOnlyTrack = SelectOnlyTrack,
    SelectOnlyTracks = SelectOnlyTracks,
    SetItemInfo = SetItemInfo,
    SetLoopTimeRange = SetLoopTimeRange,
    SetLoopTimeRangeAndCursor = SetLoopTimeRangeAndCursor,
    SetTrackInfo = SetTrackInfo,
    ShowTrackInFolderHierarchy = ShowTrackInFolderHierarchy,
    SplitItemsByTrack = SplitItemsByTrack,
    ToggleFolderCollapsedStateAtDepth = ToggleFolderCollapsedStateAtDepth
}
