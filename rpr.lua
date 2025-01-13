local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'

local function item_duplicate()
    reaper.Main_OnCommand(41295, 0) -- Item: Duplicate items
end

local function item_mute()
    reaper.Main_OnCommand(40719, 0) -- Item properties: Mute
end

local function item_glue()
    reaper.Main_OnCommand(40362, 0) -- Item: Glue items, ignoring time selection
end

local function track_insert_new(index)
    reaper.Main_OnCommand(40001, 0) -- Track: Insert new track
end

local function track_duplicate(index)
    reaper.Main_OnCommand(40062, 0) -- Track: Duplicate tracks
end

local function track_rename_last_touched()
    reaper.Main_OnCommand(40696, 0) -- Track: Rename last touched track
end

local function track_move_tracks_to_new_folder()
    reaper.Main_OnCommand(42785, 0) -- Track: Move tracks to new folder
end

local function time_selection_set_to_items()
    reaper.Main_OnCommand(40290, 0) -- Time selection: Set time selection to items
end

local function track_render_selected_area_to_stereo()
    reaper.Main_OnCommand(41719, 0) -- Track: Render selected area of tracks to stereo stem tracks (and mute originals)
end

local function track_render_selected_area_to_mono()
    reaper.Main_OnCommand(41721, 0) -- Track: Render selected area of tracks to mono stem tracks (and mute originals)
end

local function item_select_all_in_track()
    reaper.Main_OnCommand(40421, 0) -- Item: Select all items in track
end

local function sws_save_edit_cursor()
    -- SWS/BR: Save edit cursor position, slot 01
    btk.named_on_command("_BR_SAVE_CURSOR_POS_SLOT_1")
end

local function sws_restore_edit_cursor()
    -- SWS/BR: Restore edit cursor position, slot 01
    btk.named_on_command("_BR_RESTORE_CURSOR_POS_SLOT_1")
end

return {
    item_duplicate = item_duplicate,
    item_mute = item_mute,
    item_glue = item_glue,
    item_select_all_in_track = item_select_all_in_track,
    track_insert_new = track_insert_new,
    track_duplicate = track_duplicate,
    track_rename_last_touched = track_rename_last_touched,
    track_move_tracks_to_new_folder = track_move_tracks_to_new_folder,
    time_selection_set_to_items = time_selection_set_to_items,
    track_render_selected_area_to_stereo = track_render_selected_area_to_stereo,
    track_render_selected_area_to_mono = track_render_selected_area_to_mono,
    sws_save_edit_cursor = sws_save_edit_cursor,
    sws_restore_edit_cursor = sws_restore_edit_cursor,
}
