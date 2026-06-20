--*******************************************************************************************
-- This script tests the methods to call a cue part. 
-- Seq 94, Exec 104
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "CALL";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 104 /nc; delete sequence 94 cue 1 /nc; select executor 104';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 50; store sequence 94 cue 1 part 1 /nc; ; assign sequence 94 executor 104; store cue 2 part 1 /nc; fixture ' .. math.floor(fixturecount[2]/2)+1 .. ' thru ' .. fixturecount[2] ..' at 25; store cue 1 part 2 /nc; fixture '.. fixturecount[2]+1 ..' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 25; attribute colorrgb5 at 50; attribute colorrgb3 at 75; store cue 1 part 3 /overwrite /nc';
            cmd  = 'call cue 1 part 3 if presettype 4 /s; store cue 1 part 4 /nc;';
            post = 'label sequence 94 "CUEP_CAL"; label executor 104 "CUEP_CAL"';
            cleanup = '';
            test = 4;
            gold = 104;
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