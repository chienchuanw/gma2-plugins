--*******************************************************************************************
-- This script tests the method goto to a macro. 
-- Goto a certain line inside a macro.
-- Macro a.b.c is page a. macro b. line c
-- Macro 20, DMXsnap 306
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "GOTO";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 20 /nc; delete DMXsnapshot 306 /nc';
    steps =
    {
        {
            pre='store macro 1.20; store macro 1.20.1; assign macro 1.20.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 80"; assign macr 1.20.1 /info="Macro prepared for test Goto Macro"; store macro 1.20.2; assign macro 1.20.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 50"; clearall';
            cmd  = 'Goto Macro 1.20.2';
            post = 'label macro 20 "GOTO_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 306;
            gold = 806;
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