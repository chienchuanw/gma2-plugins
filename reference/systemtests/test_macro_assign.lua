--*******************************************************************************************
-- This script tests the method assign to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 11, Exec 70, DMXsnap 302
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete executor 70 /nc; delete Macro 11 /nc; delete DMXsnapshot 302';
    steps =
    {
        {
            pre  = 'store macro 1.11; store macro 1.11.1; assign macro 1.11.1 /cmd="fixture 1 thru '..fixturecount[2]..' " /info="Macro prepared for test Assign Macro"; store macro 1.11.2; assign macro 1.11.2. /cmd="at 70"';
            cmd  = 'Assign Macro 1.11 at executor 70; clearall; go executor 70';
            post = 'label macro 11 "ASS_MAC_1"; label executor 70 "ASS_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 302;
            gold = 802;
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