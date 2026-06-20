--*******************************************************************************************
-- This script tests the possibilities of the call command to Executors. 
-- Exec 21, Seq 130, DmxSnap 126
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CALL";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 130 /nc; delete executor 21 /nc; delete DmxSnapshot 126 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 45; store sequence 130 cue 1; Assign sequence 130 at executor 21; clearall';
            cmd  = 'call executor 21';
            post = 'label executor 21 "CAL_EXEC_1"; label sequence 130 "CAL_EXEC_1"; label DmxSnapshot 126 "CAL_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 126;
            gold = 626;
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