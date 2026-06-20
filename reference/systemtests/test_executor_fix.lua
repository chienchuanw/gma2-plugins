--*******************************************************************************************
-- This script tests the possibilities of the fix command to Executors. 
-- Exec 31, Seq 132, DmxSnap 130
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FIX";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; buttonpage 1; delete sequence 132 /nc; delete executor 31 /nc; delete DmxSnapshot 130 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 10 thru 90; store sequence 132 cue 1; Assign sequence 132 at executor 31; ClearAll';
            cmd  = 'fix executor 31; buttonpage 2; clearall; go executor 31';
            post = 'label executor 31 "FIX_EXEC_1"; label DmxSnapshot 168 "FIX_EXEC_1"; label sequence 132 "FIX_EXEC_1" ';
            cleanup = 'fix off executor 31; buttonpage 1';
            test_dmx = true;
            test = 130;
            gold = 630;
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