--*******************************************************************************************
-- This script tests the insert operation in a DmxSnapshot pool. 
-- Inserting at an occupied place could influence the test.
-- set to destructive
-- DmxSnap 8 - 10
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "INSERT";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; delete DmxSnapshot 8 thru 10 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 20; store DmxSnapshot 8; Fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. ' at 54; store DmxSnapshot 9';
            cmd  = 'Insert DmxSnapshot 8 at 10 /nc';  -- 10 has to be available
            post= 'label DmxSnapshot 9 "INS_DMXS_2" label DmxSnapshot 10 "INS_DMXS_3"';
            cleanup = '';
            test_dmx= true;
            test = {8,9,10};
            gold = {-1,509,508};
            destructivetest= true;
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