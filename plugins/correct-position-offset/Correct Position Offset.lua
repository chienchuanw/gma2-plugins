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

-- ─── gma 介接(需主控台,無法離線測試)────────────────────────

-- Export 指定 position preset 並讀回 XML(沿用 Update Info 的輪詢+</MA> 偵測)。
-- 失敗回 nil。
local function export_and_read(preset_no)
    local base = gma.show.getvar("path") or gma.show.getvar("PATH")
    if not base then return nil end
    local full = base .. "/importexport/" .. TMP_NAME .. ".xml"

    gma.cmd("SelectDrive 1")          -- 確保 Export 與讀檔路徑一致(內建碟)
    os.remove(full)
    gma.cmd(string.format('Export Preset 2.%s "%s" /nc', tostring(preset_no), TMP_NAME))

    local xml
    for _ = 1, 40 do                   -- gma.cmd 為非同步,輪詢等檔寫完(最多約 2 秒)
        gma.sleep(0.05)
        local f = io.open(full, "r")
        if f then
            local c = f:read("*a"); f:close()
            if c and c:find("</MA>", 1, true) then xml = c; break end
        end
    end
    os.remove(full)
    return xml
end

-- 讀某 instance 目前的 offset(prop = "panoffset"/"tiltoffset")。讀不到回 0。
local function read_offset(target, prop)
    local h = gma.show.getobj.handle(target)
    if not h then return 0 end
    local ok, v = pcall(gma.show.property.get, h, prop)
    local n = ok and tonumber(v) or nil
    if (not n) and DEBUG then
        gma.echo(string.format("[%s] could not read %s of %s → using 0", PLUGIN_TITLE, prop, target))
    end
    return n or 0
end

-- 對每個 instance 累加 delta 並送出 Assign。回傳統計。
local function apply_offsets(deltas)
    local counts = { pan = 0, tilt = 0, instances = 0 }
    for _, e in ipairs(deltas) do
        local parts = {}
        if e.pan then
            parts[#parts + 1] = "/panoffset=" .. fmt(read_offset(e.target, "panoffset") + e.pan)
            counts.pan = counts.pan + 1
        end
        if e.tilt then
            parts[#parts + 1] = "/tiltoffset=" .. fmt(read_offset(e.target, "tiltoffset") + e.tilt)
            counts.tilt = counts.tilt + 1
        end
        if #parts > 0 then
            gma.cmd(string.format("Assign %s %s", e.target, table.concat(parts, " ")))
            counts.instances = counts.instances + 1
            if DEBUG then
                gma.echo(string.format("[%s] %s %s", PLUGIN_TITLE, e.target, table.concat(parts, " ")))
            end
        end
    end
    return counts
end

-- ─── 進入點 ───────────────────────────────────────────────────

function Start()
    if not (CONFIG.OFFSET_PAN or CONFIG.OFFSET_TILT) then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Both Pan and Tilt are disabled.\n\nEnable at least one in the CONFIG block, then run again.")
        return
    end

    local orig_no = gma.textinput("Original position preset number?", "1")
    if orig_no == nil then gma.feedback(PLUGIN_TITLE .. ": cancelled."); return end
    local corr_no = gma.textinput("Corrected position preset number?", "1")
    if corr_no == nil then gma.feedback(PLUGIN_TITLE .. ": cancelled."); return end
    orig_no = orig_no:gsub("%s+", "")
    corr_no = corr_no:gsub("%s+", "")

    local O = gma.show.getobj
    if not O.handle("Preset 2." .. orig_no) then
        gma.gui.msgbox(PLUGIN_TITLE, "Position preset 2." .. orig_no .. " does not exist."); return
    end
    if not O.handle("Preset 2." .. corr_no) then
        gma.gui.msgbox(PLUGIN_TITLE, "Position preset 2." .. corr_no .. " does not exist."); return
    end

    local oxml = export_and_read(orig_no)
    local cxml = export_and_read(corr_no)
    if not oxml or not cxml then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Failed to export/read a preset (export error).\n\nSet DEBUG=true for details.")
        return
    end

    local deltas = build_deltas(parse_preset(oxml), parse_preset(cxml), CONFIG)
    if #deltas == 0 then
        gma.gui.msgbox(PLUGIN_TITLE,
            "No fixture instances appear in both presets.\n\nNothing to apply.")
        return
    end

    local c = apply_offsets(deltas)

    gma.gui.msgbox(PLUGIN_TITLE, string.format(
        "Done.\n\nOriginal preset: 2.%s\nCorrected preset: 2.%s\n" ..
        "Instances offset: %d\nPan: %d   Tilt: %d",
        orig_no, corr_no, c.instances, c.pan, c.tilt))
    gma.feedback(string.format("%s: %d instance(s) (Pan %d, Tilt %d) from 2.%s -> 2.%s",
        PLUGIN_TITLE, c.instances, c.pan, c.tilt, orig_no, corr_no))
end

function Cleanup()
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
