--*******************************************************************************************
-- This script tests the methods to delete a DmxSnapshot
-- DmxSnap 3-5
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; fixture 1 thru ' .. math.floor(fixturecount[2]/4) .. ' at 100; store DmxSnapshot 3 thru 5 /overwrite';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            cmd  = 'delete DmxSnapshot 3 /nc';
            test = 3;
            gold = -1;
        },
        {
            cmd  = 'delete DmxSnapshot 4 thru 5 /nc';
            test = {4,5};
            gold = {-1,-1};
            cleanup = '';
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