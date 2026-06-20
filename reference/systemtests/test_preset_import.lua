--*******************************************************************************************
-- This Plugin tests the import fuction for presets.
-- Preset 1.33
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "PRESET";
    pre              = 'ClearAll; delete preset 1.33 /nc' ;
    steps =
    {
        {
            smoketest = true;
            cmd  = 'Import "import-preset.xml" at preset 1.33 /overwrite';
            post = 'label preset 1.33 "PRES_IMP_1"';
            cleanup = '';
            --test = 1.33;
            --gold = 1.133;
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