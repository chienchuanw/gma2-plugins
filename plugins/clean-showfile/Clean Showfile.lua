-- Clean Showfile
-- 依序彈出對話框,詢問是否清空各個「內容」pool(Macro/Preset/Group…),
-- 先收集所有答案,最後一次確認後才批次刪除。UI 文字英文;註解中文。
-- 目標版本:grandMA2 3.9.60
--
-- 設計(經 /grill-me 討論定案,兩輪實機測試後修正):
--   1) 走訪固定、精選的「programming content」pool(不含 Patch/Fixtures/DMX)。
--   2) 每個 pool 每次執行都即時計數,並用 gma.textinput 詢問一次:
--        「Delete all <n> <label>?  (yes / no / cancel)」  預填 "no"。
--      yes = 標記待刪;no(或 Enter / 空白)= 略過此 pool;cancel = 中止整個 plugin。
--   3) 收集所有答案(collect-then-execute),過程中不刪任何東西。
--   4) 若全部沒選 → 安靜結束;否則顯示總結確認(OK = 執行,Cancel = 中止)。
--   5) 確認後才批次執行 Delete;/nc 略過主控台自身的刪除確認框。
--   6) 刪除後把摘要 echo 到 System Monitor 與 feedback 行。
--
-- 為何用 gma.textinput 而非 gma.gui.confirm(實機 + 官方 API 參考結論):
--   gma.gui.confirm 只回傳 true(OK)或 nil(其他),無法區分「No(略過)」與
--   「Cancel(中止)」,gma.gui 也沒有三按鈕對話框。要提供 yes/no/cancel 三種結果、
--   且 Enter 預設為 No,只能用 textinput 預填 "no":Enter 送出 "no" = 略過,
--   打 "yes" = 刪除,打 "cancel"(或按對話框 Cancel = nil)= 中止。
--
-- 計數方式(修正舊版「數字不更新」的問題):
--   舊版直接用 O.amount(pool) 當數量,但那是 pool 的 slot 高水位,刪除後不會縮小,
--   故顯示的是舊數字;presets 又因 handle 取法不同而被誤判為 0。
--   改為「走訪 pool 的每個 child、用 O.verify + 有名字才算」,得到當下真實數量;
--   presets 額外往下遞迴一層(pool → 各 feature type → 各 preset)。
--
-- ⚠ 仍需實機驗證的假設:
--   a) 計數:O.handle("Macro"/"Group"…) 取到的是該 pool 根、其 child 即為物件。
--      若某 pool 取法不同,計數回 nil → 詢問時不顯示數字(功能不受影響)。
--   b) Preset 計數 / 刪除的 feature type 假設為 1..9
--      (Dimmer/Position/Gobo/Color/Beam/Focus/Control/Shapers/Video);自訂型別需擴充。
--   c) 刪除:'Delete <Type> Thru /nc' 清空整個 pool;'Delete Preset <t>.* /nc' 清空該型。
--   d) 部分 pool 有無法刪除的預設物件(如 World 1、預設 View/Page),批次刪除後可能殘留,
--      屬正常;刪除空 pool 亦無害(沒東西可刪)。
--   若計數看起來不對,把下方 DEBUG 設 true,執行一次後看 System Monitor 回報實際數字。

local PLUGIN_TITLE = "Clean Showfile"

-- 設 true 會把計數與指令印到 System Monitor(除錯用)
local DEBUG = false

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

-- ─── 純邏輯(不依賴 gma,可離線單元測試)──────────────────────

-- 走訪順序:精選的內容 pool。preset=true 代表需依 feature type 展開。
-- label = 詢問 / 摘要用的複數名詞;del = Delete 指令與 handle 查詢用的物件關鍵字。
local POOLS = {
    { key = "macro",    label = "macros",    del = "Macro"    },
    { key = "preset",   label = "presets",   preset = true    },
    { key = "group",    label = "groups",    del = "Group"    },
    { key = "sequence", label = "sequences", del = "Sequence" },
    { key = "effect",   label = "effects",   del = "Effect"   },
    { key = "world",    label = "worlds",    del = "World"    },
    { key = "filter",   label = "filters",   del = "Filter"   },
    { key = "layout",   label = "layouts",   del = "Layout"   },
    { key = "view",     label = "views",     del = "View"     },
    { key = "timecode", label = "timecodes", del = "Timecode" },
    { key = "page",     label = "pages",     del = "Page"     },
}

-- Preset 的 feature type(見假設 b)。
local PRESET_TYPES = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

-- 詢問文字。count 為 nil(數不到)時不顯示數字。
local function prompt_text(label, count)
    if count then
        return string.format("Delete all %d %s?  (yes / no / cancel)", count, label)
    end
    return string.format("Delete all %s?  (yes / no / cancel)", label)
end

-- 把 textinput 的回傳(字串或 nil)解析成動作:
--   "yes"/"y"          → "select" 標記待刪
--   "cancel"/"c" 或 nil → "abort"  中止整個 plugin
--   其他(含 "no"、空白) → "skip"   略過此 pool(Enter 預填 "no" 即走這條)
local function parse_answer(input)
    if input == nil then return "abort" end
    local s = input:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if s == "yes" or s == "y" then return "select" end
    if s == "cancel" or s == "c" then return "abort" end
    return "skip"
end

-- 回傳某個 pool 要執行的 Delete 指令清單(preset 會展開成多條)。
local function delete_commands(pool)
    if pool.preset then
        local cmds = {}
        for i, t in ipairs(PRESET_TYPES) do
            cmds[i] = string.format("Delete Preset %d.* /nc", t)
        end
        return cmds
    end
    return { string.format("Delete %s Thru /nc", pool.del) }
end

-- 單一項目在摘要 / 確認框的顯示(有數字才附上)。
local function fmt_entry(e)
    if e.count then return string.format("%s (%d)", e.label, e.count) end
    return e.label
end

-- 刪除後的一行摘要:「Cleaned: macros (14), effects (3)」
local function summary_text(entries)
    if #entries == 0 then return "Cleaned: nothing." end
    local parts = {}
    for i, e in ipairs(entries) do
        parts[i] = fmt_entry(e)
    end
    return "Cleaned: " .. table.concat(parts, ", ")
end

-- 最後總結確認框的內容。
local function confirm_text(entries)
    local lines = {}
    for i, e in ipairs(entries) do
        lines[i] = "  " .. fmt_entry(e)
    end
    return "About to delete:\n" .. table.concat(lines, "\n") .. "\n\nProceed?"
end

-- ─── 主控台相依部分 ───────────────────────────────────────────

local O = gma and gma.show and gma.show.getobj

local function dbg(msg)
    if DEBUG then gma.echo("[" .. PLUGIN_TITLE .. "] " .. msg) end
end

local function call1(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

-- 走訪一個 handle 的所有 child,回傳「當下有效(verify 通過且有名字)」的數量。
-- child index 的基準(0 或 1)因物件而異,故多掃一格並靠 verify 過濾無效 index。
-- handle 為 nil → 回傳 nil(呼叫端據此不顯示數字)。
local function count_valid_children(h)
    if not h then return nil end
    local slots = call1(O.amount, h)
    if not slots then return nil end
    local n = 0
    for i = 0, slots do
        local ch = call1(O.child, h, i)
        if ch and ch ~= 0 and call1(O.verify, ch) then
            local nm = call1(O.name, ch)
            if nm and nm ~= "" then n = n + 1 end
        end
    end
    return n
end

-- 即時計數某個 pool。取不到 → nil。
local function count_pool(pool)
    if pool.preset then
        -- 嘗試 1:逐 feature type 的 pool 直接數 child。
        local total, seen = 0, false
        for _, t in ipairs(PRESET_TYPES) do
            local c = count_valid_children(call1(O.handle, "Preset " .. t))
            if c then seen = true; total = total + c end
        end
        if seen and total > 0 then return total end
        -- 嘗試 2:整個 Preset pool,其 child 可能是 type pool,再往下數一層。
        local root = call1(O.handle, "Preset")
        if root then
            local slots = call1(O.amount, root)
            if slots then
                local sum, any = 0, false
                for i = 0, slots do
                    local child = call1(O.child, root, i)
                    if child and call1(O.verify, child) then
                        any = true
                        sum = sum + (count_valid_children(child) or 0)
                    end
                end
                if any then return sum end
            end
        end
        if seen then return total end   -- 兩種方式都存在但為 0
        return nil
    end
    return count_valid_children(call1(O.handle, pool.del))
end

-- gma.cmd 是非同步的,要等 plugin yield 才會被主控台處理。
-- 批次刪除後呼叫一次,確保所有 Delete 指令都被沖出處理。
local function flush()
    gma.sleep(0.05)
end

function Start()
    -- 1) 走訪各 pool,即時計數 + 詢問,收集要刪的清單(collect-then-execute)。
    local selected = {}   -- { { pool=, label=, count= }, ... }

    for _, pool in ipairs(POOLS) do
        local count = count_pool(pool)
        dbg(string.format("%s: count = %s", pool.key, tostring(count)))

        local answer = gma.textinput(prompt_text(pool.label, count), "no")
        local action = parse_answer(answer)

        if action == "abort" then
            -- cancel / 關閉對話框 → 中止整個 plugin,不刪任何東西。
            gma.feedback(PLUGIN_TITLE .. ": cancelled, no changes.")
            return
        elseif action == "select" then
            selected[#selected + 1] = { pool = pool, label = pool.label, count = count }
        end
        -- "skip"(no / Enter)→ 不加入,繼續下一個 pool。
    end

    -- 2) 全部沒選 → 安靜結束。
    if #selected == 0 then
        gma.feedback(PLUGIN_TITLE .. ": nothing selected, no changes.")
        return
    end

    -- 3) 最後總結確認(OK = 執行,Cancel = 中止)。
    if not gma.gui.confirm(PLUGIN_TITLE, confirm_text(selected)) then
        gma.feedback(PLUGIN_TITLE .. ": cancelled at summary, no changes.")
        return
    end

    -- 4) 批次執行刪除。
    for _, s in ipairs(selected) do
        for _, cmd in ipairs(delete_commands(s.pool)) do
            dbg("cmd: " .. cmd)
            gma.cmd(cmd)
        end
    end
    flush()   -- 沖出所有 Delete 指令

    -- 5) 摘要回饋。
    local msg = summary_text(selected)
    gma.feedback(PLUGIN_TITLE .. ": " .. msg)
    gma.echo(PLUGIN_TITLE .. ": " .. msg)
end

function Cleanup()
end

-- ─── 測試匯出 / 主控台進入點 ──────────────────────────────────
-- 主控台執行時 gma 全域存在 → 回傳 Start, Cleanup。
-- 離線(本機 lua 測試)時 gma 為 nil → 匯出純函式供測試。
if gma then
    return Start, Cleanup
else
    return {
        POOLS           = POOLS,
        PRESET_TYPES    = PRESET_TYPES,
        prompt_text     = prompt_text,
        parse_answer    = parse_answer,
        delete_commands = delete_commands,
        summary_text    = summary_text,
        confirm_text    = confirm_text,
    }
end
