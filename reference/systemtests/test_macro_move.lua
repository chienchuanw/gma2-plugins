--*******************************************************************************************
-- This script tests the methods to move a macro. 
-- Leaving macro 27 for not damaging the testoracle.
-- Macro 23-27
--*******************************************************************************************

local fixturecount= get_prop_fixturecount();

local test =
{
    method_name      = "MOVE";
    object_name      = "MACRO";
    pre              = 'ClearAll; delete macro 1.23 thru 1.27 /nc';
    version_script	 = "3.1.0.0";
    steps =
    {
        {	--moving to an available position
            pre  = 'store macro 1.23; store macro 1.23.1; assign macro 1.23.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 56"; assign macro 1.23.1 /info="Prepared for moving" ';
            --post_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system a short pause for change desk
            cmd  = 'move Macro 1.23 at 1.24 /nc';
            test = {23,24};
            gold = {-1,124};
        },
        {	--moving to an occupied position
            pre  = 'store macro 1.25; store macro 1.25.1; assign macro 1.25.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 44"; store macro 1.26; store macro 1.26.1; assign macro 1.26.1 /cmd="fixture 1 thru '..math.floor(fixturecount[2]/2)..' at 33"';
            cmd  = 'move Macro 1.25 at 1.26 /nc'; --swapping positions
            post = 'label Macro 1.25 "MOVE_MAC_3"; label macro 1.26 "MOVE_MAC_4"';
            cleanup= 'off macro thru';
            test = {25,26};
            gold = {225,226};
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