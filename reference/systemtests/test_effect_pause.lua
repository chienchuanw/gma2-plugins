--*******************************************************************************************
-- This script tests the methods to pause a effect 
-- Effect 47, Exec 42
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "PAUSE";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 47 /nc; delete executor 42 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Color"; at form "Sin"; at effectBPM 50; store Effect 47; assign Effect 47 at executor 42; go executor 42';
            cmd  = 'pause executor 42';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 47 "PAU_EFF_1"';
            cleanup = 'off effect thru';
            test = 47;
            gold = 247;
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