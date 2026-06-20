--*******************************************************************************************
-- This script tests the method skip >>> to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 30, DMXsnapshot 309
-- 10.11.2016 Macro Pause funktioniert nicht-> Bug Ticket
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PAUSE";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.30 /nc; delete DMXsnapshot 309 /nc';
    steps =
    {
        {
            pre='store macro 30; store macro 1.30.1; assign macro 1.30.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 20 fade 3; feature color1 at 100"; assign macro 1.30.1 /info="Macro prepared for test Pause Macro"; clearall; go macro 1.30';
            pre_func = function () gma.sleep(1); gma.echo('sleeping for 1 second'); end; 
            cmd  = 'Pause Macro 1.30';
            post = 'label macro 1.30 "PAU_MAC_1"; label DMXsnapshot 309 "PAU_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 309;
            gold = 809;
        },
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