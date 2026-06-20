--*******************************************************************************************
-- This script tests the method highlight to a selection 
-- DmxSnap 424 + 425
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "HIGHLIGHT";
    object_name      = "SELECTION";
    pre              = 'ClearAll; delete DmxSnapshot 424 + 425 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {
            pre  = 'highlight off; Fixture 1 thru ' .. fixturecount[2];
            cmd  = 'highlight Selection';
            post = 'label DmxSnapshot 424 "HILI_SELE_1"';
            cleanup = 'clearall; off page thru';
            test_dmx = true;
            test = 424;
            gold = 724;
        },
        {
            pre  = 'highlight off; Fixture 1 thru ' .. fixturecount[2]*2;
            cmd  = 'highlight on Selection';
            post = 'label DmxSnapshot 425 "HILI_SELE_2"';
            cleanup = 'highlight off';
            test_dmx = true;
            test = 425;
            gold = 725;
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