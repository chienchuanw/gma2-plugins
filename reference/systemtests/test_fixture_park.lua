--*******************************************************************************************
-- This script tests the method park to a fixture 
-- DmxSnap 251
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 251 /nc';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' ..fixturecount[2];
            cmd  = 'Park Fixture 1 thru ' ..math.floor(fixturecount[2]/2)..'; Fixture 1 thru ' ..fixturecount[2]..'At 50';
            post = 'label DmxSnapshot 251 "PARK_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 251;
            gold = 751;
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