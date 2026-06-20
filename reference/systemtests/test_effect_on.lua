--*******************************************************************************************
-- This script tests the methods to on a effect 
-- Effect 45
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "ON";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 45 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Flat High"; at effectBPM 50; store Effect 45';
            cmd  = 'on effect 45';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 45 "ON_EFF_1"';
            cleanup = 'off effect thru';
            test = 45;
            gold = 245;
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