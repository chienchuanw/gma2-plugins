--*******************************************************************************************
-- This script tests the method on to an executor.
-- Exec 47, Seq 144, DmxSnap 142
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 47 /nc; delete sequence 144 /nc; delete DmxSnapshot 142 /nc';
    steps=
    {
        {
            pre  = 'fixture 1 thru '.. fixturecount[1] ..' at 33; Store sequence 144 cue 1 /nc; assign sequence 144 at executor 47; clearall';
            cmd  = 'on executor 47';
            post = 'label executor 47 "ON_EXEC"; label sequence 144 "ON_EXEC"; label DmxSnapshot 142 "ON_EXEC"';
            cleanup = '';
            test_dmx = true;
            test = 142;
            gold = 642;
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