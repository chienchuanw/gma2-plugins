-- Clean Showfile
-- 依序彈出 Yes/No 對話框,詢問是否清空各個「內容」pool(Macro/Preset/Group…),
-- 先收集所有答案,最後一次確認後才批次刪除。UI 文字英文;註解中文。
-- 目標版本:grandMA2 3.9.60
--
-- 設計(經 /grill-me 討論定案):
--   1) 走訪固定、精選的「programming content」pool(不含 Patch/Fixtures/DMX)。
--   2) 每個 pool 先數數量,空的直接跳過。
--   3) 非空的 pool 用 gma.gui.confirm 顯示「Delete all <n> <label>?」的 Yes/No。
--   4) 收集所有答案,過程中不刪任何東西(collect-then-execute)。
--      任何一步按 X / 關閉對話框 → 立即中止整個 plugin,不刪任何東西。
--   5) 若全部選 No → 安靜結束;否則顯示總結確認(No/X 皆為取消)。
--   6) 確認後才批次執行 Delete;/nc 略過主控台自身的刪除確認框。
--   7) 刪除後把摘要 echo 到 System Monitor 與 feedback 行。
--
-- ⚠ 需實機驗證的假設(離線無法測試):
--   a) 數量:count_pool 以 O.handle(<pool 名>) 取 pool handle,再 O.amount() 取子物件數。
--      若某 pool 的 handle 取法不同(如 Preset 依 feature type 分池),數量可能不準;
--      此時會 fallback 成「不顯示數量、一律詢問」。
--   b) 刪除:'Delete <Type> Thru /nc' 是否清空整個 pool。Thru 無上下界時應選整個 pool 範圍。
--   c) Preset:以 feature type 1..9(Dimmer/Position/Gobo/Color/Beam/Focus/Control/Shapers/Video)
--      逐型 'Delete Preset <t>.* /nc'。若主控台有自訂 preset type 超過 9,需擴充。
--   d) 部分 pool 有無法刪除的預設物件(如 World 1、預設 View/Page),批次刪除後可能殘留
--      預設物件,屬正常;plugin 不因此報錯。
--   e) 中止:gma.gui.confirm 回傳 true=Yes、false=No。若使用者按對話框的 X / 關閉,
--      「假設」主控台回傳 nil(而非 false),plugin 據此中止整個動作。若實機 X 回傳
--      false,則 X 會等同 No(略過該 pool 繼續),而非中止 —— 此行為需實機確認。

local PLUGIN_TITLE = "Clean Showfile"

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

-- ─── 純邏輯(不依賴 gma,可離線單元測試)──────────────────────

-- 走訪順序:精選的內容 pool。preset=true 代表需依 feature type 展開。
-- obj = 用來數數量 / 取 handle 的物件名;del = Delete 指令的物件關鍵字。
local POOLS = {
    { key = "macro",    label = "macros",    obj = "Macro",    del = "Macro"    },
    { key = "preset",   label = "presets",   preset = true                      },
    { key = "group",    label = "groups",    obj = "Group",    del = "Group"    },
    { key = "sequence", label = "sequences", obj = "Sequence", del = "Sequence" },
    { key = "effect",   label = "effects",   obj = "Effect",   del = "Effect"   },
    { key = "world",    label = "worlds",    obj = "World",    del = "World"     },
    { key = "filter",   label = "filters",   obj = "Filter",   del = "Filter"   },
    { key = "layout",   label = "layouts",   obj = "Layout",   del = "Layout"   },
    { key = "view",     label = "views",     obj = "View",     del = "View"     },
    { key = "timecode", label = "timecodes", obj = "Timecode", del = "Timecode" },
    { key = "page",     label = "pages",     obj = "Page",     del = "Page"      },
}

-- Preset 的 feature type(見上方假設 c)。
local PRESET_TYPES = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

-- 「Delete all <n> <label>?」
local function prompt_text(label, count)
    return string.format("Delete all %d %s?", count, label)
end

-- 把 gma.gui.confirm 的回傳分類成動作:
--   nil  (按 X / 關閉對話框)→ "abort"  中止整個 plugin
--   true (Yes)               → "select" 標記此 pool 待刪
--   false(No)                → "skip"   略過此 pool,繼續下一個
local function classify_answer(ans)
    if ans == nil then return "abort" end
    if ans then return "select" end
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

-- 刪除後的一行摘要:「Cleaned: macros (14), effects (3)」
local function summary_text(entries)
    if #entries == 0 then return "Cleaned: nothing." end
    local parts = {}
    for i, e in ipairs(entries) do
        parts[i] = string.format("%s (%d)", e.label, e.count)
    end
    return "Cleaned: " .. table.concat(parts, ", ")
end

-- 最後總結確認框的內容。
local function confirm_text(entries)
    local lines = {}
    for i, e in ipairs(entries) do
        lines[i] = string.format("  %s (%d)", e.label, e.count)
    end
    return "About to delete:\n" .. table.concat(lines, "\n") .. "\n\nProceed?"
end

-- ─── 主控台相依部分 ───────────────────────────────────────────

local O = gma and gma.show and gma.show.getobj

local function dbg(msg)
    if DEBUG then gma.echo("[" .. PLUGIN_TITLE .. "] " .. msg) end
end

local function call1(fn, ...)
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

-- 數某個 pool 的物件數量。
-- 一般 pool:O.handle(obj) 取 pool handle → O.amount() 取子物件數。
-- Preset:逐 feature type 加總 O.amount(O.handle("Preset <t>"))。
-- 取不到 handle → 回傳 nil(呼叫端會 fallback 成「一律詢問、不顯示數量」)。
local function count_pool(pool)
    if pool.preset then
        local total, any = 0, false
        for _, t in ipairs(PRESET_TYPES) do
            local h = call1(O.handle, "Preset " .. t)
            if h then
                any = true
                total = total + (call1(O.amount, h) or 0)
            end
        end
        if not any then return nil end
        return total
    end
    local h = call1(O.handle, pool.obj)
    if not h then return nil end
    return call1(O.amount, h) or 0
end

-- gma.cmd 是非同步的,要等 plugin yield 才會被主控台處理。
-- 批次刪除後呼叫一次,確保所有 Delete 指令都被沖出處理。
local function flush()
    gma.sleep(0.05)
end

function Start()
    -- 1) 走訪各 pool,收集要刪的清單(collect-then-execute)。
    local selected = {}   -- { { pool=, label=, count= }, ... }

    for _, pool in ipairs(POOLS) do
        local count = count_pool(pool)

        -- count == nil:數不到,fallback 成一律詢問(不顯示數量)。
        -- count == 0 :空 pool,跳過不問。
        local ask, question
        if count == nil then
            ask = true
            question = string.format("Delete all %s?", pool.label)
            dbg(pool.key .. ": count unavailable, asking without count")
        elseif count > 0 then
            ask = true
            question = prompt_text(pool.label, count)
        else
            ask = false
            dbg(pool.key .. ": empty, skipped")
        end

        if ask then
            local action = classify_answer(gma.gui.confirm(PLUGIN_TITLE, question))
            if action == "abort" then
                -- 使用者按 X / 關閉對話框 → 中止整個 plugin,不刪任何東西。
                gma.feedback(PLUGIN_TITLE .. ": closed dialog, aborted (no changes).")
                return
            elseif action == "select" then
                selected[#selected + 1] = {
                    pool  = pool,
                    label = pool.label,
                    count = count or 0,   -- 數不到時記 0,摘要不至於出錯
                }
            end
            -- "skip"(No)→ 不加入,繼續下一個 pool。
        end
    end

    -- 2) 全部沒選 → 安靜結束。
    if #selected == 0 then
        gma.feedback(PLUGIN_TITLE .. ": nothing selected, no changes.")
        return
    end

    -- 3) 最後總結確認(也是唯一的中止出口:選 No = 什麼都不刪)。
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
        classify_answer = classify_answer,
        delete_commands = delete_commands,
        summary_text    = summary_text,
        confirm_text    = confirm_text,
    }
end
