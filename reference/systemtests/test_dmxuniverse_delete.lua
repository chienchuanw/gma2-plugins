--*******************************************************************************************
-- This script tests the methods to delete (unpatch) a DmxUniverse 
-- set to destructive
-- DmxSnap 91
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "DMXUNIVERSE";
    pre              = 'ClearAll; delete DmxSnapshot 91 /nc';
    version_script   = '3.2.53.0';
   yield = true;
   
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100';
            cmd  = 'delete DMXUniverse 1 /nc';
            post = 'label DmxSnapshot 91 "DEL_DMXU"';
            cleanup = '';
            test_dmx = true;
            test = 91;
            gold = 591;
            destructivetest= true;
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