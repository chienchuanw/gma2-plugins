-- Color Palette
-- 對「目前選取的混色燈」批次產生一整套命名 Color 調色盤,直接寫進 Color Preset Pool。
-- UI 文字英文;註解中文(zh-TW)。目標版本:grandMA2 3.9.60
--
-- ── 設計重點(經 grill 討論定案)─────────────────────────────
--   • 只支援「混色燈」:RGB / RGBW / CMY。純色輪燈不支援(約定:不要選進來)。
--   • 跨燈種作法(方案 C):每色同時送 R/G/B 與「互補」C/M/Y(=100−RGB),
--       每顆燈各自吸收自己有的通道 → 一次涵蓋 RGB / RGBW / CMY,免建 gel 對照表。
--       互補換算自動處理特殊色:White→CMY(0,0,0)=開白;Black→CMY(100,100,100)=趨近黑。
--   • Preset 存成 Global 模式:每個 FixtureType 各存一份值,同型號燈日後皆可套用。
--   • 只對「使用者當下選取的燈」操作,plugin 不自動改變選取。
--   • 不逐色清除:每色都明確設定全部受管 attribute(R/G/B、互補 C/M/Y、White、Amber),
--       用不到的送 0,所以前一色不會殘留;選取保持不變;跑完最後 ClearAll。
--   • 覆蓋既有 preset 前,先批次跳一次確認框。
--   • Amber emitter 一律 0(保色純);White emitter 僅 RGBW=100。
--
-- ── ⚠ 待實機驗證(第一次上機是校準測試)──────────────────────
--   #1 Global 模式的存檔方式:本檔用 STORE_OPTIONS。若存出來不是 Global,
--      請在主控台 Store Preset 的 Options 把 Preset Mode 預設設為 Global,或調整 STORE_OPTIONS。
--   #2 CMY attribute 名稱:預設 "C"/"M"/"Y"。若無效改 "Cyan"/"Magenta"/"Yellow"(見 ATTR)。
--   #3 White / Amber attribute 名稱:預設 "White"/"Amber"。
--   #4 色輪轉 Open(hybrid 混色+色輪燈):預設關閉(SET_WHEEL_OPEN=false),先把純混色跑通;
--      要啟用時把它設 true,並在主控台確認 WHEEL_OPEN_CMD 的 attribute 名與 Open 值。
--   #5/#6 讀取選取/列出涵蓋的 FixtureType:MA2 Lua 無乾淨 API,本版改用「開頭確認框 + 提醒」。

local internal_name = select(1, ...)
local visible_name  = select(2, ...)

local O        = gma.show.getobj
local echo     = gma.echo
local feedback = gma.feedback

-- ── 設定(待實機驗證的點集中在這)──────────────────────────────
local PLUGIN_TITLE = "Color Palette"

-- Store 旗標:/o 覆蓋、/nc 不跳主控台確認(我們已自行批次確認過)。見 #1。
local STORE_OPTIONS = "/o /nc"

-- attribute 名稱(見 #2 #3),若實機不符請改這裡。
local ATTR = {
    R = "R", G = "G", B = "B",          -- 加色(RGB / RGBW)
    C = "C", M = "M", Y = "Y",          -- 減色(CMY)互補
    White = "White", Amber = "Amber",   -- 額外 emitter
}

-- 色輪轉 Open(見 #4)。先關閉,純混色跑通後再啟用。
local SET_WHEEL_OPEN = false
local WHEEL_OPEN_CMD = 'Attribute "Color1" At 0'  -- Open slot,實機確認名稱與值

-- ── 調色盤資料(42 色,色相排序;w = White emitter,省略視為 0)──
-- C/M/Y 由互補自動算出(=100−RGB),不需在此列出;Amber 一律 0。
local PALETTE = {
    -- 中性 / 控溫  4.1–4.6
    { p = "4.1",  name = "White",          r = 100, g = 100, b = 100, w = 0   },
    { p = "4.2",  name = "RGBW",           r = 100, g = 100, b = 100, w = 100 },
    { p = "4.3",  name = "Black",          r = 0,   g = 0,   b = 0           },
    { p = "4.4",  name = "CTO",            r = 100, g = 75,  b = 45          },
    { p = "4.5",  name = "Deep CTO",       r = 100, g = 58,  b = 22          },
    { p = "4.6",  name = "CTB",            r = 72,  g = 86,  b = 100         },

    -- 粉彩  4.11–4.19  (色相排序)
    { p = "4.11", name = "Light Red",      r = 100, g = 64,  b = 58          },
    { p = "4.12", name = "Light Orange",   r = 100, g = 80,  b = 55          },
    { p = "4.13", name = "Straw",          r = 100, g = 88,  b = 50          },
    { p = "4.14", name = "Light Yellow",   r = 100, g = 97,  b = 70          },
    { p = "4.15", name = "Light Green",    r = 70,  g = 100, b = 70          },
    { p = "4.16", name = "Light Cyan",     r = 65,  g = 100, b = 95          },
    { p = "4.17", name = "Light Blue",     r = 64,  g = 80,  b = 100         },
    { p = "4.18", name = "Light Pink",     r = 100, g = 74,  b = 84          },
    { p = "4.19", name = "Sakura",         r = 100, g = 80,  b = 88          },

    -- 飽和  4.21–4.47  (色相排序)
    { p = "4.21", name = "Red",            r = 100, g = 0,   b = 0           },
    { p = "4.22", name = "Red Orange",     r = 100, g = 25,  b = 0           },
    { p = "4.23", name = "Orange",         r = 100, g = 45,  b = 0           },
    { p = "4.24", name = "Amber",          r = 100, g = 55,  b = 0           },
    { p = "4.25", name = "Deep Yellow",    r = 100, g = 80,  b = 0           },
    { p = "4.26", name = "Yellow",         r = 100, g = 100, b = 0           },
    { p = "4.27", name = "Lime",           r = 75,  g = 100, b = 0           },
    { p = "4.28", name = "Fern Green",     r = 55,  g = 80,  b = 20          },
    { p = "4.29", name = "Neon Green",     r = 55,  g = 100, b = 0           },
    { p = "4.30", name = "Green",          r = 0,   g = 100, b = 0           },
    { p = "4.31", name = "Forest",         r = 10,  g = 55,  b = 18          },
    { p = "4.32", name = "Sea Green",      r = 15,  g = 80,  b = 55          },
    { p = "4.33", name = "Teal",           r = 0,   g = 70,  b = 70          },
    { p = "4.34", name = "Cyan",           r = 0,   g = 100, b = 100         },
    { p = "4.35", name = "Azure",          r = 0,   g = 70,  b = 100         },
    { p = "4.36", name = "Cobalt",         r = 0,   g = 40,  b = 100         },
    { p = "4.37", name = "Blue",           r = 0,   g = 0,   b = 100         },
    { p = "4.38", name = "Congo",          r = 15,  g = 0,   b = 65          },
    { p = "4.39", name = "Lavender",       r = 70,  g = 55,  b = 100         },
    { p = "4.40", name = "Indigo",         r = 30,  g = 0,   b = 85          },
    { p = "4.41", name = "Violet",         r = 55,  g = 0,   b = 100         },
    { p = "4.42", name = "Purple",         r = 65,  g = 0,   b = 85          },
    { p = "4.43", name = "Magenta",        r = 100, g = 0,   b = 100         },
    { p = "4.44", name = "Purple Magenta", r = 85,  g = 0,   b = 80          },
    { p = "4.45", name = "Pink",           r = 100, g = 35,  b = 65          },
    { p = "4.46", name = "Deep Pink",      r = 100, g = 10,  b = 50          },
    { p = "4.47", name = "Pink Red",       r = 100, g = 15,  b = 30          },
}

-- ── 工具 ──────────────────────────────────────────────────────
local function cmd(s) gma.cmd(s) end

-- 把一個顏色寫進 programmer(同時送 RGB 與互補 CMY,與額外 emitter)
local function apply_color(c)
    local r, g, b = c.r, c.g, c.b
    -- 加色(RGB / RGBW):只影響有 R/G/B 的燈
    cmd(string.format('Attribute "%s" At %d', ATTR.R, r))
    cmd(string.format('Attribute "%s" At %d', ATTR.G, g))
    cmd(string.format('Attribute "%s" At %d', ATTR.B, b))
    -- 減色(CMY):互補值,只影響有 C/M/Y 的燈
    cmd(string.format('Attribute "%s" At %d', ATTR.C, 100 - r))
    cmd(string.format('Attribute "%s" At %d', ATTR.M, 100 - g))
    cmd(string.format('Attribute "%s" At %d', ATTR.Y, 100 - b))
    -- 額外 emitter:White 依色設定、Amber 一律 0(只影響有該 emitter 的燈)
    cmd(string.format('Attribute "%s" At %d', ATTR.White, c.w or 0))
    cmd(string.format('Attribute "%s" At 0',  ATTR.Amber))
    -- hybrid 混色+色輪燈:把色輪設 Open(預設關閉,見 #4)
    if SET_WHEEL_OPEN then cmd(WHEEL_OPEN_CMD) end
end

-- 收集已存在、會被覆蓋的目標 preset 編號
local function find_existing()
    local hits = {}
    for _, c in ipairs(PALETTE) do
        if O.handle("Preset " .. c.p) then hits[#hits + 1] = c.p end
    end
    return hits
end

-- ── 主程式 ────────────────────────────────────────────────────
function Start()
    -- 1) 開頭確認:提醒「對目前選取的燈操作,選取需涵蓋所有目標燈種」。
    --    (兼作「忘了選燈」的防呆:沒選好就在這裡取消)
    local msg = string.format(
        "Build a %d-color palette on your CURRENTLY SELECTED fixtures?\n" ..
        "Stored as Global presets at 4.1-4.47.\n" ..
        "Make sure your selection covers every target fixture type.",
        #PALETTE)
    if not gma.gui.confirm(PLUGIN_TITLE, msg) then
        feedback(PLUGIN_TITLE .. ": cancelled.")
        return
    end

    -- 2) 覆蓋偵測 + 批次確認
    local existing = find_existing()
    if #existing > 0 then
        local ok = gma.gui.confirm(
            PLUGIN_TITLE .. " - Overwrite?",
            string.format("%d preset(s) already exist and will be overwritten:\n%s\n\nContinue?",
                #existing, table.concat(existing, ", ")))
        if not ok then
            feedback(PLUGIN_TITLE .. ": cancelled (kept existing presets).")
            return
        end
    end

    -- 3) 進度條
    local total = #PALETTE
    local ph = gma.gui.progress.start(PLUGIN_TITLE)
    gma.gui.progress.setrange(ph, 0, total)

    -- 4) 逐色:寫值 → Store(Global)→ Label
    for i, c in ipairs(PALETTE) do
        gma.gui.progress.settext(ph, c.p .. "  " .. c.name)
        apply_color(c)
        cmd(string.format('Store Preset %s %s', c.p, STORE_OPTIONS))
        cmd(string.format('Label Preset %s "%s"', c.p, c.name))
        gma.gui.progress.set(ph, i)
        if i % 5 == 0 then gma.sleep(0.02) end  -- 讓出時間,避免卡 UI
    end

    gma.gui.progress.stop(ph)

    -- 5) 收乾淨 programmer
    cmd("ClearAll")

    echo(string.format("[%s] done: %d color presets written (4.1-4.47).", PLUGIN_TITLE, total))
    feedback(string.format("%s: %d color presets created.", PLUGIN_TITLE, total))
end

function Cleanup()
end

return Start, Cleanup
