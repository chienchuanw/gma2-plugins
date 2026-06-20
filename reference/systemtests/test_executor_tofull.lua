--*******************************************************************************************
-- This script tests the possibilities of the toFull command to Executors 
-- Exec 60, Sequ 156, DmxSnap 156
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TOFULL";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 60 /nc; delete sequence 156 /nc; delete DmxSnapshot 156 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 75; store sequence 156 cue 1; assign sequence 156 at executor 60; executor 60 at 50; clearall';
            cmd  = 'toFull executor 60';
            post = 'label executor 60 "TOFU_EXEC_1"; label sequence 156 "TOFU_1"; label DmxSnapshot 156 "TOFU_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 156;
            gold = 656;
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