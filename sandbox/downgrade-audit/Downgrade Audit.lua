-- Downgrade Audit
-- Snapshots a show's contents so two downgrade routes can be compared as text
-- instead of by counting things on screen.
--
-- Run it three times - on the source show, on the show the macros produced, and
-- on the show the plugins produced - then diff the three reports. Differences
-- between the two downgraded shows are plugin bugs. Content missing from BOTH
-- is inherent to downgrading and belongs in the README, not the bug list.
--
-- Pure reads: no commands are executed and nothing in the show is touched.
-- Runs on 3.9.60 and on old consoles; everything is pcall-wrapped and the code
-- stays Lua 5.1 compatible.

local PLUGIN_TITLE = "Downgrade Audit"
local REPORT = "/importexport/ZZAudit_report.txt"

-- The thirteen pools the downgrade route moves, plus the three the old macro
-- never exported, so the report also shows what v2 would have to add.
local POOLS = {
    { root = 8,  label = "UserImagePool" },
    { root = 13, label = "Macros" },
    { root = 17, label = "Presets" },
    { root = 22, label = "Groups" },
    { root = 24, label = "Effects" },
    { root = 25, label = "Sequences" },
    { root = 30, label = "ExecutorPages" },
    { root = 35, label = "Timecodes" },
    { root = 38, label = "Layouts" },
    { root = 39, label = "UserProfiles" },
    { root = 40, label = "Users" },
    { root = 18, label = "Worlds        (not exported)" },
    { root = 19, label = "Filters       (not exported)" },
    { root = 26, label = "Timers        (not exported)" },
}

-- Views have no Root number; they are addressed one at a time.
local MAX_VIEW_SCAN = 60

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

-- getobj.amount over-reports a collection by one, so it is not comparable on its
-- own. Walking until a child handle comes back nil gives the real count.
local function true_count(h)
    if not h then return 0 end
    local reported = call1(O.amount, h) or 0
    local n = 0
    for i = 1, reported do
        if not call1(O.child, h, i) then break end
        n = n + 1
    end
    return n
end

function Start()
    gma.echo("")
    log("===== Downgrade Audit =====")

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
    log("%-30s %8s %8s", "pool", "direct", "nested")
    for _, p in ipairs(POOLS) do
        local h = call1(O.handle, "Root " .. p.root)
        if not h then
            log("%-30s %8s", p.label, "absent")
        else
            -- Most pools are a collection holding one pool, which holds the
            -- objects. Report both levels so neither shape hides a difference.
            local direct = true_count(h)
            local nested = 0
            for i = 1, direct do
                nested = nested + true_count(call1(O.child, h, i))
            end
            log("%-30s %8d %8d", p.label, direct, nested)
        end
    end

    log("")
    log("---- VIEWS (never exported by the downgrade route) ----")
    local views = 0
    local view_names = {}
    for i = 1, MAX_VIEW_SCAN do
        local h = call1(O.handle, "View " .. i)
        if h then
            views = views + 1
            view_names[#view_names + 1] = string.format("%d=%s", i, tostring(call1(O.name, h)))
        end
    end
    log("views found: %d", views)
    if views > 0 then log("  %s", table.concat(view_names, "  ")) end

    log("")
    log("---- FIXTURE LAYERS ----")
    local coll
    local live = call1(O.handle, "Root " .. LIVE_SETUP)
    if live then
        local n = call1(O.amount, live) or 0
        for i = 1, n do
            local child = call1(O.child, live, i)
            if child and call1(O.class, child) == LAYER_COLLECT_CLASS then
                coll = child
                break
            end
        end
    end

    if not coll then
        log("layer collection not found")
    else
        local total, layers = 0, true_count(coll)
        log("layers: %d", layers)
        for i = 1, layers do
            local h = call1(O.child, coll, i)
            if h then
                local fixtures = true_count(h)
                total = total + fixtures
                log("  number=%-4s fixtures=%-5d %s",
                    tostring(call1(O.number, h)), fixtures, tostring(call1(O.name, h)))
            end
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
            "Audit finished.\n\nRENAME the report before the next run so it is\n" ..
            "not overwritten, then send all three:\n\n" ..
            tostring(base_path) .. REPORT)
    end
end

function Cleanup()
end

return Start, Cleanup
