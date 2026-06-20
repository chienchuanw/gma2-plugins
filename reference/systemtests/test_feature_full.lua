--*******************************************************************************************
-- This script tests the method full to a feature.
-- Sequ 112, Exec 204, DmxSnap 212
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "FEATURE";
    pre              = 'ClearAll; delete sequence 112 /nc; delete Executor 204 /nc; delete DmxSnapshot 212 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 71';
            cmd  = 'feature colorrgb full; store sequence 112 cue 1 /nc; assign sequence 112 at executor 204; clearall; go executor 204';
            post = 'label sequence 112 "FULL_FEA_1"; label executor 204 "FULL_FEA_1"; label DmxSnapshot 212 "FULL_FEA_1" ';
            cleanup = '';
            test_dmx = true;
            test = 212;
            gold = 712;
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