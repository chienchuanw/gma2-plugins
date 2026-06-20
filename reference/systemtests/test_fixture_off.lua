--*******************************************************************************************
-- This script tests to off a fixture 
-- DmxSnap 249+250
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; delete DmxSnapshot 249+250 /nc';
   
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' ..fixturecount[2] .. ' at 100';
            cmd  = 'Off Fixture 1 thru ' .. math.floor(fixturecount[2]/4);
            post = 'label DmxSnapshot 249 "OFF_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 249;
            gold = 749;
        },
        {
            blacktest=true;
            pre  = 'Fixture 1 thru ' ..fixturecount[2] .. ' at 100';
            cmd  = 'On Fixture ' .. math.floor(fixturecount[2]/4);
            post = 'label DmxSnapshot 250 "OFF_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 250;
            gold = 750;
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