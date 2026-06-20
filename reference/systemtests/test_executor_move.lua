--*******************************************************************************************
-- This script tests the possibilities of the move command to Executors. 
-- Exec 40-45, Sequ 141+142, DmxSnap 139+140
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 40 thru 45 /nc; delete sequence 141 + 142 /nc; delete DMXsnapshot 139 + 140 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 59; store sequence 141 cue 1 /nc; assign sequence 141 at executor 40';
            cmd  = 'move executor 40 at 41; clearall; go executor 41';
            post = 'label executor 41 "MOV_EXEC_1"; label sequence 141 "MOV_EXEC_1"; label DMXsnapshot 139 "MOV_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 139;
            gold= 639;
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