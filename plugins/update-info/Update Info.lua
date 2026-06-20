-- Update Info
-- 讀取「目前選定 executor」當前 cue 的 Info 欄位,彈出輸入框(預填舊值)
-- 讓使用者編輯後寫回。UI 文字英文;註解中文。
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

local PLUGIN_TITLE = "Update Info"

-- 設 true 會把過程印到 System Monitor(除錯用)
local DEBUG = false

-- 匯出暫存檔名(每次覆蓋;用較獨特的名字避免撞到使用者的檔)
local TMP_NAME = "update_info_tmp"

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

-- 同一輪掃描 macro pool,回傳 (同名 macro 的編號或 nil, 第一個空欄位或 nil)。
-- 用 O.handle("Macro <i>")(帶編號)逐一查;這是可靠的單一 macro 取得方式。
-- 走訪到「連續空欄位」夠多即停,避免空轉一萬次(本 plugin 建立的 macro 一定
-- 落在最前面的空欄位,因此排列在前段,不會被提早中止漏掉)。
local function scan_macros(target_name)
    local existing, empty, consec_empty = nil, nil, 0
    for i = 1, 10000 do
        local h = call1(O.handle, "Macro " .. i)
        if h then
            consec_empty = 0
            if not existing and call1(O.name, h) == target_name then existing = i end
        else
            if not empty then empty = i end
            consec_empty = consec_empty + 1
            if empty and consec_empty >= 50 then break end
        end
    end
    return existing, empty
end

-- 找出本 plugin 自己在 Plugin pool 的編號(依名稱比對)。找不到回 nil。
-- 用編號呼叫(Plugin <n>)可避開「名稱含空白需引號、而引號在 macro
-- command 內是特殊字元」的問題。
local function find_self_plugin_no()
    local want = visible_name or PLUGIN_TITLE
    local consec_empty = 0
    for i = 1, 1000 do
        local h = call1(O.handle, "Plugin " .. i)
        if h then
            consec_empty = 0
            if call1(O.name, h) == want then return i end
        else
            consec_empty = consec_empty + 1
            if consec_empty >= 50 then break end
        end
    end
    return nil
end

local function ensure_self_macro()
    -- 1) 已存在同名 macro → 跳過。
    local existing, slot = scan_macros(PLUGIN_TITLE)
    if existing then
        dbg(string.format('macro "%s" already exists at %d, skip install', PLUGIN_TITLE, existing))
        return
    end
    if not slot then dbg("no empty macro slot found"); return end

    -- 2) 以「plugin 編號」組指令,避開引號問題。找不到自身編號就不建立
    --    (不要產生壞掉的空 macro)。
    local pno = find_self_plugin_no()
    if not pno then
        dbg("could not resolve own plugin number; skip macro install")
        return
    end
    local invoke = "Plugin " .. pno

    -- 3) 建立 macro、其第一行內容、標籤,然後讓非同步指令 flush。
    --    macro 內容只用 invoke(無引號、無空白),不會撞到 macro command 語法。
    gma.cmd(string.format('Store Macro %d', slot))
    gma.cmd(string.format('Store Macro %d.1', slot))
    gma.cmd(string.format('Assign Macro %d.1 /cmd="%s"', slot, invoke))
    gma.cmd(string.format('Label Macro %d "%s"', slot, PLUGIN_TITLE))
    gma.sleep(0.05)
    feedback(string.format('%s: installed macro %d -> %s ("%s").',
        PLUGIN_TITLE, slot, invoke, PLUGIN_TITLE))
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

    -- 4) 彈出輸入框(預填舊值)
    local title  = string.format("Update Info - Seq %s Cue %s", S(t.seq_no), S(t.cue_no))
    local result = gma.textinput(title, current_info)

    -- 5) Cancel(回傳 nil)= 不動作。
    --    ⚠ 注意:若主控台在按 Cancel 時回傳的是空字串而非 nil,
    --       則 Cancel 也會被當成「清空 info」。請在實機確認 Cancel 的行為。
    if result == nil then
        feedback(PLUGIN_TITLE .. ": cancelled (no change).")
        return
    end

    -- 沒變更就不寫
    if result == current_info then
        feedback(PLUGIN_TITLE .. ": info unchanged.")
        return
    end

    -- 6) 寫回。result 為空字串時即「清空」info。雙引號會破壞指令,改成單引號。
    local safe = result:gsub('"', "'")
    gma.cmd(string.format('Assign Sequence %s Cue %s /info="%s"', S(t.seq_no), S(t.cue_no), safe))
    if result == "" then
        feedback(string.format('%s: Seq %s Cue %s info cleared.',
            PLUGIN_TITLE, S(t.seq_no), S(t.cue_no)))
    else
        feedback(string.format('%s: Seq %s Cue %s info set to "%s"',
            PLUGIN_TITLE, S(t.seq_no), S(t.cue_no), safe))
    end
end

function Cleanup()
end

return Start, Cleanup
