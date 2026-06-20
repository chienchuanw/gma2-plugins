--*******************************************************************************************
-- This script tests the methods to park a cuepart.
-- To park a cuepart means parking the appropriate fixtures. 
-- Due to object name "CUEPART" the main_matrix does not allow a comparison for DMXsnapshots.
-- To test the method park with cuepart comparison is not possible.
-- Park and unpark fixture is tested in test_fixture_park.lua and test_fixture_unpark.lua.
-- Seq 99, Exec 109
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "PARK";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 109 /nc; delete sequence 99 cue 1 /nc; select executor 109';
   
    steps=
    {
        {
            smoketest=true;
            pre  = 'fixture '..(math.floor(fixturecount[2]/4))+fixturecount[2]..' thru '..(math.floor(fixturecount[2]/2))+fixturecount[2]..' at 45; store sequence 99 cue 1 part 1 /nc; assign sequence 99 executor 109; store sequence 99 cue 2 part 1 /nc; fixture '..(fixturecount[2]*2)..' at 50; store sequence 99 cue 1 part 2 /nc';
            cmd  = 'park sequence 99 cue 1 part 2;  '; --fixture parked not cueparts
            post = 'label sequence 99 "CUEP_PAR"; label executor 109 "CUEP_PAR"';
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