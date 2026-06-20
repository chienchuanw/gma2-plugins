--*******************************************************************************************
-- This script shows up the methods to copy a viewpage.
-- Viewpage 3+4, Viewpage 8, view 26
--*******************************************************************************************


local test =
{
    method_name      = "COPY";
    object_name      = "VIEWPAGE";
    pre              = 'ClearAll; viewpage 3; cd /';

    steps =
    {
        {
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=5 /height=3 /posx = 11 /posy=4; store view 26 /SCREEN=2; assign view 26 at viewbutton 1';
            cmd  = 'copy viewpage 3 at viewpage 4 /o';
            post = 'label view 26 "COP_VPA_1";';
            cleanup = 'viewpage 1';
            -- test = {3,4}; -- assertion failure
            -- gold = {8,8};
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