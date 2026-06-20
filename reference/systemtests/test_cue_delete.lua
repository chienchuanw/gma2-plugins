--*******************************************************************************************
-- This script test the multiple options to delete a cue. 
-- Seq 71, Exec 220
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "DELETE";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 71 /nc; delete executor 220 /nc; assign sequence 71 at executor 220; select executor 220';
    steps=
    {
        {
            -- Deleting a cue at the end of a list
            pre  = 'fixture 1 at 100; store sequence 71 cue 1 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 2 /o /nc; fixture 3 at 50; store sequence 71 cue 3 /o /nc; clearall';
            cmd  = 'delete sequence 71 cue 3 /nc';
            post = 'label sequence 71 "CUE_DEL"';
            test = 3; --comparing cue 3 with an empty object
            gold = -1;
        },
        {
            -- Deleting multiple cues at the end of a list
            pre  = 'fixture 1 at 100; store sequence 71 Cue 4 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 5 /o /nc; fixture 3 at 50; store sequence 71 cue 6 /o /nc; clearall';
            cmd  = 'delete sequence 71 cue 5+6 /nc';
            test = {4,5,6};
            gold = {-1,-1,-1};
        },
        {
            -- Deleting labeled cue at the end of a list
            pre  = 'fixture 1 at 100; store sequence 71 Cue 7 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 8 /o /nc; label sequence 71 cue 8 "deleteIt"; clearall';
            cmd  = 'delete sequence 71 cue "deleteIt" /nc';
            test = 8;
            gold = -1;
        },
        {
            -- Deleting multiple labeled cues at the end of a list
            pre  = 'fixture 1 at 100; store sequence 71 Cue 9 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 10 /o /nc; label sequence 71 cue 9 + +10 "deleteItNow"; clearall';
            cmd  = 'delete sequence 71 cue "deleteItNow" /nc';
            test = {9,10};
            gold = {-1,-1};
        },
        {
            -- Deleting a cue somewhere in the list
            pre  = 'fixture 1 at 100; store sequence 71 Cue 11 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 12 /o /nc; clearall';
            cmd  = 'delete sequence 71 cue 11 /nc';
            test = 11;
            gold = -1;
        },
        {
            -- Deleting a cue somewhere in the list cue only
            pre  = 'fixture 1 at 100; store sequence 71 Cue 13 /o /use=active /nc; fixture 2 at 75; store sequence 71 cue 14 /o /nc; clearall';
            cmd  = 'delete sequence 71 cue 13 /cueonly;';
            cleanup = '';
            test = 13;
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