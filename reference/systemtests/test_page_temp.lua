--*******************************************************************************************
-- This script tests the method "temp" for a page.
-- Page 12, Group 110, Effect 8, Macro 38, Sequ 164, DmxSnap 382-391
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "TEMP";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 12 /nc; page 12; label page 12 "TEM_PAG"; delete group 110 /nc; delete effect 8 /nc; delete macro 1.38 /nc; delete seq 164 /nc; delete DmxSnapshot 382 thru 386 /nc';
    steps =
    {
        {
            -- 'temp on' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 164; Assign Seq 164 at Exec 12.1; clearall';
            cmd  = 'temp Page 12';
            post = 'Label Exec 12.1 "TEM_PAG_1"; Label Page 12 "TEM_PAG_1"; Label DmxSnapshot 382 "TEM_PAG_1"';
            cleanup = 'temp off page 12';
            test_dmx = true;
            test = 382;
            gold = 387;
        },
        {
            -- 'temp off' Page with Sequence
            pre  = 'temp Page 12';
            cmd  = 'temp off Page 12';
            post = 'Label DmxSnapshot 383 "TEM_PAG_2"';
            test_dmx = true;
            test = 383;
            gold = 388;
        },
        {
            -- 'temp off' Page with Sequence, Blacktest
            pre  = 'temp Page 12';
            cmd  = '';
            post = 'Label DmxSnapshot 384 "TEM_PAG_3"';
            cleanup = 'temp off Page 12; delete Page 12';
            blacktest = true;
            test_dmx = true;
            test = 384; -- should be temp on
            gold = 389; -- should be temp off
        },
        {
            --'temp' Page with Group Master
            smoketest = true;
            pre  = 'fixture '..math.floor((9*fixturecount[2])/12+1)..' thru '..math.floor((10*fixturecount[2])/12)..'; Store Group 110 /o; Assign Group 110 At Exec 12.2; assign exec 12.2 /mode="additive"; clearall';
            cmd  = 'temp Page 12';
            post = 'Label Page 12 "TEM_PAG_4"; Label Group 110 "TEM_PAG_4"';
            cleanup = 'temp off page 12; delete page 12';
        },
        {
            -- 'temp' Page with Special Master
            smoketest = true;
            pre  = 'Assign SpecialMaster 1.1 At Exec 12.3';
            cmd  = 'temp Page 12';
            post = 'Label Page 12 "TEM_PAG_5"';
            cleanup = 'temp off page 12; delete page 12';
        },
        {
            -- 'temp' Page with Effect
            pre  = 'fixture thru; channel thru; at form "sin"; at effectBPM 0; Store Effect 8 /o; assign effect 8 /phase="0..180"; Assign Effect 8 At Exec 12.4; clearall';
            cmd  = 'temp Page 12';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DMXSnapshot 385 "TEM_PAG_6"; Label Page 12 "TEM_PAG_6"; Label Effect 8 "TEM_PAG_6"';
            cleanup = 'temp off page 12; delete page 12';
            test_dmx = true;
            test = 385;
            gold = 390;
        },
        {
            -- 'temp' Page with Macro
            pre  = 'store macro 1.38; store macro 1.38.1; assign macro 1.38.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 54"; Assign Macro 38 at Exec 12.5';
            cmd  = 'temp Page 12';
            post = 'Label DmxSnapshot 386 "TEM_PAG_7"; Label Page 12 "TEM_PAG_7"; Label Macro 1.38 "TEM_PAG_7"';
            cleanup = 'temp off page 12; delete page 12';
            test_dmx = true;
            test = 386;
            gold = 391;
        },
        {
            -- 'temp' Page with Timer
            smoketest = true;
            pre  = 'Assign Timer 1 At Exec 12.6';
            cmd  = 'temp Page 12';
            post = 'Label Page 12 "TEM_PAG_8"';
            cleanup = 'temp off page 12; page 1';
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