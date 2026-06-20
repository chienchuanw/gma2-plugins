--*******************************************************************************************
-- This script tests the methods to 'move' a screen. 
-- 
--*******************************************************************************************

local test =
{
    method_name      = "MOVE";
    object_name      = "SCREEN";
    pre              = 'ClearAll; cd / ; delete screen 3 + 4';
    steps =
    {
        {
            -- move screen 3 at screen 4
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4;';
            cmd  = 'move screen 3 at screen 4';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to check correct behaviour
            post = '';
            cleanup = 'delete screen 3 + 4; cd /';
        },
        {
            -- move screen 3 at screen 4 (merge, no overlapping)
            version_step = "3.8.0.0"; -- /m option is not implemented for move screen yet
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; cd screen 4; store 1 /SCREEN=4; Assign 1 /display=3 /type="channel" /posx=0 /posy=4 /width=16 /height=4;';
            cmd  = 'move screen 3 at screen 4 /m';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to visually check correct behaviour
            post = '';
            cleanup = 'delete screen 3 + 4; cd /';
        },
        {
            -- move screen 3 at screen 4 (merge, overlapping)
            version_step = "3.8.0.0"; -- /m option is not implemented for move screen yet
            smoketest = true;
            pre  = 'cd screen 3; store 1 /SCREEN=3; Assign 1 /display=2 /type="clock" /width=16 /height=4; cd screen 4; store 1 /SCREEN=4; Assign 1 /display=3 /type="channel" /posx=0 /posy=2 /width=16 /height=4;';
            cmd  = 'move screen 3 at screen 4 /m';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- to visually check correct behaviour
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