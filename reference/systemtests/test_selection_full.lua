--*******************************************************************************************
-- This script tests the method Full to a selection 
-- DmxSnap 423
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "FULL";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 423 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2];
            cmd  = 'full Selection';
            post = 'label DmxSnapshot 423 "FULL_SELE_1"';
            cleanup = '';
            test_dmx = true;
            test = 423;
            gold = 923;
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