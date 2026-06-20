--*******************************************************************************************
-- This script tests the methods to on a selection 
-- Seq 213, Exec 122
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "SELECTION";
    gs_name          = "CUE";
    pre              = 'ClearAll; delete sequence 213 cue 1 thru 99 /nc; delete executor 122 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 213 cue 1 /nc; assign sequence 213 executor 122; select executor 122; Fixture 1 thru ' .. fixturecount[2] .. '; Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            cmd  = 'on Selection; store sequence 213 cue 2 /nc';
            post = 'label sequence 213 "ON_SELE_1"';
            cleanup = '';
            test = 2;   --comparison of cues
            gold = 100.2;
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