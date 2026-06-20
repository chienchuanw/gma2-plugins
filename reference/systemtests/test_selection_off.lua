--*******************************************************************************************
-- This script tests the methods to off a selection 
-- Seq 212, Exec 121
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "SELECTION";
    gs_name          = "CUE";
    pre              = 'ClearAll; delete sequence 212 cue 1 thru 99 /nc; delete executor 121 /nc';  --golden cues up from 100
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. ' at 100; store sequence 212 cue 1 /nc; assign sequence 212 executor 121; select executor 121; Fixture 1 thru ' .. fixturecount[2] .. ' at 100; Fixture 1 thru ' .. math.floor(fixturecount[2]/2);
            cmd  = 'off Selection; store cue 2 /nc';
            post = 'label sequence 212 "OFF_SELE_1"';
            cleanup = '';
            test = 2;
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