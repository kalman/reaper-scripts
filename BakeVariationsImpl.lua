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

local function BakeTrackVariations(track, stereo)
    local info = btk.GetTrackInfo(track)
    local childTracks = btk.GetChildTracks(track)

    if #childTracks == 0 then
        reaper.ShowConsoleMsg("Skipping track " .. info.name .. " with no children")
        return
    end

    btk.SelectOnlyTrack(track)
    rpr.track_duplicate()

    local dup = btk.GetSelectedTracks()[1]

    btk.SelectOnlyTrack(track)

    -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#TrackFX_GetCount
    local trackFxCount = reaper.TrackFX_GetCount(track)

    -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#GetTrackNumSends
    local trackSendCount = reaper.GetTrackNumSends(track, 0)

    for _, childTrack in ipairs(childTracks) do
        local childFxCount = reaper.TrackFX_GetCount(childTrack)
        local childSendCount = reaper.GetTrackNumSends(childTrack, 0)

        for i = 0, trackFxCount - 1 do
            -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#TrackFX_CopyToTrack
            reaper.TrackFX_CopyToTrack(track, i, childTrack, childFxCount + i, false)
        end

        local copiedTrackSends = {}

        for i = 0, trackSendCount - 1 do
            copiedTrackSends[#copiedTrackSends + 1] = CopyTrackSend(track, i, childTrack)
        end

        btk.SelectOnlyTrack(childTrack)
        btk.RenderSelectionOrSelectedItems(stereo, false, true)

        for i = 0, trackFxCount - 1 do
            -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#TrackFX_Delete
            -- no +i here because it's deleting plugins and reducing index
            reaper.TrackFX_Delete(childTrack, childFxCount)
        end

        btk.Reverse(copiedTrackSends)

        for _, sendIndex in ipairs(copiedTrackSends) do
            -- https://www.reaper.fm/sdk/reascript/reascripthelp.html#RemoveTrackSend
            reaper.RemoveTrackSend(childTrack, 0, sendIndex)
        end

        for _, grandchildTrack in ipairs(btk.GetChildTracks(childTrack)) do
            -- For some reason I need to put the grandchild above the child before deleting it,
            -- otherwise the subsequent child tracks end up as children of the first. Reaper bug?
            btk.SelectOnlyTrack(grandchildTrack)
            reaper.ReorderSelectedTracks(btk.GetTrackInfo(childTrack).index, 0)
            reaper.DeleteTrack(grandchildTrack)
        end
    end

    btk.SelectOnlyTrack(dup)
    reaper.ReorderSelectedTracks(info.index + 1, 0)
    btk.SetTrackInfo(dup, {
        folderCompact = 2,
        mute = true,
        name = "ORIGINAL - " .. info.name
    })

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
