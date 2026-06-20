--*******************************************************************************************
-- This script tests the method "on" for a page.
-- Page 8, Group 106, Effect 4, Macro 34, Sequ 167, DmxSnapshot 313-318
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "ON";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 8 /nc; page 8; label page 8 "ON_PAG"; delete group 106 /nc; delete effect 4 /nc; delete macro 34 /nc; delete seq 167 /nc; delete DMXSnapshot 313 thru 315 /nc';
    steps =
    {
        {
            -- 'On' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 167; Assign Seq 167 at Exec 8.1; clearall';
            cmd  = 'On Page 8';
            post = 'Label DMXSnapshot 313 "ON_PAG_1"; Label Exec 8.1 "ON_PAG_1"; Label Page 8 "ON_PAG_1"';
            cleanup = '';
            test_dmx = true;
            test = 313;
            gold = 316;
        },
        {
            --'On' Page with Group Master
            smoketest = true;
            pre  = 'fixture '..math.floor((7*fixturecount[2])/12+1)..' thru '..math.floor((8*fixturecount[2])/12)..'; Store Group 106 /o; Assign Group 106 At Exec 8.2; assign exec 8.2 /mode="additive"; clearall;';
            cmd  = 'On Page 8';
            post = 'Label Page 8 "ON_PAG_2"; Label Group 106 "ON_PAG_2"';
            cleanup = 'tozero exec 8.2 /nc';
        },
        {
            -- 'On' Page with Special Master
            smoketest = true;
            pre  = 'Assign SpecialMaster 1.1 At Exec 8.3';
            cmd  = 'On Page 8';
            post = 'Label Page 8 "ON_PAG_3"';
        },
        {
            -- 'On' Page with Effect
            pre  = 'fixture thru; channel thru; presettype dimmer; at form "sin"; at effectBPM 0; Store Effect 4 /o; assign effect 4 /phase="0..180"; Assign Effect 4 At Exec 8.4; clearall';
            cmd  = 'On Page 8';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DMXSnapshot 314 "ON_PAG_4"; Label Page 8 "ON_PAG_4"; Label Effect 4 "ON_PAG_4"; clearall';
            test_dmx = true;
            test = 314;
            gold = 317;
        },
        {
            -- 'On' Page with Macro
            pre  = 'store macro 1.34; store macro 1.34.1; assign macro 1.34.1 /cmd="channel thru at 58"; Assign Macro 34 at Exec 8.5; clearall';
            cmd  = 'On Page 8';
            post = 'Label DMXSnapshot 315 "ON_PAG_5"; Label Page 8 "ON_PAG_5"; Label Macro 34 "ON_PAG_5"';
            test_dmx = true;
            test = 315;
            gold = 318;
        },
        {
            -- 'On' Page with Timer
            smoketest = true;
            pre  = 'Assign Timer 1 At Exec 8.6';
            cmd  = 'On Page 8';
            post = 'Label Page 8 "ON_PAG"';
            cleanup = 'off page 8; page 1';
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