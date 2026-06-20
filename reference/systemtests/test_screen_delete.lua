--*******************************************************************************************
-- This script tests the methods to 'delete' a screen. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "DELETE";
    object_name      = "SCREEN";
    pre              = 'ClearAll; cd / ; delete screen 3';
    steps =
    {
        {
            -- delete screen 3
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4;';
            cmd  = 'delete screen 3';
            post = '';
            cleanup = 'cd /';
        },
        {
            -- delete screen thru
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; cd screen 2; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=8;';
            cmd  = 'delete screen thru';
            post = '';
            cleanup = 'cd / ; view 1';
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