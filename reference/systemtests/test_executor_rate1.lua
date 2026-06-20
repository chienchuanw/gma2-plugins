--*******************************************************************************************
-- This script tests the method rate1 for an executor.
-- Comparing for timinig stuff is not possible.
-- Exec 52, Seq 148,  DmxSnap 147
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RATE1";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 52 /nc; delete sequence 148 /nc; delete DmxSnapshot 147 /nc';
    version_script   = '3.3.0.0';

    steps =
    {
        {
            smoketest = true;
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 75; store sequence 148 cue 1; assign sequence 148 at executor 52';
            cmd  = 'rate1 executor 52';
            post = 'label sequence 148 "RAT_EXEC_1"; label executor 52 "RAT_EXEC_1"; label DmxSnapshot 147 "RAT_EXEC_1"';
            cleanup = '';
            --[[test_dmx = true;
            test = 147;
            gold = 647;]]
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