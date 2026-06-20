--*******************************************************************************************
-- This script tests the method full to a world.
-- World 18, DmxSnap 489
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "WORLD";
    pre              = 'ClearAll; delete world 18 /nc; delete DmxSnapshot 489 /nc';
    exit_cmd	        = 'world 1';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; store world 18 /nc; clearall';
            cmd  = 'world 18 full';
            post = 'label world 18 "WOR_FUL_1"; label DmxSnapshot 489 "WOR_FUL_1"';
            cleanup = 'world 1';
            test_dmx = true;
            test = 489;
            gold = 989;
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