--*******************************************************************************************
-- This script test the multiple options to copy a cue.
-- Seq 75, Exec 207
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "COPY";
    object_name      = "CUE";
    pre              = 'ClearAll; delete sequence 75 cue 1 thru cue 99 /nc; delete executor 207 /nc';  --do not delete the golden cues 101...
    steps=
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 35; store sequence 75 cue 1 /use=active /nc; assign sequence 75 at executor 207; select executor 207; store sequence 75 cue 101 /nc';
            cmd  = 'copy sequence 75 cue 1 at sequence 75 cue 2 /cueonly ';
            post = 'label sequence 75 "CUE_COPY"; label executor 207 "CUE_COPY_1"; label sequence 75 cue 1 "origin cue 1"; label sequence 75 cue 2 "copy of cue 1"; label sequence 75 cue 101 "golden cue list from here"';
            cleanup = '';
            test = {1,2};  --comparing cues
            gold = {101.1,101.2};
        },
        {    -- Copy Status Operation
            pre = 'fixture 1 + 4 at 40; store sequence 75 cue 3 /nc';
            cmd = 'copy sequence 75 cue 3 at sequence 75 cue 2.1 /Status /nc';
            post = 'label sequence 75 cue 3 "origin cue 3"; label sequence 75 cue 2.1 "copy of cue 3"';
            cleanup = '';
            test = {3,2.1};
            gold = {103.1,102.1};
        },
        {   -- Copy Cue only and Status Operation
            pre = 'fixture 1 + 3 at 20; store sequence 75 cue 4 /nc';
            cmd = 'copy sequence 75 cue 4 at sequence 75 cue 2.2 /cueonly /status';
            post = 'label sequence 75 cue 4 "origin cue 4"; label sequence 75 cue 2.2 "copy of cue 4"';
            cleanup = '';
            test = {4,2.2};
            gold = {104.1,102.2};
        },
        {  -- Merge Operation
            pre  = 'copy sequence 75 cue 4 at sequence 75 cue 5 /nc; fixture 2 at 35; store sequence 75 cue 6 /cueonly /nc';
            cmd  = 'copy sequence 75 cue 5 at sequence 75 cue 6 /merge';
            post = 'label sequence 75 cue 5 "origin cue 5"; label sequence 75 cue 6 "copy of cue 5"';
            cleanup = '';
            test = {5,6};
            gold = {105.1,106.1};
        },
        {   -- Overwrite Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 50; store sequence 75 cue 7 /nc';
            cmd  = 'copy sequence 75 cue 6 at sequence 75 cue 7 /overwrite';
            cleanup = '';
            test = {6,7};
            gold = {106.1,107.1};
        },
        {   -- Merge Status Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 55; store sequence 75 cue 8+9 /nc';
            cmd  = 'copy sequence 75 cue 8 at sequence 75 cue 9 /merge /status';
            cleanup = '';
            test = {8,9};
            gold = {108.1,109.1};
        },
        {   -- Overwrite Status Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 75; store sequence 75 cue 10 /nc';
            cmd  = 'copy sequence 75 cue 9 at sequence 75 cue 10 /overwrite /status';
            cleanup = '';
            test = {9,10};
            gold = {109.1,110.1};
        },
        {   -- Merge Cue only Operation 
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 95; store sequence 75 cue 11 /nc';
            cmd  = 'copy sequence 75 cue 10 at sequence 75 cue 11 /merge /cueonly';
            cleanup = '';
            test = {10,11};
            gold = {110.1,111.1};
        },
        {   -- Overwrite Cue only Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 5; store sequence 75 cue 12 /nc';
            cmd  = 'copy sequence 75 cue 11 at sequence 75 cue 12 /overwrite /cueonly';
            cleanup = '';
            test = {11,12};
            gold = {111.1,112.1};
        },
        {   -- Merge Cue only and Status Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 15; store sequence 75 cue 13 /nc';
            cmd  = 'copy sequence 75 cue 12 at sequence 75 cue 13 /merge /cueonly /status';
            cleanup = '';
            test = {12,13};
            gold = {112.1,113.1};
        },
        {   -- Overwrite Cue only and Status Operation
            pre  = 'fixture 1 thru '..fixturecount[2]..' at 25; store sequence 75 cue 14 /nc';
            cmd  = 'copy sequence 75 cue 13 at sequence 75 cue 14 /overwrite /cueonly /status';
            cleanup = '';
            test = {13,14};
            gold = {113.1,114.1};
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