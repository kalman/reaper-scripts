local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'
local impl = require 'BakeVariationsImpl'

local function InsertMidiC4(track)
    local startTime, endTime = btk.GetLoopTimeRangeOrCursor()

    if startTime == endTime then
        endTime = startTime + 1
    end

    local item = reaper.CreateNewMIDIItemInProj(track, startTime, endTime, nil)
    local take = reaper.GetMediaItemTake(item, 0)

    local startPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, startTime)
    local endPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, endTime)

    reaper.MIDI_InsertNote(take, false, false, startPPQ, endPPQ, 0, 60, 127)

    return item
end

btk.main("InsertMidiC4", function()
    local lastItem = nil

    for _, track in ipairs(btk.GetSelectedTracks()) do
        lastItem = InsertMidiC4(track)
    end

    if lastItem ~= nil then
        local info = btk.GetItemInfo(lastItem)
        local endPosition = info.position + info.length
        btk.SetLoopTimeRangeAndCursor(endPosition, endPosition)
    end
end)
