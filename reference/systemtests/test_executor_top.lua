--*******************************************************************************************
-- This script tests the function top to an executor. 
-- Seq 158, Exec 62, DmxSnap 159
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "TOP";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 158 /nc; delete executor 62 /nc; delete DmxSnapshot 159 /nc';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 15; store sequence 158 cue 1 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 40; store sequence 158 cue 2 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 95; store sequence 158 cue 3 fade 4; assign sequence 158 at executor 62; ClearAll; >>> executor 62; >>> executor 62'; --executing cue 2
            pre_func = function () gma.echo('sleeping for 2 second'); gma.sleep(2); gma.echo('done'); end;
            cmd         = 'top executor 62'; --executing cue 1
            post        = 'label executor 62 "TOP_EXEC_1"; label sequence 158 "TOP_EXEC_1"; label DmxSnapshot 159 "TOP_EXEC_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 159;
            gold        = 659;
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