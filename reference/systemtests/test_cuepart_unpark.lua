--*******************************************************************************************
-- This script tests the methods to unpark a cuepart.
-- To unpark a cuepart means unparking the appropriate fixtures. 
-- Due to object name "CUEPART" the main_matrix does not allow a comparison for DMXsnapshots.
-- To test the method unpark with cuepart comparison is not possible.
-- Park and unpark fixture is tested in test_fixture_park.lua and test_fixture_unpark.lua.
-- Seq 104, Exec 114
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UNPARK";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 114 /nc; delete sequence 104 cue 1 /nc; select executor 114;';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            smoketest=true;
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 104 cue 1 part 1 /nc; assign sequence 104 executor 114; store sequence 104 cue 2 part 1 /nc; fixture '..(fixturecount[2]*2)..' at 50; store sequence 104 cue 1 part 2 /nc; park sequence 104 cue 1 part 2;';
            cmd  = 'unpark sequence 104 cue 1 part 2 '; --fixture unparked not cueparts
            post = 'label sequence 104 "CUEP_UNP"; label executor 114 "CUEP_UNP"';
            cleanup = '';
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