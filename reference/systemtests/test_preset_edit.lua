--*******************************************************************************************
-- This script tests the methods to edit a preset. 
-- Preset 1.17, DmxSnap 352
--*******************************************************************************************

local test =
{
    method_name      = "EDIT";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete Preset 1.17 /nc; delete DMXSnapshot 352 /nc';
    version_script   = '3.2.53.0';
   
    steps =
    {
        {  
            pre         = 'Fixture 1 at 92 ; store preset 1.17 /nc';
            cmd         = 'edit Preset 1.17; Fixture 1 at 100; update Preset 1.17 /nc ';
            post        = 'label DmxSnapshot 352 "PRES_EDIT_1"; label preset 1.17 "PRES_EDIT_1"';
            cleanup = '';
            test_dmx    = true;
            test        = 352;
            gold        = 752;
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