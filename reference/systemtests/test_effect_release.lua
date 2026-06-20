--*******************************************************************************************
-- This script tests the methods to release a effect 
-- Effect 48
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "RELEASE";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 48 /nc';
    steps =
    {
        {
            pre  = 'Fixture 1 thru ' .. fixturecount[2] .. '; Presettype "Color"; at form "Ramp minus"; at effectBPM 2; store Effect 48 /nc; go effect 48';
            cmd  = 'release effect 48';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 48 "REL_EFF_1"';
            cleanup = 'off effect thru';
            test = 48;
            gold = 248;
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