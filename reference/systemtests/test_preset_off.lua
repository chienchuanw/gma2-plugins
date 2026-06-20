--*******************************************************************************************
-- This script tests the methods to off a preset 
-- Preset 0.10, DmxSnap 353
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "PRESET";
    pre              = 'delete preset 0.10 /nc; delete DmxSnapshot 353 /nc; ';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {  
            pre  = 'Fixture 1 thru ' .. math.floor(fixturecount[2]/2) .. ' at 25; store preset 0.10 /nc; preset 0.10; preset 0.10';
            cmd  = 'off preset 0.10';
            post = 'label preset 0.10 "OFF_PRES_1"; label DmxSnapshot 353 "OFF_PRES_1"';
            cleanup = '';
            test_dmx = true;
            test = 353;
            gold = 853;
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