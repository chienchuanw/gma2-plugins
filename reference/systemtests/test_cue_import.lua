--*******************************************************************************************
-- This script tests the methods to import a cue. 
-- Seq 282, Exec 98
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "IMPORT";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 98 /nc; delete sequence 282 cue 1 thru cue 99 /nc; store sequence 282 cue 101 /use=all /nc; assign sequence 282 at executor 98; select executor 98';
    steps=
    {
        {
            smoketest = true;
            cmd  = 'import "import-cue" at sequence 282 cue 3 /nc';
            post = 'label sequence 282 "CUE_IMP"';
            cleanup = '';
            --test = 3;  --comparison of cues
            --gold = 101.3;
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