--*******************************************************************************************
-- This script shows up the methods to store a viewbutton.
-- Viewpage 2
--*******************************************************************************************


local test =
{
    method_name      = "STORE";
    object_name      = "VIEWBUTTON";
    pre              = 'ClearAll; cd / ; viewpage 2';

    steps =
    {
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=13 /height=5 /posx=1 /posy=1;';
            cmd  = 'store viewbutton 1 /screen=2';
            post = 'label viewbutton 1 "VBT_STO_1"; label viewpage 3 "GS_VBT_STO"';
            cleanup = 'viewpage 1; cd / ; view 1';
            test = 2.1;
            gold = 3.1;
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