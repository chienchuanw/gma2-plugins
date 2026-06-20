--*******************************************************************************************
-- This script tests the method "flash" for a page.
-- Page 11, Group 109, Effect 7, Macro 37, Sequ 170, DmxSnap 102-109 and 112-119
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "FLASH";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 11 /nc; page 11; label page 11 "FLA_PAG"; delete group 109 /nc; delete effect 7 /nc; delete macro 37 /nc; delete seq 170 /nc; delete DmxSnapshot 102 thru 109 /nc';
    steps =
    {
        {
            -- 'Flash on' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 170; Assign Seq 170 at Exec 11.1; clearall';
            cmd  = 'Flash Page 11';
            post = 'Label Exec 11.1 "FLA_PAG_1"; Label Page 11 "FLA_PAG_1"; Label DmxSnapshot 102 "FLA_PAG_1"';
            cleanup = 'flash off page 11';
            test_dmx = true;
            test = 102;
            gold = 112;
        },
        {
            -- 'Flash off' Page with Sequence
            pre  = 'Flash Page 11';
            cmd  = 'Flash off Page 11';
            post = 'Label DmxSnapshot 103 "FLA_PAG_2"';
            test_dmx = true;
            test = 103;
            gold = 113;
        },
        {
            -- 'Flash off' Page with Sequence, Blacktest
            pre  = 'Flash Page 11';
            cmd  = '';
            post = 'Label DmxSnapshot 104 "FLA_PAG_3"';
            cleanup = 'Flash off Page 11; delete exec 11.1 /nc';
            blacktest = true;
            test_dmx = true;
            test = 104; -- should be flash on
            gold = 113; -- should be flash off
        },
        {
            --'Flash' Page with Group Master
            pre  = 'fixture '..math.floor((4*fixturecount[2])/12+1)..' thru '..math.floor((5*fixturecount[2])/12)..'; store group 109 /o; Assign Group 109 At Exec 11.2; assign exec 11.2 /mode="additive"; clearall';
            cmd  = 'Flash Page 11';
            post = 'Label Page 11 "FLA_PAG_4"; Label Group 109 "FLA_PAG_4"';
            cleanup = 'flash off page 11; delete exec 11.2 /nc';
            test_dmx = true;
            test = 105;
            gold = 115;
        },
        {
            -- 'Flash' Page with Special Master (Grandmaster)
            pre  = 'Assign SpecialMaster 2.1 At Exec 11.3; tozero specialmaster 2.1; channel 1 full';
            cmd  = 'Flash Page 11';
            post = 'Label Page 11 "FLA_PAG_5"';
            cleanup = 'flash off page 11; tofull specialmaster 2.1; delete exec 11.3 /nc';
            test_dmx = true;
            test = 106;
            gold = 116;
        },
        {
            -- 'Flash' Page with Effect
            pre  = 'channel thru; Presettype "Dimmer"; at form "sin"; at effectBPM 0; Store Effect 7 /o; assign effect 7 /phase="0..360"; Assign Effect 7 At Exec 11.4; clearall';
            cmd  = 'Flash Page 11';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label Page 11 "FLA_PAG_6"; Label Effect 7 "FLA_PAG_6"';
            cleanup = 'flash off page 11; delete exec 11.4 /nc';
            test_dmx = true;
            test = 107;
            gold = 117;
        },
        {
            -- 'Flash' Page with Macro (nothing should happen, only 'go' would work with macro)
            pre  = 'store macro 1.37; store macro 1.37.1; assign macro 1.37.1 /cmd="channel thru at 58"; Assign Macro 37 at Exec 11.5';
            cmd  = 'Flash Page 11';
            post = 'Label Page 11 "FLA_PAG_7"; Label Macro 37 "FLA_PAG_7"';
            cleanup = 'flash off page 11; delete exec 11.5';
            test_dmx = true;
            test = 108;
            gold = 118;
        },
        {
            -- 'Flash' Page with Timer (nothing should happen)
            pre  = 'Assign Timer 1 At Exec 11.6';
            cmd  = 'Flash Page 11';
            post = 'Label Page 11 "FLA_PAG_8"';
            cleanup = 'flash off page 11; page 1';
            test_dmx = true;
            test = 109;
            gold = 119;
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