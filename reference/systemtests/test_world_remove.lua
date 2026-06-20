--*******************************************************************************************
-- This script tests the method to remove a world. 
-- World 32
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "REMOVE";
    object_name      = "WORLD";
    pre              = 'ClearAll; delete world 32 /nc';
    exit_cmd         = 'world 1';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; store world 32 /nc; clearall; world 32';
            cmd  = 'remove world 32; store world 32 /overwrite; world 1; world 32';
            post = 'label world 32 "WOR_REM"';
            cleanup	 = 'world 1';
            test = 32;    --comparison of worlds
            gold = 132;
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