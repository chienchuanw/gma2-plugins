--*******************************************************************************************
-- This script shows up the methods to delete a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "DELETE";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 4 /screen=2';
            cmd  = 'delete viewbutton 4 /nc';
            post = 'label viewbutton 4 "VBT_DEL_1"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = 2.4;
            gold = -1;
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