--*******************************************************************************************
-- This script tests the methods to copy a page.
-- Page 4-5, Page 26-32, Sequ 165, Group 104, Effect 2, Macro 32, Timer 1, Dmxsnap 75+76
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name      = "COPY";
    object_name      = "PAGE";
    pre              = 'ClearAll; delete page 4 thru 5 /nc; page 4; label page 4 "COP_PAG";';
    steps =
    {
        {
            -- Copy Empty Page
            pre  = '';
            cmd  = 'Copy Page 4 At Page 5';
            post = 'Label Page 5 "COP_PAG_1"';
            test = 5;
            gold = 26;
        },
        {
            -- Copy Page with Seq
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 165 /o; Assign Seq 165 at Exec 4.1; clearall'; -- Create Sequence on Executor 4.1
            cmd  = 'Copy Page 4 At Page 5 /o';
            post = 'Label Page 5 "COP_PAG_2"; Label Seq 165 "COP_PAG_2"';
            test = 5;
            gold = 27;
        },
        {
            -- Copy Page with Group Master
            pre  = 'fixture '..math.floor((2*fixturecount[2])/12+1)..' thru '..math.floor((3*fixturecount[2])/12)..'; Store Group 104 /o; Assign Group 104 At Exec 4.2; assign exec 4.2 /mode="additive"';
            cmd  = 'Copy Page 4 At Page 5 /o; tofull exec 5.2';
            post = 'Label Page 5 "COP_PAG_3"; Label Group 104 "COP_PAG_3"';
            cleanup = 'tozero exec 5.2';
            test_dmx = true;
            test = 75;
            gold = 76;
        },
        {
            -- Copy Page with Special Master
            pre  = 'Assign SpecialMaster 1.1 At Exec 4.3';
            cmd  = 'Copy Page 4 At Page 5 /o';
            post = 'Label Page 5 "COP_PAG_4"';
            test = 5;
            gold = 29;
        },
        {
            -- Copy Page with Effect
            pre  = 'fixture thru; channel thru; at form "sin"; at effectBPM 180; Store Effect 2 /o; Assign Effect 2 At Exec 4.4';
            cmd  = 'Copy Page 4 At Page 5 /o';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label Page 5 "COP_PAG_5"; Label Effect 2 "COP_PAG_5"';
            test = 5;
            gold = 30;
        },
        {
            -- Copy Page with Macro
            pre  = 'store macro 1.32; store macro 1.32.1; assign macro 1.32.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 58"; Assign Macro 32 at Exec 4.5';
            cmd  = 'Copy Page 4 At Page 5 /o';
            post = 'Label Page 5 "COP_PAG_6"; Label Macro 32 "COP_PAG_6"';
            test = 5;
            gold = 31;
        },
        {
            -- Copy Page with Timer
            pre  = 'Assign Timer 1 At Exec 4.6';
            cmd  = 'Copy Page 4 At Page 5 /o';
            post = 'Label Page 5 "COP_PAG_7"';
            cleanup = 'page 1';
            test = 5;
            gold = 32;
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