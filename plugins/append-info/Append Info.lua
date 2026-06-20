-- Append Info
-- 讀取「目前選定 executor」當前 cue 的 Info 欄位,彈出「空白」輸入框讓使用者
-- 輸入要追加的內容,並用 " / " 接在原本 info 後面寫回(append 模式)。
-- 採 append 而非預填編輯,是因為 gma.textinput 會把預填文字整段反白,
-- 一打字就覆蓋;空白輸入框 + 追加可避免這個問題。
-- UI 文字英文;註解中文。
-- 目標版本:grandMA2 3.9.60
--
-- 運作原理(經實機驗證):
--   1) gma.user.getselectedexec() 取選定 executor;O.handle("Executor <號> Cue")
--      取得「當前 cue」(class CMD_CUE),O.parent() 取得 sequence。
--   2) cue 的 Info 無法用 gma.show.property 讀,改用:
--        Export Sequence <n> "<tmp>"  → 在 importexport 產生 XML
--        io.open 讀該 XML → 解析出該 cue 的 <InfoItems><Info>文字</Info>。
--      路徑 = gma.show.getvar('path') .. "/importexport/"。
--   3) 寫回用:Assign Sequence <n> Cue <c> /info="..."。
--
-- XML 結構:
--   <Cue index="..">
--     <InfoItems><Info date="..">文字</Info></InfoItems>   (可能不存在=無 info)
--     <Number number="N" sub_number="M" />                  cue 編號 = N + M/1000
--     <CuePart .../>
--   </Cue>

local PLUGIN_TITLE = "Append Info"

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

-- 匯出暫存檔名(每次覆蓋;用較獨特的名字避免撞到使用者的檔)
local TMP_NAME = "append_info_tmp"

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

-- XML 實體還原
local function xml_unescape(s)
    if not s then return s end
    s = s:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&")
    return s
end

-- 讀整個檔案(讀不到回 nil)
local function read_file(fullpath)
    local f = io.open(fullpath, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

-- 解析 (sequence 編號, cue 編號, cue handle)
local function resolve_target(exec_handle)
    local exec_no = call1(O.number, exec_handle)
    if not exec_no then return nil end
    local cue_handle = call1(O.handle, "Executor " .. S(exec_no) .. " Cue")
    if not cue_handle then return nil end
    if S(call1(O.class, cue_handle)) ~= "CMD_CUE" then return nil end
    local cue_no = call1(O.number, cue_handle)
    local seq_no = call1(O.number, call1(O.parent, cue_handle))
    if not cue_no or not seq_no then return nil end
    return { seq_no = seq_no, cue_no = cue_no, cue_handle = cue_handle }
end

-- 從匯出的 sequence XML 中,解析出指定 cue 的 info 文字。
-- 找不到對應 cue 或該 cue 無 info → 回傳 ""。
local function parse_cue_info(xml, cue_no)
    local target = tonumber(cue_no)
    if not target then return "" end

    -- 移除自閉合的占位 cue(<Cue xsi:nil="true" />),避免 cue 區塊配對錯亂
    xml = xml:gsub('<Cue%s+xsi:nil="true"%s*/>', '')

    for block in xml:gmatch('<Cue.-</Cue>') do
        local n, sub = block:match('<Number%s+number="(%-?%d+)"%s+sub_number="(%-?%d+)"')
        if n and sub then
            local num = tonumber(n) + tonumber(sub) / 1000
            if math.abs(num - target) < 0.0005 then
                -- 注意:用 '<Info%s' 要求 Info 後接空白,以排除 <InfoItems>
                local info = block:match('<Info%s[^>]*>(.-)</Info>')
                return xml_unescape(info) or ""
            end
        end
    end
    return ""
end

-- 讀取目前 info:Export → io.open → 解析。失敗回傳 nil(代表流程出錯)。
local function read_current_info(t)
    local base = call1(gma.show.getvar, "path") or call1(gma.show.getvar, "PATH")
    if not base then dbg("no base path"); return nil end
    local full = base .. "/importexport/" .. TMP_NAME .. ".xml"

    -- 切到內建碟(drive 1)。Export 會寫到「目前 SelectDrive 選定的碟」,
    -- 但我們讀檔用的 PATH 永遠指向內建碟;若使用者選的是 USB 等其他碟,
    -- 兩者會對不上。先切到內建碟即可確保 Export 與讀檔路徑一致。
    -- (grandMA2 沒有公開「目前選定碟」的變數,故無法自動還原成原本那顆;
    --  執行後選定碟會停在內建碟。)
    gma.cmd("SelectDrive 1")

    os.remove(full)  -- 先刪舊檔,避免 Export 跳「覆蓋?」對話框
    gma.cmd(string.format('Export Sequence %s "%s"', S(t.seq_no), TMP_NAME))

    -- 重要:gma.cmd 是非同步的,命令要等 plugin yield(gma.sleep)時才被處理。
    -- 因此這裡輪詢等待匯出檔「出現且寫入完整」(含結尾 </Sequ>),最多約 2 秒。
    local xml
    for _ = 1, 40 do
        gma.sleep(0.05)
        local c = read_file(full)
        if c and c:find("</Sequ>", 1, true) then xml = c; break end
    end
    if not xml then dbg("could not read/complete " .. full); return nil end

    local info = parse_cue_info(xml, t.cue_no)
    os.remove(full)  -- 清理暫存檔
    dbg(string.format("read info for seq %s cue %s = %q", S(t.seq_no), S(t.cue_no), info))
    return info
end

-- ─── 自動安裝 macro ──────────────────────────────────────────
-- 確保 macro pool 內有一顆與本 plugin 同名的 macro,內容即「執行本 plugin」。
-- 流程:依名稱比對 → 已存在則跳過;不存在則在第一個空欄位建立。
-- 讓使用者匯入 plugin 後,自動得到一顆可放上 executor 的 macro 按鈕。
local function ensure_self_macro()
    -- 1) 依名稱比對:列舉 macro pool,已有同名 macro 就跳過。
    --    pool 根物件以 O.handle("Macro") 取得;amount/child 只會走訪「已存在」
    --    的 macro,因此不受空欄位間隔影響。
    local pool = call1(O.handle, "Macro")
    if pool then
        local n = call1(O.amount, pool) or 0
        for i = 0, n - 1 do
            local child = call1(O.child, pool, i)
            if child and call1(O.name, child) == PLUGIN_TITLE then
                dbg('macro "' .. PLUGIN_TITLE .. '" already exists, skip install')
                return
            end
        end
    end

    -- 2) 找第一個空欄位(handle 取不到即視為空欄位)。
    local slot
    for i = 1, 10000 do
        if not call1(O.handle, "Macro " .. i) then slot = i; break end
    end
    if not slot then dbg("no empty macro slot found"); return end

    -- 3) 建立 macro 及其第一行內容。內容為呼叫本 plugin。
    --    /cmd 外層已用雙引號,plugin 名稱含空白,內層改用單引號包住名稱。
    --    (grandMA2 命令列接受單引號作為字串界定符;若某些主控台版本不吃,
    --     可改成依 plugin 編號呼叫 "Plugin <num>"。)
    gma.cmd(string.format('Store Macro %d', slot))
    gma.cmd(string.format('Store Macro %d.1', slot))
    gma.cmd(string.format([[Assign Macro %d.1 /cmd="Plugin '%s'"]], slot, PLUGIN_TITLE))
    gma.cmd(string.format('Label Macro %d "%s"', slot, PLUGIN_TITLE))
    feedback(string.format('%s: installed macro %d ("%s").', PLUGIN_TITLE, slot, PLUGIN_TITLE))
end

-- ─── 進入點 ───────────────────────────────────────────────────

function Start()
    -- 0) 首次執行時,自動在 macro pool 建立同名 macro(已存在則跳過)。
    ensure_self_macro()

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

    -- 3) 讀取目前 info
    local current_info = read_current_info(t)
    if current_info == nil then
        gma.gui.msgbox(PLUGIN_TITLE,
            "Failed to read the current cue info (export/read error).\n\n" ..
            "Set DEBUG=true in the plugin for details.")
        return
    end

    -- 4) 彈出「空白」輸入框,讓使用者輸入要追加的內容。
    --    標題列顯示目前 info 作為參考(過長則截斷),但輸入框維持空白。
    local shown = current_info
    if #shown > 40 then shown = shown:sub(1, 40) .. "..." end
    local title = string.format("Append to Info - Seq %s Cue %s%s",
        S(t.seq_no), S(t.cue_no),
        (current_info ~= "") and (" (now: " .. shown .. ")") or "")
    local result = gma.textinput(title, "")

    -- 5) 空字串 = 不追加,直接結束
    if result == nil or result == "" then
        feedback(PLUGIN_TITLE .. ": no change (empty input).")
        return
    end

    -- 6) 用 " / " 把新內容接在舊 info 後面(舊 info 為空則直接用新內容)
    local SEP = " / "
    local combined = (current_info == "") and result or (current_info .. SEP .. result)

    -- 7) 寫回。雙引號會破壞 /info="..." 指令,改成單引號。
    local safe = combined:gsub('"', "'")
    gma.cmd(string.format('Assign Sequence %s Cue %s /info="%s"', S(t.seq_no), S(t.cue_no), safe))
    feedback(string.format('%s: Seq %s Cue %s info -> "%s"',
        PLUGIN_TITLE, S(t.seq_no), S(t.cue_no), safe))
end

function Cleanup()
end

return Start, Cleanup
