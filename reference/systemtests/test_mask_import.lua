--*******************************************************************************************
-- This Plugin tests the export fuction for masks.
-- Mask 14
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "MASK";
    pre              = 'clearall; delete mask 14 /nc';
    steps =
    {
        {
            smoketest = true;
            cmd  = 'Import "import-mask.xml" at Mask 14 /nc';
            post = 'label mask 14 "IMP_MASK_1"';
            cleanup = '';
            test = 14;
            gold = 15;
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