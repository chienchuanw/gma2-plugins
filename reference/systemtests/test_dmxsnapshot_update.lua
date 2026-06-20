--*******************************************************************************************
-- This script tests the methods to update a DmxSnapshot. 
-- Update at an occupied place could influence the test.
-- set to ignore
-- DmxSnap 16 + 17 
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "DMXSNAPSHOT";
    pre              = 'ClearAll; delete DmxSnapshot 16 thru 17 /nc; fixture 1 thru ' .. fixturecount[2] .. ' at 37.5; store DmxSnapshot 16 + 17';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {  destructivetest= true;
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 38.5';
            cmd  = 'update DmxSnapshot 16 /nc';
            post = 'label DmxSnapshot 16 "UPD_DMXS_1"; label DmxSnapshot 17 "UPD_DMXS_2"';
            test_dmx= true;
            test = 16;
            gold = 516;
        },
        {
            pre  = 'ClearAll; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 17.34';
            cmd  = 'update DmxSnapshot 17 "UPD_DMXS_2" /nc';
            cleanup = '';
            test_dmx= true;
            test = 17;
            gold = 517;
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