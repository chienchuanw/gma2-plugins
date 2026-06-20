--*******************************************************************************************
-- This script tests the goback function to an executor. 
-- Exec 35 + 66, Seq 136 + 162, DmxSnap 135 + 162
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GOBACK";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 136 + 162 /nc; delete DmxSnapshot 135 + 162 /nc; delete executor 35 + 66 /nc';
   
    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; store sequence 136 cue 1 /nc; presettype color at 60; store sequence 136 cue 2; assign sequence 136 at executor 35; clearall';
            cmd         = 'GoBack executor 35'; --executes the last cue
            post        = 'label sequence 136 "GOB_EXEC_1"; label executor 35 "GOB_EXEC"; label DmxSnapshot 135 "GOB_EXEC"';
            cleanup = '';
            test_dmx    = true;
            test        = 135;
            gold        = 635;
        },
        {  --changing the timing of the goback command
            version_step = "3.3.0.0";
            pre         = 'fixture ' .. fixturecount[2] .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; store sequence 162 cue 1 /nc; presettype color at 60; store sequence 162 cue 2; assign sequence 162 at executor 66; cd settings; assign show /Goback=2; cd /';
            cmd         = 'GoBack executor 66'; --executes the last cue with a fade from 2 sec
            post        = 'label executor 66 "GOB_EXEC_2"; label sequence 162 "GOB_EXEC_2"; label DmxSnapshot 162 "GOB_EXEC_2"';
            cleanup     = 'cd settings; assign show /Goback=0';
            test_dmx    = true;
            test        = 162;
            gold        = 662;
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