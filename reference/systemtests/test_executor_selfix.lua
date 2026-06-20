--*******************************************************************************************
-- This script tests the method select the fixtures of an executor 
-- Exec 56, Seq 152, DMXsnap 151
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "EXECUTOR";
    pre              = 'ClearAll; delete sequence 152 /nc; delete executor 56 /nc; delete DMXsnapshot 151 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 55; store sequence 152 cue 1; assign sequence 152 at executor 56; clearall; go executor 56';
            cmd  = 'selfix executor 56 at 66; store sequence 152 cue 2; clearall; goto executor 56 cue 2';
            post = 'label sequence 152 "SLF_EXEC_1"; label executor 56 "SLF_EXEC_1"; label DMXsnapshot 151 "SLF_EXEC_1"';
            cleanup = '';
            test_dmx = true;
            test = 151;
            gold = 651;
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