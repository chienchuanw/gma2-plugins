--*******************************************************************************************
-- This script tests the methods to update a cue part.
-- Seq 103, Exec 113
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 103 cue 1 /nc; delete executor 113 /nc; select executor 113';
    steps =
    {        
        {  --update with existing content, fixture used in the cue already
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 103 cue 1 part 1 /nc; assign sequence 103 executor 113; store sequence 103 cue 2 part 1 /nc; fixture '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' thru '..(fixturecount[2]*2)..' at 50; store sequence 103 cue 1 part 2 /nc; go executor 113; fixture '..(fixturecount[2]*2)..' at 10';
            cmd  = 'update sequence 103 cue 1 part 2 /addnewcontent= false /tracking= false /nc';  --fixture in that cuepart is updated
            post = 'label sequence 103 "CUEP_SEF"; label executor 113 "CUEP_SEF"';
            cleanup = "clearall; off page thru; off sequence thru";
            test = 2; --cue 1 part 2
            gold= 102; --cue 2 part 102
        },
        {    --update with new content, fixture not used in the cue already
            pre  = 'fixture 1 at 100; store sequence 103 cue 1 part 3 /nc; clearall; fixture 2 at 44';
            cmd  = 'update sequence 103 cue 1 part 3 /addnewcontent=true /tracking=true /nc'; --new fixture is added to the sequence
            post = 'label sequence 103 "CUEP_UPD"; label executor 113 "CUEP_UPD"';
            cleanup = '';
            test = 3;   --cue 1 part 3
            gold = 103;   --cue 2 part 103
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