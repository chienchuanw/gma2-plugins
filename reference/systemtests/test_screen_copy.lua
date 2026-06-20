--*******************************************************************************************
-- This script tests the methods to 'copy' a screen. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "COPY";
    object_name      = "SCREEN";
    pre              = 'ClearAll; cd / ; delete screen 3 + 4';
    steps =
    {
        {
            -- copy screen 3 at screen 4 (override)
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4;';
            cmd  = 'copy screen 3 at screen 4 /o';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to check correct behaviour
            post = '';
            cleanup = 'delete screen 3 + 4; cd /';
        },
        {
            -- copy screen 3 at screen 4 (merge, no overlapping)
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; cd screen 4; store 1 /SCREEN=4; Assign 1 /display=3 /type="channel" /posx=0 /posy=4 /width=16 /height=4;';
            cmd  = 'copy screen 3 at screen 4 /m';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to check correct behaviour
            post = '';
            cleanup = 'delete screen 3 + 4; cd /';
        },
        {
            -- copy screen 3 at screen 4 (merge, overlapping)
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; cd screen 4; store 1 /SCREEN=4; Assign 1 /display=3 /type="channel" /posx=0 /posy=2 /width=16 /height=4;';
            cmd  = 'copy screen 3 at screen 4 /m';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to check correct behaviour
            post = '';
            cleanup = 'delete screen 3 + 4; cd /; view 1';
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