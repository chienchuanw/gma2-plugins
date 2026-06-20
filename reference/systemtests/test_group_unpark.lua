--*******************************************************************************************
-- This script tests the method to unpark a group. 
-- Group 53, DmxSnap 278
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 53/nc; delete DmxSnapshot 278 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; store Group 53; Group 53 at 100; park Group 53';
            cmd  = 'unpark Group 53; Group 53 at 53';
            post = 'label DmxSnapshot 278 "UNP_GRP_1"; label group 53 "UNP_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 278;
            gold = 778;
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