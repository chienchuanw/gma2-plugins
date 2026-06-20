--*******************************************************************************************
-- This script tests the method update for an executor.
-- Exec 65, Seq 161,  DmxSnap 163,
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 65 /nc; delete sequence 161 /nc; delete DmxSnapshot 163 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 55; store sequence 161 cue 1; assign sequence 161 at executor 65; clearall; on executor 65; fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 90';
            cmd  = 'update executor 65';
            post = 'label sequence 161 "UPD_EXEC_1"; label executor 65 "UPD_EXEC_1"; label DmxSnapshot 163 "UPD_EXEC_1"';
            cleanup = '';
            test_dmx=true;
            test = 163;
            gold = 663;
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