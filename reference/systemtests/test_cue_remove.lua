--*******************************************************************************************
-- This script tests the methods to remove a cue 
-- Seq 84, Exec 10, DmxSnap 58
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 84 cue 1 thru 99 /nc; delete DmxSnapshot 58 /nc; delete executor 10 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre ='fixture 1 thru ' .. math.floor(fixturecount[2]/3) .. ' at 100; store sequence 84 cue 1 /nc; assign sequence 84 at executor 10; fixture 1 thru ' .. fixturecount[2] .. ' at 58; store sequence 84 cue 2 /nc';
            cmd  = 'remove sequence 84 cue 1; store sequence 84 cue 3; clearall; goto executor 10 cue 3';
            post = 'label DmxSnapshot 58 "REM_CUE_1"; label sequence 84 "CUE_REM_1"; label executor 10 "CUE_REM_2"';
            cleanup = '';
            test_dmx = true;
            test = 58;
            gold = 558;
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