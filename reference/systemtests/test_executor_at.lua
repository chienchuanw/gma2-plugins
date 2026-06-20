--*******************************************************************************************
-- This script tests the possibilities of the at command to Executors 
-- Exec 19, Seq 128, DmxSnap 123
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "EXECUTOR";                                  
    pre              = 'ClearAll; delete sequence 128 /nc; delete executor 19 /nc; delete DmxSnapshot 123 /nc';
    steps =
    {
        {
            pre  = ' fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 128 cue 1; Assign sequence 128 at executor 19; clearall';
            cmd  = 'executor 19 at 50; go executor 19';
            post = 'label executor 19 "AT_EXEC_1"; label DmxSnapshot 123 "AT_EXEC_1"; label sequence 128 "AT_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 123;
            gold = 623;
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