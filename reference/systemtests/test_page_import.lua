--*******************************************************************************************
-- This script tests the method to import a page.
-- Page 97
--*******************************************************************************************

local test=
{
    method_name     = "IMPORT";
    object_name     = "PAGE";
    pre             = 'ClearAll; delete page 97 /nc; store page 97; page 97;';
    steps =
    {
        {
            -- Import Page 97
            smoketest=true;
            pre  = '';
            cmd  = 'import "import-page.xml" at page 97 /nc';
            post = 'label page 97 "IMP_PAG_1"';
            cleanup = '';
        },
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