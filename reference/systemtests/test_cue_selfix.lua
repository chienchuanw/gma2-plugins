--*******************************************************************************************
-- This script tests the method select the fixtures of a cue 
-- Exec 11, Seq 85, DmxSnap 59
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 85 /nc; delete DmxSnapshot 59 /nc; delete executor 11 /nc';
    version_script   = '3.2.53.0';

    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. '; store sequence 85 cue 1 /nc; assign sequence 85 at executor 11; select executor 11';
            cmd  = 'selfix sequence 85 cue 1; at 100';
            post = 'label sequence 85 "CUE_SELF"; label executor 11 "CUE_SELF"; label DmxSnapshot 59 "CUE_SELF"';
            cleanup = '';
            test_dmx = true;
            test = 59;
            gold = 559;
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