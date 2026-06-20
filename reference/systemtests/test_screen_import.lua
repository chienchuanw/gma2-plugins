--*******************************************************************************************
-- This script tests the methods to 'import' a screen. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "SCREEN";
    pre              = 'ClearAll; cd / ; delete screen 3';
    steps =
    {
        {
            -- import at screen 3
            smoketest = true;
            pre  = '';
            cmd  = 'Import "import-screen.xml" at Screen 3';
            post = '';
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