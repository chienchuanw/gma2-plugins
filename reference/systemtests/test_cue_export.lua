--*******************************************************************************************
-- This script tests the methods to export a cue. 
-- Seq 281, Exec 99
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EXPORT";
    object_name      = "CUE";
    pre              = 'ClearAll; delete executor 99 /nc; delete sequence 281 cue 1 thru cue 99 /nc; store sequence 281 cue 101 /use=all /nc';
    steps=
    {
        {
            smoketest = true;
            pre  = 'fixture 1 thru ' .. fixturecount[2] .. ' at 50; store sequence 281 cue 1 /use=active /nc; assign sequence 281 cue 1 fade 5; assign sequence 281 at executor 99; select executor 99';
            cmd  = 'export sequence 281 cue 1 "export-cue" /nc'; --exports this cue into the folder importexport
            post = 'label sequence 281 "CUE_EXP"';
            cleanup= 'clearall';
        },
        {   --import is essential to verify the exported cues
            cmd  = 'import "export-cue.xml" at sequence 281 cue 2 /nc';
            cleanup = '';
            --test = 2;  --comparison of cues
            --gold = 101.2;
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