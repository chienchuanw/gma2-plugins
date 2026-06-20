--*******************************************************************************************
-- This script tests to remove a channel 
-- Seq 54, Exec 4, DmxSnap 37
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "CHANNEL";
    pre              = 'ClearAll, delete DmxSnapshot 37 /nc; delete executor 4 /nc; delete sequence 54 /nc';
   
    steps =
    {
        {
            pre  = 'Channel 1 thru '.. fixturecount[1] ..' at 85; Store sequence 54 cue 1 /nc; assign sequence 54 at executor 4; clearall; go executor 4';
            cmd  = 'Remove Channel 1; Store sequence 54 cue 2; clearall; goto executor 4 cue 2';
            post = 'label sequence 54 "REM_CH_1"; label DmxSnapshot 37 "REM_CH_1"';
            cleanup = '';
            test_dmx = true;
            test = 37;
            gold = 537;
        },
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