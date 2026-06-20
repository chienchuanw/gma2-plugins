--*******************************************************************************************
-- This script tests the method off to a macro. 
-- Macro a.b.c is page a. macro b. line c
-- Macro 28, DMXsnap 307
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete Macro 1.28 /nc; delete DMXsnapshot 307 /nc';
    steps =
    {
        {
            
            pre=' store macro 1.28; store macro 1.28.1; assign macro 1.28.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 82 fade 4"; assign macro 1.28.1 /info="Macro prepared for test Off Macro"; store macro 1.28.2; assign macro 1.28.2 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 50"; on macro 1.28.1';
            --pre_func = function () gma.sleep(2); gma.echo('sleeping for 2 second'); end; 
            cmd  = 'Off Macro 1.28';
            post = 'label macro 1.28 "OFF_MAC_1"';
            cleanup= 'off macro thru';
            test_dmx=true;
            test = 307;
            gold = 807;
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