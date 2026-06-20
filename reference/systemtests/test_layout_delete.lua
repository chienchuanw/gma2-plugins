--*******************************************************************************************
-- This script tests the methods to delete a layout 
-- Layout 6 - 9
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 6 thru 9 /nc; fixture 1 thru ' .. fixturecount[2] .. '; store layout 6 thru 9 /overwrite; clearall';
    steps =
    {
        {
            cmd  = 'delete layout 6 /nc';
            test = 6;
            gold = -1;
        },
        {
            cmd  = 'delete layout 7 thru 9 /nc';
            cleanup = '';
            test = {7,8,9};
            gold = {-1,-1,-1};
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