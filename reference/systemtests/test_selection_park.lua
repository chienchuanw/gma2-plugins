--*******************************************************************************************
-- This script tests the method to park a selection. 
-- DmxSnap 427
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 427 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture thru at 100; park selection';
            pre_func = function () gma.echo('sleeping for 2 second'); gma.sleep(2); end; -- This is needed to give the system some time 
            cmd  = 'at 50'; -- programmer shows 50, output is 100
            cmd_func = function () gma.echo('sleeping for 2 second'); gma.sleep(2); end; -- This is needed to give the system some time 
            post = 'label DmxSnapshot 427 "PARK_SELE_1"';
            cleanup = '';
            test_dmx = true;
            test = 427;
            gold = 727;
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