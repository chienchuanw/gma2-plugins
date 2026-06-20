--*******************************************************************************************
-- This script shows up the methods to assign a view.
-- View 12
--*******************************************************************************************


local test =
{
    method_name      = "ASSIGN";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 12+13 /nc; delete viewbutton 1.6 + 1.7 /nc; delete screen thru; cd /'; --deleting all screens

    steps =
    {
        {
            -- store one display and assign to viewbutton 1.6
            smoketest = true;
            --makes display 2 empty, stores view 1 from screen 2, assigns display 1 clock, assigns this view to viewbutton 1.6
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Clock" /width=16 /height=8; store view 12 /SCREEN=2';
            cmd  = 'assign view 12 at viewbutton 1.6';
            post = 'label view 12 "ASS_VIE_1"; label viewbutton 1.6 "ASS_VIE_1"';
            cleanup = 'delete 1 thru; cd /';
        },
        {
            -- store all displays and store to viewbutton 1.7
            smoketest = true;
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Help" /width=16 /height=8; cd .. ; cd "Display 1"; delete 1 thru; store 1 /SCREEN=1; Assign 1 /display=0 /type="Help" /width=10 /height=4; store view 13 /SCREEN=All;';
            cmd  = 'assign view 13 at viewbutton 1.7';
            post = 'label view 13 "ASS_VIE_2"; label viewbutton 1.7 "ASS_VIE_2"';
            cleanup = 'delete 1 thru; cd .. ; cd "Display 2"; delete 1 thru; cd /';
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