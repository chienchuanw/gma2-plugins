-- Downgrade Import
-- Imports the pools that Downgrade Export wrote into this console's folders,
-- then removes the scratch layer that had to exist for the import to work.
--
-- Target version: whatever OLD console you are downgrading to (3.3.x upwards).
-- Keep this file Lua 5.1 compatible - it loads on consoles far older than the
-- one Downgrade Export runs on. No goto, no integer division, no table.unpack,
-- and every gma.* call goes through call1 so a function missing on an old
-- console degrades instead of raising.
--
-- Replaces the "Import Low Show" and "Import User and User Profile" macros from
-- github.com/chienchuanw/gma2-macros.
--
-- The one real behaviour change is the scratch layer. The old macro ran:
--     Import "FixtureLayers" At 2    then    Delete 2
-- Layer numbering starts at 2 on this console, so before the import the scratch
-- layer is indeed number 2. Whether it is STILL number 2 afterwards was never
-- established, and the source show's own layers occupy 2..n - so if importing
-- restores their original numbers, "Delete 2" destroys a real layer on every
-- run. This plugin records the layer list first, matches the scratch layer by
-- identity afterwards, and deletes whatever number it holds by then. That is
-- correct under either answer, and it refuses rather than guesses when the
-- match is ambiguous.
--
-- Pure logic lives at the top and is exported when the global gma is nil:
--   lua tests/downgrade-import/test_logic.lua

local PLUGIN_TITLE = "Downgrade Import"

local M = {}

-- ─── pure logic ───────────────────────────────────────────────

-- Import order, matching the old macro. It carries real dependencies: fixture
-- types before the layers built on them, groups and presets and effects before
-- the sequences that reference them, images before the layouts that show them,
-- and users last because importing them changes who is logged in.
M.IMPORT_ORDER = {
    { key = "fixturetype",   file = "FixtureType",   setup = 3, at = 2 },
    { key = "fixturelayers", file = "FixtureLayers", setup = 4, at = 2 },
    { key = "userimagepool", file = "UserImagePool", root = 8  },
    { key = "effects",       file = "Effects",       root = 24 },
    { key = "groups",        file = "Groups",        root = 22 },
    { key = "layouts",       file = "Layouts",       root = 38 },
    { key = "presets",       file = "Presets",       root = 17 },
    { key = "sequence",      file = "Sequence",      root = 25 },
    { key = "executorpages", file = "ExecutorPages", root = 30 },
    { key = "timecodes",     file = "Timecodes",     root = 35 },
    { key = "macros",        file = "Macros",        root = 13 },
    { key = "userprofiles",  file = "UserProfiles",  root = 39 },
    { key = "users",         file = "Users",         root = 40 },
}

-- /nc suppresses the import confirmation dialog. The old macro used /o, which is
-- an Export option and is not documented for Import; a plugin cannot click a
-- dialog, so the documented option is used instead.
function M.import_cmd(pool)
    if pool.root then
        return string.format('Import "%s" At Root %d /nc', pool.file, pool.root)
    end
    return string.format('Import "%s" At %d /nc', pool.file, pool.at or 2)
end

-- A layer's identity: its name plus how many children the console reports for
-- it. Both halves are read the same way before and after the import, so the
-- console's habit of over-reporting a collection by one cancels out.
function M.layer_key(name, count)
    return string.format("%s|%d", name and tostring(name) or "?", tonumber(count) or -1)
end

-- Finds the layer that was already there before the import. Returns the entry
-- from the AFTER list, so the caller deletes the number it holds now rather
-- than the one it started with. Refuses - nil plus a reason - whenever the
-- answer is not unique, because deleting the wrong layer costs production data.
function M.find_scratch(before, after)
    if type(before) ~= "table" or type(after) ~= "table" then
        return nil, "layer lists were not readable"
    end
    if #before == 0 then
        return nil, "no layer list was recorded before the import"
    end

    local wanted = {}
    for _, e in ipairs(before) do wanted[e.key] = true end

    local hits = {}
    for _, e in ipairs(after) do
        if wanted[e.key] then hits[#hits + 1] = e end
    end

    if #hits == 1 then return hits[1] end
    if #hits == 0 then
        return nil, "the pre-import layer is gone; the import appears to have replaced it"
    end
    return nil, string.format("%d layers match the pre-import one; refusing to guess", #hits)
end

-- gma.show.getobj.amount over-reports a pool collection by one, so its absolute
-- value proves nothing. Two identical consecutive reads do.
function M.settled(prev, now)
    return prev ~= nil and prev == now
end

-- ─── console half ─────────────────────────────────────────────

-- Reads go through LiveSetup, which a probe showed is populated at all times.
-- Writes go through EditSetup, which is what the old macro used and what the
-- console requires for changing the patch; EditSetup reports no children unless
-- the console is inside it, which is why it cannot serve for the reads.
local LIVE_SETUP = 10
local EDIT_SETUP = 11
local LAYERS_NUMBER = 4
local LAYER_COLLECT_CLASS = "CMD_FIXTURE_LAYER_COLLECT"

local POLL_SECONDS = 1
local IMPORT_TIMEOUT = 120
-- An import that has not started yet looks identical to one that finished, so
-- never accept "settled" before this many polls have gone by.
local MIN_POLLS = 3

local SCRATCH_HINT = "Channel ID 34567 at DMX 234.56"

-- Guarded all the way down: this file is also loaded by the offline test
-- harness, where the whole gma table is nil.
local O = gma and gma.show and gma.show.getobj

local function call1(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

local function note(fmt, ...)
    gma.echo("[" .. PLUGIN_TITLE .. "] " ..
        (select("#", ...) > 0 and string.format(fmt, ...) or fmt))
end

local function fail(msg)
    call1(gma.gui.msgbox, PLUGIN_TITLE, msg)
    note(msg)
end

local function layer_collection()
    local live = call1(O.handle, "Root " .. LIVE_SETUP)
    if not live then return nil end
    local n = call1(O.amount, live) or 0
    for i = 1, n do
        local child = call1(O.child, live, i)
        if child and call1(O.class, child) == LAYER_COLLECT_CLASS then
            return child
        end
    end
    return nil
end

-- amount over-reports by one, so the loop stops at the first index that yields
-- no handle rather than trusting the count.
local function read_layers()
    local coll = layer_collection()
    if not coll then return nil end

    local out = {}
    local n = call1(O.amount, coll) or 0
    for i = 1, n do
        local h = call1(O.child, coll, i)
        if not h then break end
        local name = call1(O.name, h)
        out[#out + 1] = {
            key = M.layer_key(name, call1(O.amount, h)),
            number = tonumber(call1(O.number, h)),
            name = name,
        }
    end
    return out
end

local function pool_amount(pool)
    if not pool.root then return nil end
    local h = call1(O.handle, "Root " .. pool.root)
    if not h then return nil end
    return call1(O.amount, h)
end

-- Issue the import, then watch the destination pool's count until it stops
-- moving. Replaces the macro's fixed 1-4 second waits, which a large show wins.
local function run_import(pool)
    local start = pool_amount(pool)
    gma.cmd(M.import_cmd(pool))

    -- A setup import has no Root pool to count, so fall back to a fixed settle.
    if start == nil then
        call1(gma.sleep, MIN_POLLS * POLL_SECONDS)
        return { key = pool.key, ok = true, why = "no count available" }
    end

    local prev, now, waited, polls = nil, start, 0, 0
    while waited < IMPORT_TIMEOUT do
        call1(gma.sleep, POLL_SECONDS)
        waited = waited + POLL_SECONDS
        polls = polls + 1
        prev, now = now, pool_amount(pool)
        if polls >= MIN_POLLS and M.settled(prev, now) then
            return { key = pool.key, ok = true, gained = (now or 0) - (start or 0) }
        end
    end
    return { key = pool.key, ok = false,
             why = string.format("count still moving after %ds", IMPORT_TIMEOUT) }
end

function Start()
    gma.echo("")
    note("start")

    if not O or not O.handle then
        return fail("gma.show.getobj is not available on this console.\n\n" ..
            "This plugin cannot verify what it is deleting, so it will not run.")
    end

    local before = read_layers()
    if not before then
        return fail("Could not read the fixture layer list.\n\n" ..
            "Expected a " .. LAYER_COLLECT_CLASS .. " under Root " .. LIVE_SETUP .. ".")
    end
    if #before == 0 then
        return fail("This show has no fixture layer.\n\n" ..
            "Patch a scratch fixture first - " .. SCRATCH_HINT .. " - using an ID\n" ..
            "and address that do not clash with the show being imported, then run\n" ..
            "this plugin again.")
    end

    local names = {}
    for _, e in ipairs(before) do
        names[#names + 1] = string.format("  %s (number %s)", tostring(e.name), tostring(e.number))
    end

    if not call1(gma.gui.confirm, PLUGIN_TITLE, string.format(
        "Import a downgraded show into THIS show?\n\n" ..
        "It should be a new, empty show. Everything in it is about to be\n" ..
        "joined by 13 imported pools, and the patch will change.\n\n" ..
        "Layers currently here:\n%s\n\n" ..
        "The layer above will be removed afterwards if it can be identified.",
        table.concat(names, "\n"))) then
        gma.feedback(PLUGIN_TITLE .. ": cancelled.")
        return
    end

    gma.cmd("SelectDrive 1")

    local results = {}
    local bar = call1(gma.gui.progress.start, PLUGIN_TITLE)
    if bar then call1(gma.gui.progress.setrange, bar, 0, #M.IMPORT_ORDER) end

    -- Both setup imports happen inside one entry into Edit Setup. Each is
    -- settled before the destination moves, so an import cannot be cut short by
    -- the next ChangeDest.
    local done = 0
    gma.cmd("ChangeDest /")
    gma.cmd("ChangeDest " .. EDIT_SETUP)
    local first_setup = true
    for _, pool in ipairs(M.IMPORT_ORDER) do
        if pool.setup then
            if not first_setup then gma.cmd("ChangeDest ..") end
            first_setup = false
            gma.cmd("ChangeDest " .. pool.setup)
            note("importing %s", pool.key)
            results[#results + 1] = run_import(pool)
            done = done + 1
            if bar then call1(gma.gui.progress.set, bar, done) end
        end
    end
    gma.cmd("ChangeDest /")

    for _, pool in ipairs(M.IMPORT_ORDER) do
        if pool.root then
            note("importing %s", pool.key)
            results[#results + 1] = run_import(pool)
            done = done + 1
            if bar then call1(gma.gui.progress.set, bar, done) end
        end
    end

    if bar then call1(gma.gui.progress.stop, bar) end

    -- ── remove the scratch layer, by identity ──
    local after = read_layers()
    local scratch, why = M.find_scratch(before, after)
    local removed = false
    if scratch then
        note("removing scratch layer %s, now at number %s",
            tostring(scratch.name), tostring(scratch.number))
        gma.cmd("ChangeDest /")
        gma.cmd("ChangeDest " .. EDIT_SETUP)
        gma.cmd("ChangeDest " .. LAYERS_NUMBER)
        gma.cmd("Delete " .. tostring(scratch.number) .. " /nc")
        gma.cmd("ChangeDest /")
        removed = true
    end

    -- ── report ──
    local ok_count = 0
    gma.echo("")
    note("---- result ----")
    for _, r in ipairs(results) do
        if r.ok then
            ok_count = ok_count + 1
            if r.gained then
                note("  OK   %-14s +%d object(s)", r.key, r.gained)
            else
                note("  OK   %-14s %s", r.key, tostring(r.why))
            end
        else
            note("  FAIL %-14s %s", r.key, r.why)
        end
    end
    note("%d of %d pools imported", ok_count, #M.IMPORT_ORDER)

    if removed then
        note("scratch layer removed.")
    else
        note("scratch layer NOT removed: %s", tostring(why))
        note("  Delete it by hand from the patch once you have checked the show.")
    end
    note("")
    note("Known losses, inherent to downgrading:")
    note("  * layouts assigned into a view disappear (views are not exported)")
    note("  * default values set through presets are lost")
    gma.echo("")

    call1(gma.gui.msgbox, PLUGIN_TITLE, string.format(
        "%d of %d pools imported.\n\n%s\n\n" ..
        "Check the System Monitor for the per-pool detail, then save the show.",
        ok_count, #M.IMPORT_ORDER,
        removed and "The scratch layer was removed."
                or ("The scratch layer was left in place:\n" .. tostring(why))))
end

function Cleanup()
end

-- ─── test export / console entry point ────────────────────────
-- On the console gma exists, so hand back the plugin entry points.
-- Offline (plain lua) gma is nil, so expose the pure functions for testing.
if gma then
    return Start, Cleanup
else
    return M
end
