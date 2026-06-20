--*******************************************************************************************
-- This script shows up the methods to import a view.
-- View 25
--*******************************************************************************************

local test =
{
    method_name      = "IMPORT";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 25 /nc; delete screen thru' ;

    steps =
    {
        {
            -- Import View
            pre  = '';
            cmd  = 'Import "import-view.xml" at view 25 /nc';
            post = 'label view 25 "IMP_VIE_1"';
            cleanup = 'view 1';
            test = 25;
            gold = 125;
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