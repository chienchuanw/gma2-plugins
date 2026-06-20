--*******************************************************************************************
-- This script tests the methods to update a effect. 
-- Effect 54
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "UPDATE";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 54 /nc';
    steps =
    {
        {
            pre  = 'fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; channel 1 thru; Presettype "Dimmer"; at form "sin"; at effectBPM 60; store Effect 54 /nc; assign effect 54 /blocks = 5; ClearAll; fixture 1 thru ' .. fixturecount[2]+fixturecount[3] .. '; channel 1 thru; Presettype "Dimmer"';
            cmd  = 'at effectBPM 60; update effect 54';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 54 "UPD_EFF_1"';
            cleanup = 'off effect thru';
            test = 54;
            gold = 254;
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