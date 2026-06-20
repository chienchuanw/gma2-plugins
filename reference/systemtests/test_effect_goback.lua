--*******************************************************************************************
-- This script tests the methods to start an effect with goback 
-- Effect 39
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "GOBACK";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 39 /nc';
    version_step     = "3.2.104.0";
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Ramp"; at effectBPM 0; store Effect 39; assign effect 39 /phase="0..180"';
            cmd  = 'goback Effect 39';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 39 "GOB_EFF_1"';
            cleanup = 'off effect thru';
            test = 39;
            gold = 239;
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