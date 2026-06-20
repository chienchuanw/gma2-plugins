--*******************************************************************************************
-- This script tests the methods to unpark a DmxUniverse 
-- DmxSnap 94
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 94 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru at 100; Park DMXUniverse 1';
            cmd  = 'Unpark DMXUniverse 1; Channel 1 thru at 25 thru 100';
            post = 'label DmxSnapshot 94 "UNP_DMXU"';
            cleanup = '';
            test_dmx = true;
            test = 94;
            gold = 594;
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