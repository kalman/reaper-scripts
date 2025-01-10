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

return {
    item_duplicate = item_duplicate,
    item_mute = item_mute,
    item_glue = item_glue,
    track_insert_new = track_insert_new,
    track_duplicate = track_duplicate,
}
