--*******************************************************************************************
-- This script tests the methods to off a effect 
-- Effect 44
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "OFF";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 44 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Flat High"; at effectBPM 50; store Effect 44 /nc; on effect 44';
            cmd  = 'off Effect 44';
            cmd_func = function () gma.echo('sleeping for 1.5 seconds'); gma.sleep(1.5); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 44 "OFF_EFF_1"';
            cleanup = 'off effect thru';
            test = 44;
            gold = 244;
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