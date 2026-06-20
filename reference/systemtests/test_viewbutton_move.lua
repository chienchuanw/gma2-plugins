--*******************************************************************************************
-- This script shows up the methods to move a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "MOVE";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2; delete viewbutton 4 + 5 /nc';

    steps =
    {
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=13 /height=5 /posx=1 /posy=1; store viewbutton 4 /screen=2';
            cmd  = 'move viewbutton 4 at 5 /o';
            post = 'label viewbutton 5 "VBT_MOV_1"; label viewpage 3 "GS_VBT_MOV"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = {2.4,2.5};
            gold = {-1,3.5};
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