-- Downgrade Export
-- Exports every pool of the running show, rewrites each file's version header
-- to a lower version, and drops the result straight into that version's onPC
-- folder - together with the Downgrade Import plugin, ready to run there.
--
-- Target version: grandMA2 3.9.60 (the high side; the import half runs on the low side)
--
-- Replaces the "Export High Show" macro from github.com/chienchuanw/gma2-macros.
-- Three things that macro could not do:
--   * it left the header editing to Notepad, once per exported file
--   * it waited a fixed 1-4 seconds per export, which a large show outruns
--   * it wrote to USB, so the files still had to be carried by hand
--
-- Console facts this relies on, all probe-verified on 3.9.60 (see
-- docs/superpowers/specs/2026-09-11-showfile-downgrade-design.md):
--   * getvar("path") answers ".../grandma/gma2_V_3.9.60" with forward slashes,
--     so the other version's tree is the same string with that segment swapped
--   * io.open can write into that other tree, and os.execute can mkdir it
--   * every export ends with </MA>, which is how a finished file is recognised
--   * one file per pool, no matter how big the show
--   * ChangeDest takes an object NUMBER, not a child index
--
-- Pure logic lives at the top and is exported when the global gma is nil:
--   lua tests/downgrade-export/test_logic.lua

local PLUGIN_TITLE = "Downgrade Export"

local M = {}

-- ─── pure logic ───────────────────────────────────────────────

function M.parse_version(s)
    if type(s) ~= "string" then return nil end
    local a, b, c = string.match(s, "^%s*(%d+)%.(%d+)%.(%d+)%s*$")
    if not a then return nil end
    return tonumber(a), tonumber(b), tonumber(c)
end

-- gma.show.getvar("VERSION") answers "3.9.60.50"; the fourth component is the
-- build number and never appears in a showfile header.
function M.normalize_version(s)
    if type(s) ~= "string" then return nil end
    local a, b, c = string.match(s, "^%s*(%d+)%.(%d+)%.(%d+)")
    if not a then return nil end
    return a .. "." .. b .. "." .. c
end

function M.version_lt(a, b)
    local a1, a2, a3 = M.parse_version(a)
    local b1, b2, b3 = M.parse_version(b)
    if not a1 or not b1 then return nil end
    if a1 ~= b1 then return a1 < b1 end
    if a2 ~= b2 then return a2 < b2 end
    return a3 < b3
end

-- Rewrites the four version fields of an MA export header and nothing else.
-- The schema pattern anchors on "/grandma2/xml/<digits>/MA.xsd" so it cannot
-- touch the xmlns that ends "/grandma2/xml/MA", and the three *_vers attributes
-- are matched by name so the <?xml version="1.0"?> declaration is never a
-- candidate. Returns nil plus a reason rather than a half-rewritten file.
function M.rewrite_header(xml, target)
    if type(xml) ~= "string" then return nil, "not a string" end
    local maj, min, str = M.parse_version(target)
    if not maj then return nil, "target version must look like 3.3.4" end

    local out, n, c = xml, 0, 0
    out, c = string.gsub(out, "(/grandma2/xml/)[%d%.]+(/MA%.xsd)", "%1" .. target .. "%2", 1)
    n = n + c
    out, c = string.gsub(out, 'major_vers="%d+"', 'major_vers="' .. maj .. '"', 1)
    n = n + c
    out, c = string.gsub(out, 'minor_vers="%d+"', 'minor_vers="' .. min .. '"', 1)
    n = n + c
    out, c = string.gsub(out, 'stream_vers="%d+"', 'stream_vers="' .. str .. '"', 1)
    n = n + c

    if n < 4 then
        return nil, string.format("header incomplete: %d of 4 fields matched", n)
    end
    return out, n
end

-- Every export the console writes ends with </MA>. Polling for that is how this
-- plugin knows a file is finished, instead of the macro's fixed delays.
function M.is_complete(xml)
    return type(xml) == "string" and string.find(xml, "</MA>%s*$") ~= nil
end

-- The console's own path carries its version, so the other version's tree is
-- the same string with that segment swapped. Only the LAST version-looking run
-- is replaced: a folder further up could carry a date like 2026.01.09.
function M.sibling_path(base, target)
    if type(base) ~= "string" then return nil end
    if not M.parse_version(target) then return nil end

    local s, e, init = nil, nil, 1
    while true do
        local a, b = string.find(base, "%d+%.%d+[%.%d]*", init)
        if not a then break end
        s, e, init = a, b, b + 1
    end
    if not s then return nil end
    return string.sub(base, 1, s - 1) .. target .. string.sub(base, e + 1)
end

-- Only "Export Root 13" was probed directly, so the folder each pool lands in is
-- expected rather than guaranteed. Checking all three known export folders costs
-- nothing - io.open on a missing file just returns nil - and the run report
-- names the folder each file was actually found in.
M.SEARCH_DIRS = { "/importexport/", "/library/", "/fixture_layers/" }

function M.candidates(name)
    local out = {}
    for _, dir in ipairs(M.SEARCH_DIRS) do
        out[#out + 1] = dir .. name .. ".xml"
    end
    return out
end

-- Export order, matching the old macro. Root numbers were read off the console;
-- the full map is in the spec. "setup" entries are not Root pools: they are
-- reached by navigating the setup tree, where the number is the object number.
M.POOLS = {
    { key = "fixturetype",   file = "FixtureType",   dir = "/library/",        setup = 3  },
    { key = "fixturelayers", file = "FixtureLayers", dir = "/fixture_layers/", setup = 4  },
    { key = "sequence",      file = "Sequence",      dir = "/importexport/",   root  = 25 },
    { key = "executorpages", file = "ExecutorPages", dir = "/importexport/",   root  = 30 },
    { key = "groups",        file = "Groups",        dir = "/importexport/",   root  = 22 },
    { key = "presets",       file = "Presets",       dir = "/importexport/",   root  = 17 },
    { key = "layouts",       file = "Layouts",       dir = "/importexport/",   root  = 38 },
    { key = "userimagepool", file = "UserImagePool", dir = "/importexport/",   root  = 8  },
    { key = "macros",        file = "Macros",        dir = "/importexport/",   root  = 13 },
    { key = "effects",       file = "Effects",       dir = "/importexport/",   root  = 24 },
    { key = "timecodes",     file = "Timecodes",     dir = "/importexport/",   root  = 35 },
    { key = "userprofiles",  file = "UserProfiles",  dir = "/importexport/",   root  = 39 },
    { key = "users",         file = "Users",         dir = "/importexport/",   root  = 40 },
}

function M.export_cmd(pool)
    if pool.root then
        return string.format('Export Root %d "%s"/o', pool.root, pool.file)
    end
    return string.format('Export * "%s"/o', pool.file)
end

-- The import plugin has to be loadable by the OLD console, so its descriptor
-- needs that console's header. Generating it beats shipping one descriptor per
-- version anyone might ever target.
function M.plugin_descriptor(target, luafile, name)
    local maj, min, str = M.parse_version(target)
    if not maj then return nil end
    return table.concat({
        '<?xml version="1.0" encoding="utf-8"?>',
        string.format('<MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' ..
            ' xmlns="http://schemas.malighting.de/grandma2/xml/MA"' ..
            ' xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA' ..
            ' http://schemas.malighting.de/grandma2/xml/%s/MA.xsd"' ..
            ' major_vers="%d" minor_vers="%d" stream_vers="%d">', target, maj, min, str),
        string.format('\t<Plugin index="0" execute_on_load="0" name="%s" luafile="%s" />',
            name, luafile),
        '</MA>',
        '',
    }, "\n")
end

-- ─── console half ─────────────────────────────────────────────

-- Root 10 is LiveSetup. The old macro used Root 11 (EditSetup), which makes DMX
-- output unstable and forces a fixture/preset type rebuild on the way out.
-- LiveSetup produced a byte-identical layers export when probed, so it is used
-- here instead. The confirm dialog still warns, because whether LiveSetup fully
-- avoids that rebuild has not been confirmed.
local SETUP_ROOT = 10

local POLL_SECONDS = 1
local EXPORT_TIMEOUT = 60

local IMPORT_NAME = "Downgrade Import"
local IMPORT_LUA = "Downgrade Import.lua"
local IMPORT_XML = "Downgrade Import.xml"
-- Where plugin .lua files live was an assumption on the first console run, and
-- installing the import half failed because of it. It is no longer assumed:
-- the folder is found by looking for this plugin's own file, so whatever
-- directory THIS was loaded from is the one the import half is written to.
local SELF_LUA = "Downgrade Export.lua"
local PLUGIN_DIR_CANDIDATES = { "/plugins/", "/plugin/", "/lua/", "/luaplugins/" }
local PLUGIN_DIR = PLUGIN_DIR_CANDIDATES[1]   -- fallback for the mkdir pass

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
    gma.gui.msgbox(PLUGIN_TITLE, msg)
    note(msg)
end

local function read_file(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local c = f:read("*a")
    f:close()
    return c
end

local function write_file(path, content)
    local f, err = io.open(path, "wb")
    if not f then return false, err end
    f:write(content)
    f:close()
    return true
end

-- cmd.exe's mkdir creates intermediate folders, and errors harmlessly when the
-- folder is already there. The return value is not trusted; the probe write is.
local function ensure_dir(path)
    call1(os.execute, 'mkdir "' .. string.gsub(path, "/", "\\") .. '"')
    local probe = path .. "/_downgrade_write_test.tmp"
    local ok, err = write_file(probe, "probe")
    if ok then os.remove(probe) end
    return ok, err
end

-- A file left over from an earlier run would satisfy the completion check
-- instantly, so the poll below would return stale content. Clear first.
local function clear_candidates(base, pool)
    for _, rel in ipairs(M.candidates(pool.file)) do
        os.remove(base .. rel)
    end
end

-- Poll until one of the candidate paths holds a file ending in </MA>. Returns
-- the content and the folder it was found in, or nil on timeout.
local function await_export(base, pool)
    local waited = 0
    while waited <= EXPORT_TIMEOUT do
        for _, rel in ipairs(M.candidates(pool.file)) do
            local c = read_file(base .. rel)
            if M.is_complete(c) then return c, rel end
        end
        call1(gma.sleep, POLL_SECONDS)
        waited = waited + POLL_SECONDS
    end
    return nil
end

-- Export one pool, wait for it, rewrite its header, write the copy across.
-- Returns a result row for the report.
local function handle_pool(base, out_base, target, pool)
    clear_candidates(base, pool)
    gma.cmd(M.export_cmd(pool))

    local content, rel = await_export(base, pool)
    if not content then
        return { key = pool.key, ok = false,
                 why = string.format("no complete file after %ds", EXPORT_TIMEOUT) }
    end

    local rewritten, err = M.rewrite_header(content, target)
    if not rewritten then
        return { key = pool.key, ok = false, why = "header rewrite failed: " .. tostring(err) }
    end

    local ok, werr = write_file(out_base .. rel, rewritten)
    if not ok then
        return { key = pool.key, ok = false, why = "write failed: " .. tostring(werr) }
    end
    return { key = pool.key, ok = true, bytes = #rewritten, where = rel }
end

-- Put the import half on the other console so the next step needs no setup.
-- The .lua is copied rather than embedded: one source of truth, and no quote
-- escaping, which has bitten this repo before.
-- Look for the import plugin's source. It is NOT reliably in the console tree:
-- plugins are commonly imported straight off a USB stick, in which case nothing
-- under gma2_V_<version>/ holds a copy, so the drives are swept too.
local function find_import_source(base)
    local internal = {}
    for _, dir in ipairs(PLUGIN_DIR_CANDIDATES) do
        local path = base .. dir .. IMPORT_LUA
        internal[#internal + 1] = path
        local c = read_file(path)
        if c then return c, path end
    end

    for letter = string.byte("D"), string.byte("Z") do
        local root = string.char(letter) .. ":/"
        for _, sub in ipairs({ "", "plugins/" }) do
            local c = read_file(root .. sub .. IMPORT_LUA)
            if c then return c, root .. sub .. IMPORT_LUA end
        end
    end

    return nil, table.concat(internal, "\n  ") .. "\n  ...and D:\\ through Z:\\, root and \\plugins"
end

-- The descriptor is the part worth automating: it is what has to carry the
-- target version's header, and hand-editing that is exactly the chore this
-- plugin exists to remove. It is written whether or not the .lua turns up, so a
-- missing source costs one file copy rather than the whole step.
local function install_import_plugin(base, out_base, target)
    local dest_dir = out_base .. PLUGIN_DIR
    ensure_dir(out_base .. string.gsub(PLUGIN_DIR, "/$", ""))

    local desc = M.plugin_descriptor(target, IMPORT_LUA, IMPORT_NAME)
    local ok, err = write_file(dest_dir .. IMPORT_XML, desc)
    if not ok then
        return false, "could not write the descriptor to " .. dest_dir .. IMPORT_XML ..
            ": " .. tostring(err)
    end

    local src, where = find_import_source(base)
    if not src then
        return false, string.format(
            "%s written, but %s was not found, so copy it in beside the descriptor.\n" ..
            "  Looked in:\n  %s", dest_dir .. IMPORT_XML, IMPORT_LUA, where)
    end

    ok, err = write_file(dest_dir .. IMPORT_LUA, src)
    if not ok then
        return false, "copying " .. where .. ": " .. tostring(err)
    end
    return true, dest_dir
end

function Start()
    gma.echo("")
    note("start")

    local base = call1(gma.show.getvar, "path") or call1(gma.show.getvar, "PATH")
    if not base then
        return fail("Could not read the console path from gma.show.getvar.")
    end

    local current = M.normalize_version(call1(gma.show.getvar, "VERSION"))

    local target = gma.textinput("Target (lower) version, e.g. 3.3.4", "3.3.4")
    if target == nil then
        gma.feedback(PLUGIN_TITLE .. ": cancelled.")
        return
    end
    target = string.match(target, "^%s*(.-)%s*$")
    if not M.parse_version(target) then
        return fail("Enter three numbers separated by dots, e.g.\n\n  3.3.4")
    end
    if current and M.version_lt(target, current) ~= true then
        return fail(string.format(
            "This console runs %s.\n\nThe target must be LOWER than that; %s is not.",
            current, target))
    end

    local out_base = M.sibling_path(base, target)
    if not out_base then
        return fail("Could not find a version to substitute in:\n\n" .. base)
    end

    -- Fail before exporting anything rather than after thirteen exports.
    for _, dir in ipairs({ M.SEARCH_DIRS[1], M.SEARCH_DIRS[2], M.SEARCH_DIRS[3], PLUGIN_DIR }) do
        local ok, err = ensure_dir(out_base .. string.gsub(dir, "/$", ""))
        if not ok then
            return fail(string.format(
                "Cannot write into the %s tree.\n\n%s\n\n%s\n\n" ..
                "Launch grandMA2 onPC %s once so it creates its folders, then retry.",
                target, out_base .. dir, tostring(err), target))
        end
    end

    if not gma.gui.confirm(PLUGIN_TITLE, string.format(
        "Export this show for %s?\n\n" ..
        "13 pools are exported and copied to:\n%s\n\n" ..
        "The run reads the setup tree, which can interrupt DMX output.\n" ..
        "Offline only.", target, out_base)) then
        gma.feedback(PLUGIN_TITLE .. ": cancelled.")
        return
    end

    gma.cmd("SelectDrive 1")

    local results = {}
    local bar = call1(gma.gui.progress.start, PLUGIN_TITLE)
    if bar then call1(gma.gui.progress.setrange, bar, 0, #M.POOLS) end

    -- The setup pools share a single navigation into the setup tree. Each one is
    -- still awaited before the destination moves, so an export cannot be cut off
    -- by the next ChangeDest.
    local done = 0
    gma.cmd("ChangeDest /")
    gma.cmd("ChangeDest " .. SETUP_ROOT)
    local first_setup = true
    for _, pool in ipairs(M.POOLS) do
        if pool.setup then
            if not first_setup then gma.cmd("ChangeDest ..") end
            first_setup = false
            gma.cmd("ChangeDest " .. pool.setup)
            note("exporting %s", pool.key)
            results[#results + 1] = handle_pool(base, out_base, target, pool)
            done = done + 1
            if bar then call1(gma.gui.progress.set, bar, done) end
        end
    end
    gma.cmd("ChangeDest /")

    for _, pool in ipairs(M.POOLS) do
        if pool.root then
            note("exporting %s", pool.key)
            results[#results + 1] = handle_pool(base, out_base, target, pool)
            done = done + 1
            if bar then call1(gma.gui.progress.set, bar, done) end
        end
    end

    if bar then call1(gma.gui.progress.stop, bar) end

    local installed, install_where = install_import_plugin(base, out_base, target)

    -- ── report ──
    local ok_count = 0
    gma.echo("")
    note("---- result ----")
    for _, r in ipairs(results) do
        if r.ok then
            ok_count = ok_count + 1
            note("  OK   %-14s %7d bytes  %s", r.key, r.bytes, r.where)
        else
            note("  FAIL %-14s %s", r.key, r.why)
        end
    end
    note("%d of %d pools written to %s", ok_count, #M.POOLS, out_base)
    if installed then
        note("%s installed into %s", IMPORT_NAME, tostring(install_where))
    else
        note("%s only partly installed:", IMPORT_NAME)
        note("  %s", tostring(install_where))
    end
    note("")
    note("Known losses, measured on a 331-fixture show:")
    note("  * views are not exported at all (86 of them did not survive)")
    note("    Layouts themselves come through intact; the views arranging them do not.")
    note("  * default values set through presets are lost (inherited claim, unverified)")
    gma.echo("")

    gma.gui.msgbox(PLUGIN_TITLE, string.format(
        "%d of %d pools exported and rewritten for %s.\n\n" ..
        "Written to:\n%s\n\n%s\n\n" ..
        "Now start grandMA2 onPC %s, create an empty show, patch a scratch\n" ..
        "dimmer, and run %s there.\n\n" ..
        "See the System Monitor for the per-pool detail.",
        ok_count, #M.POOLS, target, out_base,
        installed and (IMPORT_NAME .. " is already installed in\n" .. tostring(install_where))
                  or ("Partly installed:\n" .. tostring(install_where)),
        target, IMPORT_NAME))
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
