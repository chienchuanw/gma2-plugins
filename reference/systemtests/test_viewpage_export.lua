--*******************************************************************************************
-- This script shows up the methods to export a viewpage.
-- Viewpage 5+6, Viewpage 9, view 27
--*******************************************************************************************


local test =
{
    method_name      = "EXPORT";
    object_name      = "VIEWPAGE";
    pre              = 'ClearAll; viewpage 5; cd /';

    steps =
    {
        {
            -- generate export file
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=10 /height=3 /posx=2 /posy=2; store view 27 /SCREEN=2; assign view 27 at viewbutton 1';
            cmd  = 'export viewpage 5 "export-viewpage.xml" /o';
            post = 'label view 27 "EXP_VPA_1";';
            cleanup = 'viewpage 1';
        },
        {
            -- import again
            smoketest = true;
            pre  = 'viewpage 6';
            cmd  = 'import "export-viewpage.xml" at viewpage 6';
            post = '';
            cleanup = 'viewpage 1';
            -- test = {5,6}; assertion failure
            -- gold = {9,9};
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