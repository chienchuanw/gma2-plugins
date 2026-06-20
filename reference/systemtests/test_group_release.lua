--*******************************************************************************************
-- This script tests the method to release a group. 
-- Seq 62+63, DmxSnap 275, Group 47, Exec 82
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 47 /nc; delete sequence 62 + 63 /nc; delete DmxSnapshot 275 /nc; delete executor 82 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre = 'fixture 1 thru ' .. fixturecount[2] .. '; store group 47; group 47 at 100; store sequence 62 cue 1; assign sequence 62 executor 82; group 47 at 50; store sequence 63 cue 1; assign sequence 63 executor 82; select executor 82';
            cmd  = 'release group 47; store cue 2; clearall; goto executor 82 cue 2';
            post = 'label DmxSnapshot 275 "REL_GRP_1"; label sequence 62 "REL_GRP_1"; label sequence 63 "REL_GRP_2"; label executor 82 "REL_GRP_1"; label group 47 "REL_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 275;
            gold = 775;
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