--*******************************************************************************************
-- This script tests the possibilities of the toZero command to Executors 
-- Exec 63, Sequ 159, DmxSnap 160
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TOZERO";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 63 /nc; delete sequence 159 /nc; delete DmxSnapshot 160 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 80; store sequence 159 cue 1 /nc; assign sequence 159 at executor 63; ClearAll; toFull executor 63';
            cmd  = 'toZero executor 63';
            post = 'label executor 63 "TOZE_EXEC_1"; label sequence 159 "TOZE_EXE_1"; label DmxSnapshot 160 "TOZE_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 160;
            gold = 660;
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