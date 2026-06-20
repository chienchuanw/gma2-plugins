--*******************************************************************************************
-- This script tests the methods to off a group.
-- Group 45, DmxSnap 273
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete group 45 /nc; delete DmxSnapshot 273 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' store group 45; group 45 at 45';
            cmd  = 'off group 45';
            post = 'label Group 45 "OFF_GRP_1"; label DmxSnapshot 273 "OFF_GRP_1"';
            cleanup = '';
            test_dmx = true;
            test = 273;
            gold = 773;
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