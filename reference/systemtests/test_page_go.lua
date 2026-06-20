--*******************************************************************************************
-- This script tests the method go (go +) for a page.
-- Page 14, Effect 9, Macro 39, Sequ 179, DmxSnapshot 320-330
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "GO";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 14; page 14; label page 14 "GO_PAG"; delete effect 9 /nc; delete macro 39 /nc; delete seq 179 /nc; delete DMXSnapshot 320 thru 325 /nc';
    steps =
    {
        {
            -- 'Go' Page with Sequence (2 Cues)
            pre  = 'Fixture ' .. fixturecount[1] + 1 .. ' thru ' .. fixturecount[1] + fixturecount[2] .. ' at Full; Store Seq 179; at 42; store seq 179 /a; Assign Seq 179 at Exec 14.101; Clearall';
            cmd  = 'Go Page 14';
            post = 'Label DmxSnapshot 320 "GO_PAG_1"; Label Exec 14.101 "GO_PAG_1"; Label Seq 179 "GO_PAG_1"; Label Page 14 "GO_PAG_1"';
            test_dmx = true;
            test = 320;
            gold = 326; -- fixtures at full
        },
        {
            pre  = '';
            cmd  = 'Go Page 14';
            post = 'Label DmxSnapshot 321 "GO_PAG_2"; Label Exec 14.101 "GO_PAG_2"; Label Seq 179 "GO_PAG_2"; Label Page 14 "GO_PAG_2"';
            test_dmx = true;
            test = 321;
            gold = 327; -- fixtures at 42
        },
        {
            pre  = '';
            cmd  = 'Go Page 14';
            post = 'Label DmxSnapshot 322 "GO_PAG_3"; Label Exec 14.101 "GO_PAG_3"; Label Seq 179 "GO_PAG_3"; Label Page 14 "GO_PAG_3"';
            cleanup = 'Delete Executor 14.101 /nc';
            test_dmx = true;
            test = 322;
            gold = 326; -- fixtures at full again
        },
        {
            -- 'Go' Page with Effect
            pre  = 'Channel 1 thru; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 9; assign effect 9 /phase="0..180"; assign effect 9 at exec 14.102; clearall';
            cmd  = 'Go Page 14';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DmxSnapshot 323 "GO_PAG_4"; label effect 9 "GO_PAG_4"; label exec 14.102 "GO_PAG_4"; label Page 14 "GO_PAG_4"';
            cleanup = 'off page 14; Delete Executor 14.102 /nc';
            test_dmx = true;
            test = 323;
            gold = 328;
        },
        {
            -- 'Go' Page with Macro (2 entries)
            pre  = 'store macro 1.39; store macro 1.39.1; assign macro 1.39.1 /cmd="channel thru at 10" /wait="go" /info="GO_PAG_5.1"; store macro 1.39.2; assign macro 1.39.2 /cmd="channel thru at 20" /wait="go" /info="GO_PAG_5.2"; assign macro 1.39 at exec 14.103';
            cmd  = 'Go Page 14';
            post = 'Label DmxSnapshot 324 "GO_PAG_5"; label macro 39 "GO_PAG_5"; label exec 14.103 "GO_PAG_5"; label Page 14 "GO_PAG_5"';
            test_dmx = true;
            test = 324;
            gold = 329;
        },
        {
            pre  = '';
            cmd  = 'Go Page 14';
            post = 'Label DmxSnapshot 325 "GO_PAG_6"; label macro 39 "GO_PAG_6"; label exec 14.103 "GO_PAG_6"; label Page 14 "GO_PAG_6"';
            cleanup = 'off page 14; page 1';
            test_dmx = true;
            test = 325;
            gold = 330;
        },
    };
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
    StartSingleTestScript(test);
end

return StartThisTest;