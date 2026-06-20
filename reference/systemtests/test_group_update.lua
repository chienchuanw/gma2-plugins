--*******************************************************************************************
-- This script tests the methods to update a group. 
-- Group 53
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 53 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2]..'; store Group 53 /nc; fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            cmd  = 'update Group 53 /nc';
            post = 'label Group 53 "UPD_GRP_1"';
            cleanup = '';
            test = 53;
            gold = 153;
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