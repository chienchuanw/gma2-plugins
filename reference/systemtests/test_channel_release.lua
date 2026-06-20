--*******************************************************************************************
-- This script tests to release a channel 
-- Seq 53, Exec 3, DmxSnap 36
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "CHANNEL";
    pre              = 'ClearAll; delete DmxSnapshot 36 /nc; delete sequence 53 /nc; delete executor 3 /nc';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru '.. fixturecount[1] ..' at 80; Store sequence 53 cue 1; assign sequence 53 at executor 3; clearall; go executor 3';
            cmd  = 'Release Channel 1; store sequence 53 cue 2; clearall; goto executor 3 cue 2'; --channel 1 is set back to default value ->closed
            post = 'label sequence 53 "REL_CH_1"; label DmxSnapshot 36 "REL_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 36;
            gold = 536;
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