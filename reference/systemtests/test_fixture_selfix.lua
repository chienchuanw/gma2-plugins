--*******************************************************************************************
-- This script tests to selfix a fixture 
-- DmxSnap 253,254
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "SELFIX";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 253+254 /nc';
   
    steps =
    {
        {
            pre  = '';
            cmd  = 'Selfix Fixture 1 thru '..fixturecount[2]..'at 55';  --critical, works without selfix, too
            post = 'label DmxSnapshot 253 "SLF_FIX_1"';
            cleanup = '';
            test_dmx=true;
            test = 253;
            gold = 753;
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