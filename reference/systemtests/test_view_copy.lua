--*******************************************************************************************
-- This script shows up the methods to copy a view.
-- View 14 + 15
--*******************************************************************************************

local test =
{
    method_name      = "COPY";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 14 + 15 /nc; delete screen thru' ;

    steps =
    {
        {
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru /nc; store 1 thru 5 /SCREEN=2; Assign 1 /display=1 /type="stage" /width=16 /height=4; Assign 2 /display=1 /type="groups" /width=16 /height=1 /posy=7; Assign 3 /display=1 /type="color picker" /width=5 /height=3 /posy=4; Assign 4 /display=1 /type="clock" /width=6 /height=3 /posx = 5 /posy=4; Assign 5 /display=1 /type="actionbuttons" /width=5 /height=3 /posx = 11 /posy=4; store view 14 /SCREEN=2';
            cmd  = 'copy view 14 at view 15 /overwrite /nc';  --check comparison with many displays
            --post = 'delete 1 thru /nc; store 1 thru 5 /SCREEN=2; Assign 1 /display=1 /type="comandline" /width=16 /height=4; Assign 2 /display=1 /type="plugins" /width=16 /height=1 /posy=7; Assign 3 /display=1 /type="commandlineFeddback" /width=5 /height=3 /posy=4; Assign 4 /display=1 /type="clock" /width=6 /height=3 /posx = 5 /posy=4; Assign 5 /display=1 /type="actionbuttons" /width=5 /height=3 /posx = 11 /posy=4; store view 14 /SCREEN=2';
            cleanup = 'delete 1 thru; cd /; cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 1"; delete 1 thru /nc; store 1 /SCREEN=1; Assign 1 /display=0 /type="CommandLine" /width=10 /height=4; cd /';
            test = {14,15};
            gold = {114,115};
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