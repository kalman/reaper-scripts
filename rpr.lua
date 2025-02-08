local function NamedCommand(command_name)
    local command_id = reaper.NamedCommandLookup(command_name)
    reaper.Main_OnCommand(command_id, 0)
end

local function item_duplicate()
    -- Item: Duplicate items
    reaper.Main_OnCommand(41295, 0)
end

local function item_mute()
    -- Item properties: Mute
    reaper.Main_OnCommand(40719, 0)
end

local function item_remove()
    -- Item: Remove items
    reaper.Main_OnCommand(40006, 0)
end

local function item_glue()
    -- Item: Glue items, ignoring time selection
    reaper.Main_OnCommand(40362, 0)
end

local function item_select_all_in_track()
    -- Item: Select all items in track
    reaper.Main_OnCommand(40421, 0)
end

local function item_select_all()
    -- Item: Select all items
    reaper.Main_OnCommand(40182, 0)
end

local function item_select_all_in_time_selection()
    -- Item: Select all items in current time selection
    reaper.Main_OnCommand(40717, 0)
end

local function item_unselect_all()
    -- Item: Unselect (clear selection of) all items
    reaper.Main_OnCommand(40289, 0)
end

local function track_insert_new(index)
    -- Track: Insert new track
    reaper.Main_OnCommand(40001, 0)
end

local function sws_save_edit_cursor()
    -- SWS/BR: Save edit cursor position, slot 01
    NamedCommand("_BR_SAVE_CURSOR_POS_SLOT_1")
end

local function sws_restore_edit_cursor()
    -- SWS/BR: Restore edit cursor position, slot 01
    NamedCommand("_BR_RESTORE_CURSOR_POS_SLOT_1")
end

local function sws_zoom_to_selected_items()
    -- SWS: Zoom to selected items
    NamedCommand("_SWS_ITEMZOOM")
end

local function sws_horizontal_zoom_to_selected_items()
    -- SWS: Horizontal zoom to selected items
    NamedCommand("_SWS_HZOOMITEMS")
end

local function time_selection_remove()
    -- Time selection: Remove (unselect) time selection and loop points
    reaper.Main_OnCommand(40020, 0)
end

local function time_selection_set_to_items()
    -- Time selection: Set time selection to items
    reaper.Main_OnCommand(40290, 0)
end

local function track_duplicate(index)
    -- Track: Duplicate tracks
    reaper.Main_OnCommand(40062, 0)
end

local function track_rename_last_touched()
    -- Track: Rename last touched track
    reaper.Main_OnCommand(40696, 0)
end

local function track_move_tracks_to_new_folder()
    -- Track: Move tracks to new folder
    reaper.Main_OnCommand(42785, 0)
end

local function track_render_selected_area_to_stereo()
    -- Track: Render selected area of tracks to stereo stem tracks (and mute originals)
    reaper.Main_OnCommand(41719, 0)
end

local function track_render_selected_area_to_mono()
    -- Track: Render selected area of tracks to mono stem tracks (and mute originals)
    reaper.Main_OnCommand(41721, 0)
end

local function track_select_all()
    -- Track: Select all tracks
    reaper.Main_OnCommand(40296, 0)
end

local function view_move_cursor_left_one_pixel()
    -- View: Move cursor left one pixel
    reaper.Main_OnCommand(40104, 0)
end

local function view_move_cursor_right_one_pixel()
    -- View: Move cursor right one pixel
    reaper.Main_OnCommand(40105, 0)
end

local function view_expand_selected_track_height()
    -- View: Expand selected track height, minimize others
    reaper.Main_OnCommand(40723, 0)
end

return {
    item_duplicate = item_duplicate,
    item_glue = item_glue,
    item_mute = item_mute,
    item_remove = item_remove,
    item_select_all = item_select_all,
    item_select_all_in_track = item_select_all_in_track,
    item_select_all_in_time_selection = item_select_all_in_time_selection,
    item_unselect_all = item_unselect_all,
    sws_restore_edit_cursor = sws_restore_edit_cursor,
    sws_save_edit_cursor = sws_save_edit_cursor,
    sws_zoom_to_selected_items = sws_zoom_to_selected_items,
    sws_horizontal_zoom_to_selected_items = sws_horizontal_zoom_to_selected_items,
    time_selection_remove = time_selection_remove,
    time_selection_set_to_items = time_selection_set_to_items,
    track_duplicate = track_duplicate,
    track_insert_new = track_insert_new,
    track_move_tracks_to_new_folder = track_move_tracks_to_new_folder,
    track_rename_last_touched = track_rename_last_touched,
    track_render_selected_area_to_mono = track_render_selected_area_to_mono,
    track_render_selected_area_to_stereo = track_render_selected_area_to_stereo,
    track_select_all = track_select_all,
    view_expand_selected_track_height = view_expand_selected_track_height,
    view_move_cursor_left_one_pixel = view_move_cursor_left_one_pixel,
    view_move_cursor_right_one_pixel = view_move_cursor_right_one_pixel
}
