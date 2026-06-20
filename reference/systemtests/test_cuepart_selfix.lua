--*******************************************************************************************
-- This script tests the method select the fixtures of a cue part. 
-- Seq 102, Exec 112 
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "CUEPART";
   gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete sequence 102 cue 1 /nc; delete executor 112 /nc; select executor 112';
    version_script   = '3.2.53.0';
   
    steps =
   {
      {
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 102 cue 1 part 1 /nc; assign sequence 102 executor 112; store sequence 102 cue 2 part 1 /nc; fixture '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' thru '..(fixturecount[2]*2)..' at 50; store sequence 102 cue 1 part 2 /nc';
            cmd  = 'selfix sequence 102 cue 1 part 2; at 100; store sequence 102 cue 1 part 3'; 
            post = 'label sequence 102 "CUEP_SEF"; label executor 112 "CUEP_SEF"';
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