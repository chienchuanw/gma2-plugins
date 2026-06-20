--*******************************************************************************************
-- This script tests the method at to a selection. 
-- Seq 211, Exec 120
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name     = "AT";
    object_name     = "SELECTION";
    gs_name         = "CUE";
    pre             = 'ClearAll; delete sequence 211 cue 1 thru 99 /nc; delete executor 120 /nc';  --golden cues up from 100
    steps =
    {
        {
            pre  = 'Fixture 1 at 100; store sequence 211 cue 1 /nc; assign sequence 211 at executor 120; select executor 120; Fixture 2 thru ' .. fixturecount[2];
            cmd  = 'Selection at Fixture 1; store sequence 211 cue 2 /nc';
            post = 'label sequence 211 "AT_SELE_1"';
            cleanup = '';
            test = 2;  --comparison of cues
            gold = 102;
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