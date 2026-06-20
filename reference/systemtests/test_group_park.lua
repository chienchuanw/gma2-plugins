--*******************************************************************************************
-- This script tests the method to park a group. 
-- Group 46, DmxSnap 274
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete group 46 /nc; delete DmxSnapshot 274 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 46; Group 46 at 100';
            cmd  = 'park group 46; group 46 at 50'; -- programmer shows 50, output is 100
            post = 'label group 46 "PARK_GRP"; label DmxSnapshot 274 "PARK_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 274;
            gold = 774;
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