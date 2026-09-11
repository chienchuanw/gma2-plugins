-- Repatch Probe (v4)
-- Throwaway diagnostic. v4 has one job: find a command that removes a fixture's
-- DMX patch without raising a dialog, so the Restore macro can undo a fixture
-- that had no patch before the repatch ran.
-- Target version: grandMA2 3.9.60
--
-- "Delete Dmx u.a /nc" works, but raises the delete-method dialog once per line.
-- /nc failing to suppress that dialog is a long-standing complaint on the MA
-- forum across versions, so the answer is a different command, not a flag.
--
-- Variants are ordered by risk, safest first. Variants 1-3 are property
-- assignments on the fixture and cannot remove the fixture itself. Variant 6 is
-- the only dangerous one and is behind its own confirm, because the MA docs
-- contradict each other on it: the Dmx keyword page says "Delete [Fixture-list]"
-- unpatches, the patch page says deleting a fixture erases it along with
-- everything programmed into it. It is tested last and the fixture's existence
-- is checked afterwards.
--
-- The probe parks one nominated fixture on a scratch address before each
-- variant and reports what the patch reads back as. YOU have to watch for the
-- dialog - Lua cannot see one. Note for each variant whether a dialog appeared.

local PLUGIN_TITLE = "Repatch Probe"

-- Scratch address to park the test fixture on. Must be in an unused universe.
local TEST_ADDRESS = "99.001"

-- What the console reports for a fixture with no patch.
local UNPATCHED = "(-)"

local O = gma.show.getobj
local P = gma.show.property

local function call1(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if ok then return v end
    return nil
end

local function say(fmt, ...)
    gma.echo("[" .. PLUGIN_TITLE .. "] " ..
        (select("#", ...) > 0 and string.format(fmt, ...) or fmt))
end

local function fixture_exists(id)
    return call1(O.handle, "Fixture " .. id) ~= nil
end

local function patch_of(id)
    local h = call1(O.handle, "Fixture " .. id)
    if not h then return nil end
    return call1(P.get, h, "patch")
end

-- cmd(id, addr) returns the command under test.
local VARIANTS = {
    { label = 'Assign Fixture n /patch=0', risk = false,
      cmd = function(id) return string.format("Assign Fixture %d /patch=0", id) end },

    { label = 'Assign Fixture n /patch=   (empty value)', risk = false,
      cmd = function(id) return string.format("Assign Fixture %d /patch=", id) end },

    { label = 'Assign Fixture n /patch=None', risk = false,
      cmd = function(id) return string.format("Assign Fixture %d /patch=None", id) end },

    { label = 'Delete Dmx u.a          (no /nc)', risk = false,
      cmd = function(_, addr) return string.format("Delete Dmx %s", addr) end },

    { label = 'Delete Dmx u.a /nc      (control - known to raise the dialog)', risk = false,
      cmd = function(_, addr) return string.format("Delete Dmx %s /nc", addr) end },

    { label = 'Delete Fixture n /nc    (DANGEROUS - may erase the fixture)', risk = true,
      cmd = function(id) return string.format("Delete Fixture %d /nc", id) end },
}

-- Park the fixture on the scratch address, run one variant, report the result.
local function run_variant(v, index, id)
    say("")
    say("VARIANT %d  %s", index, v.label)

    if not fixture_exists(id) then
        say("  Fixture %d no longer exists - stopping", id)
        return false
    end

    gma.cmd(string.format("Assign Fixture %d At Dmx %s", id, TEST_ADDRESS))
    gma.sleep(0.6)
    local parked = patch_of(id)
    say("  parked at %s -> patch reads %s", TEST_ADDRESS, tostring(parked))

    local command = v.cmd(id, TEST_ADDRESS)
    say("  running: %s", command)
    gma.cmd(command)
    gma.sleep(1.2)

    local exists = fixture_exists(id)
    local after  = patch_of(id)
    say("  fixture still exists = %s", tostring(exists))
    say("  patch now            = %s", tostring(after))

    if not exists then
        say("  *** THE FIXTURE IS GONE. Press Oops on the console NOW. ***")
        return false
    end
    if after == UNPATCHED then
        say("  RESULT: unpatched. If no dialog appeared, this is the command we want.")
    elseif after == parked then
        say("  RESULT: no effect - still on the scratch address.")
    else
        say("  RESULT: unexpected value, read it above.")
    end
    return true
end

function Start()
    gma.echo("")
    say("=========== PROBE v4 BEGIN ===========")
    say("looking for an unpatch command that raises NO dialog")
    say("watch the screen: note which variants pop a dialog, Lua cannot see them")

    local fid = gma.textinput("SPARE fixture ID to unpatch repeatedly (empty = abort)", "")
    if fid == nil or fid:gsub("%s+", "") == "" then
        say("aborted - no fixture given")
        say("=========== PROBE v4 END ===========")
        return
    end
    fid = tonumber(fid:gsub("%s+", ""))
    if not fid or not fixture_exists(fid) then
        say("Fixture %s does not exist - aborting", tostring(fid))
        say("=========== PROBE v4 END ===========")
        return
    end

    local original = patch_of(fid)
    say("Fixture %d original patch = %s", fid, tostring(original))

    for i, v in ipairs(VARIANTS) do
        local go = true
        if v.risk then
            go = gma.gui.confirm(PLUGIN_TITLE, string.format(
                "Variant %d runs:\n\n  %s\n\n" ..
                "The MA documentation contradicts itself on this one. It may " ..
                "simply unpatch Fixture %d, or it may DELETE the fixture along " ..
                "with everything programmed into it.\n\n" ..
                "If the fixture disappears, press Oops immediately.\n\nRun it?",
                i, v.cmd(fid, TEST_ADDRESS), fid)) and true or false
            if not go then say(""); say("VARIANT %d %s", i, v.label); say("  declined") end
        end
        if go and not run_variant(v, i, fid) then break end
    end

    -- Put the fixture back where it started, if it survived and had an address.
    if fixture_exists(fid) then
        if original and original ~= UNPATCHED and original ~= "" then
            gma.cmd(string.format("Assign Fixture %d At Dmx %s", fid, original))
            gma.sleep(0.6)
            say("")
            say("restored Fixture %d to %s -> reads %s",
                fid, original, tostring(patch_of(fid)))
        else
            say("")
            say("Fixture %d started unpatched; it now reads %s",
                fid, tostring(patch_of(fid)))
            say("if it is still parked somewhere, clear it by hand")
        end
    end

    say("=========== PROBE v4 END ===========")
    gma.gui.msgbox(PLUGIN_TITLE,
        "Probe v4 finished.\n\nCopy the System Monitor between PROBE v4 BEGIN and END, " ..
        "and tell me WHICH variants popped a dialog - the log cannot show that.")
end

function Cleanup()
end

return Start, Cleanup
