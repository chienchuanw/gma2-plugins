--*******************************************************************************************
-- This script tests the methods to toggle an effect 
-- Effect 51
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "TOGGLE";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 51 /nc';
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Dimmer"; at form "Phase 1"; at effectBPM 0; store Effect 51 /nc; assign effect 51 /phase="0..360"';
            cmd  = 'toggle effect 51';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 51 "TOG_EFF_1"';
            cleanup = 'off effect thru; clearall';
            test = 51;
            gold = 251;
        },
        {
            cmd  = 'toggle effect 51';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            cleanup = 'off effect thru';
            test = 51;
            gold = 252;
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