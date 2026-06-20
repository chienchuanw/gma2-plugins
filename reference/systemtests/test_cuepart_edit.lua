--*******************************************************************************************
-- This script tests the method to edit a cue part. 
-- Seq 96, Exec 106
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll;  delete executor 106 /nc; delete sequence 96 cue 1 /nc; select executor 106';   --golden cue parts in sequence 96 cue 2
    steps=
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 100; store sequence 96 cue 1 part 1 /nc; assign sequence 96 executor 106; store sequence 96 cue 2 part 1 /nc; fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] .. ' at 25; store sequence 96 cue 1 part 2 /nc';
            cmd  = 'edit sequence 96 cue 1 part 2; at 99; update sequence 96 cue 1 part 2 /nc';
            post = 'label sequence 96 "CUEP_EDIT"; label executor 106 "CUP_EDIT"';
            cleanup ='clearall';
            test = 2;  --cue 1 part 2
            gold = 102;  --cue 2 part 102
        },
        {
            pre  = 'fixture ' ..(fixturecount[2])+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 25; store sequence 96 cue 1 part 3 /nc';
            cmd  = 'edit sequence 96 cue 1 part 3; at 30; update sequence 96 cue 1 part 3 /nc';
            cleanup = '';
            test = 3;
            gold = 103;
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