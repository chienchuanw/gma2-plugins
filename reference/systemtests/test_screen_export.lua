--*******************************************************************************************
-- This script tests the methods to 'export' a screen. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "EXPORT";
    object_name      = "SCREEN";
    pre              = 'ClearAll; cd / ; delete screen 3';
    steps =
    {
        {
            -- export screen 3 at xml
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; store 2 /SCREEN=3; Assign 2 /display=2 /type="channel" /posx=0 /posy=4 /width=16 /height=4;';
            cmd  = 'export screen 3 "export-screen.xml" /nc';
            post = '';
            cleanup = '';
        },
        {
            -- import xml to screen 3
            smoketest = true;
            pre  = '';
            cmd  = 'import "export-screen.xml" at screen 3 /nc';
            post = '';
            cleanup = 'cd / ; view 1';
        },
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