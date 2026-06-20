--*******************************************************************************************
-- This script tests the method off to an executor 
-- Exec 46, Seq 143, DmxSnap 141
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 46 /nc; delete sequence 143 /nc; delete DmxSnapshot 141 /nc';
    steps=
    {
        {
            pre  = 'Channel 1 thru '.. fixturecount[1] ..' at 33; Store sequence 143 cue 1 /nc; assign sequence 143 at executor 46; clearall; go executor 46';
            cmd  = 'off executor 46';
            post = 'label executor 46 "OFF_EXEC"; label sequence 143 "OFF_EXEC"; label DmxSnapshot 141 "OFF_EXEC"';
            cleanup = '';
            test_dmx = true;
            test = 141;
            gold = 641;
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