--*******************************************************************************************
-- This script tests the method go to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 17, DMXsnap 304
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "GO";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 17 /nc; delete DMXsnapshot 304 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.17; store macro 1.17.1; assign macro 1.17.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 80"; assign macro 1.17.1 /info="Macro prepared for test Go Macro"; store macro 1.17.2; assign macro 1.17.2 /cmd="feature colorrgb at 100"; clearall';
            cmd  = 'Go Macro 1.17';
            post = 'label macro 1.17 "GO_MAC_1"; label DMXsnapshot 304 "GO_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx = true;
            test = 304;
            gold = 804;
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