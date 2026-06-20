--*******************************************************************************************
-- This script tests the methods to park a cue.
-- Seq 82, Exec 7, DmxSnap 56
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 7 /nc; delete sequence 82 /nc; delete DmxSnapshot 56 /nc';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 50 thru 0; store sequence 82 cue 1 /use=active /nc; clearall; assign sequence 82 at executor 7; go executor 7';
            cmd  = 'park sequence 82 cue 1; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 50'; -- dmx output is now at 50 thru 0
            post = 'label DmxSnapshot 56 "CUE_PAR"';
            cleanup = 'unpark seq 82 cue 1';
            test_dmx = true;
            test = 56;
            gold = 556;
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