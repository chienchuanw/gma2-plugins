--*******************************************************************************************
-- This script tests the method toZero the fixtures of a group 
-- Group 52, DmxSnap 277
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TOZERO";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 52 /nc; delete DmxSnapshot 277 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; store Group 48 /nc; selfix group 52 at full; clearall';
            cmd  = 'toZero Group 48';
            post = 'label Group 48 "TOF_GRP_1"; label DmxSnapshot 277 "TOF_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 277;
            gold = 777;
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