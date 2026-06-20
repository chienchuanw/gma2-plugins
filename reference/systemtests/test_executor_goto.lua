--*******************************************************************************************
-- This script tests the goto function to an executor. 
-- Exec 36, Seq 137, DmxSnap 136
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GOTO";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 137 /nc; delete DmxSnapshot 136 /nc; delete executor 36 /nc';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 99; store sequence 137 cue 1 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; attribute "Tilt" at 44 thru 136; store sequence 137 cue 2 /nc; assign sequence 137 executor 36; clearall';
            cmd         = 'Goto executor 36 cue 2';
            post        = 'label sequence 137 "GOT_EXEC"; label executor 36 "GOT_EXEC";  label DmxSnapshot 136 "GOT_EXEC"';
            cleanup = '';
            test_dmx    = true;
            test        = 136;
            gold        = 636;
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