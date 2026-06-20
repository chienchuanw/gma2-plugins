--*******************************************************************************************
-- This script tests the method to remove a group.
-- for comparing cues an executor is needed
-- Seq 64, Group 48, Exec 83
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name     = "REMOVE";
    object_name     = "GROUP";
    gs_name         = "CUE";
    pre             = 'ClearAll; delete sequence 64 cue 1 thru 99 /nc; delete group 48 /nc; delete executor 83 /nc'; --do not delete the golden cues 101..
    steps =
    {
        {
            pre = 'Fixture 1 thru ' .. fixturecount[2] .. '; store group 48; group 48 at 100; store sequence 64 cue 1 /nc; assign sequence 64 at executor 83; select executor 83';
            cmd  = 'remove group 48; store sequence 64 cue 2 /nc';
            post = 'label sequence 64 "REM_GRP_1"; label group 48 "REM_GRP_1"; label Executor 83 "REM_GRP_1"';
            cleanup = '';
            test = {1,2}; --comparison of cues
            gold = {101.1,101.2};
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