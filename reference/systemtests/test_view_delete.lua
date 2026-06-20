--*******************************************************************************************
-- This script shows up the methods to delete a view.
-- View 12+13
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "VIEW";
    pre              = 'ClearAll; ';
    
    
    steps=
    {
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru /nc; store 1 thru 5 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=16 /height=13; Assign 2 /display=1 /type="groups" /width=16 /height=1 /posy=7; Assign 12 /display=1 /type="color picker" /width=5 /height=12 /posy=13; Assign 13 /display=1 /type="clock" /width=6 /height=12 /posx = 5 /posy=13; Assign 5 /display=1 /type="actionbuttons" /width=5 /height=12 /posx = 11 /posy=13; store view 12 /SCREEN=2';
            cmd  = 'delete view 12 /nc';
            cleanup = 'delete 1 thru';
            test = 12;
            gold = -1;
            
        },
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru /nc; store 1 thru 5; Assign 1 /display=1 /type="stage" /width=16 /height=13; Assign 2 /display=1 /type="groups" /width=16 /height=1 /posy=7; Assign 12 /display=1 /type="color picker" /width=5 /height=12 /posy=13; Assign 13 /display=1 /type="clock" /width=6 /height=12 /posx = 5 /posy=13; Assign 5 /display=1 /type="actionbuttons" /width=5 /height=12 /posx = 11 /posy=13; store view 13 /SCREEN=2; label view 13 "test"';
            cmd  = 'delete view "test" /nc';
            cleanup = 'delete 1 thru; cd /; cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 1"; delete 1 thru /nc; store 1 /SCREEN=1; Assign 1 /display=0 /type="CommandLine" /width=10 /height=4; cd /';
            test = 13;
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