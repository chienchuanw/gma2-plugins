--*******************************************************************************************
-- This script tests the method on to a macro. 
-- The method on is used to start from a certain line.
-- It is not equal to go macro.
-- Macro a.b.c is page a. macro b. line c
-- Macro 29, DMXsnap 308
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.29 /nc; delete DMXsnapshot 308 /nc';
    steps =
    {
        {
            pre='store macro 1.29; store macro 1.29.1; assign macro 1.29.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 81"; assign macro 1.29.1 /info="Macro prepared for test On Macro"; store macro 1.29.2; assign macro 1.29.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 50"; clearall';
            cmd  = 'On Macro 1.29.2';
            post = 'label macro 29 "ON_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 308;
            gold = 808;
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