--*******************************************************************************************
-- This script shows up the methods to import a viewpage.
-- Viewpage 7, Viewpage 10
--*******************************************************************************************


local test =
{
    method_name      = "IMPORT";
    object_name      = "VIEWPAGE";
    pre              = 'ClearAll; viewpage 7; cd /';

    steps =
    {
        {
            -- import
            smoketest = true;
            pre  = '';
            cmd  = 'import "import-viewpage.xml" at viewpage 7';
            post = '';
            cleanup = 'viewpage 1; view 1';
            -- test = 7; assertion failure
            -- gold = 10;
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