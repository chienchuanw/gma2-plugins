--*******************************************************************************************
-- This script tests the operation off for layouts. 
-- Layout 21, Sequence 192, Exec 92; DMXsnap 291
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "LAYOUT";
    pre              = 'ClearAll; delete layout 21 /nc; delete sequence 192 /nc; delete executor 92 /nc; delete DMXsnapshot 291 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' ..math.floor(fixturecount[2]/4)..'; store layout 21 /nc; clearall; fixture 1 thru ' ..math.floor(fixturecount[2]/3)..' at 90; store sequence 192 cue 1; assign sequence 192 at executor 92; clearall; selfix executor 92';
            cmd  = 'off layout 21; at 85; store sequence 192 cue 2; clearall; goto executor 92 cue 2';  
            post = 'label layout 21 "OFF_LAY_1"';
            cleanup = '';
            test_dmx = true;
            test = 291;
            gold = 791;
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