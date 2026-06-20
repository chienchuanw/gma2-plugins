--*******************************************************************************************
-- This script test the multiple options of storing a cuepart.
-- Using the same fixture inside a cue again is not possible.
-- Seq 90, Exec 100
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "STORE";
    object_name      = "CUEPART";  --extra conditions for cuepart in main matrix, no Dmxsnap-comparison possible
    gs_name          = "CUE 1 PART"; --needed for cuepart comparison
    version_script   = "3.1.70.1";
    pre              = 'ClearAll; delete sequence 90 cue 1 /nc; delete executor 100 /nc; select executor 100';  --do not delete golden cuepart in cue 2
    steps =
    {
        {
            pre  = '';
            cmd  = 'fixture 3 + 4 at 50; store sequence 90 cue 1 part 1 /nc /track=off; assign sequence 90 at executor 100; store sequence 90 cue 2 part 1 /nc; fixture 5 at 25; store sequence 90 cue 1 part 2 /nc';
            post= 'label sequence 90 "CUEP_STO"';
            cleanup = '';
            test = 2; --cue 1 part 2
            gold = 102;  --cue 2 part 102
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