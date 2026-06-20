--*******************************************************************************************
-- This script tests the method on to a fixture 
-- DMXsnap 257
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "FIXTURE";
    pre              = 'ClearAll; Delete DMXsnapshot 257/nc';
   
    steps =
    {
        {
            pre  = 'fixture 1 at 45; off fixture thru ';
            cmd  = 'On Fixture 1';
            post = 'label DMXsnapshot 257 "ON_FIX_1"';
            cleanup = '';
            test_dmx = true;
            test = 257;
            gold = 757;
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