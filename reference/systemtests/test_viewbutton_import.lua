--*******************************************************************************************
-- This script shows up the methods to import a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "IMPORT";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            pre  = '';
            cmd  = 'import "import-viewbutton.xml" at viewbutton 10 /nc';
            post = 'label viewbutton 10 "VBT_IMP_1"; label viewpage 3 "GS_VBT_IMP"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = 2.10;
            gold = 3.10;
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