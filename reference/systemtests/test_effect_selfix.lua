--*******************************************************************************************
-- This script tests the methods to selfix a effect 
-- Effect 50
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "SELFIX";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 50 /nc';
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Dimmer"; at form "Bump"; at effectBPM 200; store Effect 50 /nc';
            cmd  = 'selfix effect 50; highlight on';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 50 "SEF_EFF_1"';
            cleanup = 'highlight off; off effect thru';
            test = 50;
            gold = 250;
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