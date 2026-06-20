--*******************************************************************************************
-- This script test the multiple options to copy a cue part.
-- Seq 95, Exec 105
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 95 cue 1 /nc; delete executor 105 /nc; select executor 105';

    steps=
    {
        { --copying at an avilable position
            pre = 'fixture 1 + 2 at 50; store sequence 95 cue 1 part 1 /nc; fixture 3 thru 99 at 25; store sequence 95 cue 1 part 2 /nc; assign sequence 95 at executor 105; store sequence 95 cue 2 part 1 /nc';
            cmd = 'copy sequecne 95 cue 1 part 2 at sequence 95 cue 1 part 3 /nc';   --cue 1 part 2 is now empty
            post= 'label sequence 95 "CUEP_COPY"; label executor 105 "CUEP_COPY"';
            cleanup ='clearall';
            test = 3;  --cue 1 part 2 and 3
            gold = 103; --cue 2 part 101
        },
        {  --copying at an occupied position by merging
            pre = 'fixture 100 at 55; store sequence 95 cue 1 part 4 /nc; fixture 101 thru 200 at 88; store sequence 95 cue 1 part 5 /nc';
            cmd = 'copy sequence 95 cue 1 part 4 at sequence 95 cue 1 part 5 /merge';  --cue 1 part 4 is now empty
            cleanup ='clearall';
            test = 5;
            gold = 105;
        },
        {  --copying at an occupied position by overwriting
            pre  = 'fixture 201 at 70; store sequence 95 cue 1 part 6 /nc; fixture 202 thru 300 at 77; store sequence 95 cue 1 part 7 /nc';
            cmd  = 'copy sequence 95 cue 1 part 6 at sequence 95 cue 1 part 7 /overwrite';  --cue 1 part 6 is now empty
            cleanup = '';
            test = 7;
            gold = 107;
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