--*******************************************************************************************
-- This script tests the methods to unpark a effect 
-- Effect 53
--*******************************************************************************************

local fixturecount = get_prop_fixturecount();

local test =
{
    method_name = "UNPARK";
    object_name = "EFFECT";
    pre         = 'ClearAll; delete effect 53 /nc';
    steps =
    {
        {
            pre  = 'Fixture ' .. fixturecount[2]+1 .. ' thru ' .. fixturecount[2]+fixturecount[3] .. '; Presettype "Gobo"; attribute GOBO1 at effectform "Flat High"; at effectBPM 50; store Effect 53; selfix Effect 53; at Effect 53; park effect 53; ClearAll';
            cmd  = 'selfix effect 53; attribute GOBO1 at 5; unpark effect 53';
            cmd_func = function () gma.echo('sleeping for 1 second'); gma.sleep(1); end; -- This is needed to give the system some time to save the effect
            post = 'label effect 53 "UNP_EFF_1"';
            cleanup = 'off effect thru';
            test = 53;
            gold = 253;
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