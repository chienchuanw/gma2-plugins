--*******************************************************************************************
-- This script tests the methods to release a cue.
-- Seq 83, Exec 214, DmxSnap 57
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 83 /nc; delete DmxSnapshot 57 /nc; delete executor 214 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre= 'fixture 1 thru '..math.floor(fixturecount[2]/4)..' at 40; feature colorrgb at 80; store sequence 83 cue 1; feature colorrgb at 20; store sequence 83 cue 2; assign sequence 83 at executor 214';
            cmd  = 'release sequence 83 cue 2; feature colorrgb at 100; store sequence 83 cue 3; clearall; goto executor 214 cue 3';
            post = 'label executor 214 "REL_CUE_1"; label DmxSnapshot 57 "REL_CUE_1"; label sequence 83 "CUE_REL_1"';
            cleanup = '';
            test_dmx = true;
            test = 57;
            gold = 557;
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