--*******************************************************************************************
-- This script tests the methods to start an effect with go 
-- Effect 38
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "GO";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 38 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 38 /nc; assign effect 38 /phase="0..180"';
            cmd  = 'go Effect 38';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 38 "GO_EFF_1"';
            cleanup = 'off effect thru';
            test = 38;
            gold = 238;
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