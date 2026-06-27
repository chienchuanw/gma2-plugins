-- Create Punch
-- 把 programmer 中「目前選定的燈具」在當前 cue 存成 dimmer full,
-- 並在其後自動插入一顆「零號 cue」把同一批燈淡降到 0,形成一個帶 fade 的 punch/bump。
-- UI 文字英文;註解中文。目標版本:grandMA2 3.9.60
--
-- 運作原理:
--   1) gma.user.getselectedexec() 取選定 executor;O.handle("Executor <號> Cue")
--      取得「當前 cue」(class CMD_CUE),O.parent() 取得 sequence。
--   2) 用內建變數 SELECTEDFIXTURESCOUNT 確認 programmer 裡確實有選定燈具。
--   3) 算「零號 cue」編號:位在「當前 cue」與「同精度下一格」的正中間。
--        d = max(1, 當前 cue 的有效小數位數)
--        zero = current + 0.5 * 10^(-d)
--      例:1→1.05、1.1→1.15、1.11→1.115。
--      當前 cue 已是 3 位小數時無法再插(sub_number 只到 /1000)→ 中止並提示。
--   4) 詢問 fade 秒數(空白=預設 1;Cancel=中止;無效輸入=退回 1)。
--   5) 送出單一指令序列:
--        At Full
--        Store Sequence <n> Cue <current> /merge /nc
--        At 0
--        Store Sequence <n> Cue <zero> Fade <seconds> /merge /nc
--        ClearAll
--      撞號一律靜默 merge,不覆蓋既有 cue 的其他內容。

local PLUGIN_TITLE = "Create Punch"

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

-- 未輸入 fade 時的預設秒數
local DEFAULT_FADE = 1

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

local O        = gma.show.getobj
local echo     = gma.echo
local feedback = gma.feedback

-- ─── 工具 ─────────────────────────────────────────────────────

local function S(v)
    if v == nil then return "nil" end
    return tostring(v)
end

local function call1(fn, ...)
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

local function dbg(msg)
    if DEBUG then echo("[" .. PLUGIN_TITLE .. "] " .. msg) end
end

-- 四捨五入到整數
local function iround(x)
    return math.floor(x + 0.5)
end

-- 把「毫單位」整數(cue 號 ×1000)格式化成乾淨的 cue 字串。
-- 去除尾端多餘的 0:1050→"1.05"、1150→"1.15"、1115→"1.115"、2000→"2"。
local function milli_to_cue(milli)
    local whole = math.floor(milli / 1000)
    local frac  = milli % 1000
    if frac == 0 then
        return tostring(whole)
    end
    local s = string.format("%03d", frac):gsub("0+$", "")
    return whole .. "." .. s
end

-- 由毫單位的小數部分推算「有效小數位數」(去尾端 0):
--   0→0(整數)、100→1、110→2、050→2、115→3、111→3
local function decimal_places(frac)
    if frac == 0 then return 0 end
    local s = string.format("%03d", frac):gsub("0+$", "")
    return #s
end

-- 解析 (sequence 編號, 當前 cue 毫單位, cue handle)
local function resolve_target(exec_handle)
    local exec_no = call1(O.number, exec_handle)
    if not exec_no then return nil end
    local cue_handle = call1(O.handle, "Executor " .. S(exec_no) .. " Cue")
    if not cue_handle then return nil end
    if S(call1(O.class, cue_handle)) ~= "CMD_CUE" then return nil end
    local cue_no = tonumber(call1(O.number, cue_handle))
    local seq_no = call1(O.number, call1(O.parent, cue_handle))
    if not cue_no or not seq_no then return nil end
    return { seq_no = seq_no, cur_milli = iround(cue_no * 1000), cue_handle = cue_handle }
end

-- 取目前選定燈具數量(讀不到回 0)
local function selected_count()
    return tonumber(call1(gma.show.getvar, "SELECTEDFIXTURESCOUNT")) or 0
end

-- 詢問 fade 秒數:Cancel→nil(中止);空白/無效→DEFAULT_FADE。
-- 回傳 (seconds_number 或 nil, cancelled_boolean)
local function ask_fade()
    local raw = gma.textinput("Fade time (seconds)", tostring(DEFAULT_FADE))
    if raw == nil then
        return nil, true  -- Cancel
    end
    raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if raw == "" then
        return DEFAULT_FADE, false
    end
    local n = tonumber(raw)
    if not n or n < 0 then
        dbg("invalid fade input " .. S(raw) .. " → default " .. S(DEFAULT_FADE))
        return DEFAULT_FADE, false
    end
    return n, false
end

-- 格式化秒數:整數用整數字串,否則保留小數(避免 "1.0")。
local function fmt_seconds(n)
    if n == math.floor(n) then
        return tostring(math.floor(n))
    end
    return tostring(n)
end

-- ─── 進入點 ───────────────────────────────────────────────────

function Start()
    -- 1) 選定 executor
    local exec = gma.user.getselectedexec()
    if not exec or exec == 0 then
        gma.gui.msgbox(PLUGIN_TITLE,
            "No executor is selected.\n\nSelect an executor that is running a cue, then run again.")
        return
    end

    -- 2) 解析當前 cue / sequence
    local t = resolve_target(exec)
    if not t then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Could not determine the current cue of the selected executor.\n\n" ..
            "Make sure the selected executor is running a cue, then try again.")
        return
    end

    -- 3) 確認 programmer 裡有選定燈具
    if selected_count() == 0 then
        gma.gui.msgbox(PLUGIN_TITLE,
            "No fixtures are selected.\n\nSelect the fixtures you want to punch, then run again.")
        return
    end

    -- 4) 算零號 cue(當前與「同精度下一格」的中點)
    local frac = t.cur_milli % 1000
    local d = math.max(1, decimal_places(frac))
    if d >= 3 then
        -- 當前 cue 已是 3 位小數,中點需要第 4 位小數,sub_number 無法表示。
        gma.gui.msgbox(PLUGIN_TITLE,
            "The current cue is already at the finest precision (3 decimals).\n\n" ..
            "Cannot insert a blackout cue after it.")
        return
    end
    local step_milli = (d == 1) and 50 or 5  -- d=1→0.05、d=2→0.005
    local cur_cue  = milli_to_cue(t.cur_milli)
    local zero_cue = milli_to_cue(t.cur_milli + step_milli)

    -- 5) 詢問 fade 秒數
    local fade, cancelled = ask_fade()
    if cancelled then
        feedback(PLUGIN_TITLE .. ": cancelled (no change).")
        return
    end
    local fade_str = fmt_seconds(fade)

    -- 6) 送出指令序列(單一指令列,以 ';' 串接確保執行順序)
    local cmd = string.format(
        "At Full; " ..
        "Store Sequence %s Cue %s /merge /nc; " ..
        "At 0; " ..
        "Store Sequence %s Cue %s Fade %s /merge /nc; " ..
        "ClearAll",
        S(t.seq_no), cur_cue,
        S(t.seq_no), zero_cue, fade_str)
    dbg("cmd = " .. cmd)
    gma.cmd(cmd)

    feedback(string.format(
        '%s: Seq %s — full stored in Cue %s, blackout stored in Cue %s (fade %ss).',
        PLUGIN_TITLE, S(t.seq_no), cur_cue, zero_cue, fade_str))
end

function Cleanup()
end

return Start, Cleanup
