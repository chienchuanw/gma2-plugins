--*******************************************************************************************
-- This script tests the method full to a group
-- Group 33, DmxSnap 272
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete group 33 /nc; delete DmxSnapshot 272 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' ..fixturecount[2] .. '; store group 33 /nc; selfix group 33 at 40';
            cmd  = 'full group 33';
            post = 'label group 33 "FULL_GRP_1"; label DmxSnapshot 272 "FULL_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 272;
            gold = 772;
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