--*******************************************************************************************
-- This script shows up the methods to move a view.
-- View 16 + 17
--*******************************************************************************************

local test =
{
    method_name      = "MOVE";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 16 + 17 /nc; cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"' ;
    steps =
    {
        {   
            pre  = 'delete 1 thru /nc; store view 16 thru 17 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=16 /height=4; Assign 1 /display=2 /type="groups" /width=16 /height=1 /posy=7; Assign 1 /display=3 /type="color picker" /width=5 /height=3 /posy=4; Assign 1 /display=4 /type="clock" /width=6 /height=3 /posx = 5 /posy=4; Assign 1 /display=5 /type="actionbuttons" /width=5 /height=3 /posx = 11 /posy=4; store view 16 /SCREEN=2';
            cmd  = 'move view 16 at 17 /SCREEN=2 /nc';
            post = 'label view 17 "MOV_VIEW_1"';
            cleanup = 'delete 1 thru; cd /; cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 1"; delete 1 thru /nc; store 1 /SCREEN=1; Assign 1 /display=0 /type="CommandLine" /width=10 /height=4; cd /';
            test = 17;
            gold = 117;
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