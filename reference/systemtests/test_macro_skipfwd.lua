--*******************************************************************************************
-- This script tests the method skip >>> to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 27, DMXsnap 311
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SKIPFW";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.27 /nc; delete DMXsnapshot 311 /nc';
    steps =
    {
        {
            pre='store macro 1.27; store macro 1.27.1; assign macro 1.27.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 65"; assign macro 1.27.1 /info="Macro prepared for test SKIPFW Macro"; store macro 1.27.2; assign macro 1.27.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/3)..' at 99"; store macro 1.27.3; assign macro 1.27.3 /cmd="feature colorrgb at 100"; go macro 1.27.2';
            cmd  = '>>> Macro 27';
            post = 'label macro 27 "FWD_MAC_1"; label DMXsnapshot 311 "FWD_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 311;
            gold = 811;
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