--*******************************************************************************************
-- This script tests the move operation in a DmxSnapshot pool.
-- Moving to an occupied position means swapping.
-- Moving at an occupied position could influence the test.
-- set to ignore
-- DmxSnap 11 - 15
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; delete DmxSnapshot 11 thru 15 /nc ';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {  destructivetest= true;
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 20; store DmxSnapshot 11; Fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. ' at 54; store DmxSnapshot 12';
            cmd  = 'Move DmxSnapshot 11 at 12 /nc'; 
            post= 'label DmxSnapshot 12 "MOV_DMXS_1"';
            cleanup= 'off page thru ';
            test_dmx= true;
            test = {11,12};
            gold = {512,511};
        },
        {
            cmd  = 'Move DmxSnapshot 12 at 13 /nc';
            cleanup= 'off page thru ';
            test_dmx= true;
            test = {12,13};
            gold = {513,512};
        },
        {
            version_step = "3.4.0.0";
            cmd  = 'Move DmxSnapshot 13 at 14 + 15 /nc';
            cleanup = '';
            test_dmx= true;
            test = {13,14,15};
            gold = {512,513,513};
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