--*******************************************************************************************
-- This script tests the method skip backwards <<<  to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 31, DMXsnap 310
-- 10.11.2016 Bug at Skip backwards. First skips in the line before, than one further, than backwards.
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SKIPBW";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.31 /nc; delete DMXsnapshot 310 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.31; store macro 1.31.1; assign macro 1.31.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 65"; assign macro 1.31.1 /info="Macro prepared for test SKIPBW Macro"; store macro 1.31.2; assign macro 1.31.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 99"; store macro 1.31.3; assign macro 1.31.3 /cmd="feature colorrgb  at 100"; ClearAll; go macro 1.31.2';
            cmd  = '<<< Macro 31';
            post = 'label macro 31 "BWD_MAC_1"; label DMXsnapshot 310 "SKBW_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx = true; 
            test = 310;
            gold = 810;
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