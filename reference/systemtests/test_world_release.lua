--*******************************************************************************************
-- This script tests the method to release a world. 
-- Seq 181, Exec 71, World 40
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "RELEASE";
    object_name      = "WORLD";
    gs_name          = "CUE";
    pre              = 'ClearAll; delete sequence 181 cue 1 thru 99 /nc; delete executor 71 /nc; delete world 40 /nc';
    exit_cmd         = 'world 1';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; store world 40 /nc; clearall; world 40 at 100; store sequence 181 cue 1 /nc; assign sequence 181 executor 71; clearall; select executor 71';
            cmd  = 'release ; store sequence 181 cue 2 /nc; clearall; world 40 at 50; store sequence 181 cue 3 /nc';
            post = 'label sequence 181 "REL_WOR_1"; label executor 71 "REL_WOR_1"; label world 40 "REL_WOR_1"';
            cleanup	 = 'world 1';
            test = {2,3};    --comparison of cues
            gold = {101.2,101.3};
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