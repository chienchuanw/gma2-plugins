--*******************************************************************************************
-- This script tests the options to delete a cuepart. 
--Cuenumber part Cuepartnumber
-- Seq 91, Exec 101
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "CUEPART";
    gs_name          ="CUE 1 PART";
    pre              = 'ClearAll; delete sequence 91 cue 1 part 1 thru 5 /nc; delete executor 101 /nc';
    
        steps=
    {
        {    --deleting at the end of a list
            pre  = 'fixture 1 at 101; store sequence 91 cue 1 part 1 /nc /co; assign sequence 91 at executor 101; select executor 101; fixture 2 at 75; store sequence 91 cue 1 part 2 /nc';
            cmd  = 'delete sequence 91 cue 1 part 2 /nc';
            post= 'label sequence 91 "CUEP_DEL"';
            cleanup='clearall';
            test = 2; --cue 1 part 2
            gold = -1;
        },
        {    --deleting in the list
            pre  = 'fixture 3 at 55; store sequence 91 cue 1 part 3 /nc; fixture 3 at 65; store sequence 91 cue 1 part 4 /nc';
            cmd  = 'delete sequence 91 cue 1 part 3 /nc';
            cleanup='clearall';
            test = 3; --cue 1 part 3
            gold = -1;
        },
        {   --deleting by label
            pre  = 'fixture 2 at 75; store sequence 91 cue 1 part 4 /nc; fixture 2 at 85; store sequence 91 cue 1 part 5 /nc; label sequence 91 cue 1 part 4 "hello"; label sequence 91 cue 1 part 5 "hallo"';
            cmd  = 'delete sequence 91 cue 1 part "hallo" /nc';
            cleanup='clearall';
            test = 5;
            gold = -1;
        },
        {   --deletevalues
            pre  = 'fixture 2 at 90; store sequence 91 cue 1 part 6 /nc; label sequence 91 cue 1 part 6 "hallo"';
            cmd  = 'delete sequence 91 cue 1 part "h*llo" /deletevalues /nc';
            cleanup='clearall';
            test = 4;
            gold = -1;
        },
        {   --cuelonly
            pre  = 'fixture 2 at 75; store sequence 91 cue 1 part 7 /nc';
            cmd  = 'delete sequence 91 cue 1 part 7 /cueonly /deletevalues /nc';
            cleanup = '';
            test = 7;
            gold = -1;
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