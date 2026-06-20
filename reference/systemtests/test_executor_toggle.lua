--*******************************************************************************************
-- This script tests the methods to toggle an executor.
-- Exec 61, Sequ 157,  DmxSnap 157+158
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "TOGGLE";
    object_name = "EXECUTOR";
    pre         = 'ClearAll; delete executor 61 /nc; delete sequence 157 /nc; delete DmxSnapshot 157+158 /nc';
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. 'at 68; attribute "colorrgb1" at 85; store sequence 157 cue 1; assign sequence 157 at executor 61; clearall';
            cmd  = 'toggle executor 61'; -- on executor
            post = 'label executor 61 "TOG_EXEC_1"; label sequence 157 "TOG_EXEC_1"; label DmxSnapshot 157 "TOG_EXEC_1"';
           cleanup = '';
            test_dmx = true;
            test = 157;
            gold = 657;
        },
        {
            cmd  = 'toggle executor 61';  -- off executor
            post = 'label DmxSnapshot 158 "TOG_EXEC_2"';
            cleanup = '';
            test_dmx = true;
            test = 158;
            gold = 658;
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