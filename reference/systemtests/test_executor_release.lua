--*******************************************************************************************
-- This script tests the method to release an executor. 
-- Seq 149, Exec 53, DMXsnap 148
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete executor 53 /nc; delete sequence 149 /nc; delete DMXsnapshot 148 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 88; store sequence 149 cue 1 /nc; assign sequence 149 at executor 53; clearall; go executor 53';
            cmd  = 'release executor 53; Fixture 1 thru ' .. fixturecount[2] .. ' at 27; store sequence 149 cue 2 /nc; goto executor 53 cue 2';
            post = 'label executor 53 "REL_EXEC_1"; label sequence 149 "REL_EXEC_1"; label dmxsnapshot 148 "REL_EXEC_1"';
            cleanup = '';
            test_dmx= true;
            test = 148;
            gold = 648;   
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