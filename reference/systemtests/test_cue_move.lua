--*******************************************************************************************
-- This script test the multiple options to move a cue.
-- Seq 80, Exec 211
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "CUE";
    pre              = 'ClearAll; page 1; delete executor 211 /nc; delete seq 80 cue 1 thru cue 99 /nc;'; -- golden cues up from cue 100
    steps =
    {
        {
            -- Move 1 to 1 (/use=Active, overwrite)
            pre  = 'select executor 211; assign sequence 80 at executor 211; store sequence 80 cue 101 /use=all /nc; fixture 3 + 4 at 50; store cue 1 /use=Active /nc; fixture 3 at 25; store cue 2 /nc';
            cmd  = 'move cue 1 at cue 2 /overwrite /nc';    --cue 1 -> cue 2
            post = 'label sequence 80 "CUE_MOV_1"; label executor 211 "CUE_MOV_1"; label sequence 80 cue 101 "golden cue list from here"';
            cleanup = '';
            test = {1,2};
            gold = {-1,102.1};
        },
        {   
            -- Move 1 to 1 (/use=All, overwrite)
            pre  = 'select executor 211; fixture 3 + 4; at 100; store cue 3 /use=All /nc; fixture 3 at 75; store sequence 80 cue 4 /nc';
            cmd  = 'move cue 3 at cue 4 /overwrite /nc';    --cue 3 -> cue 4
            post = 'label sequence 80 "CUE_MOV_3"; label executor 211 "CUE_MOV_3"';
            cleanup = '';
            test = {3,4};
            gold = {-1,104.1};
        },
        {
            -- Move 1 to N
            version_step = "4.0.0.0"; -- Error: Move 1 to N ELEMENTS NOT SUPPORTET YET
            pre  = 'select executor 211;';
            cmd  = 'move cue 4 at cue 5 + 6 /nc'; 
            post = 'label sequence 80 "CUE_MOV_2"; label executor 211 "CUE_MOV_2"';
            cleanup = '';
            test = {4,5,6};
            gold = {-1,105.1,106.1};
        },
        {
            -- Move N to M
            pre  = 'select executor 211; fixture 2 at 42; store cue 1 /o /nc; fixture 2 at 43; store cue 2 /o /nc;';
            cmd  = 'move cue 1 + 2 at cue 7 + 8 /o /nc';
            post = 'label sequence 80 "CUE_MOV_4"; label executor 211 "CUE_MOV_4"';
            cleanup = '';
            test = {1,2,7,8};
            gold = {-1, -1,107.1,108.1};
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