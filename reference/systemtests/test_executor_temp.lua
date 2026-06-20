--*******************************************************************************************
-- This script tests the possibilities of the temp command to Executors 
-- Exec 59, Seq 155, DmxSnap 154+155
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "TEMP";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 155 /nc; delete executor 59 /nc; delete DmxSnapshot 154+155 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 65; store sequence 155 cue 1; Assign sequence 155 at executor 59';
            cmd  = 'temp executor 59';  
            post = 'label executor 59 "TMP_EXEC_1"; label sequence 155 "TEP_EXEC_1"; label DmxSnapshot 154 "TMP_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 154;
            gold = 654;
        },
        {
            pre  = '';
            cmd  = 'temp off executor 59';
            post = 'label DmxSnapshot 155 "TMP_EXEC_2"';
            cleanup = '';
            test_dmx = true;
            test = 155;
            gold = 655;
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