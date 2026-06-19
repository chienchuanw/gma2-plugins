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

    -- 5) 空字串 = 不動作(避免誤抹原值,亦無法可靠區分 Cancel)
    if result == nil or result == "" then
        feedback(PLUGIN_TITLE .. ": no change (empty input).")
        return
    end
    if result == current_info then
        feedback(PLUGIN_TITLE .. ": info unchanged.")
        return
    end

    -- 6) 寫回。雙引號會破壞 /info="..." 指令,改成單引號。
    local safe = result:gsub('"', "'")
    gma.cmd(string.format('Assign Sequence %s Cue %s /info="%s"', S(t.seq_no), S(t.cue_no), safe))
    feedback(string.format('%s: Seq %s Cue %s info set to "%s"',
        PLUGIN_TITLE, S(t.seq_no), S(t.cue_no), safe))
end

function Cleanup()
end

return Start, Cleanup
