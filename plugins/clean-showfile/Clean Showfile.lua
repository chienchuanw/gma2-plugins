-- Clean Showfile
-- 依序彈出 Yes/No 對話框,詢問是否清空各個「內容」pool(Macro/Preset/Group…),
-- 先收集所有答案,最後一次確認後才批次刪除。UI 文字英文;註解中文。
-- 目標版本:grandMA2 3.9.60
--
-- 設計(經 /grill-me 討論定案,實機測試後修正):
--   1) 走訪固定、精選的「programming content」pool(不含 Patch/Fixtures/DMX)。
--   2) 每個 pool 每次執行都詢問一次 gma.gui.confirm「Delete all <label>?」的 Yes/No。
--      不做數量顯示,也不跳過空 pool —— 見下方「為何不數數量」。
--   3) 收集所有答案,過程中不刪任何東西(collect-then-execute)。
--      任何一步按 X / 關閉對話框 → 立即中止整個 plugin,不刪任何東西。
--   4) 若全部選 No → 安靜結束;否則顯示總結確認(No/X 皆為取消)。
--   5) 確認後才批次執行 Delete;/nc 略過主控台自身的刪除確認框。
--   6) 刪除後把摘要 echo 到 System Monitor 與 feedback 行。
--
-- 為何不數數量(實機測試結論):
--   gma.show.getobj.handle("Macro"/"Preset 1"…) 取到的是「特定編號物件」而非
--   「pool 根」;O.amount() 回的是該物件的子數或 pool 的 slot 高水位,刪除後不會縮小。
--   結果:presets 被誤判為空而不彈窗;其他 pool 顯示的是不會更新的舊數字。
--   透過此 API 可靠地即時計數 pool 內容過於脆弱,故改為「每次都詢問、不顯示數量」——
--   如此每次執行都反映當下狀態(無任何快取),presets 也一定會被詢問。
--
-- ⚠ 仍需實機驗證的假設:
--   a) 刪除:'Delete <Type> Thru /nc' 是否清空整個 pool。Thru 無上下界時應選整個 pool 範圍。
--   b) Preset:以 feature type 1..9(Dimmer/Position/Gobo/Color/Beam/Focus/Control/Shapers/Video)
--      逐型 'Delete Preset <t>.* /nc'。若主控台有自訂 preset type 超過 9,需擴充。
--   c) 部分 pool 有無法刪除的預設物件(如 World 1、預設 View/Page),批次刪除後可能殘留
--      預設物件,屬正常;plugin 不因此報錯。刪除空 pool 亦無害(沒東西可刪)。
--   d) 中止:gma.gui.confirm 回傳 true=Yes、false=No。若使用者按對話框的 X / 關閉,
--      「假設」主控台回傳 nil(而非 false),plugin 據此中止整個動作。若實機 X 回傳
--      false,則 X 會等同 No(略過該 pool 繼續),而非中止 —— 此行為需實機確認。

local PLUGIN_TITLE = "Clean Showfile"

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

-- ─── 純邏輯(不依賴 gma,可離線單元測試)──────────────────────

-- 走訪順序:精選的內容 pool。preset=true 代表需依 feature type 展開。
-- label = 詢問 / 摘要用的複數名詞;del = Delete 指令的物件關鍵字。
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

-- Preset 的 feature type(見上方假設 b)。
local PRESET_TYPES = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

-- 「Delete all <label>?」(不顯示數量,見上方「為何不數數量」)
local function prompt_text(label)
    return string.format("Delete all %s?", label)
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

-- 刪除後的一行摘要:「Cleaned: macros, effects」
local function summary_text(entries)
    if #entries == 0 then return "Cleaned: nothing." end
    local parts = {}
    for i, e in ipairs(entries) do
        parts[i] = e.label
    end
    return "Cleaned: " .. table.concat(parts, ", ")
end

-- 最後總結確認框的內容。
local function confirm_text(entries)
    local lines = {}
    for i, e in ipairs(entries) do
        lines[i] = "  " .. e.label
    end
    return "About to delete:\n" .. table.concat(lines, "\n") .. "\n\nProceed?"
end

-- ─── 主控台相依部分 ───────────────────────────────────────────

local function dbg(msg)
    if DEBUG then gma.echo("[" .. PLUGIN_TITLE .. "] " .. msg) end
end

-- gma.cmd 是非同步的,要等 plugin yield 才會被主控台處理。
-- 批次刪除後呼叫一次,確保所有 Delete 指令都被沖出處理。
local function flush()
    gma.sleep(0.05)
end

function Start()
    -- 1) 走訪各 pool,每個都詢問一次,收集要刪的清單(collect-then-execute)。
    --    不數數量、不跳過空 pool —— 每次執行都反映當下狀態(見檔頭「為何不數數量」)。
    local selected = {}   -- { { pool=, label= }, ... }

    for _, pool in ipairs(POOLS) do
        local action = classify_answer(gma.gui.confirm(PLUGIN_TITLE, prompt_text(pool.label)))
        if action == "abort" then
            -- 使用者按 X / 關閉對話框 → 中止整個 plugin,不刪任何東西。
            gma.feedback(PLUGIN_TITLE .. ": closed dialog, aborted (no changes).")
            return
        elseif action == "select" then
            selected[#selected + 1] = { pool = pool, label = pool.label }
        end
        -- "skip"(No)→ 不加入,繼續下一個 pool。
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
