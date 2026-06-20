--*******************************************************************************************
-- This script test the multiple options to move a cuepart.
-- Seq 97, Exec 107
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 97 cue 1 /nc; delete executor 107 /nc; select executor 107';
    steps =
    {
        {   --moving a cuepart to an avilable position
            pre  = 'fixture 3 + 4 at 35; store sequence 97 cue 1 part 1 /nc; assign sequence 97 at executor 107; store sequence 97 cue 2 part 1 /nc; fixture 5 at 25; store sequence 97 cue 1 part 2 /nc';
            cmd  = 'move sequence 97 cue 1 part 2 at sequence 97 cue 1 part 3 /nc';  
            post = 'label sequence 97 "CUEP_MOV"; label executor 107 "CUEP_MOV"';
            test = 3;   --cue 1 part 3
            gold = 103; --cue 2 part 103
        },
        {   --moving a cuepart to an occupied position
            pre  = 'fixture 6 at 55; store sequence 97 cue 1 part 4 /nc; fixture 7 thru 30 at 76; store sequence 97 cue 1 part 5 /nc';
            cmd  = 'move sequence 97 cue 1 part 4 at sequence 97 cue 1 part 5 /nc';  --means swapping the cuepart 4 and 5
            cleanup = '';
            test = 5;
            gold = 105;
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