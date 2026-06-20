--*******************************************************************************************
-- This script tests the methods to park a DmxUniverse 
-- DmxSnap 93
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 93 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru at 100';
            cmd  = 'Park DMXUniverse 1; Channel 1 thru at 25 thru 100';
            post = 'label DmxSnapshot 93 "PARK_DMXU"';
            cleanup = '';
            test_dmx = true;
            test = 93;
            gold = 593;
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