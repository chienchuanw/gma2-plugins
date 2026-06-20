--*******************************************************************************************
-- This script tests the method goBack to a macro. 
-- Goto a certain line inside a macro.
-- Macro a.b.c is page a. macro b. line c
-- 14.11.2016 goBack from one line to another is executing the next line-> Bug Ticket
-- Macro 19, DMXsnap 305
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "GOBACK";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 19 /nc; delete DMXsnapshot 305 /nc';
    steps =
    {
        {
            pre  = 'store macro 1.19; store macro 1.19.1; assign macro 1.19.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 80"; assign macro 1.19.1 /info="Macro prepared for test Goback Macro"; assign macro 1.19.1 /wait="Go"; store macro 1.19.2; assign macro 1.19.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 50"; clearall';
            cmd  = 'Goback Macro 1.19';
            post = 'label macro 1.19 "GOBA_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 305;
            gold = 805;
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