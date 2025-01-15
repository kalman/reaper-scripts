local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function run(stereo)
    local selectedTracks = btk.GetSelectedTracks()

    if #selectedTracks == 0 then
        return
    elseif #selectedTracks > 1 then
        reaper.SetOnlyTrackSelected(selectedTracks[1])
        selectedTracks = btk.GetSelectedTracks()
    end

    local track = selectedTracks[1]
    local trackInfo = btk.GetTrackInfo(track)

    local loopStart, loopEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
    local loopItems = nil

    if loopStart == loopEnd then
        loopItems = btk.GetSelectedItems()
        if #loopItems == 0 then
            return
        end
        rpr.sws_save_edit_cursor()
        rpr.time_selection_set_to_items()
        btk.ExtendTimeSelection(1)
    end

    if trackInfo.trackNumber1Based == 1 then
        if stereo then
            rpr.track_render_selected_area_to_stereo()
        else
            rpr.track_render_selected_area_to_mono()
        end
    else
        -- GetTrack is 0-based, trackNumber1Based is 1-based.
        local previousTrack = reaper.GetTrack(0, trackInfo.trackNumber1Based - 2)
        rpr.track_render_selected_area_to_stereo()
        rpr.item_select_all_in_track()
        btk.MoveItemToTrack(btk.GetSelectedItems()[1], previousTrack)
        reaper.DeleteTrack(btk.GetSelectedTracks()[1])
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

    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", trackInfo.mute)
end

btk.main("RenderSelectionOrSelectedItemsStereo", function()
    run(true)
end)
