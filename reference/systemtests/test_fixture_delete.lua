--*******************************************************************************************
-- This script tests the method to delete a fixture. -> Unpatch the fixture 
-- set to destructive
-- DmxSnap 241
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 241 /nc';
    version_script   = '3.2.53.0';
    yield = true;
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100';
            cmd  = 'delete Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            post = 'label DmxSnapshot 241 "DEL_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 241;
            gold = 741;
            destructivetest= true;
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