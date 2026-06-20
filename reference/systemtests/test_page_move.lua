--*******************************************************************************************
-- This script tests the methods to move a page.
-- Page 6+7, Page 33-34, Sequ 166, Group 105, Effect 3, Macro 33, Timer 1, Dmxsnap 432-441
--*******************************************************************************************

-- final result should be like this: on page 6 all the odd Executors are assigned, on page 7 all the even executors are assigned.
-- with the 'move' command the pages are going to be interchanged!

local fixturecount = get_prop_fixturecount();

local test=
{
    method_name     = "MOVE";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete Page 6 thru 7 /nc; Page 6; label Page 6 "MOV_PAG";';
    steps =
    {
        {
            -- Move Empty Page
            pre  = '';
            cmd  = 'Move Page 6 At Page 7';
            post = 'Label Page 7 "MOV_PAG_1"';
            test = {6,7};
            gold = {33,33};
        },
        {
            -- Move Page with Seq
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at Full; Store Seq 166 /o; Assign Seq 166 at Exec 6.1'; -- Create Sequence on Executor 6.1
            cmd  = 'Move Page 6 At Page 7 /o; go exec 7.1';
            post = 'Label Page 7 "MOV_PAG_2"; Label Seq 166 "MOV_PAG_2"';
            cleanup = 'off exec 7.1';
            test_dmx = true;
            test = 432;
            gold = 437;
        },
        {
            -- Move Page with Group Master
            pre  = 'fixture '..math.floor((5*fixturecount[2])/12+1)..' thru '..math.floor((6*fixturecount[2])/12)..'; Store Group 105 /o; Assign Group 105 At Exec 6.2; assign exec 6.2 /mode="additive"; clearall';
            cmd  = 'Move Page 6 At Page 7 /o; tofull exec 7.2';
            post = 'Label Page 7 "MOV_PAG_3"; Label Group 105 "MOV_PAG_3"';
            cleanup = 'tozero exec 7.2 /nc';
            test_dmx = true;
            test = 433;
            gold = 438;
        },
        {
            -- Move Page with Special Master
            pre  = 'Assign SpecialMaster 2.1 At Exec 6.3;';
            cmd  = 'Move Page 6 At Page 7 /o; channel thru; tozero exec 7.3';
            post = 'Label Page 7 "MOV_PAG_4"';
            cleanup = 'tofull exec 7.3; delete exec 7.3 /nc';
            test_dmx = true;
            test = 434;
            gold = 439;
        },
        {
            -- Move Page with Effect
            pre  = 'fixture thru; channel thru; at form "sin"; at effectBPM 0; Store Effect 3 /o; assign effect 3 /phase="0..360"; Assign Effect 3 At Exec 6.4; clearall';
            cmd  = 'Move Page 6 At Page 7 /o; go exec 7.4; tofull exec 7.4';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'Label Page 7 "MOV_PAG_5"; Label Effect 3 "MOV_PAG_5"';
            cleanup = 'off exec 6.4';
            test_dmx = true;
            test = 435;
            gold = 440;
        },
        {
            -- Move Page with Macro
            pre  = 'store macro 1.33; store macro 1.33.1; assign macro 1.33.1 /cmd="channel 1 thru ' .. fixturecount[1] .. ' at 59"; Assign Macro 33 at Exec 6.5';
            cmd  = 'Move Page 6 At Page 7 /o; go exec 7.5';
            post = 'Label Page 7 "MOV_PAG_6"; Label Macro 33 "MOV_PAG_6"';
            cleanup = 'off exec 6.5';
            test_dmx = true;
            test = 436;
            gold = 441;
        },
        {
            -- Move Page with Timer
            pre  = 'Assign Timer 1 At Exec 6.6';
            cmd  = 'Move Page 6 At Page 7 /o';
            post = 'Label Page 7 "MOV_PAG_7"';
            cleanup = 'page 1';
            test = 6;
            gold = 34;
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