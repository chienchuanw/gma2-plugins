--*******************************************************************************************
-- This script tests the method tofull the fixtures to a group 
-- Group 51, DmxSnap 276
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TOFULL";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 51 /nc; delete DmxSnapshot 276 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; store Group 51 /o; selfix group 51 at 55';
            cmd  = 'tofull Group 51';
            post = 'label Group 51 "TOF_GRP_1"; label DmxSnapshot 276 "TOF_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 276;
            gold = 767;
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