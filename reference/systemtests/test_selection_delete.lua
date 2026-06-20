--*******************************************************************************************
-- This script tests the method to delete a selection. -> Unpatch the selection 
-- set to destructive
-- DmxSnap 421,422
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 421 + 422 /nc';
    version_script   = '3.2.53.0';
    yield = true;
   
    steps =
    {
        {
            destructivetest= true;
            cmd  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100';
            post = 'label DmxSnapshot 421 "DEL_SELE_1"';
            cleanup = '';
            test_dmx = true;
            test = 421;
            gold = 921;
        },
        {
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            cmd  = 'Selection delete';
            post = 'label DmxSnapshot 422 "DEL_SELE_2"';
            cleanup = '';
            test_dmx = true;
            test = 422;
            gold = 922;
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