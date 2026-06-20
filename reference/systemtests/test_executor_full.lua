--*******************************************************************************************
-- This script tests the possibilities of the full command to Executors 
-- Exec 33, Seq 134, DmxSnap 133
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 134 /nc; delete executor 33 /nc; delete DmxSnapshot 133 /nc';
    steps =
    {
        {
            pre  = 'fixture '..fixturecount[2]..' thru '..fixturecount[2]+ fixturecount[2]..' at 57; store sequence 134 cue 1 /nc; Assign sequence 134 at executor 33; executor 33 at 50; ClearAll';
            cmd  = 'executor 33 full; go executor 33';
            post = 'label executor 33 "FUL_EXEC_1"; label sequence 134 "FUL_EXEC_1"; label DmxSnapshot 133 "FUL_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 133;
            gold = 633;
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