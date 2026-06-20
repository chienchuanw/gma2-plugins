--*******************************************************************************************
-- This script tests to set a fixture to full. 
-- DmxSnap 246
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 246 /nc';
   
    steps =
    {
        {  
            cmd  = 'Fixture 1 full';
            post = 'label DmxSnapshot 246 "FUL_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 246;
            gold = 746;
        },
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