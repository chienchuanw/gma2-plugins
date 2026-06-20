--*******************************************************************************************
-- This script tests the methods to assign a cue. 
-- Seq 72, Exec 205
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 72 cue 1 thru 99 /nc; delete executor 205 /nc; delete DMXsnapshot 50 /nc';  --do not delete the golden cues 101..
    steps=
    {
        {
            pre  = 'store sequence 72 cue 101 /nc; assign sequence 72 at executor 205; select executor 205; fixture 3 + 4 at 50; store sequence 72 cue 1 /use=Active /nc';
            cmd  = 'assign sequence 72 cue 1 fade 7; assign sequence 72 cue 1 outfade 10.5; assign sequence 72 cue 1 delay 2; assign sequence 72 cue 1 outdelay 3.5; assign sequence 72 cue 1 snap 5; assign sequence 72 cue 1 /trig=time /trigTime=5 /info="Assigend with CMD" /fade_dimmer=20 /delay_position=20; clearall; go sequence 72';
            post = 'label sequence 72 "ASS_CUE_1"; label sequence 72 cue 1 "assign"; label sequence 72 cue 101 "golden cue list from here"';
            cleanup = '';
            test = 1;  --comparing cues
            gold = 101.1; 
        }
    }
};

RegisterTestScript(test);

--*******************************************************************************************
-- module entry point
--*******************************************************************************************

local function StartThisTest()
   StartSingleTestScript(test);
end

return StartThisTest;