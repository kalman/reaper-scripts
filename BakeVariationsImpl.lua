local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function CopyTrackSend(fromTrack, fromIndex, toTrack)
    -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#GetTrackSendInfo_Value
    local dstTrack = reaper.GetTrackSendInfo_Value(fromTrack, 0, fromIndex, "P_DESTTRACK");

    -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#CreateTrackSend
    local toIndex = reaper.CreateTrackSend(toTrack, dstTrack)

    -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#SetTrackSendInfo_Value
    local params = {"B_MUTE", "B_PHASE", "B_MONO", "D_VOL", "D_PANLAW", "I_SENDMODE", "I_AUTOMODE", "I_SRCCHAN",
                    "I_DSTCHAN", "I_MIDIFLAGS"}
    for _, param in ipairs(params) do
        reaper.SetTrackSendInfo_Value(toTrack, 0, toIndex, param,
            reaper.GetTrackSendInfo_Value(fromTrack, 0, fromIndex, param))
    end

    return toIndex
end

local function DeleteAllFX(track)
    while reaper.TrackFX_GetCount(track) > 0 do
        reaper.TrackFX_Delete(track, 0)
    end
end

local function DeleteAllSends(track)
    while reaper.GetTrackNumSends(track, 0) > 0 do
        reaper.RemoveTrackSend(track, 0, 0)
    end
end

local function BakeTrackVariations(track, stereo)
    local trackInfo = btk.GetTrackInfo(track)
    local childTracks = btk.GetChildTracks(track)

    if #childTracks == 0 then
        reaper.ShowConsoleMsg("Skipping track " .. trackInfo.name .. " with no children")
        return
    end

    btk.SelectOnlyTrack(track)
    rpr.track_duplicate()

    local dup = btk.GetSelectedTracks()[1]
    local trackFxCount = reaper.TrackFX_GetCount(track)
    local trackSendCount = reaper.GetTrackNumSends(track, 0)

    for _, childTrack in ipairs(childTracks) do
        local childFxCount = reaper.TrackFX_GetCount(childTrack)

        for i = 0, trackFxCount - 1 do
            -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#TrackFX_CopyToTrack
            reaper.TrackFX_CopyToTrack(track, i, childTrack, childFxCount + i, false)
        end

        for i = 0, trackSendCount - 1 do
            CopyTrackSend(track, i, childTrack)
        end

        btk.SelectOnlyTrack(childTrack)
        btk.RenderSelectionOrSelectedItems(stereo, false, true)

        for _, grandchildTrack in ipairs(btk.GetChildTracks(childTrack)) do
            btk.DeleteTrackRecursive(grandchildTrack)
        end

        DeleteAllFX(childTrack)
        DeleteAllSends(childTrack)
    end

    btk.SetTrackInfo(dup, {
        folderCompact = 2,
        mute = true,
        name = "ORIGINAL - " .. trackInfo.name
    })
    btk.SelectOnlyTrack(dup)
    reaper.ReorderSelectedTracks(trackInfo.index + 1, 0)

    DeleteAllFX(track)
    DeleteAllSends(track)

    return childTracks
end

local function Run(stereo)
    if not btk.HasLoopTimeRange() then
        return
    end

    local selectedTracks = btk.GetSelectedTracks()
    local allChildTracks = {}
    local allChildItems = {}

    for _, track in ipairs(selectedTracks) do
        local childTracks = BakeTrackVariations(track, stereo)
        allChildTracks = btk.Concat(allChildTracks, childTracks)
    end

    for _, childTrack in ipairs(allChildTracks) do
        allChildItems = btk.Concat(allChildItems, btk.GetItemsInTrack(childTrack))
    end

    btk.SelectOnlyTracks(allChildTracks)
    btk.SelectOnlyItems(allChildItems)
    btk.GenerateMarkerColors()
end

return {
    Run = Run
}
