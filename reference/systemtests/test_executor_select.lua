--*******************************************************************************************
-- This script tests the method select for an executor.
-- Exec 55, Seq 151, DmxSnap 150
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELECT";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 55 /nc; delete sequence 151 /nc; delete DmxSnapshot 150 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru '.. fixturecount[2] ..' at 50; store sequence 151 cue 1 /nc; fixture 1 thru '.. fixturecount[2] ..' at 90; store sequence 151 cue 2; assign sequence 151 at executor 55; clearall';
            cmd  = 'select executor 55; on specialmaster 1.1';
            post = 'label sequence 151 "SEL_EXEC_1"; label executor 55 "SEL_EXEC_1"; label DmxSnapshot 150 "SEL_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 150;
            gold = 650;
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