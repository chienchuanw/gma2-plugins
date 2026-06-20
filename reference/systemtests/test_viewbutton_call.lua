--*******************************************************************************************
-- This script shows up the methods to call a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "CALL";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 6 /screen=2; delete screen 2; store 1 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 7 /screen=2; viewbutton 7';
            cmd  = 'call viewbutton 6 /nc';
            post = 'label viewbutton 6 + 7 "VBT_CAL_1"';
            cleanup = 'viewpage 1; cd / ; view 1';
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