--*******************************************************************************************
-- This Plugin tests the export fuction for masks. 
-- Mask 11,12
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "MASK";
    pre              = 'Clearall; delete mask 11 /nc';
    steps =
    {
        {
            smoketest =true;
            cmd  = 'Export Mask 11 "export-mask.xml" /nc';
        },
        {
            cmd  = 'Import ""export-mask.xml"" at mask 12 /nc';
            post = 'label mask 12 "EXP_MASK_1"';
            cleanup = '';
            test = 12;
            gold = 13;
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