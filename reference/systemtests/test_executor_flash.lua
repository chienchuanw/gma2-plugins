--*******************************************************************************************
-- This script tests the possibilities of the flash command to Executors 
-- Exec 32, Seq 133, DmxSnap 131+132
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FLASH";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 133 /nc; delete executor 32 /nc; delete DmxSnapshot 131 + 132 /nc';
    steps =
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 57; store sequence 133 cue 1; Assign sequence 133 at executor 32; clearall';
            cmd  = 'flash executor 32';
            post = 'label executor 32 "FSH_EXEC_1"; label DmxSnapshot 131 "FSH_EXEC_1"; label sequence 133 "FSH_EXEC_1"';
            cleanup = 'flash off executor 32';
            test_dmx = true;
            test = 131;
            gold = 631;
        },
        {
            pre  = 'flash executor 32';
            cmd  = 'flash off executor 32';
            post = 'label DmxSnapshot 132 "FSH_EXEC_2';
           cleanup = '';
            test_dmx = true;
            test = 132;
            gold = 632;
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