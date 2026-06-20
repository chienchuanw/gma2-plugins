--*******************************************************************************************
-- This script tests the method select the fixtures of a group 
-- Group 49 + 50
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "GROUP";
    pre              = 'ClearAll; delete Group 49 thru 50 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; store Group 49';
            cmd  = 'selfix Group 49; store Group 50';
            post = 'label Group 49 "SELF_GRP_1"; label Group 50 "SELF_GRP_2"';
            cleanup = '';
            test = {49,50};
            gold = {149,150};
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