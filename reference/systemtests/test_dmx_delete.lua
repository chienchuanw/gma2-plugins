--*******************************************************************************************
-- This script tests the method to delete (unpatch) a fixture that is assigned to a dmx-value.
-- The dmx tester has highest priority. Make sure to reset!!
-- set on destructive table
-- DmxSnap 76+77
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "DMX";
    pre              = 'ClearAll; delete DmxSnapshot 76 + 77 /nc';
    yield = true;
   
    steps =
    {
        {
            pre  = 'Channel 1 thru ' .. fixturecount[1] .. ' at 100';
            cmd  = 'delete Channel 1 thru ' .. math.floor(fixturecount[1]/2);
            post = 'label DmxSnapshot 76 "DEL_DMX_1"';
            cleanup = '';
            test_dmx = true;
            test = 76;
            gold = 576;
        },
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100';
            cmd  = 'delete Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            post = 'label DmxSnapshot 77 "DEL_DMX_2"';
            cleanup = '';
            test_dmx = true;
            test = 77;
            gold = 577;
            destructivetest = true;
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