--*******************************************************************************************
-- This script shows up the methods to call a view.
-- View 26
--*******************************************************************************************


local test =
{
    method_name      = "CALL";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 26 /nc; delete screen thru; cd /'; --deleting all screens

    steps =
    {
        {
            -- store a view on screen 2 and call it on screen 3
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Stage" /width=16 /height=8; store view 26 /SCREEN=2';
            cmd  = 'call view 26 /screen=3';
            post = 'label view 26 "CAL_VIE_1"';
            cleanup = 'delete 1 thru; cd /';
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