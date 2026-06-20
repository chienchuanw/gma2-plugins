--*******************************************************************************************
-- This script tests the method to remove a selection. 
-- Seq 176, Exec 124
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "SELECTION";
    gs_name          = "CUE";
    pre              = 'ClearAll; delete sequence 176 cue 1 thru 99 /nc; delete executor 124 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 176 cue 1 /nc; assign sequence 176 executor 124; select executor 124; Fixture 1 thru ' .. fixturecount[2] .. ' at 50; Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            cmd  = 'remove selection; store cue 2 /nc';
            post = 'label sequence 176 "REM_SELE_1"';
            cleanup = '';
            test = {1,2};
            gold = {101.1,101.2};
        },
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