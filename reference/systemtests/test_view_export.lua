--*******************************************************************************************
-- This script shows up the methods to export a view.
-- View 28+29, View 128+129
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 28 + 29 /nc; delete screen thru' ;

    steps =
    {
        {
            -- Export View
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Clock" /width=16 /height=8; store view 28 /SCREEN=2';
            cmd  = 'export view 28 "export-view.xml" /nc';
            post = 'label view 28 "EXP_VIE_1"';
            cleanup = 'cd /';
            test = 28;
            gold = 128;
        },
        {
            -- Import View
            pre  = '';
            cmd  = 'Import "export-view.xml" at view 29 /nc';
            post = 'label view 29 "EXP_VIE_1"';
            cleanup = 'view 1';
            test = 29;
            gold = 129;
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