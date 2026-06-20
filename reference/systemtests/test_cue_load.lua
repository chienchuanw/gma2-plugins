--*******************************************************************************************
-- This script tests the methods to load a cue.
-- Seq 79, Exec 210, DmxSnap 54
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "LOAD";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 210 /nc; delete DmxSnapshot 54/nc; delete sequence 79 /nc';
    version_script   = '3.2.53.0';

    steps=
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; store sequence 79 cue 1 /use=active /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 75; store sequence 79 cue 2 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 55; store sequence 79 cue 3 /nc; assign sequence 79 at executor 210; clearall';
            cmd  = 'select executor 210; load sequence 79 cue 3; go executor 210';
            post = 'label DmxSnapshot 54 "CUE_LOD"; label executor 210 "CUE_LOD"; label sequence 79 "CUE_LOD"';
            cleanup = '';
            test_dmx = true;
            test = 54;
            gold = 554;
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