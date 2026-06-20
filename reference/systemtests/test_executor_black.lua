--*******************************************************************************************
-- This script tests the possibilities of the black command to Executors
-- Exec 20, Seq 129, DmxSnap 124+125
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "BLACK";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 129 /nc; delete executor 20 /nc; delete DmxSnapshot 124+125 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 90; store sequence 129 cue 1 /nc; Assign sequence 129 at executor 20; clearall; go executor 20';
            cmd  = 'black executor 20';
            post = 'label executor 20 "BLK_EXEC_1"; label sequence 129 "BLK_EXEC_1"; label DmxSnapshot 124 "BLK_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 124;
            gold = 624;
        },
        {
            pre = 'clearall; go executor 20; black executor 20';
            cmd  = 'black off executor 20';
            post = 'label DmxSnapshot 125 "BLK_EXEC_2"';
            cleanup = '';
            test_dmx = true;
            test = 125;
            gold = 625;
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