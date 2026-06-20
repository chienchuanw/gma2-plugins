--*******************************************************************************************
-- This script tests the methods to unpark a cue 
-- Seq 86, Exec 12, DmxSnap 60
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 12 /nc; delete sequence 86 /nc; delete DmxSnapshot 60 /nc';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 50 thru 10; store sequence 86 cue 1 /use=active /nc; park cue 1; assign sequence 86 at executor 12; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 45';
            cmd  = 'unpark sequence 86 cue 1';
            post = 'label sequence 86 "CUE_UNP"; label executor 12 "CUE_UNP"; label DmxSnapshot 60 "CUE_UNP"';
            cleanup = '';
            test_dmx = true;
            test = 60;
            gold = 560;
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