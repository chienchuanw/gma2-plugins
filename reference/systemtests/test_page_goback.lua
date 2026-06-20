--*******************************************************************************************
-- This script tests the method goback (go -) for a page.
-- Page 15, Effect 10, Macro 40, Sequ 180, DmxSnapshot 370-381
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "GOBACK";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 15 /nc; page 15; label page 15 "GOB_PAG"; delete DmxSnapshot 370 thru 375 /nc; delete seq 180 /nc';
    steps =
    {
        {
            -- 'Goback' Page with Sequence (2 Cues)
            pre  = 'Fixture ' .. fixturecount[1] + 1 .. ' thru ' .. fixturecount[1] + fixturecount[2] .. ' at Full; Store Seq 180; at 42; store seq 180 /a; Assign Seq 180 at Exec 15.101; clearall; go page 15; go page 15';
            cmd  = 'Goback Page 15';
            post = 'Label DmxSnapshot 370 "GOB_PAG_1"; Label Exec 15.101 "GOB_PAG_1"; Label Seq 180 "GOB_PAG_1"; Label Page 15 "GOB_PAG_1"';
            test_dmx = true;
            test = 370;
            gold = 376; -- fixtures at full (cue 1)
        },
        {
            pre  = '';
            cmd  = 'Goback Page 15';
            post = 'Label DmxSnapshot 371 "GOB_PAG_2"; Label Exec 15.101 "GOB_PAG_2"; Label Seq 180 "GOB_PAG_2"; Label Page 15 "GOB_PAG_2"';
            test_dmx = true;
            test = 371;
            gold = 377; -- fixtures at 42 (cue 2)
        },
        {
            pre  = '';
            cmd  = 'Goback Page 15';
            post = 'Label DmxSnapshot 372 "GOB_PAG_3"; Label Exec 15.101 "GOB_PAG_3"; Label Seq 180 "GOB_PAG_3"; Label Page 15 "GOB_PAG_3"';
            cleanup = 'Delete Executor 15.101 /nc';
            test_dmx = true;
            test = 372;
            gold = 378; -- fixtures at full again (cue 1)
        },
        {
            -- 'Goback' Page with Effect
            pre  = 'Channel thru; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 10 /o; assign effect 10 /phase="0..180"; assign effect 10 at exec 15.102; clearall; go page 15';
            cmd  = 'Goback Page 15';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DmxSnapshot 373 "GOB_PAG_4"; label effect 10 "GOB_PAG_4"; label exec 15.102 "GOB_PAG_4"; label Page 15 "GOB_PAG_4"';
            cleanup = 'off page 15; Delete Executor 15.102 /nc';
            test_dmx = true;
            test = 373;
            gold = 379;
        },
        {
            -- 'Goback' Page with Macro (2 entries)
            pre  = 'store macro 1.40; store macro 1.40.1; assign macro 1.40.1 /cmd="channel thru at 10" /wait="go" /info="GOB_PAG_5.1"; store macro 1.40.2; assign macro 1.40.2 /cmd="channel thru at 20" /wait="go" /info="GOB_PAG_5.2"; assign macro 1.40 at exec 15.103; go page 15; go page 15';
            cmd  = 'Goback Page 15';
            post = 'Label DmxSnapshot 374 "GOB_PAG_5"; label macro 40 "GOB_PAG_5"; label exec 15.103 "GOB_PAG_5"; label Page 15 "GOB_PAG_5"';
            test_dmx = true;
            test = 374;
            gold = 380;
        },
        {
            pre  = '';
            cmd  = 'Goback Page 15';
            post = 'Label DmxSnapshot 375 "GOB_PAG_6"; label macro 40 "GOB_PAG_6"; label exec 15.103 "GOB_PAG_6"; label Page 15 "GOB_PAG_6"';
            cleanup = 'off page 15; page 1';
            test_dmx = true;
            test = 375;
            gold = 381;
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