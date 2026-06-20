--*******************************************************************************************
-- This script tests the methods to assign a cue part. 
-- Seq 92, Exec 102
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ASSIGN";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 102 /nc; delete sequence 92 cue 1 /nc; select executor 102'; --golden cueparts in cue 2

    steps=
    {
        {
            pre  = 'fixture 3 + 4 at 50; store sequence 92 cue 1 part 1 /track=off; assign sequence 92 at executor 102; store sequence 92 cue 2 part 1 /nc; fixture 5 at 99; store sequence 92 cue 1 part 2 /nc';
            cmd  = 'assign sequence 92 cue 1 part 2 fade 5; assign sequence 92 cue 1 part 2 outfade 10.5; assign sequence 92 cue 1 part 2 delay 2; assign sequence 92 cue 1 part 2 outdelay 3.5; assign sequence 92 cue 1 part 2 snap 5; assign sequence 92 cue 1 part 2 /trig=time /trigTime=5 /info="Assigend with CMD" /fade_dimmer=20 /delay_position=20';
            post= 'label sequence 92 "CUEP_ASS"';
            cleanup = '';
            test = 2; --cue 1 part 2
            gold = 102;  --cue 2 part 102
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