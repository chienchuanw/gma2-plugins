-- Effect BPM Diagnostic
-- 一次性「探針」plugin:把 programmer 目前的暫存 effect 暫 store 到一個高號段
-- scratch slot,逐一 dump 出該 Effect 物件(以及它每一條 effect line)的所有
-- 屬性「名稱 = 值」到 System Monitor,再把 scratch 刪掉。
--
-- 目的:確認正式的 Halve / Double Effect BPM plugin 該讀「哪個屬性」拿到 BPM、
--       單位是不是 BPM、以及 effectBPM 是否吃小數。這台機器無法執行 grandMA2,
--       所以這支的輸出要靠你上機跑一次、把 System Monitor 內容貼回來。
--
-- 用法(實機):
--   1) 在 programmer 裡選一批 fixture、套一個 effect(例如 at form "sin"
--      at effectBPM 35),維持選取狀態。
--   2) 執行本 plugin。
--   3) 打開 System Monitor,複製所有 [Effect BPM Diagnostic] 開頭的行貼回來。
--
-- 目標版本:grandMA2 3.9.60
-- UI/輸出文字英文;註解中文。

local PLUGIN_TITLE = "Effect BPM Diagnostic"

-- scratch Effect pool slot:刻意用高號段,降低撞到既有 effect 的機率。
-- 動作前會檢查它是空的;若被占用就中止,不覆寫。
local SCRATCH_SLOT = 9999

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

local O    = gma.show.getobj
local P    = gma.show.property
local echo = gma.echo

-- ─── 工具 ─────────────────────────────────────────────────────

-- 統一加前綴輸出,方便你在 System Monitor 一眼挑出本 plugin 的行
local function log(msg)
    echo("[" .. PLUGIN_TITLE .. "] " .. (msg or ""))
end

local function S(v)
    if v == nil then return "nil" end
    return tostring(v)
end

-- 安全呼叫:回傳 (ok, value);把 gma.* 偶發的 error 吞掉不讓 plugin 中斷
local function try(fn, ...)
    local ok, v = pcall(fn, ...)
    if ok then return true, v end
    return false, nil
end

-- 把一個物件 handle 的所有屬性 dump 出來。
-- property index 在官方文件沒寫明是 0-based 還 1-based,所以從 0 掃到 amount,
-- 每個 index 都用 pcall 包住,雙基底都涵蓋,取得到名稱才印。
local function dump_properties(handle, indent)
    indent = indent or "    "
    local ok_amt, amount = try(P.amount, handle)
    if not ok_amt or not amount then
        log(indent .. "(property.amount 讀不到)")
        return
    end
    log(indent .. "property.amount = " .. S(amount))
    -- 掃 0..amount(含)以同時覆蓋 0-based 與 1-based 兩種可能
    for i = 0, amount do
        local ok_name, pname = try(P.name, handle, i)
        local ok_byidx, vbyidx = try(P.get, handle, i)
        if ok_name and pname ~= nil and pname ~= "" then
            -- 同時用「index」與「名稱」兩種方式取值,確認哪種可靠
            local ok_byname, vbyname = try(P.get, handle, pname)
            log(string.format("%s[%d] %-22s = %s   (by-name: %s)",
                indent, i, S(pname), S(vbyidx),
                ok_byname and S(vbyname) or "n/a"))
        elseif ok_byidx and vbyidx ~= nil then
            -- 沒名稱但有值,也印出來以防漏
            log(string.format("%s[%d] (no-name)             = %s", indent, i, S(vbyidx)))
        end
    end
end

-- dump 一個物件的基本身份(class / name / number / 子物件數)
local function dump_identity(handle, label)
    local _, cls  = try(O.class, handle)
    local _, name = try(O.name, handle)
    local _, num  = try(O.number, handle)
    local _, amt  = try(O.amount, handle)
    log(string.format("%s: class=%s name=%s number=%s children=%s",
        label, S(cls), S(name), S(num), S(amt)))
end

-- ─── 進入點 ───────────────────────────────────────────────────

function Start()
    log("==== start ====")

    local slot_name = "Effect " .. SCRATCH_SLOT

    -- 1) 檢查 scratch slot 是空的;被占用就中止,絕不覆寫
    local _, existing = try(O.handle, slot_name)
    if existing then
        log("ABORT: scratch slot " .. slot_name ..
            " 已被占用(handle=" .. S(existing) .. "),不覆寫。請改 SCRATCH_SLOT 後再試。")
        gma.feedback(PLUGIN_TITLE .. ": scratch slot " .. slot_name ..
            " is occupied — aborted (change SCRATCH_SLOT).")
        return
    end

    -- 2) 把 programmer 目前內容 store 成 scratch effect
    --    /nc = no confirm,避免跳出確認對話框。
    log("storing programmer -> " .. slot_name)
    gma.cmd("Store " .. slot_name .. " /nc")

    -- 3) 取得 scratch effect 的 handle
    local _, eff = try(O.handle, slot_name)
    if not eff then
        log("ABORT: store 後仍取不到 " .. slot_name ..
            " 的 handle。programmer 可能沒有任何 effect 內容。")
        gma.feedback(PLUGIN_TITLE .. ": nothing stored — is there an effect in the programmer?")
        -- 保險:即使取不到 handle 也嘗試清掉
        gma.cmd("Delete " .. slot_name .. " /nc")
        return
    end

    -- 4) dump 頂層 Effect 物件
    log("---- TOP-LEVEL EFFECT OBJECT ----")
    dump_identity(eff, "effect")
    dump_properties(eff, "    ")

    -- 5) dump 每一條 effect line(子物件;child 是 1-based)
    local _, child_amount = try(O.amount, eff)
    child_amount = child_amount or 0
    log("---- EFFECT LINES (children = " .. S(child_amount) .. ") ----")
    for i = 1, child_amount do
        local ok_c, line = try(O.child, eff, i)
        if ok_c and line then
            dump_identity(line, "  line[" .. i .. "]")
            dump_properties(line, "        ")
        else
            log("  line[" .. i .. "] (取不到 child handle)")
        end
    end

    -- 6) 清掉 scratch
    log("deleting " .. slot_name)
    gma.cmd("Delete " .. slot_name .. " /nc")

    log("==== done ==== 請把上面所有 [" .. PLUGIN_TITLE .. "] 開頭的行貼回來")
    gma.feedback(PLUGIN_TITLE .. ": done — see System Monitor, copy the output back.")
end

function Cleanup()
end

return Start, Cleanup
