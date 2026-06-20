--*******************************************************************************************
-- This script tests the methods to park a effect 
-- Effect 46
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "PARK";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 46 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Color"; at form "Flat High"; at effectBPM 50; store Effect 46';
            cmd  = 'selfix Effect 46; at Effect 46; park effect 46; ClearAll';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 46 "PAR_EFF_1"';
            cleanup = 'off effect thru';
            test = 46;
            gold = 246;
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