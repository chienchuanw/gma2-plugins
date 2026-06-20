--*******************************************************************************************
-- This script tests the method "toggle" for a page.
-- Page 13,Group 111, Effect 9, Macro 39, Sequ 177+178, DMXSnapshot 354-381
--*******************************************************************************************

local fixturecount  = get_prop_fixturecount();

local test=
{
    method_name     = "TOGGLE";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 13 /nc; page 13; label page 13 "TOG_PAG"; delete DmxSnapshot 354 thru 361 /nc';
    steps =
    {
        {
            -- 'Toggle on' Page with Sequence
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 177 /o; Assign Seq 177 at Exec 13.1; clearall';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 354 "TOG_PAG_1"; Label Exec 13.1 "TOG_PAG_1"; Label Page 13 "TOG_PAG_1"; Label seq 177 "TOG_PAG_1"';
            test_dmx = true;
            test = 354;
            gold = 362;
        },
        {
            -- 'Toggle off' Page with Sequence
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 355 "TOG_PAG_2"; Label Exec 13.1 "TOG_PAG_2"; Label Page 13 "TOG_PAG_2"; Label seq 177 "TOG_PAG_2"';
            test_dmx = true;
            cleanup = 'delete exec 13.1';
            test = 355;
            gold = 363;
        },
        {
            --'Toggle on' Page with Group Master
            smoketest = true;
            pre  = 'fixture '..math.floor((10*fixturecount[2])/12+1)..' thru '..math.floor((11*fixturecount[2])/12)..'; Store Group 111 /o; Assign Group 111 At Exec 13.2; assign exec 13.2 /mode="additive"; clearall';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_3"; Label Group 111 "TOG_PAG_3"';
            cleanup = 'tozero exec 13.2; delete exec 13.2 /nc';
        },
        {
            --'Toggle off' Page with Group Master
            smoketest = true;
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_4"; Label Group 111 "TOG_PAG_4"';
            cleanup = 'delete exec 13.2';
        },
        {
            -- 'Toggle on' Page with Special Master
            smoketest = true;
            pre  = 'Assign SpecialMaster 1.1 At Exec 13.3';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_5"';
        },
        {
            -- 'Toggle off' Page with Special Master
            smoketest = true;
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_6"';
            cleanup = 'delete exec 13.3';
        },
        {
            -- 'Toggle on' Page with Effect
            pre  = 'fixture thru; at form "sin"; at effectBPM 0; Store Effect 9 /o; Assign Effect 9 At Exec 13.4; clearall';
            cmd  = 'Toggle Page 13';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DMXSnapshot 356 "TOG_PAG_7"; Label Page 13 "TOG_PAG_7"; Label Effect 9 "TOG_PAG_7"';
            test_dmx = true;
            test = 356;
            gold = 364;
        },
        {
            -- 'Toggle off' Page with Effect
            pre  = '';
            cmd  = 'Toggle Page 13';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label DMXSnapshot 357 "TOG_PAG_8"; Label Page 13 "TOG_PAG_8"; Label Effect 9 "TOG_PAG_8"';
            cleanup = 'delete exec 13.4';
            test_dmx = true;
            test = 357;
            gold = 365;
        },
        {
            -- 'Toggle on' Page with Macro
            pre  = 'store macro 1.39; store macro 1.39.1; assign macro 1.39.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 59"; Assign Macro 39 at Exec 13.5; clearall';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 358 "TOG_PAG_9"; Label Page 13 "TOG_PAG_9"; Label Macro 39 "TOG_PAG_9"';
            test_dmx = true;
            test = 358;
            gold = 366;
        },
        {
            -- 'Toggle off' Page with Macro
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 359 "TOG_PAG_10"; Label Page 13 "TOG_PAG_10"; Label Macro 39 "TOG_PAG_10"';
            cleanup = 'delete exec 13.5';
            test_dmx = true;
            test = 359;
            gold = 367;
        },
        {
            -- 'Toggle on' Page with Timer
            smoketest = true;
            pre  = 'Assign Timer 1 At Exec 13.6';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_11"';
        },
        {
            -- 'Toggle off' Page with Timer
            smoketest = true;
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label Page 13 "TOG_PAG_12"';
            cleanup = 'delete exec 13.6';
        },
        {
            -- 'Toggle on' Page with second sequence in conflict
            pre  = 'Assign Seq 177 at Exec 13.1; Channel 1 thru ' .. fixturecount[1] .. ' at 55; Store Seq 178 /o; Assign Seq 178 at Exec 13.101; clearall';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 360 "TOG_PAG_13"; Label Exec 13.101 "TOG_PAG_13"; Label Page 13 "TOG_PAG_13"; Label seq 178 "TOG_PAG_13"';
            test_dmx = true;
            test = 360;
            gold = 368;
        },
        {
            -- 'Toggle off' Page with second sequence in conflict
            pre  = '';
            cmd  = 'Toggle Page 13';
            post = 'Label DMXSnapshot 361 "TOG_PAG_14"; Label Page 13 "TOG_PAG_14"; Label seq 178 "TOG_PAG_13"';
            cleanup = 'clearall; off page 13; page 1';
            test_dmx = true;
            test = 361;
            gold = 369;
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