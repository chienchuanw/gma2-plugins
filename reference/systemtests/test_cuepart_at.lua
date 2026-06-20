--*******************************************************************************************
-- This script tests the method at to a cuepart. 
-- Seq 93, Exec 103
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "AT";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 103 /nc; delete sequence 93 cue 1 /nc; select executor 103'; --golden cueparts in cue 2
    
    steps=
    {
        {
            pre  = 'fixture 1 at 65; store sequence 93 cue 1 part 1 /nc; assign sequence 93 at executor 103; store sequence 93 cue 2 part 1 /nc; fixture 3 thru 10 at 99; store sequence 93 cue 1 part 2 /nc';
            cmd  = 'fixture 2 at 100; store sequence 93 cue 1 part 2 /overwrite /nc';
            post = 'label sequence 93 "CUEP_AT"; label executor 103 "CUEP_AT"';
            cleanup = '';
            test = 2;  --cue 1 part 2
            gold = 102;  --cue 2 part 102
        },
        {
            pre  = 'fixture 11 thru 999 at 25; attribute colorrgb1 at 50; attribute colorrgb2 at 75; store sequence 93 cue 1 part 3 /nc';
            cmd  = 'fixture 1000 at 50; attribute colorrgb1 at 70; store sequence 93 cue 1 part 4 /nc;';
            cleanup = '';
            test = 4;  --cue 1 part 4
            gold = 104;  --cue 1 part 104
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