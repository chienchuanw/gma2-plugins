--*******************************************************************************************
-- This Plugin tests the export fuction for presets. 
-- Preset 1.31, 1.32
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete preset 1.31 + 1.32 /nc';
    steps =
    {
        {
            smoketest =true;
            pre  = 'Channel 1 thru 100 at 65; store preset 1.31 /nc';
            cmd  = 'Export preset 1.31 "export-preset.xml" /nc';   --folder importexport
            post = 'label preset 1.31 "PRES_EXP_1"';
            cleanup = '';
        },
        {
            --import essentailassary to verify export
            cmd  = 'Import "export-preset.xml" at preset 1.32';
            post = 'label preset 1.32 "PRES_EXP_2"';
            cleanup = '';
            --test = 1.32;
            --gold = 1.132;
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