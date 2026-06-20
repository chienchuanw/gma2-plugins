--*******************************************************************************************
-- This Plugin tests the call fuction for presets. 
-- Preset 1.7, DmxSnap 351
--*******************************************************************************************

local test =
{
    method_name         = "CALL";
    object_name         = "PRESET";
    pre                 = 'ClearAll; delete Preset 1.7 /nc; delete DmxSnapshot 351 /nc';
    version_script      = '3.2.53.0';
   
    steps =
    {
        {  
            pre         = 'Fixture 1 at 92 ; store preset 1.7 /nc';
            cmd         = 'Call Preset 1.7';
            post        = 'label Preset 1.7 "PRES_CALL_1"; label DmxSnapshot 351 "PRES_CALL_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 351;
            gold        = 851;
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