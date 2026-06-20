--*******************************************************************************************
-- This script shows up the methods to export a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "EXPORT";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="dmx" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 8 /screen=2;';
            cmd  = 'export viewbutton 8 "export-viewbutton.xml" /nc';
            post = 'label viewbutton 8 "VBT_EXP_1"';
        },
        {
            pre  = '';
            cmd  = 'import "export-viewbutton.xml" at viewbutton 9 /nc';
            post = 'label viewbutton 9 "VBT_EXP_2"; label viewpage 3 "GS_VBT_EXP"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = 2.9;
            gold = 3.9;
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