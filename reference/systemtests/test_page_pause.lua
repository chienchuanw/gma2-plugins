--*******************************************************************************************
-- This script tests the method to pause a page.
-- Page 18+90, DMXSnapshot 260-262+265-26, Seq 185+186, Effect 11, Macro 41
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "PAUSE";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 18 /nc; page 18; delete seq 185+186 /nc; delete effect 11 /nc; delete macro 41 /nc; delete DmxSnapshot 260 thru 262';
    steps =
    {
        {
            -- 'Pause' Crossfade between two cues
            pre  = 'fixture thru at 0; store seq 185; at 1; store seq 185 time 2 /a; assign seq 185 Cue 2 /trig=follow; assign seq 185 at exec 18.101; clearall; go exec 18.101';
            pre_func = function () gma.echo('sleeping for 1.2 seconds'); gma.sleep(1.2); gma.echo('done'); end;
            cmd  = 'pause page 18'; -- stop 2 sec crossfade at 1.2 seconds (DMX-Output = '1' at a Range from 0 to 255)
            post = 'label sequence 185 "PAU_PAG_1"; label executor 18.101 "PAU_PAG_1"; label DmxSnapshot 207 "PAU_PAG_1"; label page 18 "PAU_PAG_1"';
            cleanup = '';
            test_dmx = true;
            test = 260;
            gold = 265;
            --[[
                Crossfade from 2 seconds is set, so within 2 seconds we increment the DMX Value by 1% = 2,56 Bits
                DMX-Outputvalue should be '1' from 0.8 to 1.6 seconds. To be sure we don't get timing problems we test in the middle of the time (1.2 seconds).
            ]]
        },
        {
            -- 'Pause' Chase Exec
            pre  = 'channel 1 zero channel 2 full; store seq 186; channel 1 full channel 2 zero; store seq 186 /a; assign seq 186 /trigTime=1; assign seq 186 at exec 18.102; assign exec 18.102 /chaser=on; go exec 18.102';
            pre_func = function () gma.echo('sleeping for 0.5 seconds'); gma.sleep(0.5); gma.echo('done'); end;
            cmd  = 'pause page 18'; -- Stop at first Cue
            post_func = function () gma.echo('sleeping for 1 seconds'); gma.sleep(1); gma.echo('done'); end;
            post = 'label DMXsnapshot 208 "PAU_PAG_2"; label seq 186 "PAU_PAG_2"; label exec 18.102 "PAU_PAG_2"; label page 18 "PAU_PAG_2"';
            cleanup = 'delete exec 18.101 /nc; delete exec 18.102 /nc';
            test_dmx = true;
            test = 261;
            gold = 266;
        },
        {
            -- 'Pause' Macro
            pre  = 'store macro 1.41; store macro 1.41.1; assign macro 1.41.1 /cmd="channel thru at 25" /wait=1 /info="PAU_PAG_3.1"; store macro 1.41.2; assign macro 1.41.2 /cmd="channel thru at 100" /wait=0.25 /info="PAU_PAG_3.2"; assign macro 1.41 at exec 18.103; go exec 18.103';
            pre_func = function () gma.echo('sleeping for 0.5 seconds'); gma.sleep(0.5); gma.echo('done'); end; -- let it work for some time
            cmd  = 'pause page 18';
            post = 'label exec 18.103 "PAU_PAG_3"; label macro 1.41 "PAU_PAG_3"; label page 18 "PAU_PAG_3"';
            cleanup = 'off page 18; clearall; page 1';
            test_dmx = true;
            test = 262;
            gold = 267;
        },
        {
            -- 'Pause' Timer
            smoketest = true;
            pre  = 'assign timer 1 at exec 18.1; go exec 18.1';
            pre_func = function () gma.echo('sleeping for 0.5 second'); gma.sleep(0.5); gma.echo('done'); end; -- give the timer a second to count
            cmd  = 'pause page 18';
            post = 'label exec 18.1 "PAU_PAG_4"; label page 18 "PAU_PAG_4"';
            -- test = 18;
            -- gold = 90;
        },
        {
            -- 'Pause' Selective effect exec
            smoketest = true;
            pre  = 'channel thru; presettype dimmer; at form "sin"; at effectBPM 0; Store Effect 11 /o; assign effect 11 /phase="0..180"; assign effect 11 at exec 18.103; go exec 18.103';
            cmd  = 'pause page 18';
            post = 'label exec 18.103 "PAU_PAG_5"; label page 18 "PAU_PAG_5"; label effect 11 "PAU_PAG_5"';
            cleanup = '';
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