--*******************************************************************************************
-- This script tests the go function to an executor.
-- Exec 34, Seq 135, DmxSnap 134
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name         = "GO";
    object_name         = "EXECUTOR";
    pre                 = 'ClearAll; delete sequence 135 /nc; delete executor 34 /nc; delete DmxSnapshot 134 /nc';

    steps =
    {
        {
            pre         = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 12 thru 82; store sequence 135 cue 1 /nc; assign sequence 135 at executor 34; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; attribute "Tilt" at 44 thru 136; store sequence 135 cue 2 /nc; clearall';
            cmd         = 'go executor 34';
            post        = 'label sequence 135 "GO_EXEC_1"; label executor 34 "GO_EXEC_1"; label DmxSnapshot 134 "GO_EXEC_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 134;
            gold        = 634;
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