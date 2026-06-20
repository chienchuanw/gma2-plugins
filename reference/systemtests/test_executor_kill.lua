--*******************************************************************************************
-- This script tests the possibilities of the kill command to Executors
-- Exec 37+38, Seq 138+139, DmxSnap 137
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "KILL";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 37+38 /nc; delete sequence 138+139 /nc; delete DmxSnapshot 137 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 0 thru 95; store sequence 138 cue 1 /nc; assign sequence 138 at executor 37; fixture 1 thru ' .. fixturecount[2] .. ' at 0 thru 95; store sequence 139 cue 1 /nc; assign sequence 139 at executor 38; clearall; go executor 37+38';
            cmd  = 'kill executor 38';
            post = 'label executor 37 "KIL_EXEC_1"; label executor 38 "KIL_EXEC_2"; label sequence 138 "KIL_EXEC_1"; label sequence 139 "KIL_EXEC_2"; label DmxSnapshot 137 "KIL_EXEC"';
            cleanup = '';
            test_dmx = true;
            test = 137;
            gold = 637;
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