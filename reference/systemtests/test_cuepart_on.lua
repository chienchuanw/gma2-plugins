--*******************************************************************************************
-- This script tests the methods to load a cuepart into the programmer with the command on.
-- Seq 98, Exec 109
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "CUEPART";
    gs_name          = "CUE 1 PART";
    pre              = 'ClearAll; delete executor 109 /nc; delete sequence 98 cue 1 /nc; select executor 109';
    version_script   = '3.2.53.0';
   
    steps=
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 50 thru 0; store sequence 98 cue 1 part 1 /nc; assign sequence 98 executor 109; store sequence 98 cue 2 part 1 /nc; fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. ' at 10; store sequence 98 cue 1 part 2 /nc';
            cmd  = 'on sequence 98 cue 1 part 1; store sequence 98 cue 1 part 3 delay 2 /nc';
            post = 'label sequence 98 "CUEP_ON"; label executor 109 "CUEP_ON"';
            cleanup = '';
            test = 3;  --cue 1 part 3
            gold = 103;  --cue 2 part 103
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