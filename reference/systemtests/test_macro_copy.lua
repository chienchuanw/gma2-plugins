--*******************************************************************************************
-- This script tests the methods to copy a macro.
-- Macro a.b.c is Page a. Macro b. Line c
-- Macro 13, 14, 15, 16
--*******************************************************************************************

local test =
{
    method_name      = "COPY";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete macro 13 thru 16 /nc';
    version_script	 = "3.1.0.0";
    steps =
    {
        {
            --simply copying at an empty place
            pre  = 'store macro 1.13; store macro 1.13.1; assign macro 1.13.1 /cmd="fixture 5 at full"; assign macro 1.13.1 /info="highlights fixture 5"; store macro 1.13.2; assign macro 1.13.2 /cmd="ClearAll"; assign macro 1.13.2 /info="Clear"';
            --pre_func = function () gma.sleep(1); gma.echo('sleeping for 1 second'); end; -- This is needed to give the system a short pause for change desk
            cmd  = 'Copy Macro 13 At 14 /nc';
            post = 'label macro 13 "COPY_MAC_1"; label macro 14 "COPY_MAC_2"';
            test = {13,14};
            gold = {113,113};
        },
        {
            --copying at an occupied place by merging
            pre  = 'store macro 1.15; store macro 1.15.1; assign macro 1.15.1 /cmd="ClearAll" /info="ClearAll"';
            --pre_func = function () gma.sleep(1); gma.echo('sleeping for 1 second'); end; -- This is needed to give the system a short pause for change desk
            cmd  = 'Copy Macro 13 at 15 /merge';
            post = 'label macro 13 "COPY_MAC_3"; label macro 15 "COPY_MAC_4"';
            test = 15;
            gold = 115;
        },
        {
            --copying at an occupied place by overwriting
            pre='store macro 1.16; store macro 1.16.1; assign macro 1.16.1 /cmd="ClearAll" /info="ClearAll"';
            cmd  = 'Copy Macro 13 at 16 /overwrite';
            cleanup= 'off macro thru';
            test = 16;
            gold = 116;
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