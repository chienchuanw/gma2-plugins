--*******************************************************************************************
-- This script tests the method top to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 28, DMXsnap 312
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TOP";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.28 /nc; delete DMXsnapshot 312 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.28; store macro 1.28.1; assign macro 1.28.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 25 fade 3"; assign macro 1.28.1 /info="Macro prepared for test Top Macro"; store macro 1.28.2; assign macro 1.28.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 99"; store macro 1.28.3; assign macro 1.28.3 /cmd="feature colorrgb  at 88"; clearall; Go macro 1.28.3';
            cmd  = 'Top Macro 1.28';
            post = 'label macro 28 "TOP_MAC_1"; label DMXsnapshot 312 "TOP_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx = true;
            test = 312;
            gold = 812;
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