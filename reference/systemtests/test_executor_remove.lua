--*******************************************************************************************
-- This script tests the method to remove an executor.
-- Removing an executor is not really possible, the values are removed.
-- Seq 150, Exec 54, DMXsnap 149
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 54 /nc; delete sequence 150+354 /nc; delete DMXsnap 149 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 80; store sequence 150 cue 1; assign sequence 150 at executor 54; go executor 54';
            cmd  = 'remove executor 54; store sequence 150 cue 2 /nc; clearall; go executor 54';
            post = 'label executor 54 "REM_EXEC_1"; label sequence 150 "REM_EXEC_1"; label DMXsnap 149 "REM_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 149;
            gold = 649;
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