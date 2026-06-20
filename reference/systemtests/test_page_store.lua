--*******************************************************************************************
-- This script tests the methods to store a page.
-- Page 2, DMXSnap 604-613, Sequ 163, Group 103, Effect 1, Macro 42, Timer 1
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "STORE";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 2 /nc; page 2; label page 2 "STO_PAG"; delete dmxsnap 604 thru 608 /nc';
    steps =
    {
        {
            -- Sequence at Exec 2.1
            pre  = 'Channel thru at 99; Store Seq 163 /o; clearall';
            cmd  = 'Assign Seq 163 at Exec 2.1; go exec 2.1';
            post = 'Label Seq 163 "STO_PAG_1"; Label Exec 2.1 "STO_PAG_1"';
            test_dmx = true;
            test = 604;
            gold = 609;
        },
        {
            -- Group Master at Exec 2.2
            pre  = 'fixture '..math.floor((8*fixturecount[2])/12+1)..' thru '..math.floor((9*fixturecount[2])/12)..'; Store Group 103 /o;';
            cmd  = 'Assign Group 103 At Exec 2.2; assign exec 2.2 /mode="additive"; clearall; tofull exec 2.2';
            post = 'Label Group 103 "STO_PAG_2"; Label Exec 2.2 "STO_PAG_2"';
            cleanup = 'clearall; tozero exec 2.2 /nc';
            test_dmx = true;
            test = 605;
            gold = 610;
        },
        {
            -- Special Master at Exec 2.3
            pre = 'fixture 1 + 5 full;';
            cmd  = 'Assign SpecialMaster 2.1 At Exec 2.3; tozero exec 2.3;';
            post = 'Label Exec 2.3 "STO_PAG_3"';
            cleanup = 'tofull exec 2.3; delete exec 2.3';
            test_dmx = true;
            test = 606;
            gold = 611;
        },
        {
            -- Effect at Exec 2.4
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; Store Effect 1 /o; assign effect 1 /Phase = "0..369"; clearall';
            pre_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            cmd  = 'Assign Effect 1 At Exec 2.4; go exec 2.4';
            post = 'Label Effect 1 "STO_PAG_4"; Label Exec 2.4 "STO_PAG_4"';
            cleanup = 'off exec 2.4';
            test_dmx = true;
            test = 607;
            gold = 612;
        },
        {
            -- Macro at Exec 2.5
            pre  = 'store macro 1.42 /o; store macro 1.42.1; assign macro 1.42.1 /cmd="channel 1 thru ' .. math.floor(fixturecount[1]/4) .. ' at 57"; clearall';
            cmd  = 'Assign Macro 42 at Exec 2.5; go exec 2.5';
            post = 'Label Macro 42 "STO_PAG_5"; Label Exec 2.5 "STO_PAG_5"';
            cleanup = 'off exec 2.5';
            test_dmx = true;
            test = 608;
            gold = 613;
        },
        {
            -- Timer at Exec 2.6
            smoketest = true;
            pre  = '';
            cmd  = 'Assign Timer 1 At Exec 2.6';
            post = 'Label Exec 2.6 "STO_PAG_6" ';
            cleanup = 'page 1';
        }
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