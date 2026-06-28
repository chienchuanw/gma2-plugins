-- Correct Position Offset
-- 把兩個 Position preset 的差值,累加進每顆燈「每個 instance」的 Pan/Tilt offset。
-- UI 文字英文;註解中文。目標版本:grandMA2 3.9.60
--
-- 原理:
--   Export Preset 2.<orig> / 2.<corrected> → 讀 importexport XML → 解析每個
--   <PresetValue> 的 fixture_id / subfixture_id(無=1)/ attribute_name(PAN/TILT)/ Value。
--   對兩個 preset 都出現的 instance,delta = corrected - orig;讀目前 offset 累加後
--   Assign Fixture <id>.<sub> /panoffset= /tiltoffset=。
--   instance 用 subfixture_id 區分,故 .1 .3 .5 .7 .9 全部會被校正(原版只到 .1)。

local PLUGIN_TITLE = "Correct Position Offset"

---- USER CONFIG ----
local CONFIG = {
    OFFSET_PAN  = true,   -- 套用 Pan offset
    OFFSET_TILT = true,   -- 套用 Tilt offset
}

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

-- 匯出暫存檔名(每次覆蓋後刪除)
local TMP_NAME = "correct_position_offset_tmp"

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

-- ─── 純邏輯(不依賴 gma,可離線單元測試)──────────────────────

-- attribute_name(PAN/TILT,大小寫不拘)→ "pan"/"tilt";其他屬性回 nil
local function attr_key(name)
    name = name:lower()
    if name == "pan"  then return "pan"  end
    if name == "tilt" then return "tilt" end
    return nil
end

-- 把一份 preset XML 解析成 { pan = {[key]=value}, tilt = {[key]=value} }
-- key = "<idtype>:<id>.<sub>",idtype = fixt|chan,sub 預設 1。
local function parse_preset(xml)
    local out = { pan = {}, tilt = {} }
    for block in xml:gmatch("<PresetValue.-</PresetValue>") do
        local value = tonumber(block:match('PresetValue Value="([%-%d%.]+)"'))
        local attr  = block:match('attribute_name="([^"]+)"')
        local ak    = attr and attr_key(attr) or nil
        if value and ak then
            local idtype, id = "fixt", block:match('fixture_id="([%-%d%.]+)"')
            if not id then
                idtype, id = "chan", block:match('channel_id="([%-%d%.]+)"')
            end
            local sub = block:match('subfixture_id="([%-%d%.]+)"') or "1"
            if id then
                out[ak][idtype .. ":" .. id .. "." .. sub] = value
            end
        end
    end
    return out
end

-- 由 idtype/id/sub 組出指令用的目標字串
local function offset_target(idtype, id, sub)
    local kw = (idtype == "chan") and "Channel" or "Fixture"
    return string.format("%s %s.%s", kw, id, sub)
end

-- 數字格式化(degrees,3 位小數)
local function fmt(n)
    return string.format("%.3f", n)
end

-- 取兩個 preset 的交集,算每個 instance 的 pan/tilt delta。
-- 回傳依 target 排序的清單:{ {target, pan=?, tilt=?}, ... }
local function build_deltas(orig, corr, cfg)
    local attrs = {}
    if cfg.OFFSET_PAN  then attrs[#attrs + 1] = "pan"  end
    if cfg.OFFSET_TILT then attrs[#attrs + 1] = "tilt" end

    local byKey, keys = {}, {}
    for _, a in ipairs(attrs) do
        for key, cval in pairs(corr[a]) do
            local oval = orig[a][key]
            if oval ~= nil then
                local e = byKey[key]
                if not e then e = {}; byKey[key] = e; keys[#keys + 1] = key end
                e[a] = cval - oval
            end
        end
    end

    table.sort(keys)  -- 穩定輸出順序,方便測試與閱讀
    local list = {}
    for _, key in ipairs(keys) do
        local idtype, id, sub = key:match("^(%a+):(%-?%d+)%.(%-?%d+)$")
        list[#list + 1] = {
            target = offset_target(idtype, id, sub),
            pan    = byKey[key].pan,
            tilt   = byKey[key].tilt,
        }
    end
    return list
end

-- ─── 測試匯出 / 主控台進入點 ──────────────────────────────────
-- 在主控台執行時 gma 全域存在 → 回傳 Start, Cleanup。
-- 離線(本機 lua 測試)時 gma 為 nil → 匯出純函式供測試。
if gma then
    return Start, Cleanup
else
    return {
        parse_preset  = parse_preset,
        build_deltas  = build_deltas,
        offset_target = offset_target,
        fmt           = fmt,
    }
end
