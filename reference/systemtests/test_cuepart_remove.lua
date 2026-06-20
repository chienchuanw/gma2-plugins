--*******************************************************************************************
-- This script tests the methods to remove a cuepart.
-- Seq 101, Exec 111
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "CUEPART";
   gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 101 cue 1 /nc; delete executor 111 /nc; select executor 111';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 101 cue 1 part 1 /nc; assign sequence 101 executor 111; store sequence 101 cue 2 part 1 /nc; fixture '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' thru '..(fixturecount[2]*2)..' at 50; store sequence 101 cue 1 part 2 /nc';
            cmd  = 'remove sequence 101 cue 1 part 2; store sequence 101 cue 1 part 3'; --removes the fixture from the cue list
            post = 'label sequence 101 "CUEP_REM"; label executor 111 "CUEP_REM"';
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