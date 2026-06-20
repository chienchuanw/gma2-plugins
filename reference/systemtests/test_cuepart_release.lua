--*******************************************************************************************
-- This script tests the methods to release a cuepart.
-- Seq 100, Exec 110
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "CUEPART";
   gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 100 cue 1 /nc; delete executor 110 /nc; select executor 110';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 100 cue 1 part 1 /nc; assign sequence 100 executor 110; store sequence 100 cue 2 part 1 /nc; fixture '..(fixturecount[2]*2)..' at 50; store sequence 100 cue 1 part 2 /nc';
            cmd  = 'release sequence 100 cue 1 part 2; store sequence 100 cue 1 part 3 /nc'; 
            post = 'label sequence 100 "CUEP_REL"; label executor 110 "CUEP_REL"';
            cleanup = '';
            test = 3; --cue 1 part 3
            gold= 103; --cue 2 part 103
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