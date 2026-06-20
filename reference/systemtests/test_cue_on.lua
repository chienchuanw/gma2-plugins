--*******************************************************************************************
-- This script tests the methods to load a cue 
-- Seq 81, Exec 212, DmxSnap 55
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 212 /nc; delete sequence 81 /nc; delete DmxSnapshot 55 /nc';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture 1 thru ' ..fixturecount[2]+fixturecount[3].. 'at 57; store sequence 81 cue 1; assign sequence 81 at executor 212; fixture 1 thru ' ..fixturecount[2]+fixturecount[3].. ' at 50 thru 0; store sequence 81 cue 2 /use=active /nc; clearall; go executor 212';
            cmd  = 'on sequence 81 cue 2; at 50; store sequence 81 cue 3; goto executor 212 cue 3';
            post = 'label sequence 81 "CUE_ON"; label DmxSnapshot 55 "CUE_ON"';
            cleanup = '';
            test_dmx = true;
            test = 55;
            gold = 555;
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