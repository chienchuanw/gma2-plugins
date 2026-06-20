--*******************************************************************************************
-- This script shows up the methods to store a view.
-- View 7-11
--*******************************************************************************************


local test =
{
    method_name      = "STORE";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 7 thru 11 /nc; delete screen thru'; --deleting all screens

    steps =
    {
        {   --makes display 2 empty, stores view 1 from screen 2, assigns display 1 stage view
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=16 /height=4';
            cmd  = 'store view 7 /SCREEN=2';  --working on view 7, screen 2, display 1 (stageview)
            post = 'label view 7 "STORE_VIEW_1"';
            cleanup = 'delete 1 thru';
            test = 7;   --comparison of views, having more than one screen or display in that view, comparison has to be adjusted
            gold = 107;
        },
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="commandline" /width=16 /height=10';
            cmd  = 'store view 8 /SCREEN=2';
            post = 'label view 8 "STORE_VIEW_2"';
            cleanup = 'delete 1 thru';
            test = 8;
            gold = 108;
        },
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="color picker" /width=5 /height=3 /posy=4';
            cmd  = 'store view 9 /SCREEN=2';
            post = 'label view 9 "STORE_VIEW_3"';
            cleanup = 'delete 1 thru';
            test = 9;
            gold = 109;
             
        },
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="clock" /width=6 /height=3 /posx = 5 /posy=4;';
            cmd  = 'store view 10 /SCREEN=2';
            post = 'label view 10 "STORE_VIEW_4"';
            cleanup = 'delete 1 thru';
            test = 10;
            gold = 110;
        },
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="actionbuttons" /width=5 /height=3 /posx = 11 /posy=4';
            cmd  = 'store view 11 /SCREEN=2';
            post = 'label view 11 "STORE_VIEW_5"';
            cleanup = 'delete 1 thru; cd /; cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 1"; delete 1 thru /nc; store 1 /SCREEN=1; Assign 1 /display=0 /type="CommandLine" /width=10 /height=4; cd /';
            test = 11;
            gold = 111;
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