--*******************************************************************************************
-- This script tests the method call to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 12, DMXsnap 303
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CALL";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 12 /nc; delete DMXsnap 303 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.12; store macro 1.12.1; assign macro 1.12.1 /cmd="fixture 1 thru '..fixturecount[2]..'"; assign macro 1.12.1 /info="Macro prepared for test Call Macro"; store macro 1.12.2; assign macro 1.12.2. /cmd="at 70"; clearall';
            cmd  = 'Call Macro 1.12';
            post = 'label macro 1.12 "CALL_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx= true;
            test = 303;
            gold = 803;
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