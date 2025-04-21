local _, path = reaper.get_action_context()
local folder_path = path:match('^.+[\\/]')
package.path = folder_path .. '?.lua;'
local btk = require 'btk'
local rpr = require 'rpr'

local function CreateBuffer(size, fill)
    local buf = reaper.new_array(size)
    for i = 1, #buf do
        buf[i] = fill
    end
    return buf
end

local function TrimItem(item)
    local info = btk.GetItemInfo(item)

    local takeSource = reaper.GetMediaItemTake_Source(info.take)
    local sampleRate = reaper.GetMediaSourceSampleRate(takeSource)
    local numChannels = reaper.GetMediaSourceNumChannels(takeSource)
    local numSamples = math.floor(sampleRate * math.min(info.length, 0.01)) -- 10ms

    if numSamples == 0 then
        return item
    end

    local accessor = reaper.CreateTakeAudioAccessor(info.take)
    local buf = reaper.new_array(numSamples * numChannels)
    local result = reaper.GetAudioAccessorSamples(accessor, sampleRate, numChannels, 0, numSamples, buf)

    if result ~= 1 then
        return item
    end

    local minIndex = 1
    local minIndexValue = math.abs(buf[minIndex])

    for i = 1, #buf - 1 do
        if buf[i] * buf[i + 1] <= 0 then
            -- found zero-crossing
            local indexValue = math.max(math.abs(buf[i]), math.abs(buf[i + 1]))
            if indexValue < minIndexValue then
                minIndex = i
                minIndexValue = indexValue
            end
        end
    end

    if minIndex == 1 then
        return item
    end

    local minIndexAbsolutePosition = info.position + (minIndex + 0.5) / sampleRate
    local rhsItem = reaper.SplitMediaItem(item, minIndexAbsolutePosition)

    -- cancel any auto fade creation from splitting
    btk.SetItemInfo(rhsItem, {
        fadeInLength = info.fadeInLength
    })

    reaper.DeleteTrackMediaItem(info.track, item)
    reaper.DestroyAudioAccessor(accessor)

    return rhsItem
end

btk.main("TrimItemToFirstSafeCrossing", function()
    local newItems = {}

    for _, item in ipairs(btk.GetSelectedItems()) do
        newItems[#newItems + 1] = TrimItem(item)
    end

    btk.SelectOnlyItems(newItems)

    -- This script doesn't update until the cursor is moved for some reason
    rpr.view_move_cursor_right_one_pixel()
    rpr.view_move_cursor_left_one_pixel()
end)
