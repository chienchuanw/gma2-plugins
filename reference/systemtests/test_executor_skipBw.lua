--*******************************************************************************************
-- This script tests the function skip <<< to an executor. 
-- Exec 57, Seq 153, DMXsnap 152
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "SKIPBW";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 153 /nc; delete executor 57 /nc; delete DmxSnapshot 152 /nc';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 85; store sequence 153 cue 1 fade 2; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 40; store sequence 153 cue 2 fade 3; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 95; store sequence 153 cue 3 fade 4; assign sequence 153 at executor 57; ClearAll; go executor 57';
            cmd         = '<<< executor 57'; --started with cue 1, executes the last cue 
            post        = 'label executor 57 "SKIP_EXEC_1"; label sequence 153 "SKIP_EXEC_1"; label DmxSnapshot 152 "SKIP_EXEC_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 152;
            gold        = 652;
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