--*******************************************************************************************
-- This script shows up the methods to insert a view.
-- View 20-22
--*******************************************************************************************


local test =
{
    method_name      = "INSERT";
    object_name      = "VIEW";
    pre              = 'ClearAll; delete view 20 thru 22 /nc; delete screen thru; cd /'; --deleting all screens

    steps =
    {
        {
            -- insert view at occupied location
            -- makes display 2 empty, stores view 1 from screen 2, assigns display 1 clock
            pre  = 'cd "userprofiles"; cd "Default"; cd "Displays"; cd "Display 2"; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Clock" /width=16 /height=8; store view 20 /SCREEN=2; delete 1 thru; store 1 /SCREEN=2; Assign 1 /display=1 /type="Stage" /width=16 /height=8; store view 21 /SCREEN=2';
            cmd  = 'insert view 21 at 20 /nc';
            post = 'label view 20 + 21 "INS_VIE_1"';
            cleanup = 'delete screen thru; cd /';
            test = {20,21};
            gold = {120,121};
        },
        {
            -- insert at free location
            pre  = '';
            cmd  = 'insert view 21 at 22 /nc';
            post = 'label view 21 + 22 "INS_VIE_2"';
            cleanup = 'delete screen thru; cd /';
            test = 22;
            gold = 122;
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