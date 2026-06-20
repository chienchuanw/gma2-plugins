--*******************************************************************************************
-- This script tests the method to release a sequence. 
-- Seq 32, Exec 202, DmxSnap 456
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "SEQUENCE";
    pre              = 'ClearAll; delete sequence 32 /nc; delete executor 202 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 100; store sequence 32 cue 1; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 60; feature colorrgb at 50; store sequence 32 cue 2; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 80; feature colorrgb at 90; store sequence 32 cue 3; assign sequence 32 at executor 202; go executor 202';
            cmd  = 'release sequence 32; Fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. ' at 20; store sequence 32 cue 4; go executor 202';
            post = 'label executor 202 "REL_SEQ_1"; label DmxSnapshot 456 "REL_SEQ_1"; label sequence 32 "REL_SEQ_1"';
            cleanup = '';
            test_dmx = true;
            test = 456;
            gold = 956;
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