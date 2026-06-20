--*******************************************************************************************
-- This script tests the methods to delete a group. 
-- Group 12 - 17
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "GROUP";
    pre              = 'Clearall; delete group 12 thru 17 /nc';
   
    steps =
    {
        {
            pre = 'fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. '; store Group 12 /nc';
            cmd  = 'delete Group 12 /nc';
            cleanup = '';
            test = 12;
            gold = -1;
        },
        {  --deleting many groups
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. '; store Group 13 thru 15 /nc';
            cmd  = 'delete Group 13 thru 15 /nc';
            cleanup = '';
            test = {13,14,15};
            gold = {-1,-1,-1};
        },
        {  --deleting by label
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. '; store Group 16 thru 17 /nc; label group 16 "hubba"; label group 17 "bubba"';
            cmd  = 'delete Group "*ubba" /nc';
            cleanup = '';
            test = {16,17};
            gold = {-1,-1};
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