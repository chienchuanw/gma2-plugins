--*******************************************************************************************
-- This script tests the function skip >>> to an executor.
-- Seq 154, Exec 58, DmxSnap 153
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "SKIPFW";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 154 /nc; delete executor 58 /nc; delete DmxSnapshot 153 /nc';

    steps =
   {
      {
         pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 85; store sequence 154 cue 1 fade 2; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 40; store sequence 154 cue 2 fade 3; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]-1 .. ' at 95; store sequence 154 cue 3 fade 4; assign sequence 154 at executor 58; ClearAll; goto executor 58 cue 2';
         cmd         = '>>> executor 58'; --executes cue 3
         post        = 'label executor 58 "SKIP_EXEC_2"; label sequence 154 "SKIP_EXEC_2"; label DmxSnapshot 153 "SKIP_EXEC_2"';
         cleanup = '';
         test_dmx    = true;
         test        = 153;
         gold        = 653;
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