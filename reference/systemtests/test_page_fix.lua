--*******************************************************************************************
-- This script tests the method fix for a page.
-- Page 10, Group 108, Effect 6, Macro 36, Seq 200, DMXSnapshot 460-467
--*******************************************************************************************

-- Page Comparison is not possible (Fixed Golden Sample would be unfixed)

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "FIX";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete Page 10 /nc; Page 10; label Page 10 "FIX_PAG"; delete seq 200 /nc';
    steps =
    {
        {
            -- 'Fix' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 200 /o; Assign Seq 200 at Exec 10.1';
            cmd  = 'Fix Page 10; page 1; Go Exec 1';
            post = 'Label DmxSnapshot 460 "FIX_PAG_1"; Label Exec 10.1 "FIX_PAG_1"; Label Page 10 "FIX_PAG_1"; Label Seq 200 "FIX_PAG_1"';
            cleanup = 'Fix Page 10; page 10';
            test_dmx = true;
            test = 460;
            gold = 464;
        },
        {
            --'Fix' Page with Group Master
            pre  = 'fixture '..math.floor((3*fixturecount[2])/12+1)..' thru '..math.floor((4*fixturecount[2])/12)..'; Store Group 108 /o; Assign Group 108 At Exec 10.2; assign exec 10.2 /mode="additive";';
            cmd  = 'Fix Page 10; page 1; tofull Exec 2';
            post = 'Label DmxSnapshot 461 "FIX_PAG_2"; Label Page 10 "FIX_PAG_2"; Label Group 108 "FIX_PAG_2"';
            cleanup = 'Fix Page 10; page 10; tozero exec 10.2';
            test_dmx = true;
            test = 461;
            gold = 465;
        },
        {
            -- 'Fix' Page with Special Master
            smoketest = true;
            pre  = 'Assign SpecialMaster 1.1 At Exec 10.3';
            cmd  = 'Fix Page 10; page 1';
            post = 'Label Page 10 "FIX_PAG_3"';
            cleanup = 'Fix Page 10; page 10';
        },
        {
            -- 'Fix' Page with Effect
            pre  = 'fixture thru; channel thru; at form "sin"; at effectBPM 0; Store Effect 6 /o; assign effect 6 /phase="0..180"; Assign Effect 6 At Exec 10.4';
            cmd  = 'Fix Page 10; page 1; go exec 4';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DmxSnapshot 462 "FIX_PAG_4"; Label Page 10 "FIX_PAG_4"; Label Effect 6 "FIX_PAG_4"';
            cleanup = 'Fix Page 10; page 10';
            test_dmx = true;
            test = 462;
            gold = 466;
        },
        {
            -- 'Fix' Page with Macro
            pre  = 'store macro 1.36; store macro 1.36.1; assign macro 1.36.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 53"; Assign Macro 36 at Exec 10.5';
            cmd  = 'Fix Page 10; page 1; go exec 5';
            post = 'Label DmxSnapshot 463 "FIX_PAG_5"; Label Page 10 "FIX_PAG_5"; Label Macro 36 "FIX_PAG_5"';
            cleanup = 'Fix Page 10; page 10';
            test_dmx = true;
            test = 463;
            gold = 467;
        },
        {
            -- 'Fix' Page with Timer
            smoketest = true;
            pre  = 'Assign Timer 1 At Exec 10.6';
            cmd  = 'Fix Page 10; page 1; go exec 6';
            post = 'Label Page 10 "FIX_PAG"';
            cleanup = 'Fix Page 10';
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