-- Downgrade Audit (v2)
-- Snapshots a show's contents so two downgrade routes can be compared as text
-- instead of by counting things on screen.
--
-- Run it on the source show, on the show the macros produced, and on the show
-- the plugins produced, then diff the three reports. Differences between the
-- two downgraded shows are plugin bugs. Content missing from BOTH is inherent
-- to downgrading and belongs in the README, not the bug list.
--
-- v1 counted pools by walking "Root <n>" children from index 1 and trusting
-- getobj.amount. That reported zero for almost every pool. Clean Showfile had
-- already solved this: the child index base is 0 for some objects and 1 for
-- others, invalid slots have to be filtered with getobj.verify, and the pools
-- answer to their object keyword ("Macro", "Group", ...) rather than to their
-- Root number. v2 uses that method and reports both addressing routes, so a
-- disagreement between them is visible rather than silently wrong.
--
-- Pure reads: no commands are executed and nothing in the show is touched.
-- Lua 5.1 compatible, everything pcall-wrapped, runs on old consoles too.

local PLUGIN_TITLE = "Downgrade Audit"
local REPORT = "/importexport/ZZAudit_report.txt"

-- keyword = how the command line addresses the pool; root = its Root number.
-- Pools the downgrade route moves, then the ones the old macro never exported.
local POOLS = {
    { label = "Macros",        keyword = "Macro",       root = 13 },
    { label = "Groups",        keyword = "Group",       root = 22 },
    { label = "Sequences",     keyword = "Sequence",    root = 25 },
    { label = "Effects",       keyword = "Effect",      root = 24 },
    { label = "Layouts",       keyword = "Layout",      root = 38 },
    { label = "Timecodes",     keyword = "Timecode",    root = 35 },
    { label = "ExecutorPages", keyword = "Page",        root = 30 },
    { label = "UserImagePool", keyword = "Image",       root = 8  },
    { label = "UserProfiles",  keyword = "UserProfile", root = 39 },
    { label = "Users",         keyword = "User",        root = 40 },
    { label = "Worlds     (x)", keyword = "World",      root = 18 },
    { label = "Filters    (x)", keyword = "Filter",     root = 19 },
    { label = "Timers     (x)", keyword = "Timer",      root = 26 },
    { label = "Views      (x)", keyword = "View",       root = nil },
}

local PRESET_TYPES = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }

local MAX_VIEW_SCAN = 80
local LIVE_SETUP = 10
local LAYER_COLLECT_CLASS = "CMD_FIXTURE_LAYER_COLLECT"

local O = gma and gma.show and gma.show.getobj

local function call1(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

local lines = {}
local base_path

local function flush()
    if not base_path or not io or not io.open then return end
    local ok, f = pcall(io.open, base_path .. REPORT, "w")
    if not ok or not f then return end
    pcall(function() f:write(table.concat(lines, "\n")) end)
    pcall(function() f:close() end)
end

local function log(fmt, ...)
    local line = fmt
    if select("#", ...) > 0 then
        local ok, s = pcall(string.format, fmt, ...)
        line = ok and s or fmt
    end
    lines[#lines + 1] = line
    gma.echo("[" .. PLUGIN_TITLE .. "] " .. line)
end

-- Borrowed wholesale from Clean Showfile: scan one slot past the reported
-- amount because the index base varies by object, and let verify plus a
-- non-empty name decide which slots are real.
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

local function valid_children(h)
    local out = {}
    if not h then return out end
    local slots = call1(O.amount, h) or 0
    for i = 0, slots do
        local ch = call1(O.child, h, i)
        if ch and ch ~= 0 and call1(O.verify, ch) then
            local nm = call1(O.name, ch)
            if nm and nm ~= "" then out[#out + 1] = ch end
        end
    end
    return out
end

local function fmt(n)
    if n == nil then return "-" end
    return tostring(n)
end

-- Most pools are a collection holding one pool holding the objects, so the
-- interesting number is one level down. Report both and let the diff decide.
local function root_counts(root)
    if not root then return nil, nil end
    local h = call1(O.handle, "Root " .. root)
    if not h then return nil, nil end
    local kids = valid_children(h)
    local nested = 0
    for _, ch in ipairs(kids) do
        nested = nested + (count_valid_children(ch) or 0)
    end
    return #kids, nested
end

function Start()
    gma.echo("")
    log("===== Downgrade Audit v2 =====")

    base_path = call1(gma.show.getvar, "path") or call1(gma.show.getvar, "PATH")
    log("path    = %s", tostring(base_path))
    log("version = %s", tostring(call1(gma.show.getvar, "VERSION")))
    log("show    = %s", tostring(call1(gma.show.getvar, "SHOWFILE")))

    if not O or not O.handle then
        log("gma.show.getobj is unavailable; cannot audit.")
        flush()
        return
    end

    log("")
    log("---- POOL COUNTS ----")
    log("(x) = never exported by the downgrade route")
    log("%-18s %10s %10s %10s", "pool", "byKeyword", "rootDirect", "rootNested")
    for _, p in ipairs(POOLS) do
        local kw = count_valid_children(call1(O.handle, p.keyword))
        local d, n = root_counts(p.root)
        log("%-18s %10s %10s %10s", p.label, fmt(kw), fmt(d), fmt(n))
    end

    -- "Preset <type>" resolves to a single preset rather than the type's pool,
    -- so count the pool through the parent of a known member instead.
    log("")
    log("---- PRESETS BY TYPE ----")
    local preset_total = 0
    for _, t in ipairs(PRESET_TYPES) do
        local c
        local item = call1(O.handle, "Preset " .. t .. ".1")
        if item then c = count_valid_children(call1(O.parent, item)) end
        if not c or c == 0 then
            local alt = count_valid_children(call1(O.handle, "Preset " .. t))
            if alt and alt > 0 then c = alt end
        end
        log("  type %d: %s", t, fmt(c))
        if c then preset_total = preset_total + c end
    end
    log("preset total: %d", preset_total)

    log("")
    log("---- VIEWS (never exported) ----")
    local names = {}
    for i = 1, MAX_VIEW_SCAN do
        local h = call1(O.handle, "View " .. i)
        if h then
            names[#names + 1] = string.format("%d=%s", i, tostring(call1(O.name, h)))
        end
    end
    log("views found: %d", #names)
    if #names > 0 then log("  %s", table.concat(names, "  ")) end

    log("")
    log("---- FIXTURE LAYERS ----")
    local coll
    local live = call1(O.handle, "Root " .. LIVE_SETUP)
    if live then
        for _, ch in ipairs(valid_children(live)) do
            if call1(O.class, ch) == LAYER_COLLECT_CLASS then coll = ch break end
        end
    end

    if not coll then
        log("layer collection not found")
    else
        local layers = valid_children(coll)
        local total = 0
        log("layers: %d", #layers)
        for _, h in ipairs(layers) do
            local fixtures = count_valid_children(h) or 0
            total = total + fixtures
            log("  number=%-4s fixtures=%-5d %s",
                tostring(call1(O.number, h)), fixtures, tostring(call1(O.name, h)))
        end
        log("fixtures across all layers: %d", total)
    end

    log("")
    log("===== end =====")
    flush()

    gma.echo("")
    gma.echo("[" .. PLUGIN_TITLE .. "] report written to:")
    gma.echo("[" .. PLUGIN_TITLE .. "] " .. tostring(base_path) .. REPORT)

    if gma.gui and gma.gui.msgbox then
        pcall(gma.gui.msgbox, PLUGIN_TITLE,
            "Audit v2 finished.\n\nRENAME the report before the next run so it\n" ..
            "is not overwritten:\n\n" .. tostring(base_path) .. REPORT)
    end
end

function Cleanup()
end

return Start, Cleanup
