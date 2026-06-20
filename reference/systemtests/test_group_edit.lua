--*******************************************************************************************
-- This script tests the edit operation in a group pool. 
-- Group 32
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "GROUP";
    pre              = 'Clearall; delete Group 32 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. '; store Group 32;';
            cmd  = 'edit Group 32; fixture 1 thru ' .. fixturecount[2] .. '; update group 32 /nc';
            post= ' label Group 32 "EDIT_GROUP_1"';
            cleanup = '';
            test = 32;
            gold = 132;
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