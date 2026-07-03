-- Clean Showfile
-- 依序彈出對話框,詢問是否清空各個「內容」pool(Macro/Preset/Group…),
-- 先收集所有答案,最後一次確認後才批次刪除。UI 文字英文;註解中文。
-- 目標版本:grandMA2 3.9.60
--
-- 設計(經 /grill-me 討論定案,多輪實機測試後修正):
--   1) 走訪固定、精選的「programming content」pool(不含 Patch/Fixtures/DMX)。
--   2) 每個 pool 每次執行都即時計數,並用 gma.gui.confirm 按鈕對話框詢問一次:
--        「Delete all <n> <label>?」  按 Yes = 標記待刪;按 No / 關閉 = 略過此 pool。
--   3) 收集所有答案(collect-then-execute),過程中不刪任何東西。
--   4) 若全部沒選 → 安靜結束;否則顯示總結確認,按 Cancel 即中止(這是唯一的中止出口)。
--   5) 確認後才批次執行 Delete;/nc 略過主控台自身的刪除確認框。
--   6) 刪除後把摘要 echo 到 System Monitor 與 feedback 行。
--
-- 為何用按鈕(gma.gui.confirm)而非文字輸入:
--   使用者偏好按鈕一鍵作答。gma.gui.confirm 回傳 true(Yes)或 nil(No/關閉),
--   故只有兩種結果:Yes = 標記、其他 = 略過。沒有「per-pool 中止」——要中止就在
--   最後的總結確認按 Cancel(此時什麼都還沒刪)。
--
-- 計數方式(修正「數字不更新」與「presets 顯示 0」):
--   一般 pool:O.handle("Macro"/"Group"…) 取 pool 根,走訪其 child、用 O.verify +
--   有名字才算,得到當下真實數量(不用 O.amount 的 slot 高水位,故刪除後會更新)。
--   Preset:handle "Preset <t>" 常解析成「某顆 preset(leaf,無 child)」而非 type pool,
--   直接數 child 會得 0;故改用「該 type 內某顆已存在 preset 的 parent」當 type pool 來數。
--   只有在有把握(數到 >0)時才顯示數字;數不到就不顯示數字(不再誤顯示 0)。
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
        return string.format("Delete all %d %s?", count, label)
    end
    return string.format("Delete all %s?", label)
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

-- 即時計數某個 pool。取不到 / 沒把握 → nil(詢問時不顯示數字)。
local function count_pool(pool)
    if pool.preset then
        local total, found = 0, false
        for _, t in ipairs(PRESET_TYPES) do
            -- "Preset <t>" 常解析成某顆 preset(leaf,無 child),直接數會得 0;
            -- 故優先用「該 type 內某顆已存在 preset 的 parent」當 type pool 來數。
            local c
            local item = call1(O.handle, "Preset " .. t .. ".1")
            if item then
                c = count_valid_children(call1(O.parent, item))
            end
            -- 後備:直接把 "Preset <t>" 當 pool 數(某些版本可能可行)。
            if not c or c == 0 then
                local alt = count_valid_children(call1(O.handle, "Preset " .. t))
                if alt and alt > 0 then c = alt end
            end
            dbg(string.format("preset type %d: children=%s", t, tostring(c)))
            if c and c > 0 then found = true; total = total + c end
        end
        -- 只有數到 >0 才回傳數字;否則回 nil,避免像舊版誤顯示 0。
        if found then return total end
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

        if gma.gui.confirm(PLUGIN_TITLE, prompt_text(pool.label, count)) then
            selected[#selected + 1] = { pool = pool, label = pool.label, count = count }
        end
        -- 未按 Yes(No / 關閉)→ 略過此 pool。要中止請在最後的總結確認按 Cancel。
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
        delete_commands = delete_commands,
        summary_text    = summary_text,
        confirm_text    = confirm_text,
    }
end
