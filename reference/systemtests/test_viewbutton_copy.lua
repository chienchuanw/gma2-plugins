--*******************************************************************************************
-- This script shows up the methods to copy a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "COPY";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 2 /screen=2';
            cmd  = 'copy viewbutton 2 at 3 /o';
            post = 'label viewbutton 2 + 3 "VBT_COP_1"; label viewpage 3 "GS_VBT_COP"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = {2.2,2.3};
            gold = {3.2,3.3};
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