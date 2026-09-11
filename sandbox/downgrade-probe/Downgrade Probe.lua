-- Downgrade Probe (v4)
-- Throwaway diagnostic for the showfile-downgrade plugin pair.
--
-- v3 walked LiveSetup but skipped the one node that mattered: its filter
-- excluded any class containing "FIXTURE", and the Layers collection is
-- CMD_FIXTURE_LAYER_COLLECT. So the layer list was never printed.
--
-- v4 does nothing but print that list, with both numbers that matter:
--   index  = position in the parent's child list (getobj.index)
--   number = what the command line addresses it by (getobj.number)
-- v3 established those differ: LiveSetup's 3rd child is named "Layers 4" and
-- ChangeDest 4 reaches it. So the old Import macro's "Delete 2" removes the
-- layer whose NUMBER is 2, not the second layer in the list.
--
-- Run this on the low-version console, in the fresh show, AFTER patching the
-- scratch dimmer. That is the only place the answer is visible.
--
-- Pure reads. No commands are executed, nothing is written except the report.

local PLUGIN_TITLE = "Downgrade Probe"
local REPORT = "/importexport/ZZProbe_report4.txt"

-- Layers hang under LiveSetup; v3 confirmed LiveSetup is Root 10 and its
-- Layers child is the one named "Layers 4".
local LIVESETUP = "Root 10"

-- Cap per layer, so a production layer with a thousand fixtures cannot flood
-- the report. The first few are enough to identify what a layer holds.
local MAX_FIXTURES = 6

local O = gma.show and gma.show.getobj

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

local function describe(h)
    return string.format("index=%-4s number=%-6s name=%-28s class=%-30s children=%s",
        tostring(call1(O.index, h)), tostring(call1(O.number, h)),
        tostring(call1(O.name, h)), tostring(call1(O.class, h)),
        tostring(call1(O.amount, h)))
end

function Start()
    gma.echo("")
    log("===== Downgrade Probe v4 =====")

    base_path = call1(gma.show.getvar, "path") or call1(gma.show.getvar, "PATH")
    log("path    = %s", tostring(base_path))
    log("version = %s", tostring(call1(gma.show.getvar, "VERSION")))
    log("show    = %s", tostring(call1(gma.show.getvar, "SHOWFILE")))
    log("")

    if not O or not O.handle then
        log("getobj.handle missing - cannot run on this console.")
        flush()
        return
    end

    local live = call1(O.handle, LIVESETUP)
    if not live then
        log("%s has no handle.", LIVESETUP)
        flush()
        return
    end

    -- Find the Layers collection by class rather than by a hardcoded index,
    -- because index and number are not the same thing here.
    local layers, layers_i
    local n = call1(O.amount, live) or 0
    log("LiveSetup children:")
    for i = 1, n do
        local child = call1(O.child, live, i)
        if child then
            log("  %s", describe(child))
            local cls = call1(O.class, child) or ""
            if cls == "CMD_FIXTURE_LAYER_COLLECT" then
                layers, layers_i = child, i
            end
        end
    end

    if not layers then
        log("")
        log("No CMD_FIXTURE_LAYER_COLLECT among LiveSetup's children.")
        flush()
        return
    end

    log("")
    log("---- THE LAYER LIST ----")
    log("Layers collection is LiveSetup child %d: %s", layers_i, describe(layers))
    log("")

    local ln = call1(O.amount, layers) or 0
    if ln == 0 then
        log("The layer list is EMPTY. If you patched the scratch dimmer, it did")
        log("not create a layer - which itself answers why the macro needs one.")
    end

    for i = 1, ln do
        local layer = call1(O.child, layers, i)
        if layer then
            log("LAYER %s", describe(layer))
            local fn = call1(O.amount, layer) or 0
            local shown = fn > MAX_FIXTURES and MAX_FIXTURES or fn
            for j = 1, shown do
                local fx = call1(O.child, layer, j)
                if fx then
                    log("    fixture %s", describe(fx))
                end
            end
            if fn > shown then
                log("    ... %d more fixtures not listed", fn - shown)
            end
        end
    end

    log("")
    log("---- HOW TO READ THIS ----")
    log("The old Import macro runs, with the destination set to the Layers list:")
    log("    Import \"FixtureLayers\" At 2   then   Delete 2")
    log("Command line numbers address objects by NUMBER, not by list position.")
    log("So 'Delete 2' removes the layer whose number= field above reads 2.")
    log("")
    log("If that is the scratch dimmer's layer, the macro is correct.")
    log("If it is anything else, the macro destroys a real layer on every run.")

    flush()

    gma.echo("")
    gma.echo("[" .. PLUGIN_TITLE .. "] report written to:")
    gma.echo("[" .. PLUGIN_TITLE .. "] " .. tostring(base_path) .. REPORT)

    if gma.gui and gma.gui.msgbox then
        pcall(gma.gui.msgbox, PLUGIN_TITLE,
            "Probe v4 finished.\n\nOpen this file in Notepad and send the text:\n\n" ..
            tostring(base_path) .. REPORT)
    end
end

function Cleanup()
end

return Start, Cleanup
