--*******************************************************************************************
-- This script tests the methods to edit a effect 
-- Effect 37
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name      = "EDIT";
    object_name      = "EFFECT";
    pre              = 'ClearAll; delete effect 37 /nc; delete DmxSnapshot 102 /nc';
    version_script   = "3.3.0.0";
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Dimmer"; at form "Flat High"; at effectBPM 50; store Effect 37';
            cmd  = 'edit Effect 37 /nc; edit effect 37 /nc';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 37 "OFF_EFF_1"';
            cleanup = 'off effect thru';
            test = 37;
            gold = 237;
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